class AddEventCountToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :event_count, :integer
  end

  def self.down
    remove_column :posts, :event_count
  end
end
