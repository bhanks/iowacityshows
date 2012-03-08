class AddScrapedDescriptionToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :scraped_description, :text
  end

  def self.down
    remove_column :events, :scraped_description
  end
end
