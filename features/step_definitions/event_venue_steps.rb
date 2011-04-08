#####
Given /^I am creating an event$/ do
  @event = Event.create(:name => "Test", :venue_id => 1)
end

When /^I save the event$/ do
  @event.save
end

Then /^the event should have a venue$/ do
  @event.venue_id.should == 1
end

#####
Given /^I have created an event with a date MM\/DD\/YYYY$/ do
  Event.create(:name=>'ExAM', :date=>"2011-3-25".to_date)
end

When /^I look for an event on that date$/ do
  @event = Event.find(:first, :conditions => {:name => "ExAM"})
end

Then /^I should find one event$/ do
  @event.nil?.should == false
end


#####
Given /^there is an event occurring today$/ do
  Event.create!(:name=>'Tday', :date => Date.today)
end

When /^I look for today events$/ do
  @event = Event.today
end

Then /^I should see the event occurring today$/ do
  @event.first.name.should == "Tday"
end