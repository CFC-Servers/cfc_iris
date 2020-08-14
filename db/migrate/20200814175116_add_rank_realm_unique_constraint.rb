class AddRankRealmUniqueConstraint < ActiveRecord::Migration[5.2]
  def change
    add_index :ranks, [:name, :realm, :user_id], :unique => true
  end
end
