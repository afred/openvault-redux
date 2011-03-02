# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/blacklight/vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  config.plugin_paths += ["#{RAILS_ROOT}/vendor/plugins/blacklight/vendor/plugins"]
  config.gem 'authlogic', :version => '2.1.2'
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "compass", :version => ">= 0.10.6"
  config.gem "nokogiri"
  config.gem "streamly"
  config.gem "sqlite3"
  config.gem "fastercsv"
  config.gem "rest-client", :lib => "rest_client"
  config.gem "acl9"
  config.gem "cql-ruby", :lib => "cql_ruby"
  config.gem "rubytree", :lib => "tree", :version => '0.5.2'
  config.gem "oai"
  require 'open-uri'
  gem "soap4r"
config.gem "acts-as-taggable-on", :source => "http://gemcutter.org", :version => '2.0.0.rc1'
config.gem 'jackdempsey-acts_as_commentable', :lib => 'acts_as_commentable', :source => "http://gems.github.com"
config.gem "acts_as_rateable"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end
