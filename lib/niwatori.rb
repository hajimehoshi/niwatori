module Niwatori

  class Paths

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
        unless @level
          @level = 0
          branch = self.parent
          while branch
            @level += 1
            branch = branch.parent
          end
        end
        @level
      end

    end

    def initialize(start)
      branch = Branch.new(nil)
      branch.nodes << [*start, 0]
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

    def add_branch(branch)
      @branches << branch
      branch.nodes.each do |node|
        @node_flags[node] = true
        @position_flags[node[0..2]] = true
      end
    end

    def include?(node)
      @node_flags[node]
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
    paths = Paths.new([0, 0, 0])
    keys = []
    generate_paths(paths, keys)
    generate_rooms(paths, keys)
  end

  def generate_paths(paths, keys)
    length = -> { 4 + rand(5) }
    get_next_nodes = ->(node) {
      next_nodes = []
      next_nodes << node.dup.tap {|n| n[0] += 1 } if node[0] + 1 <= 6
      next_nodes << node.dup.tap {|n| n[0] -= 1 } if -6 <= node[0] - 1
      next_nodes << node.dup.tap {|n| n[1] += 1 } if node[1] + 1 <= 6
      next_nodes << node.dup.tap {|n| n[1] -= 1 } if -6 <= node[1] - 1
      next_nodes << node.dup.tap {|n| n[2] += 1 } if node[2] + 1 <= 6
      next_nodes << node.dup.tap {|n| n[2] -= 1 } if -6 <= node[2] - 1
      next_nodes << node.dup.tap {|n| n[3] = 1 - n[3] }
      next_nodes
    }
    add_branch = ->(branch_index, node_index, length, with_goal) {
      parent_branch = paths.branches[branch_index]
      branch = Paths::Branch.new(parent_branch, node_index)
      loop do
        node = branch.nodes.last.dup
        next_nodes = get_next_nodes.(node)
        next_nodes.reject! {|n| paths.include?(n) or branch.include?(n) }
        if next_nodes.empty?
          if with_goal
            inverse_node = [*node[0..2], 1 - node[3]]
            if paths.include?(inverse_node) or branch.include?(inverse_node)
              return false
            end
          end
          break
        end
        node = next_nodes.sample
        branch.add_node(node)
        if length <= branch.nodes.size
          if with_goal
            inverse_node = [*node[0..2], 1 - node[3]]
            break unless paths.include?(inverse_node) or branch.include?(inverse_node)
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
    add_branch.(0, 0, length.(), false)
    (loops = 500).times do |i|
      begin
        branches = paths.branches
        branch_index = rand(branches.size)
        node_index = rand(branches[branch_index].nodes.size)
        r = add_branch.(branch_index, node_index, length.(), false)
      end until r
    end
    branch = paths.branches.max {|a, b| a.level - b.level}
    branch_index = paths.branches.index(branch)
    begin
      node_index = rand(branch.nodes.size)
      r = add_branch.(branch_index, node_index, 2, true)
    end until r
  end

  def generate_rooms(paths, keys)
    connections = {}
    size = {
      :max_x => paths.start_node[0],
      :min_x => paths.start_node[0],
      :max_y => paths.start_node[1],
      :min_y => paths.start_node[1],
      :max_z => paths.start_node[2],
      :min_z => paths.start_node[2],
    }
    paths.branches.each do |branch|
      (nodes = branch.nodes).each_with_index do |node, i|
        position = node[0..2]
        connections[position] ||= {
          0 => [], 1 => [],
        }
        if position[0] < size[:min_x]
          size[:min_x] = position[0]
        elsif size[:max_x] < position[0]
          size[:max_x] = position[0]
        end
        if position[1] < size[:min_y]
          size[:min_y] = position[1]
        elsif size[:max_y] < position[1]
          size[:max_y] = position[1]
        end
        if position[2] < size[:min_z]
          size[:min_z] = position[2]
        elsif size[:max_z] < position[2]
          size[:max_z] = position[2]
        end
        neighbor_nodes = []
        neighbor_nodes << nodes[i-1] if 0 <= i-1
        neighbor_nodes << nodes[i+1] if nodes[i+1]
        cs = connections[position][node[3]]
        neighbor_nodes.each do |n|
          if node[0] - 1 == n[0]
            cs << :west
          elsif node[0] + 1 == n[0]
            cs << :east
          elsif node[1] - 1 == n[1]
            cs << :north
          elsif node[1] + 1 == n[1]
            cs << :south
          elsif node[2] - 1 == n[2]
            cs << :down
          elsif node[2] + 1 == n[2]
            cs << :up
          elsif node[3] != n[3]
            connections[position][:switch] = true
          end
        end
      end
    end
    keys.each do |position|
      connections[position][:key] = true
    end
    goal_node = paths.branches.max {|a, b| a.level - b.level }.nodes.last
    raise "invalid goal" if paths.include?([*goal_node[0..2], 1 - goal_node[3]])
    return Rooms.new(connections, size, paths.start_node[0..2], goal_node[0..2])
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
[]: Big tresure box

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
            if room = @connections[[x, y, z]]
              new_lines = ["  %3d   %3d  " % [x - min_x, y - min_y],
                           "  +-------+  ",
                           "  |       |  ",
                           "  |       |  ",
                           "  |       |  ",
                           "  +-------+  ",
                           "             ",]
              if [x, y, z] == @start
                new_lines[4][3] = "S"
              end
              if [x, y, z] == @goal
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
