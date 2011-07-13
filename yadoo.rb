#!/usr/bin/env ruby

require 'rumpy'

class Yadoo
  include Rumpy

  def initialize
    @models_path = '/models/*.rb'
    @config_path = 'config'
    @main_model  = :user
    @mutexes     = Hash.new do |h, k|
                              h[k] = Mutex.new
                            end
  end

  def parser_func(m)
    m.strip!
    result = {}
    if m.downcase == "help" or m.downcase == "usage" then
      result[:action] = :help
    else
      mh = /([\w\s]*)([+:-]?)(.*)/.match m
      result[:tag] = mh[1].strip.gsub /\s+/, '_'
      result[:tag] = "_" if result[:tag] == ""
      result[:action] = case mh[2]
                        when '+'
                          :add
                        when '-'
                          :remove
                        when ':'
                          :print
                        end
      result[:wut] = mh[3].strip.gsub(/\s+/, ' ')
    end
    result
  end

  def print_notes(model, tag)
    result, k = "", 0
    for note in model.notes do
      result << "#{k+=1}. #{note.tag.name}\t::\t#{note.name}\n" if (tag.nil? or note.tag == tag) and
                                                                    not note.name.empty?
    end
    result = @lang[:nothing] if result.empty?
    result
  end

  def remove_note_by_name(tag, note)
    if note.nil? or note.tag != tag then
      @lang['nosuchitem']
    else
      note.destroy
      @lang['removednote']
    end
  end

  def remove_note_by_number(model, tag, number)
    k = 0
    for note in model.notes do
      k += 1 if (tag.nil? or (note.tag == tag)) and not note.name.empty?
      if number == k then
        note.destroy
        return @lang['removednote']
      end
    end
    @lang['nosuchitem']
  end

  def add_note(model, tag, text)
    if model.notes.find_by_name text then
      @lang['noteexists']
    else
      model.notes.create :name => text, :tag => tag
      @lang['noteadded']
    end
  end

  def do_func(model, pars)
    case pars[:action]
    when :help
      @lang['help']
    when :remove
      if pars[:wut].empty? or (pars[:wut][0] == ?# and (pars[:wut].gsub(/^#/, '').to_i) == 0) then
        @lang['parserror']
      else
        tag = model.tags.find_by_name pars[:tag]
        if pars[:tag] != '_' and tag.nil? then
          @lang['nosuchtag']
        elsif pars[:wut][0] == ?# then
          remove_note_by_number model, tag, pars[:wut].gsub(/^#/, '').to_i
        else
          remove_note_by_name tag, model.notes.find_by_name(pars[:wut])
        end
      end
    when :add
      if pars[:tag] == '_' or pars[:wut].empty? or pars[:wut][0] == ?# then
        @lang['parserror']
      else
        if (tag = Tag.find_by_name pars[:tag]).nil? then
          tag = Tag.create :name => pars[:tag]
        end

        add_note model, tag, pars[:wut]
      end
    when :print
      tag = model.tags.find_by_name pars[:tag]
      if pars[:tag] != '_' and tag.nil? then
        @lang['nosuchtag']
      else
        print_notes model, tag
      end
    end
  end
end

Yadoo.new.start
