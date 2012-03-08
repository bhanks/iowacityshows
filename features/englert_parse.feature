#START:title_and_narrative
Feature: Scrape the same block from Englert consistently

	As a system
	I want to scrape the same block from the Englert every time
	So that when I compare new scrapes I can find new data
#END:title_and_narrative

#START:scenario
	Scenario: Scrape the correct block
		Given I have a page to scrape twice
		When I pull the block out of those pages
		Then I should have the same block
#END:scenario