module Niwatori

  class Position

    attr_reader :x, :y, :z

    def initialize(x, y, z)
      @x, @y, @z = x, y, z
    end

    def ==(other)
      other.kind_of?(Position) and 
        @x == other.x and
        @y == other.y and
        @z == other.z
    end
    
    def hash
      @hash ||= ((@x + 8) << 8) | ((@y + 8) << 4) | (@z + 8)
    end

    alias :eql? :==

  end

  class Node

    attr_reader :x, :y, :z, :position, :switch

    def initialize(position, switch)
      @position, @switch = position, switch
      @x = position.x
      @y = position.y
      @z = position.z
    end

    def ==(other)
      other.kind_of?(Node) and 
        @position == other.position and
        @switch == other.switch
    end

    def hash
      @hash ||= (@switch << 12) | ((@x + 8) << 8) | ((@y + 8) << 4) | (@z + 8)
    end

    def next_nodes
      next_nodes = []
      next_nodes << Node.new(Position.new(@x + 1, @y, @z), @switch) if @x + 1 <= 6
      next_nodes << Node.new(Position.new(@x - 1, @y, @z), @switch) if -6 <= @x - 1
      next_nodes << Node.new(Position.new(@x, @y + 1, @z), @switch) if @y + 1 <= 6
      next_nodes << Node.new(Position.new(@x, @y - 1, @z), @switch) if -6 <= @y - 1
      next_nodes << Node.new(Position.new(@x, @y, @z + 1), @switch) if @z + 1 <= 6
      next_nodes << Node.new(Position.new(@x, @y, @z - 1), @switch) if -6 <= @z - 1
      next_nodes << Node.new(Position.new(@x, @y, @z), 1 - @switch)
      next_nodes
    end

    def inspect
      "Node(#{x},#{y},#{z},#{switch})"
    end

    alias eql? ==

  end

  class Branch

    def initialize(parent = nil, node_index = 0)
      @parent = parent
      if parent
        @nodes = [parent.nodes[node_index]]
      else
        @nodes = []
      end
    end

    def add_node(node)
      @nodes << node
    end

    def nodes
      @nodes
    end

    def include?(node)
      @nodes.include?(node)
    end

    def parent
      @parent
    end

    def level
      level = 0
      branch = self.parent
      while branch
        level += 1
        branch = branch.parent
      end
      level
    end

    def inspect
      "Branch[#{nodes.map(&:inspect)}]"
    end

  end

  class Paths

    def initialize(start)
      branch = Branch.new(nil)
      branch.nodes << Node.new(start, 0)
      @branches = [branch]
      @node_flags = {}
      @position_flags = {}
    end

    def branches
      @branches
    end

    def remove_branch
      raise "can't remove" unless @branches.last.nodes.size <= 1
      @branches.pop
    end

    def start_node
      @branches.first.nodes.first
    end

    def goal_node
      @goal_node ||= start_node
    end

    def goal_node=(v)
      raise ArgumentError, "invalid goal node" if include?(Node.new(v.position, 1 - v.switch))
      @goal_node = v
    end

    def add_branch(branch)
      @branches << branch
      branch.nodes.each do |node|
        @node_flags[node] = true
        @position_flags[node.position] = true
      end
    end

    def include?(node)
      @node_flags.include?(node)
    end

    def nodes
      @node_flags.keys
    end

    def positions
      @position_flags.keys
    end

  end

  module_function

  def generate_dungeon()
    paths = Paths.new(Position.new(0, 0, 0))
    keys = []
    generate_paths(paths, keys)
    generate_rooms(paths, keys)
  end

  def generate_paths(paths, keys)
    length = -> { 4 + rand(5) }
    add_branch = ->(branch_index, node_index, length, with_goal) {
      parent_branch = paths.branches[branch_index]
      branch = Branch.new(parent_branch, node_index)
      goal_node = paths.goal_node
      reverse_goal_node = Node.new(goal_node.position, 1 - goal_node.switch)
      loop do
        node = branch.nodes.last.dup
        next_nodes = node.next_nodes
        next_nodes.reject! do |n|
          paths.include?(n) or branch.include?(n) or n == reverse_goal_node
        end
        if next_nodes.empty?
          if with_goal
            reverse_node = Node.new(node.position, 1 - node.switch)
            if paths.include?(reverse_node) or branch.include?(reverse_node)
              return false
            end
          end
          break
        end
        node = next_nodes.sample
        branch.add_node(node)
        if length <= branch.nodes.size
          if with_goal
            reverse_node = Node.new(node.position, 1 - node.switch)
            if !paths.include?(reverse_node) and !branch.include?(reverse_node)
              break
            end
          else
            break
          end
        end
      end
      if branch.nodes.size == 1
        false
      else
        paths.add_branch(branch)
        true
      end
    }
    1000.times do |i|
      branches = paths.branches
      max_level = branches.map {|b| b.level}.max
      begin
        branch = branches.sample
        branch_index = branches.index(branch)
        node_index = rand(branch.nodes.size)
        with_goal = (branch.level == max_level)
        r = add_branch.(branch_index, node_index, length.(), with_goal)
        if r and with_goal
          paths.goal_node = branches.last.nodes.last
        end
      end until r
    end
  end

  def generate_rooms(paths, keys)
    connections = {}
    size = {
      :max_x => paths.start_node.x,
      :min_x => paths.start_node.x,
      :max_y => paths.start_node.y,
      :min_y => paths.start_node.y,
      :max_z => paths.start_node.z,
      :min_z => paths.start_node.z,
    }
    paths.branches.each do |branch|
      (nodes = branch.nodes).each_with_index do |node, i|
        position = node.position
        connections[position] ||= {
          0 => [], 1 => [],
        }
        %w(x y z).each do |d|
          value = position.send(d)
          if value < size[:"min_#{d}"]
            size[:"min_#{d}"] = value
          elsif size[:"max_#{d}"] < value
            size[:"max_#{d}"] = value
          end
        end
        neighbor_nodes = []
        neighbor_nodes << nodes[i-1] if 0 <= i-1
        neighbor_nodes << nodes[i+1] if nodes[i+1]
        cs = connections[position][node.switch]
        neighbor_nodes.each do |n|
          if node.x - 1 == n.x
            cs << :west
          elsif node.x + 1 == n.x
            cs << :east
          elsif node.y - 1 == n.y
            cs << :north
          elsif node.y + 1 == n.y
            cs << :south
          elsif node.z - 1 == n.z
            cs << :down
          elsif node.z + 1 == n.z
            cs << :up
          elsif node.switch != n.switch
            connections[position][:switch] = true
          end
        end
      end
    end
    keys.each do |position|
      connections[position][:key] = true
    end
    return Rooms.new(connections, size, paths.start_node.position,
                     paths.goal_node.position)
  end
        
  class Rooms

    def initialize(connections, size, start, goal)
      @connections = connections
      @size = size
      @start = start
      @goal = goal
    end

