class AddTypeToVenues < ActiveRecord::Migration
  def self.up
    add_column :venues, :type, :string
  end

  def self.down
    remove_column :venues, :type
  end
end
