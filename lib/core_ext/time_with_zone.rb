class ActiveSupport::TimeWithZone
  def to_epoch
    Time.zone.parse(self.to_s).to_i
  end

  def to_epoch_beginning_of_day
    Time.zone.parse(self.to_s).beginning_of_day.to_i
  end
end
