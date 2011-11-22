require 'lib/bot.rb'

namespace :bot do
  desc 'Start bot in background'
  task :start => :environment do
    puts 'Starting the bot'
    bot = Bot.new
    puts (if Rumpy.start bot then 'Started' else 'Not started' end)
  end

  desc 'Stop bot'
  task :stop => :environment do
    puts 'Stopping the bot''
    bot = Bot.new
    puts (if Rumpy.stop bot then 'Stopped' else 'Not stopped' end)
  end

  desc 'Restart bot'
  task :restart => [:stop, :start]
end
