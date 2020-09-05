class CreateApiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :api_tokens, id: :uuid do |t|
      t.string :description
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
