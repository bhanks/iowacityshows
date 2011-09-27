#START:title_and_narrative
Feature: Scraping the same post only updatess when content_interior block changes

	As a system
	I want to eliminate updating posts excessively
	So that when 
#END:title_and_narrative

#START:scenario
	Scenario: Update only on content change
		Given I scrape the englert events
		When I scrape them again
		Then I should have no new events
#END:scenario