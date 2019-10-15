module Helpers
  def encode_id(object)
    GraphQL::Schema::UniqueWithinType.encode(object.class.to_s, object.id)
  end
end

RSpec.configure do |config|
  config.include Helpers
end
