@record
Feature: Record View
  In order to find similar records
  As a user
  I want to see the appropriate information in the related content section

  Scenario: Intelligent matching
    When I am on the document page for id vietnam-369379-interview-with-bill-d-moyers-1981
    And I should see "Interview with Bill D. Moyers, 1981"
    And I should not see "Bill Cosby"

    Scenario: More parts
        When I am on the document page for id wpna-c8416a-interview-with-jimmy-carter-1987-part-1-of-2
        Then I should see "Interview with Jimmy Carter, 1987 [Part 1 of 2]"
        And I should see "Interview with Jimmy Carter, 1987 [Part 2 of"
