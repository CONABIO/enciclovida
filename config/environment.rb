# Load the rails application.
require File.expand_path('../application', __FILE__)

# Initialize the rails application.
Buscador::Application.initialize!

ActionMailer::Base.smtp_settings = {
    :domain => CONFIG.smtp.domain,
    :address => CONFIG.smtp.address,
    #:user_name => CONFIG.smtp.user_name,
    #:password => CONFIG.smtp.password,
    #:port => CONFIG.smtp.port,
    :authentication => :plain,
    :enable_starttls_auto => true
}
