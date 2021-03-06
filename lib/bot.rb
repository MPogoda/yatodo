class Bot
  include Rumpy::Bot

  def initialize
    @pid_file    = 'tmp/pids/bot.pid'
    @log_file    = 'log/bot'
    @website     = 'http://yatodo.net'
    @bot_name    = 'Yatodo'
  end

  def parser_func(m)
    m.strip!
    spl = m.split ' ', 2
    spl[0].downcase!

    result = Hash.new

    case spl[0]
    when 'help'
      result[:action] = :help
    when 'debug'
      result[:action] = :debug
      result[:wut]    = spl[1]
    else
      mh = /([^[:punct:]]*|_)([+-@]?)(.*)/.match m
        result[:tag] = mh[1].strip.tr_s ' ', '_'

        result[:tag] = '_' if result[:tag].empty?

        result[:action] = case mh[2]
                          when '+'
                            :add
                          when '-'
                            :remove
                          when ''
                            :print
                          when '@'
                            :www
                          end

        result[:wut] = mh[3].strip.squeeze ' '
    end
    result
  end

  def print_notes(model, tag)
    result, k = '', 0
    model.notes.find_each do |note|
      result << "#{k+=1}. #{note.tag.name}\t::\t#{note.name}\n" if tag.nil? || note.tag == tag
    end
    result = @lang[:nothing] if result.empty?
    result
  end

  def remove_note_by_name(note)
    if note.nil?
      @lang['nosuchitem']
    else
      note.destroy
      @lang['removednote']
    end
  end

  def remove_note_by_number(model, tag, number)
    k = 0
    model.notes.find_each do |note|
      k += 1 if tag.nil? || note.tag == tag
      if number == k then
        note.destroy
        return @lang['removednote']
      end
    end
    @lang['nosuchitem']
  end

  def add_note(model, tag, text)
    if (note = model.notes.find_by_name text) && note.tag == tag
      @lang['noteexists']
    else
      model.notes.create :name => text, :tag => tag
      @lang['noteadded']
    end
  end

  def do_func(model, pars)
    case pars[:action]
    when :debug
      case pars[:wut]
      when 'stat'
        "Users::#{User.count}.\t\tTags::#{Tag.count}.\t\tNotes::#{Note.count}."
      when 'times'
        p = Process.times
        "User: #{p.utime}.\t\tSystem: #{p.stime}"
      else
        @lang['parserror']
      end
    when :help
      @lang['help']
    when :remove
      if pars[:wut].empty? || pars[:wut][0] == ?# && pars[:wut][1..-1].to_i == 0
        @lang['parserror']
      else
        tag = model.tags.find_by_name pars[:tag]
        if pars[:tag] != '_' && tag.nil?
          @lang['nosuchtag']
        elsif pars[:wut][0] == ?#
          remove_note_by_number model, tag, pars[:wut][1..-1].to_i
        else
          if (notes = model.notes.where('tag_id = ? AND name LIKE ?', tag.id, pars[:wut] + "%")).size > 1
            names = []
            notes.each do |note|
              return remove_note_by_name note if note.name == pars[:wut]
              names << note.name
            end
            @lang['multiple'] % names.join("\n")
          else
            remove_note_by_name notes[0]
          end
        end
      end
    when :www
      if pars[:tag] == '_'
        "#{@website}/#{model.jid}"
      elsif model.tags.find_by_name pars[:tag]
        "#{@website}/#{model.jid}/#{pars[:tag]}"
      else
        @lang['nosuchtag']
      end
    when :add
      if pars[:tag] == '_' || pars[:wut].empty? || pars[:wut][0] == ?#
        @lang['parserror']
      else
        tag = Tag.find_by_name(pars[:tag]) || Tag.create(:name => pars[:tag])
        if tag
          add_note model, tag, pars[:wut]
        else
          @lang['parserror']
        end
      end
    when :print
      tag = model.tags.find_by_name pars[:tag]
      if pars[:tag] != '_' && tag.nil?
        @lang['nosuchtag']
      else
        print_notes model, tag
      end
    else
      @lang['parserror']
    end
  end
end
