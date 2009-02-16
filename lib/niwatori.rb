module Niwatori

  Vertex = Struct.new(:x, :y, :z)

  Edge = Struct.new(:initial, :terminal)

  class Digraph

    attr_reader :edges

    def initialize(directions, options)
      options = {
        start: [2, 5, 0],
        size: [6, 6],
        floors: -6..5,
      }.merge(options)
      vertex1 = Vertex[*options[:start]]
      width, height = *options[:size]
      @edges = []
      directions.each do |direction|
        vertex2 = vertex1.dup
        case direction
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
        when :go_up
          vertex2.z += 1
        else
          raise "invalid direction"
        end
        if 0 <= vertex2.x and vertex2.x < width and
            0 <= vertex2.y and vertex2.y < height and
            options[:floors].include?(vertex2.z) and
            @edges.all?{|e| e.initial != vertex2 and e.terminal != vertex2}
          @edges << Edge.new(vertex1, vertex2)
          @edges << Edge.new(vertex2, vertex1)
          vertex1 = vertex2
        end
      end
    end

  end

end
