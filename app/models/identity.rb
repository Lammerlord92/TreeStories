class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_by_oauth(auth)
    identity = Identity.where({uid: auth.uid, provider: auth.provider}).last
    identity
  end
end
