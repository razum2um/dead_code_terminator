# frozen_string_literal: true

module DeadCodeTerminator
  module Cond
    # ENV['PRODUCTION']
    # s(:index,
    #   s(:const, nil, :ENV),
    #   s(:str, "PRODUCTION"))
    class EnvIndex < Base
      def value
        return if ast.type != :index

        hash, key = ast.children
        return if hash != s(:const, nil, :ENV)

        return unless (matched_env_key = given_env_key(key))

        env[matched_env_key] ? THEN : ELSE
      end

      private

      def given_env_key(ast)
        env.keys.detect { |key| ast == s(:str, key) }
      end
    end

    register EnvIndex
  end
end
