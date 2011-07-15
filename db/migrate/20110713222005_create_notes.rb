class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.integer :user_id, :null => false
      t.integer :tag_id, :null => false
      t.string :name, :limit => 200, :null => false
    end
    add_index :notes, :user_id
    add_index :notes, :tag_id
  end

  def self.down
    drop_table :notes
  end
end
