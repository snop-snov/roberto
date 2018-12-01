# frozen_string_literal: true

class Rpc
  @moves = {}

  class << self
    def perform(channel, message, users, current_user)
      start_game(channel, users) if need_start_game?(message)
      accept_move(message, current_user) if need_accept_move?(message, current_user)

      return unless need_check_moves?

      remove_losers
      # send_repeat if @moves.keys.count > 1
      if @moves.keys.count == 1
        send_winner
        stop_game
      end
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

    def need_check_moves?
      return false if @moves.empty?
      return false if @moves.values.any?(&:nil?)

      true
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

    def send_repeat
      users = @moves.keys.map { |u| wrap(u) }
      slack.chat_postMessage(channel: '#general', as_user: true, text: 'бросить вызов ' + users.join(', '))
    end

    def send_winner
      winner = @moves.keys.first
      slack.chat_postMessage(channel: '#general', as_user: true, text: wrap(winner) + ' ПОБЕДИЛ !!!')
    end

    def stop_game
      @moves = {}
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

    def losers
      rock_users = @moves.select { |_, move| move == :rock }.keys
      scissers_users = @moves.select { |_, move| move == :scissers }.keys
      paper_users = @moves.select { |_, move| move == :paper }.keys

      return [] if rock_users.any? && scissers_users.any? && paper_users.any?

      return scissers_users if rock_users.any?
      return paper_users if scissers_users.any?
      return rock_users if paper_users.any?
    end

    def remove_losers
      moves = @moves.map { |u, m| [wrap(u), m].join(': ') }
      slack.chat_postMessage(channel: '#general', as_user: true, text: 'ход: ' + moves.join(', '))

      losers.each { |u| @moves.delete(u) }
    end
  end
end
