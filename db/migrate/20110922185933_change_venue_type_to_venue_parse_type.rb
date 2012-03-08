class ChangeVenueTypeToVenueParseType < ActiveRecord::Migration
  def self.up
    rename_column :venues, :type, :parse_type
  end

  def self.down
    rename_column :venues, :parse_type, :type
  end
end
