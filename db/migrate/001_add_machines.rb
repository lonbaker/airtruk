class AddMachines < ActiveRecord::Migration
  def self.up
    create_table :machines do |t|
      t.string :hostname
    end
    add_index :machines, :hostname, :unique => true
  end
  def self.down
    drop_table :machines
  end
end
