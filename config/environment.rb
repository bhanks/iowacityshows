# Load the rails application
require File.expand_path('../application', __FILE__)


#config.time_zone = "Central Time"

# Initialize the rails application
Onesheet::Application.initialize!

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :user_name => "app495320@heroku.com",
  :password => "6ywe2peu",
  :domain => "iowacityshows.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}
