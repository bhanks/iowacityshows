class AlterAdmissionType < ActiveRecord::Migration
  def self.up
    remove_column :events, :date
    remove_column :events, :price
    add_column :events, :price, :string
    add_column :events, :begins_at, :date
  end

  def self.down
    remove_column :events, :begins_at
    remove_column :events, :price
    add_column :events, :date, :date
    add_column :price, :integer
  end
end
