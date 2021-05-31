# frozen_string_literal: true

# IMPORTANT!
# please, enable whitespace showing, take care of expected heredoc contents,
#         disable stripping lines in git/tools
# note: despite line seems empty, spaces left before old `if` place:
# - where, shifted by class/method nesting
# - after `=` sign
RSpec.describe DeadCodeTerminator do
  let(:env) { {} }
  let(:io) { "" }
  let(:subject) { described_class.strip(io, env: env) }

  let(:then_branch_on_line_2_of_total_5_shift_by_2) { "\n  :then_branch\n\n\n\n" }
  let(:else_branch_on_line_4_of_total_5_shift_by_2) { "\n\n\n  :else_branch\n\n" }

  before do
    expect(subject).to be_valid_ruby_code
  end

  describe "static truthty if branch" do
    let(:io) do
      <<~CODE
        if true
          :then_branch
        else
          :else_branch
        end
      CODE
    end

    it "preserves then-branch" do
      expect(subject).to eq then_branch_on_line_2_of_total_5_shift_by_2
    end
  end

  describe "static falsy if branch" do
    let(:io) do
      <<~CODE
        if false
          :then_branch
        else
          :else_branch
        end
      CODE
    end

    it "preserves else-branch" do
      expect(subject).to eq else_branch_on_line_4_of_total_5_shift_by_2
    end
  end

  describe "truthty if branch marked via ENV[]" do
    let(:env) { { "PRODUCTION" => true } }

    let(:io) do
      <<~CODE
        if ENV['PRODUCTION']
          :then_branch
        else
          :else_branch
        end
      CODE
    end

    it "preserves then_branch" do
      expect(subject).to eq then_branch_on_line_2_of_total_5_shift_by_2
    end
  end

  describe "falsy if branch marked via ENV[] written with ternary operator" do
    let(:env) { { "PRODUCTION" => false } }

    let(:io) do
      <<~CODE
        ENV['PRODUCTION'] ? :then_branch : :else_branch
      CODE
    end

    it "preserves then_branch" do
      expect(subject).to eq ":else_branch\n"
    end
  end

  describe "truthty if branch marked via ENV[] written with ternary operator returning expression" do
    let(:env) { { "PRODUCTION" => true } }

    let(:io) do
      <<~CODE
        x = ENV['PRODUCTION'] ? :then_branch : :else_branch
      CODE
    end

    it "preserves then_branch" do
      expect(subject).to eq "x = :then_branch\n"
    end
  end

  describe "truthty if branch marked via ENV[] in brackets" do
    let(:env) { { "PRODUCTION" => true } }

    let(:io) do
      <<~CODE
        if (ENV['PRODUCTION'])
          :then_branch
        else
          :else_branch
        end
      CODE
    end

    it "preserves then_branch" do
      expect(subject).to eq then_branch_on_line_2_of_total_5_shift_by_2
    end
  end

  describe "truthty if branch marked via ENV[] shifted inside class and method" do
    let(:env) { { "PRODUCTION" => true } }

    let(:io) do
      <<~CODE
        class X
          def x
            if ENV['PRODUCTION']
              :then_branch
            else
              :else_branch
            end
          end
        end
      CODE
    end

    let(:expected) do
      <<~CODE
        class X
          def x
            
              :then_branch
      
      
      
          end
        end
      CODE
    end

    it "preserves then_branch" do
      expect(subject).to eq expected
    end
  end

  describe "truthty if branch marked via ENV.fetch()" do
    let(:env) { { "PRODUCTION" => true } }

    let(:io) do
      <<~CODE
        if ENV.fetch('PRODUCTION')
          :then_branch
        else
          :else_branch
        end
      CODE
    end

    it "preserves then_branch" do
      expect(subject).to eq then_branch_on_line_2_of_total_5_shift_by_2
    end
  end

  describe "if branch marked via ENV[] not present in env" do
    let(:io) do
      <<~CODE
        if ENV['PRODUCTION']
          :then_branch
        else
          :else_branch
        end
      CODE
    end

    it "dosn't touch code" do
      expect(subject).to eq io
    end
  end

  describe "arbitrary code" do
    let(:io) do
      <<~CODE
        class ENV
          def if(arg, arg2)
            x = if arg
              :then_branch
            else
              :else_branch
            end

            y = unless arg2
              :then_branch_2
            else
              :else_branch_2
            end

            x ? x : y
          end
        end
      CODE
    end

    it "dosn't touch anything" do
      expect(subject).to eq io
    end
  end

  describe "truthty if branch marked via ENV[] and used as value" do
    let(:env) { { "PRODUCTION" => true } }

    let(:io) do
      <<~CODE
        value = if ENV['PRODUCTION']
          :then_branch
        else
          :else_branch
        end
      CODE
    end

    let(:expected) do
      <<~CODE
        value = 
          :then_branch

        

      CODE
    end

    it "preserves then_branch" do
      expect(subject).to eq expected
    end
  end

  describe "truthty if branch marked via ENV[] and used as value after unless" do
    let(:env) { { "PRODUCTION" => true } }

    let(:io) do
      <<~CODE
        value = unless ENV['PRODUCTION']
          :then_branch
        else
          :else_branch
        end
      CODE
    end

    let(:expected) do
      <<~CODE
        value = 
        

          :else_branch

      CODE
    end

    it "preserves else_branch" do
      expect(subject).to eq expected
    end
  end

  describe "multiple sequential branches" do
    let(:env) { { "PRODUCTION" => true } }

    let(:io) do
      <<~CODE
        class X
          def x
            value = if ENV['PRODUCTION']
              :then_branch
            else
              :else_branch
            end
            value2 = unless ENV['PRODUCTION']
              :then_branch
            else
              :else_branch
            end
            [value, value2]
          end
        end
      CODE
    end

    let(:expected) do
      <<~CODE
        class X
          def x
            value = 
              :then_branch
        
        
        
            value2 = 
        
        
              :else_branch
        
            [value, value2]
          end
        end
      CODE
    end

    it "preserves top-level branch" do
      expect(subject).to eq expected
    end
  end

  describe "multiple nested branches with same env" do
    let(:env) { { "PRODUCTION" => true } }

    let(:io) do
      <<~CODE
        value = if ENV['PRODUCTION']
          :then_branch
        else
          value2 = if ENV['PRODUCTION']
            :then_branch
          else
            :else_branch
          end
        end
      CODE
    end

    let(:expected) do
      <<~CODE
        value = 
          :then_branch


        
        
        
        
        
      CODE
    end

    it "preserves only top-level branch" do
      expect(subject).to eq expected
    end
  end

  describe "multiple nested branches with different keys" do
    let(:env) { { "PRODUCTION" => true, "FLAG" => false } }

    let(:io) do
      <<~CODE
        value = if ENV['FLAG']
          :then_branch
        else
          value2 = unless ENV['PRODUCTION']
            :then_branch
          else
            ENV['RUNTIME'] ? :else1 : :else2
          end
        end
      CODE
    end

    let(:expected) do
      <<~CODE
        value = 


          value2 = 
        
        
            ENV['RUNTIME'] ? :else1 : :else2
        
        
      CODE
    end

    it "preserves only top-level branch" do
      expect(subject).to eq expected
    end
  end
end
