class Bot
  include Rumpy::Bot

  def initialize
    @pid_file    = 'tmp/pids/bot.pid'
    @config_path = 'config'
    @main_model  = :user
    @website     = 'http://yatodo.net'
  end
 
  def parser_func(m)
    m.strip!
    result = Hash.new
    if m.downcase == 'help' or m.downcase == 'usage' then
      result[:action] = :help
    elsif m == '::::times::::'
      result[:action] = :times
    elsif m == '::::stat::::'
      result[:action] = :stat
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
    result, k = "", 0
    model.notes.find_each do |note|
      result << "#{k+=1}. #{note.tag.name}\t::\t#{note.name}\n" if tag.nil? or note.tag == tag
    end
    result = @lang[:nothing] if result.empty?
    result
  end

  def remove_note_by_name(note)
    if note.nil? then
      @lang['nosuchitem']
    else
      note.destroy
      @lang['removednote']
    end
  end

  def remove_note_by_number(model, tag, number)
    k = 0
    model.notes.find_each do |note|
      k += 1 if (tag.nil? or (note.tag == tag))
      if number == k then
        note.destroy
        return @lang['removednote']
      end
    end
    @lang['nosuchitem']
  end

  def add_note(model, tag, text)
    if (note = model.notes.find_by_name text) and note.tag == tag then
      @lang['noteexists']
    else
      model.notes.create :name => text, :tag => tag
      @lang['noteadded']
    end
  end

  def do_func(model, pars)
    case pars[:action]
    when :stat
      "#{User.count} users.\t\t#{Tag.count} tags.\t\t#{Note.count} notes."
    when :times
      p = Process.times
      "User: #{p.utime}.\t\tSystem: #{p.stime}"
    when :help
      @lang['help']
    when :remove
      if pars[:wut].empty? or (pars[:wut][0] == ?# and (pars[:wut][1..-1].to_i) == 0) then
        @lang['parserror']
      else
        tag = model.tags.find_by_name pars[:tag]
        if pars[:tag] != '_' and tag.nil? then
          @lang['nosuchtag']
        elsif pars[:wut][0] == ?# then
          remove_note_by_number model, tag, pars[:wut][1..-1].to_i
        else
          if (notes = model.notes.where('tag_id = ? AND name LIKE ?', tag.id, pars[:wut] + "%")).size > 1 then
            notes.each do |note|
              return remove_note_by_name note if note.name == pars[:wut]
            end
            @lang['multiple']
          else
            remove_note_by_name notes[0]
          end
        end
      end
    when :www
      if pars[:tag] == '_' then
        "#{@website}/#{model.jid}"
      elsif model.tags.find_by_name pars[:tag] then
        "#{@website}/#{model.jid}/#{pars[:tag]}"
      else
        @lang['nosuchtag']
      end
    when :add
      if pars[:tag] == '_' or pars[:wut].empty? or pars[:wut][0] == ?# then
        @lang['parserror']
      else
        tag = Tag.find_or_create_by_name pars[:tag]

        add_note model, tag, pars[:wut]
      end
    when :print
      tag = model.tags.find_by_name pars[:tag]
      if pars[:tag] != '_' and tag.nil? then
        @lang['nosuchtag']
      else
        print_notes model, tag
      end
    else
      @lang['parserror']
    end
  end
end
