# frozen_string_literal: true

module DeadCodeTerminator
  module Cond
    @nodes = []

    def self.register(node)
      @nodes << node
    end

    def self.nodes
      @nodes
    end
  end
end
