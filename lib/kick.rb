class Kick
  class << self
    def need_perform?(message)
      message.include?('пинок')
    end

    def perform(event)
      slack.chat_postMessage(channel: event[:channel], as_user: true, text: 'даю пендель') if need_perform?(event[:text])
    end
  end
end
