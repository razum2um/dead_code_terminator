# frozen_string_literal: true

module DeadCodeTerminator
  module Cond
    # ENV['PRODUCTION']
    #
    # s(:send,
    #   s(:const, nil, :ENV), :[],
    #   s(:str, "FLAG"))
    class EnvIndex < Base
      def value
        return if ast.type != :send

        hash, bracket_meth, *args = ast.children

        return if hash != s(:const, nil, :ENV)

        return if bracket_meth != :[]

        return if args.size != 1

        key = args[0]
        return unless (matched_env_key = given_env_key(key))

        env[matched_env_key] ? THEN : ELSE
      end

      def given_env_key(ast)
        env.keys.detect { |key| ast == s(:str, key) }
      end
    end

    register EnvIndex
  end
end
