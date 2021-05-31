# frozen_string_literal: true

module DeadCodeTerminator
  module Cond
    class Base
      include ::AST::Sexp

      THEN = :then
      ELSE = :else

      attr_reader :env, :ast

      def initialize(env:, ast:)
        @env = env
        @ast = ast
      end

      def value; end
    end
  end
end
