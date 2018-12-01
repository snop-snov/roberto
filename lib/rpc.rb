class Rpc
  @moves = {}

  class << self
    def perform(channel, message, users, current_user)
      start_game(channel, users) if need_start_game?(message)
      accept_move(message, current_user) if need_accept_move?(message, current_user)
      slack.chat_postMessage(channel: '#general', as_user: true, text: @moves.to_s)
    end

    def need_start_game?(message)
      return false if @moves.any?
      message.include?('бросить вызов')
    end

    def need_accept_move?(message, current_user)
      return false if current_user.nil?
      return false if @moves.empty?
      return false unless @moves.keys.include?(current_user)
      rock?(message) || scissers?(message) || paper?(message)
    end

    def start_game(channel, users)
      slack.chat_postMessage(channel: channel, as_user: true, text: greeting_players(users))
      @moves = users.each_with_object({}) { |u, result| result[u] = nil }
      users.each { |u| ask_move(u) }
    end

    def ask_move(user)
      data = slack.im_open(user: user)
      slack.chat_postMessage(channel: data['channel']['id'], as_user: true, text: 'ход за тобой, червь: камень ножницы бумага?')
    end

    def accept_move(user, message)
      move =
        case
        when rock?(message) then :rock
        when scissers?(message) then :scissers
        when paper?(message) then :paper
        end
      @moves[user] = move
    end

    def rock?(message)
      message.include?('камень')
    end

    def scissers?(message)
      message.include?('ножницы')
    end

    def paper?(message)
      message.include?('бумага')
    end

    def greeting_players(users)
      "'камень ножницы бумага начались для' " + users.map { |u| wrap(u) }.join(', ')
    end
  end
end
