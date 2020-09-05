class CreateApiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :api_tokens, id: false do |t|
      t.string :key, primary_key: true
      t.string :description
      t.boolean :active

      t.timestamps
    end
  end
end
