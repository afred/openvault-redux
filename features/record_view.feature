@record
Feature: Record View
  In order to see the record media and metadata
  As a user
  I want to see the appropriate information on the record page

    Scenario: Metadata-only record
        Given I am on the document page for id sbro01401-15-annual-gala-celebration
        Then I should see "15 Annual Gala Celebration" within ".document_heading"

    Scenario: Video record
        Given I am on the document page for id 95e868-17th-parallel-wrecked-landscape
        Then I should see a video player as a primary datastream

    Scenario: Video with transcript record
        Given I am on the document page for id bee5c6-berlin-story-the-part-i

    Scenario: Audio record
        Given I am on the document page for id 484665-boston-symphony-audience-learns-of-the-death-of-jfk 
        Then I should see an audio player as a primary datastream

    Scenario: Audio with transcript record
        Given I am on the document page for id 6c7004-interview-with-richard-c-holbrooke-1-1983
        Then I should see an audio player as a primary datastream
        And I should see "North Vietnam's centralization of power"


