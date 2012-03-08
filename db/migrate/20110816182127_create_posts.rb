class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :url
      t.text :block
      t.integer :venue_id
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
