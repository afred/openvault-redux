class User < ActiveRecord::Base
  include Blacklight::User::UserGeneratedContent
  include Blacklight::User::Authlogic

  acts_as_authorization_subject  :association_name => :roles

end
