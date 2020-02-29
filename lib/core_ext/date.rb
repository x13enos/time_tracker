class Date
  def to_epoch
    Time.zone.parse(self.to_s).to_i
  end
end
