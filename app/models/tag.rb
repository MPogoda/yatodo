class Tag < ActiveRecord::Base
  validates_uniqueness_of :jid
  has_many :notes
end
