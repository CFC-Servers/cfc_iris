Sentry.init do |config|
  config.dsn = 'https://ddde46248b0f42bcb89372ffe3dcb41b@o380324.ingest.sentry.io/5205995'
  config.breadcrumbs_logger = [:active_support_logger]

  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  config.traces_sample_rate = 0.5
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end
