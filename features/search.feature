@search
Feature: Search
  In order to find documents
  As a user
  I want to enter terms

    Scenario: Search Page
        When I go to the catalog page
        Then I should see a search field
        And I should see a "search" button
        And I should see a stylesheet

    Scenario: Submitting a Search
        When I go to the catalog page
        And I fill in "q" with "Holbrooke"
        And I press "search"
        Then I should be on "the catalog page"
        And I should see an rss discovery link
        And I should see an atom discovery link
        And I should see opensearch response metadata tags
        And I should see "Sort by"
        And I should see "1."
        And I should see "2."
        And I should see "3."

    Scenario: Results Page Shows Title, Description and Thumbnails
        Given I have done a search with term "Holbrooke"
        Then I should see "Interview with"
        And I should see "Between 1963-1966 Richard C. Holbrooke"

    Scenario: Results Page Shows Search Highlights
        Given I have done a search with term "Holbrooke"
        Then I should see "Holbrooke" within "em"

    Scenario: Results Page Date Created
        Given I have done a search with term "Holbrooke"
        Then I should see "Date Created"
        And I should see "07/07/1983" 

    Scenario: Results Page Media
        Given I have done a search with term "Holbrooke"
        Then I should see "Media"
        And I should see "Audio" 

    Scenario: Results Page Program
        Given I have done a search with term "Holbrooke"
        Then I should see "Program"
        And I should see "Vietnam: A Television History" 
    
    Scenario: Click on a record
        Given I have done a search with term "Holbrooke"
        When I follow "Interview with Richard C. Holbrooke [1], 1983" 
        Then I should be on the record page

    Scenario: Click on a record thumbnail
        Given I have done a search with term "Holbrooke"
        When I follow ""
        Then I should be on the record page
