class Identity < ApplicationRecord
  belongs_to :user, dependent: :destroy
end
