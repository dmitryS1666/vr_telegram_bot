require 'rubygems'
require 'daemons'

pwd  = File.dirname(File.expand_path(__FILE__))
file = pwd + '/start_bot.rb'

puts pwd

Daemons.run_proc(
    'telegram_bot_service',
    :log_output => true
) do
  exec "ruby #{file}"
end