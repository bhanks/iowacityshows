class AlterEventTime < ActiveRecord::Migration
  def self.up
    remove_column :events, :begins_at
    add_column :events, :begins_at, :datetime
  end

  def self.down
    remove_column :events, :begins_at
    add_column :events, :begins_at, :date
    
  end
end
