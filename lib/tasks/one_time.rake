namespace :one_time do
  desc "2020-05-02 update assigned date for time records"
  task "2020_05_02_update_assigned_date_for_time_records" => :environment do
    TimeRecord.all.each do |time_record|
      timezone = time_record.user.timezone
      time_record.update(
        assigned_date: time_record.assigned_date.in_time_zone(timezone).to_date
      )
    end
  end
end
