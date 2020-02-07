class Integer
  def convert_to_date_time
    Time.zone.at(self)
  end

  def convert_to_date
    convert_to_date_time.to_date
  end
end
