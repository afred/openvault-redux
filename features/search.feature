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
