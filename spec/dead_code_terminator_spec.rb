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
end
