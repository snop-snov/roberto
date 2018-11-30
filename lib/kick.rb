class Kick
  class << self
    def need_perform?(message)
      message.include?('пинок')
    end

    def perform(message, channel)
      slack.chat_postMessage(channel: channel, as_user: true, text: 'даю пендель') if need_perform?(message)
    end
  end
end
