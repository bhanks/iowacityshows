class FlattenPrices < ActiveRecord::Migration
  def self.up
  	drop_table :prices
  	add_column :events, :price, :string
  end

  def self.down
  	create_table :prices do |t|
      t.string :amount
      t.string :description
      t.integer :event_id
      t.timestamps
    end
  end
end
