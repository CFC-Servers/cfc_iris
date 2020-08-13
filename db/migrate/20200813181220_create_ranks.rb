class CreateRanks < ActiveRecord::Migration[5.2]
  def change
    create_table :ranks do |t|
      t.string :name
      t.string :realm
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
