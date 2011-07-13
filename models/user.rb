class User < ActiveRecord::Base
  validates_uniqueness_of :jid
  has_many :notes
  has_many :tags, :through => :notes
end
