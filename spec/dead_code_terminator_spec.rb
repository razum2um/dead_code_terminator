# frozen_string_literal: true

RSpec.describe DeadCodeTerminator do
  let(:env) { {} }
  let(:io) { "" }
  let(:subject) { described_class.strip(io, env: env) }

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

    let(:expected) do
      <<~CODE
        
        :then_branch

        

      CODE
    end

    it "preserves then-branch" do
      expect(subject).to eq expected
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

    let(:expected) do
      <<~CODE
        


        :else_branch

      CODE
    end

    it "preserves else-branch" do
      expect(subject).to eq expected
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

    let(:expected) do
      <<~CODE
        
        :then_branch

        

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

    let(:expected) do
      <<~CODE
        
        :then_branch

        

      CODE
    end

    it "preserves then_branch" do
      expect(subject).to eq expected
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
          def if(arg)
            if arg
              :then_branch
            else
              :else_branch
            end
          end
        end
      CODE
    end

    it "dosn't touch anything" do
      expect(subject).to eq io
    end
  end
end
