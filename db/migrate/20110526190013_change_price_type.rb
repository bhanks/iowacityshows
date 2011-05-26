class ChangePriceType < ActiveRecord::Migration
  def self.up
    remove_column :events, :price
    add_column :events, :price, :text
  end

  def self.down
    remove_column :events, :price
    add_column :events, :price, :string
  end
end
