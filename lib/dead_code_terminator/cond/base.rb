# frozen_string_literal: true

module DeadCodeTerminator
  module Cond
    class Base
      THEN = :then
      ELSE = :else

      attr_reader :env, :ast

      def initialize(env:, ast:)
        @env = env
        @ast = ast
      end

      def value; end

      private

      def s(type, *children)
        Parser::AST::Node.new(type, children)
      end
    end
  end
end
