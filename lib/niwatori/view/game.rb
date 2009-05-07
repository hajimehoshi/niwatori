module Niwatori

  module View

    require "starruby"

    class Game

      def initialize
        @game = StarRuby::Game.new(320, 240, :window_scale => 2)
      end

      def update
        @game.wait
        @game.update_state
        exit if @game.window_closing?
        @game.update_screen
        @game.screen.clear
      end

      def dispose
        @game.dispose
      end

    end

  end

end
