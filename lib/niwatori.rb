module Niwatori

  Vertex = Struct.new(:x, :y, :z)

  Edge = Struct.new(:initial, :terminal)

  class Digraph

    attr_reader :edges

    def initialize(x, y, z, directions)
      vertex1 = Vertex[x, y, z]
      @edges = []
      directions.each do |d|
        vertex2 = vertex1.dup
        case d[0]
        when :go_north
          vertex2.y -= 1
        when :go_west
          vertex2.x -= 1
        when :go_east
          vertex2.x += 1
        when :go_south
          vertex2.y += 1
        when :go_down
          vertex2.z -= 1
        else
          raise "invalid direction"
        end
        if edges.all?{|e| e.initial != vertex2 and e.terminal != vertex2}
          @edges << Edge.new(vertex1, vertex2)
          @edges << Edge.new(vertex2, vertex1)
          vertex1 = vertex2
        end
      end
    end

  end

end
