@record
Feature: Record View
  In order to verify the information on the record view (CatalogController#show)
  As a user
  I want to see the appropriate information in context to the records being viewed

  Scenario: Record header
    When I am on the document page for id vietnam-6c7004-interview-with-richard-c-holbrooke-1-1983
    Then I should see "Interview with Richard C. Holbrooke [1], 1983"
    And I should see "Summary"
    And I should see "Topics"
    And I should see "Tags"
    And I should see "Annotations"
    And I should see link rel=alternate tags

    Scenario: Record metadata
    When I am on the document page for id vietnam-6c7004-interview-with-richard-c-holbrooke-1-1983
    Then I should see "Interview with Richard C. Holbrooke [1], 1983"
    And I should see "Media"
    And I should see "Original recording" within ".instantiation"
    And I should see "Source"
    And I should not see "Interview with Richard C. Holbrooke" within ".source"
    And I should see "Date Covered"
    And I should see "Place Covered"
    And I should see "Interviewee"

    Scenario: Record video + transcript
    When I am on the document page for id wpna-c8416a-interview-with-jimmy-carter-1987-part-1-of-2
    Then I should see a video player as a primary datastream 
    And I should see "Transcript" within ".secondary-datastream-container"


    Scenario: Record audio + transcript
    When I am on the document page for id vietnam-6c7004-interview-with-richard-c-holbrooke-1-1983
    Then I should see "Interview with Richard C. Holbrooke [1], 1983"
    And I should see an audio player as a primary datastream 
    And I should see "Transcript" within ".secondary-datastream-container"




