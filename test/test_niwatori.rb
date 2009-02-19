require "niwatori"

class TestNiwatori < MiniTest::Unit::TestCase

  include Niwatori

  def test_dungeon_path
    dungeon_path = DungeonPath.new
    expected_nodes = []
    expected_nodes << DungeonPath::Node[0, 0, 0, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :north
    assert_equal(true, dungeon_path.addable?(:north))
    dungeon_path.add(:north)
    expected_nodes << DungeonPath::Node[0, -1, 0, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :west
    assert_equal(true, dungeon_path.addable?(:west))
    dungeon_path.add(:west)
    expected_nodes << DungeonPath::Node[-1, -1, 0, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :south
    assert_equal(true, dungeon_path.addable?(:south))
    dungeon_path.add(:south)
    expected_nodes << DungeonPath::Node[-1, 0, 0, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :north (conflict)
    assert_equal(false, dungeon_path.addable?(:north))
    assert_raises(RuntimeError) { dungeon_path.add(:north) }
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :down
    assert_equal(true, dungeon_path.addable?(:down))
    dungeon_path.add(:down)
    expected_nodes << DungeonPath::Node[-1, 0, -1, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :up (conflict)
    assert_equal(false, dungeon_path.addable?(:up))
    assert_raises(RuntimeError) { dungeon_path.add(:up) }
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :east
    assert_equal(true, dungeon_path.addable?(:east))
    dungeon_path.add(:east)
    expected_nodes << DungeonPath::Node[0, 0, -1, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :east
    assert_equal(true, dungeon_path.addable?(:east))
    dungeon_path.add(:east)
    expected_nodes << DungeonPath::Node[1, 0, -1, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :up
    assert_equal(true, dungeon_path.addable?(:up))
    dungeon_path.add(:up)
    expected_nodes << DungeonPath::Node[1, 0, 0, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :up
    assert_equal(true, dungeon_path.addable?(:up))
    dungeon_path.add(:up)
    expected_nodes << DungeonPath::Node[1, 0, 1, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :down (conflict)
    assert_equal(false, dungeon_path.addable?(:down))
    assert_raises(RuntimeError) { dungeon_path.add(:down) }
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :switch
    assert_equal(true, dungeon_path.addable?(:switch))
    dungeon_path.add(:switch)
    expected_nodes << DungeonPath::Node[1, 0, 1, 1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :switch (conflict)
    assert_equal(false, dungeon_path.addable?(:switch))
    assert_raises(RuntimeError) { dungeon_path.add(:switch) }
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :west
    assert_equal(true, dungeon_path.addable?(:west))
    dungeon_path.add(:west)
    expected_nodes << DungeonPath::Node[0, 0, 1, 1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :switch
    assert_equal(true, dungeon_path.addable?(:switch))
    dungeon_path.add(:switch)
    expected_nodes << DungeonPath::Node[0, 0, 1, 0]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
  end

  def test_dungeon_new
    dungeon_path = DungeonPath.new
    [:north, :west, :south, :down, :east, :east, :up, :up,
     :switch, :west, :switch].each do |direction|
      dungeon_path.add(direction)
    end
  end

end
