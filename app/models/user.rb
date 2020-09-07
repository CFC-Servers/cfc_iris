class User < ApplicationRecord
  has_many :identities, dependent: :destroy
  has_many :ranks, dependent: :destroy

  private

  def consume_users!(*users)
    identities = users.map(&:identities)
    identities.update_all(user_id: id)
    users.destroy_all
  end
end
