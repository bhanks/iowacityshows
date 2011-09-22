class AddRemoveOnToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :remove_on, :datetime
  end

  def self.down
    remove_column :posts, :remove_on
  end
end
