# frozen_string_literal: true

class DropUserIds < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :discord_id
    remove_column :users, :steam_id
  end
end
