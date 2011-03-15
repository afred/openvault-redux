@search
Feature: Search
    In order to efficiently discover documents
    As a user
    I want to sort found documents

    Scenario: Default sort order
        Given I have done a search with term "vietnam"
        Then I should be on the catalog page
        and I should see "relevance"

    Scenario: Changing sort order 
        Given I have done a search with term "vietnam"
        When I select "title" from "sort"
        And I press "sort results" 
        Then I should be on "the catalog page"
        And I should see "You searched for:"
        And I should see "vietnam"
        Then I should see "BU Theology students talk about the Persian Gulf War" before "Interview with Arthur Egendorf, 1983"

