require "niwatori"

class TestNiwatori < MiniTest::Unit::TestCase

  include Niwatori

  def test_node
    hash = {}
    hash[Node.new(Position.new(1, 2, 3), 0)] = true
    hash[Node.new(Position.new(1, 2, 3), 1)] = true
    assert(hash.include?(Node.new(Position.new(1, 2, 3), 0)))
    assert(hash.include?(Node.new(Position.new(1, 2, 3), 1)))
    assert(!hash.include?(Node.new(Position.new(1, 2, 2), 0)))
  end

  def test_branch
    branch = Branch.new
    assert(!branch.include?(Node.new(Position.new(0, 0, 0), 0)))
    assert(!branch.include?(Node.new(Position.new(0, 0, 1), 0)))
    branch.add_node(Node.new(Position.new(0, 0, 0), 0))
    assert(branch.include?(Node.new(Position.new(0, 0, 0), 0)))
    assert(!branch.include?(Node.new(Position.new(0, 0, 1), 0)))
  end

end
