#START:title_and_narrative
Feature: user creates an unconfirmed event

	As a user
	I want all newly created events to be unconfirmed
	So that I can confirm the event myself
#END:title_and_narrative

#START:scenario
	Scenario: Create an Unconfirmed event
		Given an unconfirmed event is created
		When I look at that event later
		Then the event should remain unconfirmed
#END:scenario