if %w(staging production).include?(Rails.env)
  Raven.configure do |config|
    config.dsn = ENV["SENTRY_URL"]
  end
end
