# frozen_string_literal: true

class Rpc
  @moves = {}

  class << self
    def perform(channel, message, users, current_user)
      start_game(channel, users) if need_start_game?(message)
      accept_move(message, current_user) if need_accept_move?(message, current_user)
      send_result if need_send_result?
    end

    def need_start_game?(message)
      return false if @moves.any?
      message.include?('бросить вызов')
    end

    def need_accept_move?(message, current_user)
      return false if current_user.nil?
      return false if @moves.empty?
      return false unless @moves.keys.include?(current_user)

      move(message) != nil
    end

    def need_send_result?
      return false if @moves.empty?
      return false if @moves.values.any?(&:nil?)
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

    def send_result
      slack.chat_postMessage(channel: '#general', as_user: true, text: @moves.to_s)
    end

    def accept_move(message, current_user)
      @moves[current_user] = move(message)
    end

    def move(message)
      if message.include?('камень')
        :rock
      elsif message.include?('ножницы')
        :scissers
      elsif message.include?('бумага')
        :paper
      end
    end

    def greeting_players(users)
      "'камень ножницы бумага' начались для " + users.map { |u| wrap(u) }.join(', ')
    end
  end
end
