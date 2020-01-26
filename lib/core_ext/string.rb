class String
  def convert_to_date_time
    Time.zone.at(self.to_i)
  end

  def convert_to_date
    convert_to_date_time.to_date
  end
end
