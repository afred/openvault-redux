@search
Feature: Search
    In order to efficiently browse documents 
    As a user
    I want to specify a per-page count

    Scenario: Changing per page number 
        Given I have done a search with term "vietnam"
        When I select "20" from "per_page"
        And I press "update" 
        Then I should be on "the catalog page"
        And I should see "You searched for:"
 	And I should see "vietnam"
