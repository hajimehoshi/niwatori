module Niwatori

  Vertax = Struct.new(:x, :y, :z)

  Edge = Struct.new(:initial, :terminal)

  class Digraph

    include Enumerable

    def self.generate(x, y, z, r)
      vertax1 = Vertax[x, y, z]
      edges = r.to_enum(:directions).map do |d|
        vertax2 = vertax1.dup
        case d[0]
        when :x
        when :y
          vertax2.y += d[1]
        end
        e1 = Edge.new(vertax1, vertax2)
        e2 = Edge.new(vertax2, vertax1)
        vertax1 = vertax2
        [e1, e2]
      end.flatten
      Digraph.new(edges)
    end

    attr_reader :edges

    def initialize(edges)
      @edges = edges.to_a
    end

    def each
    end
    
  end

end
