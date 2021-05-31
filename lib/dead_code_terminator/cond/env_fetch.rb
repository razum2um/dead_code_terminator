# frozen_string_literal: true

module DeadCodeTerminator
  module Cond
    # ENV.fetch('PRODUCTION')
    # s(:send,
    #   s(:const, nil, :ENV), :fetch,
    #   s(:str, "PRODUCTION"))
    class EnvFetch < Base
      def value
        return if ast.type != :send

        receiver, method, *args = ast.children
        return unless receiver == s(:const, nil, :ENV) && method == :fetch

        return unless (matched_env_key = given_env_key(args[0]))

        env[matched_env_key] ? THEN : ELSE
      end

      private

      def given_env_key(ast)
        env.keys.detect { |key| ast == s(:str, key) }
      end
    end

    register EnvFetch
  end
end
