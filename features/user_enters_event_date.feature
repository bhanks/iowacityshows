Feature: User Enters Event's Date as MM/DD/YYYY

	As a user
	I want the event's date represented as MM/DD/YYYY
	So that I know when an event is occurring
	
Scenario: save event date as MM/DD/YYYY

	Given I have created an event with a date MM/DD/YYYY
	When I look for an event on that date
	Then I should find one event