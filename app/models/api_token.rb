class ApiToken < ApplicationRecord
  default_scope where(active: true)
  scope :inactive, -> { where(active: false) }
end
