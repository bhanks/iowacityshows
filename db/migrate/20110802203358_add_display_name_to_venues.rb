class AddDisplayNameToVenues < ActiveRecord::Migration
  def self.up
    add_column :venues, :display_name, :string
  end

  def self.down
    remove_column :venues, :display_name
  end
end
