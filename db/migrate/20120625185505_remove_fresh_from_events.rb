class RemoveFreshFromEvents < ActiveRecord::Migration
  def self.up
  	remove_column :events, :fresh
  end

  def self.down
  end
end
