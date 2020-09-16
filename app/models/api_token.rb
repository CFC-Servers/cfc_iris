class ApiToken < ApplicationRecord
  default_scope { where(active: true) }
  scope :inactive, -> { where(active: false) }

  before_create do
    self.uuid ||= SecureRandom.uuid
  end
end
