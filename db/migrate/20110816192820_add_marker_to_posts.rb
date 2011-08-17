class AddMarkerToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :marker, :string
  end

  def self.down
    remove_column :posts, :marker
  end
end