=begin

+-^-----+    +-----v-+  
| r     |    |       |
|   K  B|----|   *   |
|       |    |S      |
+-------+    +-------+
    ^
    |
+-------+
|       |p
|       |
|G      |
+-------+

S: Starting position
G: Goal posiion

*: Crystal switch
r: Red block
B: Blue block

k: Small key
K: Big key

u: Upper stair
d: Downer stair

x: Small key door
X: Big key door

=end
    def to_aa
      lines = []
      min_x, min_y = @size[:min_x], @size[:min_y]
      (@size[:min_z]..@size[:max_z]).reverse_each do |z|
        lines << ((0 <= z) ? "#{z+1}F" : "B#{-z}F")
        (@size[:min_y]..@size[:max_y]).each do |y|
          7.times { lines << "" }
          (@size[:min_x]..@size[:max_x]).each do |x|
            if room = @connections[position = Position.new(x, y, z)]
              new_lines = ["  %3d   %3d  " % [x - min_x, y - min_y],
                           "  +-------+  ",
                           "  |       |  ",
                           "  |       |  ",
                           "  |       |  ",
                           "  +-------+  ",
                           "             ",]
              if position == @start
                new_lines[4][3] = "S"
              end
              if position == @goal
                new_lines[4][3] = "G"
              end
              if room[:switch]
                new_lines[3][6] = "*"
              end
              if room[:key]
                new_lines[3][5] = "k"
              end
              (room[0] | room[1]).each do |door|
                case door
                when :north
                  new_lines[0][6] = "|"
                when :south
                  new_lines[6][6] = "|"
                when :west
                  new_lines[3][0..1] = "--"
                when :east
                  new_lines[3][11..12] = "--"
                when :up
                  new_lines[1][z%2 == 0 ? 4 : 8] = "^"
                when :down
                  new_lines[1][z%2 == 0 ? 8 : 4] = "v"
                end
              end
              if !room[0].empty? and !room[1].empty?
                [["r", 0, 1], ["B", 1, 0]].each do |color, i1, i2|
                  (room[i1] - room[i2]).each do |door|
                    case door
                    when :north
                      new_lines[2][6] = color
                    when :south
                      new_lines[4][6] = color
                    when :west
                      new_lines[3][3] = color
                    when :east
                      new_lines[3][9] = color
                    when :up
                      new_lines[2][z%2 == 0 ? 4 : 8] = color
                    when :down
                      new_lines[2][z%2 == 0 ? 8 : 4] = color
                    end
                  end
                end
              end
              new_lines.each_with_index do |line, i|
                lines[i - new_lines.size] << line
              end
            else
              (-7..-1).each {|i| lines[i] << "             " }
            end
          end
        end
      end
      lines.join("\n")
    end

  end

end

if $0 == __FILE__

  puts Niwatori.generate_dungeon.to_aa

end
