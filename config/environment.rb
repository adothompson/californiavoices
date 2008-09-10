
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  # Cookie sessions (limit = 4K)
  config.action_controller.session = {
    :session_key => '_californiavoices',
    :secret      => '3d2bfc4c9b0e0e8410833a8533af8a24537759b36d86ca2965acbf2f1dc3be86a45ebe29f379f36b0af8d9283defae16369193f0c22a799bd20e2f0decded6ba'
  }
  config.action_controller.session_store = :active_record_store

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # Gem dependencies
  config.gem 'will_paginate', :version => '~> 2.2.2'
  config.gem 'colored', :version=> '1.1'
  config.gem 'youtube-g', :version=> '0.4.1', :lib=>'youtube_g'
  config.gem 'uuidtools', :version=> '1.0.3'
  config.gem 'acts_as_ferret', :version=> '0.4.3'
  config.gem 'ferret', :version=> '0.11.6' # not included in build
  config.gem 'hpricot', :version=>"0.6.161" # not inlcuded in build
  config.gem 'mocha', :version=>"0.5.6"
  config.gem 'redgreen', :version=>"1.2.2"
  config.gem 'gcnovus-avatar', :version=>"0.0.7", :lib => 'avatar'
  # TODO: for backgroundrb - maybe doesn't need to be included here?
  #config.gem 'chronic', :version => "0.2.3"
  #config.gem 'packet', :version => "0.1.12"
  # amazon web services
  config.gem 'aws-s3', :lib => 'aws/s3'
  # flvtool2
  #config.gem 'flvtool2', :version => "1.0.6"
  # rvideo
  #config.gem 'rvideo'  

end

