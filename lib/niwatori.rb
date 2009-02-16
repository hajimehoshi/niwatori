module Niwatori

  Vertex = Struct.new(:x, :y, :z, :switch)

  Edge = Struct.new(:initial, :terminal)

  class Digraph

    attr_reader :start
    attr_reader :size
    attr_reader :floors
    attr_reader :vertexes
    attr_reader :edges

    def width
      size[0]
    end

    def height
      size[1]
    end

    def initialize(directions, options)
      @start = options[:start]
      @size = options[:size]
      @floors = options[:floors]
      @vertexes = [Vertex[*start, :state1]]
      @edges = []
      directions.each do |direction|
        new_vertex = @vertexes.last.dup
        case direction
        when :go_north
          new_vertex.y -= 1
        when :go_west
          new_vertex.x -= 1
        when :go_east
          new_vertex.x += 1
        when :go_south
          new_vertex.y += 1
        when :go_down
          new_vertex.z -= 1
        when :go_up
          new_vertex.z += 1
        when :switch
          new_vertex.switch = {
            state1: :state2,
            state2: :state1,
          }[new_vertex.switch]
        else
          raise "invalid direction"
        end
        if 0 <= new_vertex.x and new_vertex.x < width and
            0 <= new_vertex.y and new_vertex.y < height and
            floors.include?(new_vertex.z) and
            not vertexes.include?(new_vertex)
          @edges << Edge.new(vertexes.last, new_vertex)
          @edges << Edge.new(new_vertex, vertexes.last)
          @vertexes << new_vertex
        end
      end
    end

  end

  class Dungeon

    attr_reader :rooms

    def initialize(digraph)
      rooms = {}
      digraph.vertexes.each.with_index do |vertex, i|
        key = [vertex.x, vertex.y, vertex.z]
        doors = []
        digraph.edges.select {|e| e.initial == vertex}.each do |edge|
          terminal = edge.terminal
          case vertex.x - terminal.x
          when 1
            doors << :west
          when -1
            doors << :east
          end
          case vertex.y - terminal.y
          when 1
            doors << :north
          when -1
            doors << :south
          end
        end
        rooms[key] = Room.new(i == 0, doors)
      end
      @rooms = Rooms.new(rooms)
    end

  end

  class Rooms
    
    def initialize(rooms)
      @rooms = rooms
    end

    def [](x, y, z)
      @rooms[[x, y, z]]
    end

    include Enumerable

    def each
      @rooms.values.each
    end

  end

  class Room

    attr_reader :doors

    def initialize(start, doors)
      @start = start
      @doors = doors
    end

    def start?
      @start
    end

  end

end
