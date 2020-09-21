Raven.configure do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, Rails.env, :SENTRY_DSN)
end
