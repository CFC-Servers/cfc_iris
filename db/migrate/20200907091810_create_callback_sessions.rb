class CreateCallbackSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :callback_sessions do |t|
      t.boolean :active
      t.json :results
      t.json :params
      t.string :ip
      t.string :uuid
      t.string :referrer

      t.timestamps
    end

    add_index :callback_sessions, :uuid
  end
end
