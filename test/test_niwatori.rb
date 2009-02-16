require "niwatori"

class TestNiwatori < MiniTest::Unit::TestCase

  include Niwatori

  def test_generate_graph
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
    e = digraph.edges.each
    edge = e.next
    assert_equal(Vertex[2, 5, 0], edge.initial)
    assert_equal(Vertex[2, 4, 0], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[2, 4, 0], edge.initial)
    assert_equal(Vertex[1, 4, 0], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[1, 4, 0], edge.initial)
    assert_equal(Vertex[1, 5, 0], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[1, 5, 0], edge.initial)
    assert_equal(Vertex[1, 5, -1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[1, 5, -1], edge.initial)
    assert_equal(Vertex[2, 5, -1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[2, 5, -1], edge.initial)
    assert_equal(Vertex[3, 5, -1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[3, 5, -1], edge.initial)
    assert_equal(Vertex[3, 5, 0], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    edge = e.next
    assert_equal(Vertex[3, 5, 0], edge.initial)
    assert_equal(Vertex[3, 5, 1], edge.terminal)
    edge2 = e.next
    assert_equal(edge.terminal, edge2.initial)
    assert_equal(edge.initial, edge2.terminal)
    assert_raises(StopIteration){ e.next }
  end

end
