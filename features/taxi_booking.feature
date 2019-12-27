Feature: Booking
  As a customer
  Such that I go to destination
  I want to arrange a taxi ride

  Scenario: Booking via STRS' web page (ACCEPTED)
    Given the following taxis are on duty
          | username | location	     | status    |
          | peeter88 | Juhan Liivi 2 | busy      |
          | juhan85  | Kalevi 4      | available |
    And I want to go from "Juhan Liivi 2" to "Muuseumi tee 2"
    And I open STRS' web page
    And I enter the booking information
    When I summit the booking request
    Then I should receive a confirmation message


Feature: Taxi
  As a customer
  Such that I go to destination
  I want to arrange a taxi ride
    Scenario: Booking via STRS' web page (OFF-DUTY)
        Given the following taxis are on duty
            | username  | location  | status |
            | juhan85   | Kaubamaja | OFF-DUTY   |
            | peeter88  | Kaubamaja | OFF-DUTY   |
        And I want to go from "Liivi 2" to "Lõunakeskus"
	    And I open STRS' web page
	    And I enter the booking information
	    When I summit the booking request
      And all drivers are OFF-DUTY
	    Then I should receive a rejection message

Feature: Allocation
  As a taxi driver
  I want to accept customer request
  Scenario: Booking via STRS' web page (ALLOCATED)
    And customer want to go from "Juhan Liivi 2" to "Muuseumi tee 2"
    And I open STRS' web page
    And I accept taxi ride