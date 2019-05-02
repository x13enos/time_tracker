require "rails_helper"

RSpec.describe PolicyExecutor do

  describe "perform" do
    it "should build and call policy by passed data if object is string" do
      policy = double
      allow(ProjectPolicy).to receive(:new).with('user', 'project') { policy }
      expect(policy).to receive(:create?) { true }
      PolicyExecutor.new('project', 'user', 'Create').perform
    end

    it "should build and call policy by passed data if object is real" do
      project = create(:project)
      policy = double
      allow(ProjectPolicy).to receive(:new).with('user', project) { policy }
      expect(policy).to receive(:create?) { true }
      PolicyExecutor.new(project, 'user', 'Create').perform
    end

    it "should raise error if policy returns false" do
      policy = double
      allow(ProjectPolicy).to receive(:new).with('user', 'project') { policy }
      allow(policy).to receive(:create?) { false }
      expect { PolicyExecutor.new('project', 'user', 'Create').perform }.to raise_error(GraphQL::ExecutionError)
    end
  end
end
