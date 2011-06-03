class User < ActiveRecord::Base
  validates_acceptance_of :terms_and_conditions

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :postal_code, :country, :mla_updates, :remember_me
  # Connects this user object to Blacklights Bookmarks and Folders. 
  include Blacklight::User

  acts_as_authorization_subject  :association_name => :roles
  acts_as_tagger

  def to_s
    email
  end

end
