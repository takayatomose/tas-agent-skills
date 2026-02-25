---
description: Iterative Quality Assurance focused on rapid feedback and acceptance testing for incremental changes.
---

Follow this workflow to verify each delivered increment against its specific acceptance criteria.

### 1. Acceptance Testing (per Story)
- [ ] **AC Validation**: Systematically verify each Acceptance Criterion (AC) defined in the BA workflow.
- [ ] **Iteration Data**: Use factories to generate the specific data needed for the story's scenarios.

### 2. Automated Regression Safety
- [ ] **Targeted Integration Tests**: Verify that the new increment correctly integrates with existing modules without breakages.
- [ ] **Functional E2E**: Perform a focused request-based test of the new feature increment.

### 3. Feedback & Correction
- [ ] **Bug Triage**: Identify any defects introduced in the current increment. Fix immediately (within the same iteration).
- [ ] **Performance Pulse**: Briefly assess if the increment has caused obvious performance regressions (e.g., slow queries).

### 4. Iteration Increment Review
- [ ] **Evidence Collection**: Record the successful completion of the story's criteria.
- [ ] **Final DoD Sign-off**: Confirm the story is "Done" and ready for deployment or the next iteration.
