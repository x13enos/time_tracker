# require "rails_helper"
#
# RSpec.describe Mutations::Reports::Generate do
#
#   let!(:current_user) { create(:user, :admin) }
#   let!(:user) { create(:user) }
#
#   let!(:time) { Time.now }
#   let!(:epoch_time) { time.utc.iso8601.to_time.to_i }
#   let!(:context) { { current_user: current_user } }
#   let(:result) { TimeTrackerSchema.execute(query_string, context: context) }
#   let(:query_string) do
#     %|mutation {
#       generateReport(
#        		fromDate: 1573776000,
#   	      toDate: 1575072000,
#           userId: "#{ user_id }"
#       ){
#     		link
#       }
#     }|
#   end
#
#   describe "resolve" do
#     context "when passed data is correct" do
#
#       context "user wasn't passed" do
#         let!(:user_id) { encode_id(current_user) }
#         let!(:context) { { current_user: nil } }
#
#         it "should return error" do
#           expect(result["errors"][0]["message"]).to eq(I18n.t('graphql.errors.not_authorized'))
#         end
#
#         it "should return error code" do
#           expect(result["errors"][0]["extensions"]["code"]).to eq("401")
#         end
#       end
#
#       context "user was passed" do
#         let!(:user_id) { encode_id(user) }
#         let!(:context) { { current_user: user } }
#
#         it "should build generator" do
#           expect(ReportGenerator).to receive(:new).with({
#             from_date: Time.zone.at(1573776000).to_date,
#             to_date: Time.zone.at(1575072000).to_date,
#             user: user
#           }) { double(perform: true, link: "link") }
#           result
#         end
#
#         it "should execute generator" do
#           generator = double(perform: "link")
#           allow(ReportGenerator).to receive(:new) { generator }
#           expect(generator).to receive(:perform)
#           result
#         end
#
#         it "should return link of generated report" do
#           generator = double(perform: "link")
#           allow(ReportGenerator).to receive(:new) { generator }
#           expect(result["data"]["generateReport"]["link"]).to eq('link')
#         end
#       end
#     end
#   end
# end
