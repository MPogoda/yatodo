# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Rails::env = 'production'
Yatodo::Application.initialize!