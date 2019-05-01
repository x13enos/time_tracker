require "rails_helper"

RSpec.describe Mutations::Projects::Create do

  let(:result) { TimeTrackerSchema.execute(query_string) }
  let(:query_string) do
    %|mutation{
        createProject(
          name: "#{name}",
        ){
        project{
          id,
          name
        }
      }
    }|
  end

  describe "resolve" do
    context "when passed data is correct" do
      let!(:name) { 'New project' }

      it "should create new project" do
        expect { result }.to change{ Project.count }.from(0).to(1)
      end

      it "should return project's data" do
        expect(result['data']['createProject']['project']['name']).to eq('New project')
      end
    end

    context "when passed data is wrong" do
      let!(:name) { nil }

      it "should return error if name wasn't passed" do
        expect(result['errors'][0]['message']).to_not be_empty
      end
    end
  end
end
