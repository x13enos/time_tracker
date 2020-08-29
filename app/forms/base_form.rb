class BaseForm
  include ActiveModel::Model
  extend ActiveModel::Callbacks

  def save
    ActiveRecord::Base.transaction do
      begin
        if valid?
          persist!
          true
        else
          false
        end
      rescue => e
        Raven.capture_exception(e)
        false
      end
    end
  end
end
