# frozen_string_literal: true

module DeadCodeTerminator
  class Ast
    attr_reader :env, :ast, :buf, :cond, :then_branch, :else_branch

    def initialize(env:, ast:)
      @env = env
      @ast = ast
      @buf = @ast.loc.expression.source_buffer
      @cond, @then_branch, @else_branch = @ast.children

      # handle single brackets around: `if (ENV['X'])`
      @cond = @cond.children[0] if (@cond.type == :begin) && (@cond.children.size == 1)
    end

    def process
      static_if_branch ? [erase_before_args, erase_after_args] : []
    end

    private

    def erase_before_args
      [range(total_begin, begin_pos_before_spaces), "\n" * (from_line - total_first_line)]
    end

    def erase_after_args
      [range(end_pos, total_end), "\n" * (total_lines - to_line)]
    end

    def begin_pos_before_spaces
      begin_pos - count_spaces_before_first_line_of_static_if_branch
    end

    def begin_pos
      static_if_branch.loc.expression.begin_pos
    end

    def end_pos
      static_if_branch.loc.expression.end_pos
    end

    def total_begin
      ast.loc.expression.begin_pos
    end

    def total_end
      ast.loc.expression.end_pos
    end

    def from_line
      @from_line ||= line_for_position_of_static_if_branch(begin_pos)
    end

    def to_line
      line_for_position_of_static_if_branch(end_pos)
    end

    def total_lines
      ast.loc.last_line
    end

    def total_first_line
      ast.loc.first_line
    end

    def range(from, to)
      Parser::Source::Range.new(buf, from, to)
    end

    # :(
    def count_spaces_before_first_line_of_static_if_branch
      return 0 if total_lines == 1

      (begin_pos - 1).downto(0).take_while do |pos|
        line_for_position_of_static_if_branch(pos) == from_line
      end.size
    end

    def line_for_position_of_static_if_branch(pos)
      static_if_branch.loc.expression.source_buffer.line_for_position(pos)
    end

    def static_if_branch
      return @static_if_branch if defined? @static_if_branch

      Cond.nodes.each do |klass|
        if (value = klass.new(env: env, ast: cond).value)
          return (@static_if_branch = then_branch) if value == Cond::Base::THEN
          return (@static_if_branch = else_branch) if value == Cond::Base::ELSE
        end
      end

      @static_if_branch = nil
    end
  end
end
