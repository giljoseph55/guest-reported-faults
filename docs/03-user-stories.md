# User stories, acceptance criteria and UAT

Companion to [`01-requirements.md`](01-requirements.md). Traceability to the business
requirements is in the right-hand column of each story.

Acceptance criteria are written Given / When / Then so that each one is a test somebody can
run, not a statement somebody can agree with.

---

## Epic

> **As a** Duty Manager
> **I want** every guest-reported fault to have a visible state and an age
> **so that** none of them can sit unattended without anyone noticing.

---

## US-01 · Log a fault at the moment it is reported

> **As a** Front Office agent
> **I want** to record a guest-reported fault in one place while the guest is still in front of me
> **so that** it does not depend on my memory at handover.

*Traces to BR-01, BR-02*

**Acceptance criteria**

1. **Given** a guest reports a fault at the desk
   **When** the agent records it
   **Then** room, symptom, reporting guest and timestamp are all captured, and the fault is
   created in state `OPEN`.

2. **Given** the agent is recording a fault
   **When** any of room, symptom or timestamp is missing
   **Then** the record cannot be saved.

3. **Given** a fault has been created
   **When** the agent looks for it again in the same shift
   **Then** it is findable by room number.

4. **Given** the same fault is reported twice by different guests in the same room
   **When** the second report is entered
   **Then** the agent is shown the existing open fault and can link to it rather than
   creating a duplicate.

---

## US-02 · See what is open, and how old

> **As a** Duty Manager
> **I want** the count of open faults and the age of the oldest on the morning report
> **so that** I can act on the queue before the shift starts rather than after a guest complains.

*Traces to BR-03, BR-04*

**Acceptance criteria**

1. **Given** faults exist in state `OPEN` or `IN PROGRESS`
   **When** the morning report is produced
   **Then** it shows the count of those faults and the age in days of the oldest.

2. **Given** a fault was reported on 1 September and is still not closed on 7 September
   **When** the age is calculated
   **Then** it reads 6 days, measured from the guest's report and not from assignment.

3. **Given** no faults are open
   **When** the report is produced
   **Then** it shows zero and the age field is blank, not "0 days".

4. **Given** a fault is closed
   **When** the next report is produced
   **Then** that fault is no longer counted.

---

## US-03 · Close a fault, with a name and a time

> **As a** Maintenance technician
> **I want** to close a fault and have it recorded who closed it and when
> **so that** "fixed" means something checkable.

*Traces to BR-05*

**Acceptance criteria**

1. **Given** a fault in state `IN PROGRESS`
   **When** the technician closes it
   **Then** state becomes `CLOSED`, and closed-by and closed-at are stored.

2. **Given** a fault cannot be fixed because parts are needed
   **When** the technician releases it
   **Then** state returns to `OPEN` and the age continues from the original guest report,
   not from the release.

3. **Given** a fault is closed
   **When** anyone views its history afterwards
   **Then** reported-at, assigned-at and closed-at are all visible.

---

## US-04 · Tell the guest

> **As a** guest who reported something broken
> **I want** to be told when it has been fixed
> **so that** I know my report went somewhere.

*Traces to BR-06*

**Acceptance criteria**

1. **Given** a fault is closed **and** the reporting guest is still in house
   **When** the closure is recorded
   **Then** a task appears for Front Office to inform that guest.

2. **Given** that task appears
   **When** the guest is informed
   **Then** the task is marked done with a timestamp.

3. **Given** a fault is closed **and** the guest has already checked out
   **When** the closure is recorded
   **Then** no task is raised, and the fault is marked closed silently.

4. **Given** the informing task has been open for more than four hours during an occupied
   shift
   **When** the shift report runs
   **Then** the task is listed as outstanding.

---

## US-05 · Escalate what has waited too long

> **As a** Rooms Division Manager
> **I want** faults open beyond a threshold to surface without me going looking
> **so that** the oldest one is never a surprise.

*Traces to BR-08. Could-have — the threshold should be set from the first month of real data,
not guessed now.*

**Acceptance criteria**

1. **Given** a fault has been open longer than the configured threshold
   **When** the threshold is crossed
   **Then** it is flagged to the Duty Manager.

2. **Given** a fault has been flagged
   **When** it remains open a further full day
   **Then** it is flagged to the Rooms Division Manager.

---

## UAT scenarios

Written to be run end to end on a live shift, by the people who will use it, before anyone
agrees the thing works.

| ID | Scenario | Expected |
|---|---|---|
| UAT-01 | Report a broken television at the desk. Check the morning report the next day. | Fault appears, count incremented, age 1 day |
| UAT-02 | Report the same fault again from the same room. | Agent is shown the existing fault, no duplicate created |
| UAT-03 | Assign, then release for parts. Wait a day. Check the age. | Age counts from the original guest report, not the release |
| UAT-04 | Close a fault while the guest is in house. | Front Office task appears |
| UAT-05 | Close a fault after the guest has checked out. | No task appears, fault closed |
| UAT-06 | Leave a fault open past the threshold. | Flag reaches the Duty Manager |
| UAT-07 | Close every open fault. Run the report. | Count zero, age blank |
| UAT-08 | Hand over mid-shift with three faults open. Ask the incoming Duty Manager the two numbers. | They can answer without asking anyone |

**UAT-08 is the one that matters.** Everything else tests whether the records behave. That one
tests whether the original problem is solved, and it is the only scenario that can fail while
all the others pass.

---

## Out of the first release

Deliberately not included, and worth saying so rather than leaving them to be assumed:

- Photographs attached to a fault report
- Guest-facing status, in-app or otherwise
- Cost tracking per fault
- Any link to compensation or service recovery
- Predicting faults from history

Each of these is defensible later. None of them is needed to answer *"how many are open, and
how old is the oldest?"*, which is the whole of the first release.
