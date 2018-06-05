require 'uri'
require 'net/http'
require 'net/https'
require 'json'

require '../system/db'
require '../logic/dialog'
require '../logic/helper'
require '../logic/vremonte'
require '../system/bot_log'

extend Db
extend Dialog
extend Helper
extend Vremonte

telegram_token = '580514110:AAGjF6HFkOVIgvUhWA3bV1lYwX9iVaJAsrM'

def send_response(bot, message, type_menu)
  track message

  markup = create_menu(type_menu)

  case type_menu
    when 'start'
      resp_message = response_for_start(message)
  end

  response = bot.api.send_message(chat_id: message.chat.id, text: resp_message, disable_web_page_preview: true, reply_markup: markup)
  track response

end

Telegram::Bot::Client.run(telegram_token) do |bot|
  bot.listen do |message|

    case message.text.to_s
      when '/start'
        send_response(bot, message, 'start')

      when /Back/
        send_response(bot, message, 'start')

      when '1. Show me all auto services.'
        send_response(bot, message, 'show_auto_service')

      when '2. Search auto service by name.'
        send_response(bot, message, 'search_by_name')

      when '3. Create request for auto services.'
        send_response(bot, message, 'create_request')

      else
        prepare_response(bot, message)
    end
  end
end