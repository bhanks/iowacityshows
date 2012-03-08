class RemovePriceColumnFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :price
  end

  def self.down
    add_column :events, :price, :string
  end
end
