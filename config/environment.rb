# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
Rails.application.eager_load!

#ActionMailer::Base.smtp_settings = {
#  user_name: Rails.application.credentials.sendgrid[:username],
#  password: Rails.application.credentials.sendgrid[:password],
#  domain: 'cfcservers.org',
#  address: 'smtp.sendgrid.net',
#  port: 465,
#  authentication: :plain,
#  enable_starttls_auto: true
#}
