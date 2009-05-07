require "niwatori/view"

begin
  scene = Niwatori::View::TitleScene.new
  game = Niwatori::View::Game.new
  while scene
    scene = scene.update(game)
  end
ensure
  game.dispose
end
