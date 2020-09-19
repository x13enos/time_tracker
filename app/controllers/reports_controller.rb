class ReportsController < ApplicationController
  def show
    report = Report.find_by(uuid: params[:id])
    send_data(report.file.download,
              filename: report.file.filename.to_s,
              type: report.file.content_type,
              disposition: 'inline')
  end
end
