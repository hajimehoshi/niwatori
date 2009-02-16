require "niwatori"

class TestNiwatori < MiniTest::Unit::TestCase

  include Niwatori

  def test_digraph_new
    directions = [:go_north,
                  :go_west,
                  :go_south,
                  :go_north, # conflict
                  :go_down,
                  :go_up, # conflict
                  :go_east,
                  :go_east,
                  :go_up,
                  :go_up,
                  :go_south, # conflict (by size)
                  :go_down, # conflict
                 ]
    digraph = Digraph.new(directions,
                          start: [2, 5, 0],
                          size: [6, 6],
                          floors: -6..5)
    assert_equal([2, 5, 0], digraph.start)
    assert_equal([6, 6], digraph.size)
    assert_equal(-6..5, digraph.floors)
    e = digraph.edges.each
    edge = e.next
    assert_equal(Vertex[2, 5, 0, :state1], edge.initial)
    assert_equal(Vertex[2, 4, 0, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[2, 4, 0, :state1], edge.initial)
    assert_equal(Vertex[1, 4, 0, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[1, 4, 0, :state1], edge.initial)
    assert_equal(Vertex[1, 5, 0, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[1, 5, 0, :state1], edge.initial)
    assert_equal(Vertex[1, 5, -1, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[1, 5, -1, :state1], edge.initial)
    assert_equal(Vertex[2, 5, -1, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[2, 5, -1, :state1], edge.initial)
    assert_equal(Vertex[3, 5, -1, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[3, 5, -1, :state1], edge.initial)
    assert_equal(Vertex[3, 5, 0, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[3, 5, 0, :state1], edge.initial)
    assert_equal(Vertex[3, 5, 1, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    assert_raises(StopIteration) { e.next }
    e = digraph.vertexes.each
    assert_equal(Vertex[2, 5, 0, :state1], e.next)
    assert_equal(Vertex[2, 4, 0, :state1], e.next)
    assert_equal(Vertex[1, 4, 0, :state1], e.next)
    assert_equal(Vertex[1, 5, 0, :state1], e.next)
    assert_equal(Vertex[1, 5, -1, :state1], e.next)
    assert_equal(Vertex[2, 5, -1, :state1], e.next)
    assert_equal(Vertex[3, 5, -1, :state1], e.next)
    assert_equal(Vertex[3, 5, 0, :state1], e.next)
    assert_equal(Vertex[3, 5, 1, :state1], e.next)
    assert_raises(StopIteration) { e.next }
  end

  def test_digraph_new2
    directions = [:go_north, :switch, :go_north, :switch]
    digraph = Digraph.new(directions,
                          start: [2, 5, 0],
                          size: [6, 6],
                          floors: -6..5)
    e = digraph.edges.each
    edge = e.next
    assert_equal(Vertex[2, 5, 0, :state1], edge.initial)
    assert_equal(Vertex[2, 4, 0, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[2, 4, 0, :state1], edge.initial)
    assert_equal(Vertex[2, 4, 0, :state2], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[2, 4, 0, :state2], edge.initial)
    assert_equal(Vertex[2, 3, 0, :state2], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[2, 3, 0, :state2], edge.initial)
    assert_equal(Vertex[2, 3, 0, :state1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    assert_raises(StopIteration) { e.next }
  end

  def test_dungeon_new
    directions = [:go_north,
                  :go_west,
                  :go_south,
                  :go_north, # conflict
                  :go_down,
                  :go_up, # conflict
                  :go_east,
                  :go_east,
                  :go_up,
                  :go_up,
                  :go_south, # conflict (by size)
                  :go_down, # conflict
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
  end

end
