class CreatePrices < ActiveRecord::Migration
  def self.up
    create_table :prices do |t|
      t.string :amount
      t.string :description
      t.integer :event_id
      t.timestamps
    end
  end

  def self.down
    drop_table :prices
  end
end
