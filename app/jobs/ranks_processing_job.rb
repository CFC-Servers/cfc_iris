class RanksProcessingJob < ApplicationJob
  queue_as :default

  def perform(users, realm, platform)
    rank_rows = []

    Identity.where(identifier: users.keys, platform: platform).find_each do |identity|
      group = users[identity.identifier]['group']
      next unless group

      rank_rows << { name: group, user_id: identity.user_id, realm: realm }
    end

    Rank.import rank_rows, on_duplicate_key_update: [:name], batch_size: 10_000
  end
end
