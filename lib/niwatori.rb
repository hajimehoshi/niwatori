module Niwatori

  module_function

  def generate_dungeon()
    start = [0, 0, 0]
    generate_rooms(generate_path(start), start)
  end

  def generate_path(start)
    size = 10
    path = [[*start, 0]]
    loop do
      node = path.last.dup
      next_nodes = []
      next_nodes << node.dup.tap {|a| a[0] += 1 }
      next_nodes << node.dup.tap {|a| a[0] -= 1 }
      next_nodes << node.dup.tap {|a| a[1] += 1 }
      next_nodes << node.dup.tap {|a| a[1] -= 1 }
      next_nodes << node.dup.tap {|a| a[2] += 1 }
      next_nodes << node.dup.tap {|a| a[2] -= 1 }
      next_nodes << node.dup.tap {|a| a[3] = 1 - a[3] }
      if next_nodes.all? {|n| path.include?(n) }
        return generate_path(start)
      end
      case i = rand(7)
      when 0..5
        node[i/2] += (i % 2) * 2 - 1
      when 6
        node[3] = 1 - node[3]
      end
      unless path.include?(node)
        begin
          if size <= path.size + 1 and
              path.all? {|n| n[0..2] != node[0..2] }
            break
          end
        ensure
          path.push(node)
        end
      end
    end
    path
  end

  def generate_rooms(path, start)
    connections = {}
    size = {
      :max_x => start[0],
      :min_x => start[0],
      :max_y => start[1],
      :min_y => start[1],
      :max_z => start[2],
      :min_z => start[2],
    }
    path.each_with_index do |node, i|
      locate = node[0..2]
      connections[locate] ||= {
        0 => [], 1 => [],
      }
      if locate[0] < size[:min_x]
        size[:min_x] = locate[0]
      elsif size[:max_x] < locate[0]
        size[:max_x] = locate[0]
      end
      if locate[1] < size[:min_y]
        size[:min_y] = locate[1]
      elsif size[:max_y] < locate[1]
        size[:max_y] = locate[1]
      end
      if locate[2] < size[:min_z]
        size[:min_z] = locate[2]
      elsif size[:max_z] < locate[2]
        size[:max_z] = locate[2]
      end
      neighbor_nodes = []
      neighbor_nodes << path[i-1] if 0 <= i-1
      neighbor_nodes << path[i+1] if path[i+1]
      cs = connections[locate][node[3]]
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
          connections[locate][:switch] = true
        end
      end
    end
    rooms = Rooms.new(connections, size, start, path.last[0..2])
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
|       |
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
      (@size[:min_z]..@size[:max_z]).reverse_each do |z|
        lines << ((0 <= z) ? "#{z+1}F" : "B#{-z}F")
        (@size[:min_y]..@size[:max_y]).each do |y|
          7.times { lines << "" }
          (@size[:min_x]..@size[:max_x]).each do |x|
            if room = @connections[[x, y, z]]
              new_lines = ["             ",
                           "  +-------+  ",
                           "  |       |  ",
                           "  |       |  ",
                           "  |       |  ",
                           "  +-------+  ",
                           "             "]
              if [x, y, z] == @start
                new_lines[4][3] = "S"
              end
              if [x, y, z] == @goal
                new_lines[4][3] = "G"
              end
              if room[:switch]
                new_lines[3][6] = "*"
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
              p [x, y, z, room]
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
