module Niwatori

  class DungeonPath

    Node = Struct.new(:x, :y, :z, :switch)

    class Node

      def locate
        [x, y, z]
      end

      def move(direction)
        new_node = self.dup
        case direction
        when :north
          new_node.y -= 1
        when :west
          new_node.x -= 1
        when :east
          new_node.x += 1
        when :south
          new_node.y += 1
        when :up
          new_node.z += 1
        when :down
          new_node.z -= 1
        else
          raise "invalid direction"
        end
        new_node
      end

    end

    attr_reader :start

    def initialize(options)
      @start = options[:start]
      @nodes = [Node[*@start, :state1].freeze]
    end

    def width
      @size[0]
    end

    def height
      @size[1]
    end

    def nodes
      @nodes.each
    end

    def addable?(direction)
      new_node = @nodes.last.move(direction)
      !@nodes.include?(new_node)
    end

    def add(direction)
      raise "can't add" unless addable?(direction)
      new_node = @nodes.last.move(direction)
      @nodes << new_node.freeze
    end

  end

=begin

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

=end

end
