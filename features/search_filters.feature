Feature: Search Filters
  In order constrain searches
  As a user
  I want to filter search results via facets on the search page
  
  Scenario: Filter a blank search
    Given I am on the catalog page
    When I follow "Arts"
    Then I should see the applied facet "Category" with the value "Arts"
    When I follow "Video art"
    Then I should get exactly 38 results
    And I should see the applied facet "Category" with the value "Humanities)"
    And I should see the applied facet "Topic" with the value "Video art"
  
  Scenario: Search with no filters applied
    When I am on the catalog page
    And I fill in "q" with "bod"
    And I press "search"
    Then I should be on "the catalog page"
    And I should see "We did not find any matches for this search."
    And I should not see "Filters applied"
  
  Scenario: Apply and remove filters
    Given I am on the catalog page
    When I follow "Civil rights"
    Then I should see the applied facet "Topic" with the value "Civil rights"
    When I follow "Remove constraint Civil rights: Civil rights"
    And I should not see "Filters applied"

  Scenario: Changing search term should retain filters
    When I am on the catalog page
    And I fill in "q" with "history"
    And I press "search"
    Then I should be on "the catalog page"
    When I follow "Civil rights"
    Then I should see the applied facet "Topic" with the value "Civil rights"
    When I fill in "q" with "buses"
    And I press "search"
    Then I should be on "the catalog page"
    Then I should see the applied facet "Topic" with the value "Civil rights"


  Scenario: Changing search term should retain filters
    When I am on the catalog page
    And I fill in "q" with "history"
    And I press "search"
    Then I should be on "the catalog page"
    When I follow "Civil rights"
    Then I should see the applied facet "Topic" with the value "Civil rights"
    When I fill in "q" with "buses"
    And I choose "All Records"
    And I press "search"
    Then I should be on "the catalog page"
    Then I should not see the applied facet "Topic" with the value "Civil rights"
  
