module Niwatori

  module View

    require "starruby"

    class Game

      def initialize
        @game = StarRuby::Game.new(320, 240)
      end

      def update
        @game.wait
        @game.update_state
        break if @game.window_closing?
        @game.update_screen
      end

      def dispose
        @game.dispose
      end

    end

  end

end
