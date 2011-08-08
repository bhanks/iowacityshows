class AddScrapedAgeToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :scraped_age, :string
  end

  def self.down
    remove_column :events, :scraped_age
  end
end
