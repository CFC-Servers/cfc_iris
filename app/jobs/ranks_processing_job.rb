# frozen_string_literal: true

class RanksProcessingJob < ApplicationJob
  queue_as :default

  def perform(users, realm, platform)
    user_rows = []
    rank_rows = []

    user_identities = Identity.where(identifier: users.keys, platform: platform)
                              .pluck(:identifier, :user_id)
                              .to_h

    users.each do |identifier, group|
      user_id = user_identities[identifier]
      rank = Rank.new(name: group, realm: realm)

      if user_id.nil?
        user = User.new
        identity = Identity.new(identifier: identifier, platform: platform)
        identity.user = user
        rank.user = user

        user.identities << identity
        user.ranks << rank
        user_rows << user
      else
        rank.user_id = user_id
        rank_rows << rank
      end
    end

    User.import user_rows, recursive: true, batch_size: 5_000
    Rank.import rank_rows,
                batch_size: 5_000,
                on_duplicate_key_update: {
                  conflict_target: %i[user_id realm],
                  columns: [:name]
                }
  end
end
