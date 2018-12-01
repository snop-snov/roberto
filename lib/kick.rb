class Kick
  class << self
    def need_perform?(message)
      return false if message.nil?
      message.include?('пинок')
    end

    def perform(channel, message, users)
      slack.chat_postMessage(channel: channel, as_user: true, text: pendel(users)) if need_perform?(message)
    end

    def kick_ass(channel, users)
      slack.chat_postMessage(channel: channel, as_user: true, text: pendel(users))
    end

    def pendel(users)
      'даю пендель ' + users.map { |u| wrap(u) }.join(', ')
    end
  end
end
