# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_openvault-blacklight-app_session',
  :secret      => 'a5b97dacef9907adcbdf9c8a8cabdf4803caaa64ffde9886e2ef591cfabc07af94f276bdbdd8819f6315f398444cf5d03d963161c84783c047a574246a4987d8'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
