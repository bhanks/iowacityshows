Feature: user views todays events

	As a user
	I want to view events occurring today
	So that I know what's happening tonight
	
Scenario: view today's events

	Given there is an event occurring today
	When I look for today events
	Then I should see the event occurring today