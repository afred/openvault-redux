@search
Feature: Search
  In order to find documents
  As a user
  I want to enter terms, select fields, and select number of results per page
  
  Scenario: Search Page
    When I go to the catalog page
    Then I should see a search field
    And I should see a stylesheet
  
  Scenario: Submitting a Search
    When I am on the catalog page
    And I fill in "q" with "history"
    And I press "search"
    Then I should be on "the catalog page"
    And I should see an rss discovery link
    And I should see an atom discovery link
    And I should see opensearch response metadata tags
    And I should see "Filters applied:"
    And I should see "Displaying items 1 - 10 of"

  Scenario: Results Page Has Sorting Available
    Given I am on the catalog page
    And I fill in "q" with "history"
    When I press "search"
    Then I should see select list "select#sort" with field labels "relevance, title, year"
  
  Scenario: Can clear a search
    When I am on the catalog page
    And I fill in "q" with "history"
    And I press "search"
    Then I should be on "the catalog page"
    When I follow "Arts"
    Then the "q" field should contain "history"
    And I should see "Arts" within "#appliedParams"
    When I fill in "q" with "vietnam"
    And I choose "All Records"
    And I press "search"
    Then I should be on "the catalog page"
    And I should not see "Arts" within "#appliedParams"
