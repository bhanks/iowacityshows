#START:title_and_narrative
Feature: Flushing Events Deletes Associated Price

	As a user
	I want prices associated with events to be deleted when events are flush
	So that the database remains clean
#END:title_and_narrative

#START:scenario
	Scenario: Flushing Events Deletes Associated Prices
		Given I have an event in the past associated with a venue and a price
		When I flush the past events for that venue
		Then the price should be deleted as well
#END:scenario