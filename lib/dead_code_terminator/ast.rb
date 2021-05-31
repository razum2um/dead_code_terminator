# frozen_string_literal: true

module DeadCodeTerminator
  class Ast
    attr_reader :env, :ast

    def initialize(env:, ast:)
      @env = env
      @ast = ast
    end

    def process
      erase_before!
      erase_after!
      rewriter.process
    end

    private

    def erase_before!
      rewriter.replace(range(end_pos, (total_end - end_pos)), "\n" * (total_lines - to_line))
    end

    def erase_after!
      rewriter.replace(range(0, begin_pos), "\n" * (from_line - 1))
    end

    def begin_pos
      new_ast.loc.expression.begin_pos
    end

    def end_pos
      new_ast.loc.expression.end_pos
    end

    def total_end
      ast.loc.expression.end_pos
    end

    def from_line
      new_ast.loc.expression.source_buffer.line_for_position(begin_pos)
    end

    def to_line
      new_ast.loc.expression.source_buffer.line_for_position(end_pos)
    end

    def total_lines
      ast.loc.last_line
    end

    def rewriter
      @rewriter ||= Parser::Source::TreeRewriter.new(buf)
    end

    def range(from, len = nil)
      unless len
        len = from.end - from.begin
        from = from.begin
      end
      Parser::Source::Range.new(buf, from, from + len)
    end

    def buf
      @buf ||= ast.loc.expression.source_buffer
    end

    def new_ast
      @new_ast ||= case ast.type
                   when :if then if_ast
                   else ast
                   end
    end

    def if_ast
      cond, then_branch, else_branch = ast.children

      Cond.nodes.each do |klass|
        if (value = klass.new(env: env, ast: cond).value)
          return then_branch if value == Cond::Base::THEN
          return else_branch if value == Cond::Base::ELSE
        end
      end
    end
  end
end
