class AddShellScripts < ActiveRecord::Migration
  def self.up
    create_table :shell_scripts do |t|
      t.string :configuration_name, :filename, :owner, :mode
      t.text :contents
    end
    add_index :shell_scripts, :configuration_name, :unique => true
    add_index :shell_scripts, :filename
  end
  def self.down
    drop_table :shell_scripts
  end
end
