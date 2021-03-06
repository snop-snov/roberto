class Kick
  class << self
    def need_perform?(message)
      return false if message.nil?
      message.include?('пинок')
    end

    def perform(channel, message, users)
      slack.chat_postMessage(channel: channel, as_user: true, text: pendel(users)) if need_perform?(message)
    end

    def kick_ass(channel, users, current_user)
      slack.chat_postMessage(channel: channel, as_user: true, text: pendel(users, current_user))
    end

    def kick_from_rpc(channel, users)
      slack.chat_postMessage(channel: channel, as_user: true, text: 'даю пендель ' + users.map { |u| wrap(u) }.join(', '))
    end

    def pendel(users, current_user)
      wrap(current_user) + ' отвешивает пендель ' + users.map { |u| wrap(u) }.join(', ')
    end
  end
end
