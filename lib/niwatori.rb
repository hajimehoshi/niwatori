module Niwatori

  Vertex = Struct.new(:x, :y, :z)

  Edge = Struct.new(:initial, :terminal)

  class Digraph

    def self.generate(x, y, z, r)
      vertex1 = Vertex[x, y, z]
      edges = []
      r.to_enum(:directions).each do |d|
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
        else
          raise "invalid direction"
        end
        if edges.all?{|e| e.initial != vertex2 and e.terminal != vertex2}
          edges << Edge.new(vertex1, vertex2)
          edges << Edge.new(vertex2, vertex1)
          vertex1 = vertex2
        end
      end
      Digraph.new(edges)
    end

    attr_reader :edges

    def initialize(edges)
      @edges = edges.to_a
    end

  end

end
