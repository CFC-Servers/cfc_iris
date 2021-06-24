class Rank < ApplicationRecord
  belongs_to :user, dependent: :destroy
end
