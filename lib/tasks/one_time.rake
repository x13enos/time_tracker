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

  task "2020_07_29_create_notification_settings_for_users" => :environment do
    User.all.each do |user|
      user.create_notification_settings
    end
  end

  task "2020_08_09_create_roles_in_accociated_table" => :environment do
    UsersWorkspace.update_all(role: "staff")
  end

  task "2021_06_07_update_workspace_id_for_time_records" => :environment do
    TimeRecord.where.not(project_id: nil).each do |time_record|
      time_record.update_column(:workspace_id, time_record.project.workspace_id)
    end
  end
end
