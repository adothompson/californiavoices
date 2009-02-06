
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.load_paths += %w(discussion).collect{|dir|"#{RAILS_ROOT}/app/models/#{dir}"}

  # Cookie sessions (limit = 4K)
  # WARNING: You MUST generate a new secret (use "rake secret") and add it below!
  config.action_controller.session = {
    :session_key => '_californiavoices',
    :secret      => '3d2bfc4c9b0e0e8410833a8533af8a24537759b36d86ca2965acbf2f1dc3be86a45ebe29f379f36b0af8d9283defae16369193f0c22a799bd20e2f0decded6ba'
  }
  config.action_controller.session_store = :active_record_store

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  
  # Gem dependencies
  config.gem 'will_paginate', :version => '~> 2.2.2'
  config.gem 'colored', :version=> '1.1'
  # config.gem 'youtube-g', :version=> '0.4.9.9', :lib=>'youtube_g'
  config.gem 'uuidtools', :version=> '1.0.4'
  config.gem 'hpricot', :version=>"0.6.164" # not inlcuded in build
  config.gem 'mocha', :version=> '0.9.3'
  config.gem 'redgreen', :version=>"1.2.2" unless ENV['TM_MODE']
  config.gem 'gcnovus-avatar', :version=>"0.0.7", :lib => 'avatar'
  config.gem 'RedCloth', :version=>"4.1.1", :lib => 'redcloth'
  # amazon web services
  config.gem 'aws-s3', :lib => 'aws/s3'
end

Less::JsRoutes.generate!
