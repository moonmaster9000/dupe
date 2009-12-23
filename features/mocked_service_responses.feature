Feature: Mocking Service Responses
  As a programmer implementing the client side of an service-oriented application
  I want Dupe to mock service responses using duped objects I create
  So that I can test out my application without having to worry about whether or not the service is live or available.
  
  Scenario: Simple Mocking
    Given I have duped an object
    When I request that object via the RESTful url for the object
    Then Dupe should return the appropriate xml for the duped object
  
  
