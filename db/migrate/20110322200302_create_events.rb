class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer "venue_id"
      t.string "name"
      t.string "time"
      t.string "description"
      t.integer "price"
      t.string "age_restriction"
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
