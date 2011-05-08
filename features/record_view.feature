@record
Feature: Record View
  In order to verify the information on the record view (CatalogController#show)
  As a user
  I want to see the appropriate information in context to the records being viewed

  Scenario: Normal record
    Given I am on the document page for id vietnam-6c7004-interview-with-richard-c-holbrooke-1-1983
    And I should see "Interview with Richard C. Holbrooke [1], 1983"
    And I should see "Summary"
    And I should see "Topics"
    And I should see "Tags"
    And I should see "Annotations"
    And I should see link rel=alternate tags

