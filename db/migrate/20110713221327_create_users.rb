class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :jid, :limit => 100, :null => false
    end
    add_index :users, :jid, :unique => true
  end

  def self.down
    drop_table :users
  end
end
