require 'telegram/bot'
require 'supermodel'


class User < SuperModel::Base
end

class Operation < SuperModel::Base
end

module Db
  def users_table(name, token, date)
    user = User.new
    user.user = name
    user.token = token
    user.created_at = date
    user.save
  end

  def operations_table(number_operation, short_name, text, desc, regex, count)
    operation = Operation.new
    operation.number_operation = number_operation
    operation.short_name = short_name
    operation.text = text
    operation.desc = desc
    operation.regex = regex
    operation.count = count
    operation.save
  end

end