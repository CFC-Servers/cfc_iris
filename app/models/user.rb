class User < ApplicationRecord
  has_many :identities, dependent: :destroy
  has_many :ranks, dependent: :destroy

  private

  def consume_users!(*users)
    Rails.logger.log("[User ##{id}] consuming #{users.count} users [#{users.pluck(:id)}]")
    identities = users.map(&:identities)
    identities.update_all(user_id: id)
    users.destroy_all
  end
end
