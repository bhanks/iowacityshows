Feature: user requests name

	As a user
	I want the name of the event as it was scraped if no modified name exists
	So that I have some version of the name
	
Scenario: view today's events

	Given there is an event with the scraped name 'Scraped' that has no modified name
	When I look at the name for that event
	Then I should see the scraped name