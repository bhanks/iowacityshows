#START:title_and_narrative
Feature: user saves event venue

	As a user
	I want to save an event's venue
	So that I know where the event occurs
#END:title_and_narrative

#START:scenario

	Scenario: save event venue
		Given I am creating an event
		When I save the event
		Then the event should have a venue
#END:scenario