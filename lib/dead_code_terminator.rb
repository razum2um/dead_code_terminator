# frozen_string_literal: true

require "parser/current"
require "unparser"
require_relative "dead_code_terminator/version"
require_relative "dead_code_terminator/ast"
require_relative "dead_code_terminator/cond"
require_relative "dead_code_terminator/cond/base"
require_relative "dead_code_terminator/cond/literal"
require_relative "dead_code_terminator/cond/env_index"
require_relative "dead_code_terminator/cond/env_fetch"

module DeadCodeTerminator
  class Error < StandardError; end

  def self.strip(io, env: {})
    Ast.new(env: env, ast: Unparser.parse(io)).process
  end
end
