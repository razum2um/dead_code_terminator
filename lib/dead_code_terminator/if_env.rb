# frozen_string_literal: true

module DeadCodeTerminator
  class IfEnv < PlainIf
    def self.match?(ast); end

    def then_branch; end

    def else_branch; end

    def self.nodes
      ancestors
    end
  end
end
