@search
Feature: Search
    In order to efficiently discover documents
    As a user
    I want to sort found documents

    Scenario: Default sort order
        Given I have done a search with term "vietnam"
        Then the "search" field should contain "vietnam"
        And I should see "relevance"

    Scenario: Changing sort order 
        Given I have done a search with term "vietnam"
        When I select "title" from "sort"
        And I press "sort results" 
        Then the "search" field should contain "vietnam"
        And I should see "You searched for:"
        And I should see "vietnam"
        And I should see select list "select#sort" with "title" selected
        And I should get ckey "95e868-17th-parallel-wrecked-landscape" before ckey "485-acquisition-radar-against-enemy-mortars-dong-tam"
        And I should see "17th Parallel Wrecked Landscape" before "Acquisition radar (against enemy mortars); Dong Tam."
