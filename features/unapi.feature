@unapi
Feature: unAPI
  In order to discover underlying document data
  As a user
  I want to use an unAPI endpoint
  
  Scenario: Search Page has unAPI discovery link and microformats
    When I go to the catalog page
    And I fill in the search box with ""
    And I press "search"
    Then I should see an unAPI discovery link 
    And I should see a "abbr" element with "class" = "unapi-id" exactly 10 times

  Scenario: Document Page has an unAPI discovery link and microformat
    Given I am on the document page for id vietnam-6c7004-interview-with-richard-c-holbrooke-1-1983
    Then I should see an unAPI discovery link
    And I should see a "abbr" element with "class" = "unapi-id" at least 1 time

  Scenario: unAPI endpoint with no parameters
    When I go to the unAPI endpoint
    Then I should see a "format" element with "name" = "oai_dc_xml" exactly 1 time

  Scenario: Request list of formats for an object
    When I go to the unAPI endpoint for "vietnam-6c7004-interview-with-richard-c-holbrooke-1-1983"
    Then I should see a "format" element with "name" = "pbcore" exactly 1 time
    Then I should see a "format" element with "name" = "oai_dc_xml" exactly 1 time

  Scenario: Request format of object
    When I go to the unAPI endpoint for "vietnam-6c7004-interview-with-richard-c-holbrooke-1-1983" with format "oai_dc_xml"
    Then I should see "Interview with Richard C. Holbrooke [1], 1983"
