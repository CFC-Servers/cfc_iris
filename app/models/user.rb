class User < ApplicationRecord
  has_many :identities
  has_many :ranks
end
