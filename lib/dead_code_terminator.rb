# frozen_string_literal: true

require "parser/current"
require "unparser"
require_relative "dead_code_terminator/version"

module DeadCodeTerminator
  class Error < StandardError; end

  def self.range(from, len = nil)
    unless len
      len = from.end - from.begin
      from = from.begin
    end
    Parser::Source::Range.new(@buf, from, from + len)
  end

  def self.strip(io, env: {})
    ast = Unparser.parse(io)

    new_ast = if ast.type == :if
                cond, then_branch, else_branch = ast.children

                case cond.type
                when :true then then_branch
                when :false then else_branch
                else ast
                end
              else
                ast
              end

    @buf = ast.loc.expression.source_buffer
    @rewriter = Parser::Source::TreeRewriter.new(@buf)

    begin_pos = new_ast.loc.expression.begin_pos
    end_pos = new_ast.loc.expression.end_pos

    total_end = ast.loc.expression.end_pos

    from_line = new_ast.loc.expression.source_buffer.line_for_position(begin_pos)
    to_line = new_ast.loc.expression.source_buffer.line_for_position(end_pos)

    total_lines = ast.loc.last_line

    @rewriter.replace(range(end_pos, (total_end - end_pos)), "\n" * (total_lines - to_line))
    @rewriter.replace(range(0, begin_pos), "\n" * (from_line - 1))

    @rewriter.process
  end
end
