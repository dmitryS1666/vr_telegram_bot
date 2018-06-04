require 'logger'

class BotLog
  def self.log
    if @logger.nil?
      pwd  = File.dirname(File.expand_path(__FILE__))
      @logger = Logger.new(pwd+'/log/log.txt', shift_age = 7, shift_size = 1048576)
      @logger.level = Logger::DEBUG
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    end
    @logger
  end
end