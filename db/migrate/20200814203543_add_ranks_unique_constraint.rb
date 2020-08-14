class AddRanksUniqueConstraint < ActiveRecord::Migration[5.2]
  def change
    add_index :ranks, [:realm, :user_id], :unique => true
  end
end
