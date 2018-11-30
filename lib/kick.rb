class Kick
  class << self
    def need_perform?(message)
      message.include?('пинок')
    end

    def perform(channel, message)
      slack.chat_postMessage(channel: channel, as_user: true, text: pendel(message)) if need_perform?(message)
    end

    def users(message)
      message.scan(/<\@[^>]*>/)
    end

    def pendel(message)
      users = users(message)
      'даю пендель ' + users.join(', ')
    end
  end
end
