# frozen_string_literal: true

module DeadCodeTerminator
  class PlainIf < Node
    def self.match?(ast); end

    def then_branch; end

    def else_branch; end
  end
end
