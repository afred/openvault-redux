@search
Feature: Search Results
  In order to find documents
  As a user
  I want to enter terms, select fields, and select number of results per page
  
    Scenario: Empty query
      Given I am on the catalog page
      When I fill in the search box with ""
      And I press "search"
      Then I should get at least 1 result




        
