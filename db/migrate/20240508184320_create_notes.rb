class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.string :title, null:false
      t.text :content, null:false
      t.integer :note_type, null:false, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
