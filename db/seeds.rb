# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => "Chicago" }, { :name => "Copenhagen" }])
#   Mayor.create(:name => "Daley", :city => cities.first)

Venue.create!(:name=>"Gabe's", :address=>"330 East Washington Street", :site_url=>"http://www.iowacitygabes.com/", :display_name=>"Gabe's")
Venue.create!(:name=>"The Mill", :address=>"120 E. Burlington Street", :site_url=>"http://icmill.com/", :display_name=>"Mill")
Venue.create!(:name=>"Blue Moose Taphouse", :address=>"211 Iowa Ave", :site_url=>"http://bluemooseic.com/", :display_name=>"Blue Moose")
Venue.create!(:name=>"The Yacht Club", :address=>"13 S Linn St", :site_url=>"http://www.iowacityyachtclub.org/", :display_name=>"Yacht Club")
Venue.create!(:name=>"The Englert", :address=>"221 East Washington Street", :site_url=>"http://www.englert.org/", :display_name=>"Englert")
