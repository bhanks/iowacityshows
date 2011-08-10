
#####
Given /^there is an event occurring today$/ do
  Event.create!(:name=>'Tday', :begins_at => Date.today)
end

When /^I look for today events$/ do
  @event = Event.today
end

Then /^I should see the event occurring today$/ do
  @event.first.name.should == "Tday"
end

#####
Given /^an unconfirmed event is created$/ do
  Event.create!(:name=>'Unconfirmed', :confirmed=>0)
end

When /^I look at that event later$/ do
  @event = Event.find_by_name("Unconfirmed")
end

Then /^the event should remain unconfirmed$/ do
  @event.confirmed.should == 0
end



