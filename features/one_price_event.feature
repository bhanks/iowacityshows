#START:title_and_narrative
Feature: Event has a single price

	As a user
	I want all events to have at least one price
	So that I know how much it costs
#END:title_and_narrative

#START:scenario
	Scenario:Create an Event with One Price
		Given I have an event with one price
		When I view that event
		Then I should be given the event price with a description
#END:scenario