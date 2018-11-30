class Rpc
  @moves = {}

  class << self
    def perform(channel, message, users)
      start_game(channel, users) if need_start_game?(message)
    end

    def need_start_game?(message)
      return false if @moves.any?
      message.include?('бросить вызов')
    end

    def start_game(channel, users)
      slack.chat_postMessage(channel: channel, as_user: true, text: greeting_players(users))
      @moves = users.each_with_object({}) { |u, result| result[u] = nil }
      users.each { |u| ask_move(u) }
      # wait_for_response
      # get_moves()
    end

    def ask_move(user)
      data = slack.im_open(user: user)
      slack.chat_postMessage(channel: data['channel']['id'], as_user: true, text: 'ход за тобой, червь: камень ножницы бумага?')
    end

    def wait_for_response

      # ожидаем от второго игрока ответа на вызов в течение n секунд
    end

    def get_moves(first_player_move, second_player_move)
      wait intil first_player_move.present? && second_player_move.present?
      # игроки вводят камень/ножницы/бумага (через / - в канале не видно другому игроку)
    end

    def put_result

    end

    def greeting_players(users)
      "'камень ножницы бумага начались для' " + users.map { |u| wrap(u) }.join(', ')
    end
  end
end
