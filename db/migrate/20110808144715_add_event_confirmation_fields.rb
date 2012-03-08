class AddEventConfirmationFields < ActiveRecord::Migration
  def self.up
    add_column :events, :confirmed, :integer
    add_column :events, :scraped_name, :string
    add_column :events, :marker, :string
    add_column :events, :url, :string
  end

  def self.down
    remove_column :events, :confirmed
    remove_column :events, :scraped_name
    remove_column :events, :marker
    remove_column :events, :url
  end
end
