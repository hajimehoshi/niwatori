require "niwatori"

class TestNiwatori < MiniTest::Unit::TestCase

  include Niwatori

  def test_generate_graph
    mock_random_generator = Object.new
    def mock_random_generator.directions
      yield [:go_north]
      yield [:go_west]
      yield [:go_south]
      yield [:go_north]
    end
    digraph = Digraph.generate(2, 5, 0, mock_random_generator)
    edges = digraph.edges
    assert_equal(6, edges.size)

    assert_equal(Vertax[2, 5, 0], edges[0].initial)
    assert_equal(Vertax[2, 4, 0], edges[0].terminal)
    assert_equal(Vertax[2, 4, 0], edges[1].initial)
    assert_equal(Vertax[2, 5, 0], edges[1].terminal)
    
    assert_equal(Vertax[2, 4, 0], edges[2].initial)
    assert_equal(Vertax[1, 4, 0], edges[2].terminal)
    assert_equal(Vertax[1, 4, 0], edges[3].initial)
    assert_equal(Vertax[2, 4, 0], edges[3].terminal)

    assert_equal(Vertax[1, 4, 0], edges[4].initial)
    assert_equal(Vertax[1, 5, 0], edges[4].terminal)
    assert_equal(Vertax[1, 5, 0], edges[5].initial)
    assert_equal(Vertax[1, 4, 0], edges[5].terminal)
  end

end
