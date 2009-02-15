require "niwatori"

class TestNiwatori < MiniTest::Unit::TestCase

  include Niwatori

  def test_generate_graph
    mock_random_generator = Object.new
    def mock_random_generator.directions
      yield [:y, -1]
    end
    digraph = Digraph.generate(2, 5, 0, mock_random_generator)
    edges = digraph.edges
    assert_equal(2, edges.size)
    assert_equal(Vertax[2, 5, 0], edges[0].initial)
    assert_equal(Vertax[2, 4, 0], edges[0].terminal)
    assert_equal(Vertax[2, 4, 0], edges[1].initial)
    assert_equal(Vertax[2, 5, 0], edges[1].terminal)
  end

end
