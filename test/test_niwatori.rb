require "niwatori"

class TestNiwatori < MiniTest::Unit::TestCase

  include Niwatori

  def test_path
    dungeon_path = DungeonPath.new(start: [2, 5, 0],
                                   size: [6, 6],
                                   floors: -6..5)
    assert_equal([2, 5, 0], dungeon_path.start)
    expected_nodes = []
    expected_nodes << DungeonPath::Node[2, 5, 0, :state1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :north
    assert_equal(true, dungeon_path.addable?(:north))
    dungeon_path.add(:north)
    expected_nodes << DungeonPath::Node[2, 4, 0, :state1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :west
    assert_equal(true, dungeon_path.addable?(:west))
    dungeon_path.add(:west)
    expected_nodes << DungeonPath::Node[1, 4, 0, :state1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :south
    assert_equal(true, dungeon_path.addable?(:south))
    dungeon_path.add(:south)
    expected_nodes << DungeonPath::Node[1, 5, 0, :state1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :north (conflict)
    assert_equal(false, dungeon_path.addable?(:north))
    assert_raises(RuntimeError) { dungeon_path.add(:north) }
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :down
    assert_equal(true, dungeon_path.addable?(:down))
    dungeon_path.add(:down)
    expected_nodes << DungeonPath::Node[1, 5, -1, :state1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :up # conflict
    assert_equal(false, dungeon_path.addable?(:up))
    assert_raises(RuntimeError) { dungeon_path.add(:up) }
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :east
    assert_equal(true, dungeon_path.addable?(:east))
    dungeon_path.add(:east)
    expected_nodes << DungeonPath::Node[2, 5, -1, :state1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :east
    assert_equal(true, dungeon_path.addable?(:east))
    dungeon_path.add(:east)
    expected_nodes << DungeonPath::Node[3, 5, -1, :state1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :up
    assert_equal(true, dungeon_path.addable?(:up))
    dungeon_path.add(:up)
    expected_nodes << DungeonPath::Node[3, 5, 0, :state1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :up
    assert_equal(true, dungeon_path.addable?(:up))
    dungeon_path.add(:up)
    expected_nodes << DungeonPath::Node[3, 5, 1, :state1]
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
    # :down # conflict
    assert_equal(false, dungeon_path.addable?(:down))
    assert_raises(RuntimeError) { dungeon_path.add(:down) }
    assert_equal(expected_nodes, dungeon_path.nodes.to_a)
  end

=begin
  def test_dungeon_new
    directions = [:go_north,
                  :go_west,
                  :go_south,
                  :go_down,
                  :go_east,
                  :go_east,
                  :go_up,
                  :go_up,
                 ]
    digraph = Digraph.new(directions,
                          start: [2, 5, 0],
                          size: [6, 6],
                          floors: -6..5)
    dungeon = Dungeon.new(digraph)
    rooms = dungeon.rooms
    room = rooms[2, 5, 0]
    assert_equal(true, room.start?)
    assert_equal([:north], room.doors.sort)
    room = rooms[2, 4, 0]
    assert_equal(false, room.start?)
    assert_equal([:south, :west], room.doors.sort)
    room = rooms[1, 4, 0]
    assert_equal(false, room.start?)
    assert_equal([:east, :south], room.doors.sort)
    room = rooms[1, 5, 0]
    assert_equal(false, room.start?)
    assert_equal([:north], room.doors.sort)
    room = rooms[1, 5, -1]
    assert_equal(false, room.start?)
    assert_equal([:north], room.doors.sort)
    room = rooms[2, 5, -1]
    assert_equal(false, room.start?)
    assert_equal([:east, :west], room.doors.sort)
    room = rooms[3, 5, -1]
    assert_equal(false, room.start?)
    assert_equal([:west], room.doors.sort)
  end
=end


end
