class CleanUpEventModel < ActiveRecord::Migration
  def self.up
  	remove_column :events, :scraped_age
  	remove_column :events, :scraped_description
  	remove_column :events, :post_id
  	remove_column :events, :scraped_name
  	remove_column :events, :confirmed
  end

  def self.down
  end
end
