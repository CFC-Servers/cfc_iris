class CreateApiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :api_tokens do |t|
      t.string :key, null: false
      t.boolean :active, default: true
      t.string :description

      t.timestamps
    end
  end
end
