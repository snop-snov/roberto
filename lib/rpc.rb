# frozen_string_literal: true

class Rpc
  @moves = {}

  class << self
    def perform(channel, current_user, users)
      start_game(channel, current_user, users) if need_start_game?
    end

    def press_button(press_button_user, action, logger)
      logger.info @moves.to_s
      accept_move(action, press_button_user) if need_accept_move?(press_button_user)

      return unless need_check_moves?

      remove_losers
      reset_moves

      repeat_game if @moves.keys.count > 1
      if @moves.keys.count == 1
        send_winner
        stop_game
      end
    end

    def need_start_game?
      @moves.empty?
    end

    def need_accept_move?(press_button_user)
      return false if @moves.empty?
      @moves.keys.include?(press_button_user)
    end

    def need_check_moves?
      return false if @moves.empty?
      return false if @moves.values.any?(&:nil?)

      true
    end

    def start_game(channel, current_user, users)
      text = "#{wrap(current_user)} бросает вызов организмам " + users.map { |u| wrap(u) }.join(', ')
      slack.chat_postMessage(channel: channel, as_user: true, text: text, attachments: game_buttons)
      @moves = users.each_with_object(current_user => nil) { |u, result| result[u] = nil }
    end

    def repeat_game
      users = @moves.keys.map { |u| wrap(u) }
      text = users.join(', ') + ' Попробуйте ещё раз, кожаные мешки!'
      slack.chat_postMessage(channel: '#general', as_user: true, text: text, attachments: game_buttons)
    end

    def send_winner
      winner = @moves.keys.first
      slack.chat_postMessage(channel: '#general', as_user: true, text: wrap(winner) + ' ПОБЕДИЛ !!!')
    end

    def stop_game
      @moves = {}
    end

    def accept_move(action, press_button_user)
      @moves[press_button_user] = action
    end

    def game_buttons
      text = 'раз, два, три ...'
      [{
        text: text,
        callback_id: 'rpc_game', color: '#3AA3E3', attachment_type: 'default',
        actions: [
          {name: 'game', text: 'Камень :curling_stone:', type: 'button', value: 'rock'},
          {name: 'game', text: 'Ножницы :scissors:', type: 'button', value: 'scissers'},
          {name: 'game', text: 'Бумага :page_with_curl:', type: 'button', value: 'paper'}
        ]
      }]
    end

    def losers
      rock_users = @moves.select { |_, move| move == :rock }.keys
      scissers_users = @moves.select { |_, move| move == :scissers }.keys
      paper_users = @moves.select { |_, move| move == :paper }.keys

      return [] if rock_users.any? && scissers_users.any? && paper_users.any?

      return scissers_users if rock_users.any? && scissers_users.any?
      return paper_users if scissers_users.any? && paper_users.any?
      return rock_users if paper_users.any? && rock_users.any?

      []
    end

    def remove_losers
      moves = @moves.map { |u, m| [move_emoji(m), wrap(u)].join(' ') }
      slack.chat_postMessage(channel: '#general', as_user: true, text: moves.join("\n"))

      losers.each { |u| @moves.delete(u) }
      Kick.kick_from_rpc '#general', losers
    end

    def reset_moves
      @moves = @moves.each_with_object({}) { |(user, _), result| result[user] = nil }
    end

    def move_emoji(move)
      case move
      when :rock then ':curling_stone:'
      when :scissers then ':scissors:'
      when :paper then ':page_with_curl:'
      end
    end
  end
end
