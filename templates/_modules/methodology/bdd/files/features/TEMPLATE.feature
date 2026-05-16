# TEMPLATE.feature — copy to features/<slug>.feature and fill in.
# Gherkin style: business language, declarative, readable by a non-technical
# stakeholder. Describe WHAT the system does, never the UI steps to do it.

Feature: <capability in plain language>
  # One or two sentences of context: who benefits and why this behavior exists.
  As a <role>
  I want <capability>
  So that <business value>

  Background:
    # Steps common to every scenario below. Keep it minimal — only true
    # preconditions, no test data noise.
    Given <a shared precondition>

  Scenario: <the happy path, named as an outcome>
    Given <a known starting state in domain terms>
    When <the event or action the actor takes>
    Then <the observable outcome>
    And <a further expected outcome, if any>

  Scenario: <a meaningful edge case, named as an outcome>
    Given <a different starting state>
    When <the same or related action>
    Then <the different expected outcome>

  Scenario Outline: <a behavior that varies by input>
    Given <a starting state using <placeholder> values>
    When <an action involving "<input>">
    Then <the outcome should be "<result>">

    Examples:
      | input    | result   |
      | <value1> | <value1> |
      | <value2> | <value2> |
