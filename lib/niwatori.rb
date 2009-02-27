module Niwatori

  class Paths

    class Branch

      def initialize(node, parent)
        @nodes = [node]
        @parent = parent
      end
      
      def initialize(parent = nil, node_index = 0)
        @parent = parent
        if parent
          @nodes = [parent.nodes[node_index]]
        else
          @nodes = []
        end
      end

      def nodes
        @nodes
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
      branch = Branch.new
      branch.nodes << [*start, 0]
      @branches = [branch]
      @node_flags = {}
      @position_flags = {}
    end

    def add_branch(branch_index, node_index)
      parent_branch = @branches[branch_index]
      @branches << Branch.new(parent_branch, node_index)
    end

    def branches
      @branches
    end

    def remove_branch
      raise "can't remove" unless @branches.last.size <= 1
      @branches.pop
    end

    def first_node
      @branches.first.nodes.first
    end

    def last_node
      @branches.last.nodes.last
    end

    def last_branch
      @branches.last
    end

    def add_node(node)
      raise "invalid node" if node.size != 4
      @branches.last.nodes << node
      @node_flags[node] = true
      @position_flags[node[0..2]] = true
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
    length = -> { 6 + rand(5) }
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
    add_branch = ->(branch_index, path_index, length) {
      paths.add_branch(branch_index, path_index)
      loop do
        node = paths.last_node.dup
        next_nodes = get_next_nodes.(node)
        next_nodes.reject! {|n| paths.include?(n) }
        break if next_nodes.empty?
        node = next_nodes.sample
        paths.add_node(node)
        break if length <= paths.last_branch.nodes.size and
          !paths.include?([*node[0..2], 1 - node[3]])
      end
      if paths.last_branch.nodes.size == 1
        paths.remove_branch
        false
      else
        true
      end
    }
    add_branch.(0, 0, length.())
    6.times do |i|
      begin
        branches = paths.branches
        branch_index = rand(branches.size)
        node_index = rand(branches[branch_index].nodes.size)
        r = add_branch.(branch_index, node_index, length.())
      end until r
    end
=begin
    600.times do |i|
      # $stderr.puts(i)
      # key_nodes = (paths.positions - keys).sample(rand(2))
      # key_count = key_nodes.size
      # keys.push(*key_nodes)
      begin
        # r = add_path(paths, paths.last_path.sample[0..2], length.())
        r = add_path(paths, paths.nodes.sample, length.())
      end until r
      # p keys
      #i = 0
      #while i < key_count
      #end
    end
=end
  end

  def generate_rooms(paths, keys)
    connections = {}
    size = {
      :max_x => paths.first_node[0],
      :min_x => paths.first_node[0],
      :max_y => paths.first_node[1],
      :min_y => paths.first_node[1],
      :max_z => paths.first_node[2],
      :min_z => paths.first_node[2],
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
    goal = paths.branches.max {|a, b| a.level - b.level }.nodes.last
    return Rooms.new(connections, size, paths.first_node[0..2], goal)
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
