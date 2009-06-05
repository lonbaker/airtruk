class MachinesShellScriptsHabtm < ActiveRecord::Migration
  def self.up
    create_table :machines_shell_scripts, :id => false do |t|
      t.integer :machine_id, :shell_script_id
    end
    add_index :machines_shell_scripts, :machine_id
    add_index :machines_shell_scripts, :shell_script_id
  end
  def self.down
    drop_table :machines_shell_scripts
  end
end
