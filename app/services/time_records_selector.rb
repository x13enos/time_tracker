class TimeRecordsSelector

  def initialize(params, user)
    @params = params
    @user = user
  end

  def perform
    return {
      projects: projects,
      total_spent_time: count_total_spent_time,
      converted_dates: converted_dates,
      grouped_time_records: group_time_records
    }
  end

  private
  attr_reader :params, :user

  def converted_dates
    @converted_dates ||= {
      from: params[:from_date].to_date,
      to: params[:to_date].to_date
    }
  end

  def user_time_records
    @user_time_records ||= user.nil? ? [] : get_time_records
  end

  def get_time_records
    user.time_records
      .joins(:project)
      .joins(:user)
      .where("assigned_date BETWEEN ? AND ?", converted_dates[:from], converted_dates[:to])
      .order(created_at: :desc)
  end

  def group_time_records
    user_time_records.group_by do |time_record|
      regexp = time_record.project.regexp_of_grouping
      if regexp
        /#{regexp}/.match(time_record.description).to_a.first || time_record.id
      else
        time_record.id
      end
    end.values
  end

  def count_total_spent_time
    user_time_records.empty? ? 0.0 : user_time_records.sum(:spent_time)
  end

  def projects
    user_time_records.map(&:project).uniq
  end
end
