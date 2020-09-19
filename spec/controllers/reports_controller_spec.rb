require 'rails_helper'

RSpec.describe ReportsController, type: :controller do

  describe "GET #show" do
    let(:report) { create(:report) }

    it "should send pdf file to user" do
      get :show, params: { id: report.uuid, format: :json }
      expect(response.body).to eq(report.file.download)
    end
  end

end
