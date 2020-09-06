# frozen_string_literal: true

class AddRanksUniqueConstraint < ActiveRecord::Migration[5.2]
  def change
    add_index :ranks, %i[realm user_id], unique: true
  end
end
