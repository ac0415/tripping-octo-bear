class User < ActiveRecord::Base
	has_many :participants
	has_many :events, :through => :participants
	has_many :events
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :omniauthable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
  :address, :city, :state, :country, :image, :phone, :website1, :website2, :contact_number, :name, :screen_name, :latitude, :longitude, :description, :is_organization
  # attr_accessible :title, :body
  
  # Validations
#  validates :email, presence: true
#  validates :email, uniqueness: true
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = User.where(:email => data.email).first
      user.update_attributes(:name => data.name, :image => access_token["info"]["image"] )
      user.update_attributes( :website2 => data.link ) unless user.website1 == data.link
      user
    else # create a user with a stub password
      User.create!(:email => data.email, :password => Devise.friendly_token[0, 20], :name => data.name, :image => access_token["info"]["image"], :website1 => data.link, :is_organization => false)
    end
  end

	def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = User.where(:name => data.name).first
      user.update_attributes(:name => data.name, :image => data.profile_image_url, :screen_name => data.screen_name)
      user.update_attributes( :website2 => access_token["info"]["urls"]["Twitter"] ) unless user.website1 == access_token["info"]["urls"]["Twitter"]
      user
    else # create a user with a stub password
      User.create!(:screen_name => data.screen_name, :password => Devise.friendly_token[0, 20], :name => data.name, :image => data.profile_image_url, :website1 => access_token["info"]["urls"]["Twitter"], :is_organization => false)
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
     elsif data = session["devise.twitter_data"] && session["devise.twitter_data"]["extra"]["raw_info"]
        user.screen_name = data["screen_name"]
      end
    end
  end
end
