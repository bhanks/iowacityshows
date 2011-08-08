
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


#####
Given /^there is an event with the scraped name 'Scraped' that has no modified name$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I look at the name for that event$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the scraped name$/ do
  pending # express the regexp above with the code you wish you had
end
