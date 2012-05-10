class User < ActiveRecord::Base
	has_many :participants
	has_many :events, :through => :participants
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable
  devise :omniauthable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
  :address, :city, :state, :country, :image, :phone, :website1, :website2, :contact_number, :name
  # attr_accessible :title, :body
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = User.where(:email => data.email).first
      user.update_attributes(:name => data.name, :image => access_token["info"]["image"], :website1 => data.link)
      user
    else # create a user with a stub password
      User.create!(:email => data.email, :password => Devise.friendly_token[0, 20], :name => data.name, :image => access_token["info"]["image"], :website1 => data.link)
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
      end
    end
  end
end
