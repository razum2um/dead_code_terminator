# frozen_string_literal: true

module DeadCodeTerminator
  module Cond
    class Literal < Base
      def value
        return THEN if ast.type == :true
        return ELSE if ast.type == :false
      end
    end

    register Literal
  end
end
