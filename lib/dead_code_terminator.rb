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
    replaces = on_node(Unparser.parse(io)) do |ast|
      Ast.new(env: env, ast: ast).process if ast.type == :if
    end

    rewrite(Parser::Source::Buffer.new("buffer-or-filename", source: io), replaces)
  end

  def self.rewrite(buffer, replaces)
    Parser::Source::TreeRewriter.new(buffer).tap do |rewriter|
      replaces.each do |replace|
        rewriter.replace(*replace)
      end
    end.process
  end

  def self.on_node(node, &block)
    Array(yield(node)) + node.children.flat_map do |elem|
      on_node(elem, &block) if elem.is_a?(Parser::AST::Node)
    end.compact
  end
end
