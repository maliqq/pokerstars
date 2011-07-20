require 'models'

class Async
  def incoming(message, callback)
    callback.call(message)
  end

  def outgoing(message, callback)
    callback.call(message)
  end
end
