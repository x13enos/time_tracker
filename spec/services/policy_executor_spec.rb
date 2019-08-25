require "rails_helper"

RSpec.describe PolicyExecutor do

  let(:project) { create(:project) }
  let(:policy) { double }

  describe "perform" do
    it "should build and call policy by passed data if object is string" do
      allow(ProjectPolicy).to receive(:new).with('user', 'project') { policy }
      expect(policy).to receive(:create?) { true }
      PolicyExecutor.new('project', 'user', 'Create').perform
    end

    it "should build and call policy by passed data if object is real" do
      allow(ProjectPolicy).to receive(:new).with('user', project) { policy }
      expect(policy).to receive(:create?) { true }
      PolicyExecutor.new(project, 'user', 'Create').perform
    end

    it "should remove object name from action if its was included to path" do
      allow(ProjectPolicy).to receive(:new).with('user', project) { policy }
      expect(policy).to receive(:create?) { true }
      PolicyExecutor.new(project, 'user', 'ProjectCreate').perform
    end

    it "should raise error if policy returns false" do
      allow(ProjectPolicy).to receive(:new).with('user', 'project') { policy }
      allow(policy).to receive(:create?) { false }
      expect { PolicyExecutor.new('project', 'user', 'Create').perform }.to raise_error(GraphQL::ExecutionError)
    end
  end
end
