Given /^I have an event with one price$/ do
  e = Event.create!(:name=>"One Price")
  p = Price.create!(:amount=>"5",:description=>"Door",:event_id=>e.id)

end

When /^I view that event$/ do
  @event = Event.find_by_name("One Price")
end

Then /^I should be given the event price with a description$/ do
  @event.prices.count == 1
  price = @event.prices
  price.first.amount.should == "5"
  Venue.destroy_all
  Event.destroy_all
  Price.destroy_all
end

#####

Given /^I have an event in the past associated with a venue and a price$/ do
  v = Venue.create!(:name=>"V")
  e = Event.create!(:name=>"Flush", :begins_at=>Date.today-1, :venue_id=>v.id)
  @e_id = e.id
  #e.venue.name.should == "V"
  p = Price.create!(:amount=>"5",:event_id=>e.id)
  @p_id = p.id
end

When /^I flush the past events for that venue$/ do
  v = Venue.find_by_name("V")
  v.events.past.should_not == []
  v.flush_events
  
end

Then /^the price should be deleted as well$/ do
  v = Venue.find_by_name("V")
  #v.events.past.count.should == 0
  #Price.all.should == []
  Event.exists?(@e_id).should == false
  Price.exists?(@p_id).should == false
  Venue.destroy_all
  Event.destroy_all
  Price.destroy_all
end
