class AddFreshToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :fresh, :string, :default => "true"
  end

  def self.down
    remove_column :events, :fresh
  end
end
