require '../system/bot_log'
require 'open-uri'

module Helper

  def create_menu(type_menu)
    case type_menu
      when 'start'
        kb = ['1. Show me all auto services.', '2. Search auto service by name.', '3. Create request for auto services']
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true)

      else
        kb=['⬅️ Back']
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, resize_keyboard: true)
    end
    markup
  end

  def set_token
    Array.new(10) { [*'A'..'Z', *'0'..'9'].sample }.join
  end

  def prepare_response(bot, message)
    track message

    user = User.find_by_user(message.from.first_name)
    if user and Time.now < user.created_at + 300
      response = Response.find_by_user_id(user.id)
    elsif user
      user.destroy
      BotLog.log.info 'Your session exp let\'s /start Mr./Ms.' + message.from.first_name.to_s

      text = 'Your session exp let\'s /start'
      send_response(bot, message, 'validation_start', text)

    else
      text = 'Start'
      send_response(bot, message, 'start', text)
    end
  end

  def offer_accept(bot, message, response)
    accept_offer(response.token, response.msisdn)
    send_status(bot, message, nil, get_status(response.token, response.msisdn))
    # response.destroy
  end

  def get_trx_status(bot, message, response)
    send_status(bot, message, nil, get_status(response.token, response.msisdn))
    # response.destroy
  end

  def log_step(number_next_step, number_operation, message, number_step)
    BotLog.log.info '-------------------'
    BotLog.log.info 'number_next_step: '+number_next_step.to_s
    BotLog.log.info 'short_name: '+Operation.find_by_number_operation(number_operation.to_i).short_name
    BotLog.log.info 'number_step: '+number_step.to_s
    BotLog.log.info '-------------------'
  end

  def prepare_message(response, message)
    BotLog.log.info 'end insert params, let\'s send request to PMC'
    BotLog.log.info response.type
    param=''

    case response.type
      when 'card2card'
        'paymentId=MoneyTransfer_KazPost_Card2Card&currency=KZT&amount='+message.text.to_s+'00'+
            '&src.type=card_id&dst.type=card&src.cardId='+get_cards(response.msisdn, response.short_pan.to_s).to_s+'&src.csc='+
            response.cvv.to_s+'&dst.pan='+response.dst_pan.to_s+'&state.redirect=no&state.in_progress=no&comment=comment'+
            '&returnUrl=https://webportal-test-kz.intervale.ru/money-transfer/card-to-card?token=XHOGVY5FFXORZW0P'

      when 'pay'
        'paymentId=ACQ_kazpost_'+response.code_shop.to_s+'&currency=KZT&amount='+message.text.to_s+'00'+'&src.type=card_id'+
            '&src.cardId='+get_cards(response.msisdn, response.short_pan.to_s).to_s+'&src.csc='+response.cvv.to_s+
            '&state.redirect=no&state.in_progress=no&comment=comment'
    end
  end

  def get_body(params, response, message)
    'paymentId='+params['paymentId'].to_s+
        '&commission='+params['commission'].to_s+
        '&src.cardholder=NAME'+
        '&currency='+params['currency'].to_s+
        '&amount='+message.text.to_s+'00'+
        '&total='+((message.text.to_s+'00').to_i+params['commission'].to_i).to_s+
        '&src.type=card_id'+
        '&src.cardId='+params['src']['cardId']+
        '&src.csc='+response.cvv.to_s+'&'

  end

  def check_user_phone(message, regex)
    if message.contact and Regexp.new(regex) === message.contact['phone_number'].gsub(/[() +-]/, '')
      get_user_from_pmc(message.contact['phone_number'].gsub(/[() +-]/, ''))
    else
      false
    end
  end

  def select_response(message, regex)
    if message.contact and Regexp.new(regex) === message.contact['phone_number'].gsub(/[() +-]/, '')
      unless get_user_from_pmc(message.contact['phone_number'].gsub(/[() +-]/, ''))
        markup = create_menu('')
        return {'markup' => markup, 'text' => 'Dannyj nomer ne zaregestrirovan v post.kz'}
      end
    else
      if message.text and Regexp.new(regex) === message.text.gsub(/[() +-]/, '')
        if get_user_from_pmc(message.text.gsub(/[() +-]/, ''))
          markup = create_menu('phone_number')
          return {'markup' => markup, 'text' => 'Podtverdite vash nomer telefona, najav konky "Razreshit\' ispolzovat\' vash nomer telefona"'}
        else
          markup = create_menu('')
          return {'markup' => markup, 'text' => 'Dannyj nomer ne zaregestrirovan v post.kz'}
        end
      end
    end
  end

  def response_for_start(message)
    user = User.find_by_user(message.from.first_name)

    if user
      user.destroy
      users_table(message.from.first_name, set_token, Time.now)
      "Hi, #{message.from.first_name}"
    else
      users_table(message.from.first_name, set_token, Time.now)
      "Hi, #{message.from.first_name}"
    end
  end

  def update_session(message)
    user = User.find_by_user(message.from.first_name)
    user.created_at = Time.now + 600
    user.save
    BotLog.log.info 'update exp session'
    BotLog.log.info user.created_at.to_s
  end

end


