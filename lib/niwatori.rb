module Niwatori

  class Paths

    def initialize
      @paths = []
      @node_flags = {}
    end

    def add_path
      @paths << []
    end

    def remove_path
      raise "can't remove" unless @paths.last.size <= 1
      @paths.pop
    end

    def first_node
      @paths.first.first
    end

    def last_node
      @paths.last.last
    end

    def last_path
      @paths.last
    end

    def add_node(node)
      @paths.last << node
      @node_flags[node] = true
    end

    def include?(node)
      @node_flags[node]
    end

    def positions
      positions = []
      @paths.each do |path|
        path.each do |node|
          positions << node[0..2]
        end
      end
      positions.uniq
    end

    include Enumerable

    def each
      @paths.each do |path|
        yield(path)
      end
    end

  end

  module_function

  def generate_dungeon()
    paths = Paths.new
    keys = []
    generate_paths([0, 0, 0], paths, keys)
    generate_rooms(paths, keys)
  end

  def generate_paths(start, paths, keys)
    length = -> { 8 + rand(5) }
    add_path(paths, start, length.())
    4.times do |i|
#      p i
      key_nodes = (paths.positions - keys).sample(rand(2))
      key_count = key_nodes.size
      keys.push(*key_nodes)
      begin
        r = add_path(paths, paths.last_path.sample[0..2], length.())
      end until r
      # p keys
      #i = 0
      #while i < key_count
      #end
    end
  end

  def get_next_nodes(node)
    next_nodes = []
    next_nodes << node.dup.tap {|n| n[0] += 1 } if node[0] + 1 <= 6
    next_nodes << node.dup.tap {|n| n[0] -= 1 } if -6 <= node[0] - 1
    next_nodes << node.dup.tap {|n| n[1] += 1 } if node[1] + 1 <= 6
    next_nodes << node.dup.tap {|n| n[1] -= 1 } if -6 <= node[1] - 1
    next_nodes << node.dup.tap {|n| n[2] += 1 } if node[2] + 1 <= 6
    next_nodes << node.dup.tap {|n| n[2] -= 1 } if -6 <= node[2] - 1
    next_nodes << node.dup.tap {|n| n[3] = 1 - n[3] }
    next_nodes
  end 

  def add_path(paths, start, length)
    paths.add_path
    paths.add_node([*start, 0])
    loop do
      node = paths.last_node.dup
      next_nodes = get_next_nodes(node)
      next_nodes.reject! {|n| paths.include?(n) }
      break if next_nodes.empty?
      # priority_nodes = next_nodes.dup
      # priority_nodes.reject! {|n| n[3] == 1 - node[3] }
      # priority_nodes.reject! {|n| !paths.include?([*n[0..2], 1 - n[3]]) }
      # node = (next_nodes + priority_nodes * 4).sample
      node = next_nodes.sample
      begin
        if length <= paths.last_path.size + 1 and
            !paths.include?([*node[0..2], 1 - node[3]])
          break
        end
      ensure
        paths.add_node(node)
      end
    end
    if paths.last_path.size == 1
      paths.remove_path
      false
    else
      true
    end
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
    paths.each do |path|
      path.each_with_index do |node, i|
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
        neighbor_nodes << path[i-1] if 0 <= i-1
        neighbor_nodes << path[i+1] if path[i+1]
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
    return Rooms.new(connections, size, paths.first_node[0..2], paths.last_node[0..2])
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
