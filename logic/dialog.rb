require 'telegram/bot'
require '../system/bot_log'

module Dialog
  def track(message)
    payload = if message.is_a?(Hash)
                # Outbound message
                BotLog.log.info 'Outgoing message'
                BotLog.log.info Time.now
                {
                    message: {
                        platform: 'telegram',
                        to: message['result']['chat']['id'],
                        sent_at: message['result']['date'],
                        distinct_id: message['result']['message_id'],
                        properties: {
                            text: message['result']['text']
                        }
                    }
                }
                # Inbound message
              else
                BotLog.log.info 'Incoming message'
                BotLog.log.info Time.now
                {
                    message:{
                        platform: 'telegram',
                        from: message.from.id,
                        sent_at: message.date,
                        distinct_id: message.message_id,
                        properties: {
                            # text: message.text
                        },
                        contact:{
                            contact: message.contact
                        }
                    }
                }
              end
    BotLog.log.info '---------------'
    BotLog.log.info 'payload: '+payload.to_s
    BotLog.log.info 'END'
    BotLog.log.info ''
  end
end