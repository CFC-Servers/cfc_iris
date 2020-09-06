# frozen_string_literal: true

class AddIndexPairToIdentities < ActiveRecord::Migration[5.2]
  def change
    add_index :identities, %i[platform identifier], unique: true
  end
end
