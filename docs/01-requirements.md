# Guest-reported fault tracking — requirements

**Status** Draft for discussion · **Author** Gilroy Joseph · **Date** September 2026
**Evidence base** 222 Booking.com reviews, four Amsterdam five-star hotels, 14 January – 8 September 2026

---

## 1. Why this exists

Across 30 written reviews at the subject property, **9 guests reported that something in the
hotel did not work** — 30% of everyone who wrote anything. At three comparable Amsterdam
hotels the same measure runs between 0% and 5.9%.

Three of those nine describe a fault that had **already been reported and was still broken**:

> *"The room-cleaning light was not working, I reported it but it was never fixed."*

> *"Had to change rooms due to aircon not working, sent engineers up and they said it would
> work, so I waited an hour. Second room I went to, the curtain was broken."*

> *"The elevators had been out of service for three days and the problem still had not been
> fixed."*

Three cases out of eleven is too thin to call a pattern. It is enough to ask whether a
guest-reported fault has an owner and a closing date, or whether it stops at a shift note.

**This document assumes the answer is not known, and specifies the smallest thing that would
make it known.** It does not assume the hotel lacks a maintenance system. It assumes nobody
can currently answer *"how many guest-reported faults are open right now, and how old is the
oldest one?"* — and that is a different question from *"do we log faults?"*

## 2. Scope

**In scope.** Faults reported by a guest to any member of staff, in any channel, concerning
something in the guest's room or on the guest's route through the building.

**Out of scope.** Planned maintenance. Faults found by staff during inspection. Anything
requiring capital approval. Complaint handling, service recovery and compensation — those are
separate processes that may be triggered by a fault but are not part of tracking it.

**Explicitly out of scope: buying anything.** The measure below is intended to run on whatever
system already records maintenance jobs. If no such system exists, that is a finding in
itself and a larger conversation.

## 3. Stakeholders

| Who | Interest | Needed from them |
|---|---|---|
| Duty Manager | Owns the shift. Answers to the guest. | Daily use of the two figures |
| Front Office | First to hear about a fault | Logs it once, in one place |
| Housekeeping | Finds faults during service | Same log |
| Maintenance / Engineering | Fixes it | Marks it closed, with a timestamp |
| Rooms Division Manager | Accountable for the number | Reviews the ageing weekly |
| Guest | Reported it | Gets told when it is fixed |

## 4. Problem statement

Fault reports enter through several doors — desk, phone, housekeeping, in-room — and there is
no single place where an open fault is visibly open. A fault that is not visibly open cannot
be chased, and a guest who reported one has no way of knowing whether anything happened.

The absence is not a log. It is a **state** and an **age**.

## 5. Business requirements

| ID | Requirement | Priority |
|---|---|---|
| BR-01 | A guest-reported fault is recorded once, against a room or location, at the moment it is reported | Must |
| BR-02 | Every fault carries a state: open, in progress, closed | Must |
| BR-03 | The age of an open fault is derivable at any moment | Must |
| BR-04 | The Duty Manager can see, without asking anyone, how many faults are open and how old the oldest is | Must |
| BR-05 | Closing a fault requires the closer to be identified and the time recorded | Must |
| BR-06 | When a fault is closed, the guest who reported it is told, if still in house | Should |
| BR-07 | Faults are reportable by room, by category and by age band | Should |
| BR-08 | A fault open beyond a defined threshold is escalated automatically | Could |

## 6. The measure

Two numbers on the existing morning report:

```
Guest-reported faults open        14
Oldest open fault                 6 days
```

Split weather-of-the-day noise from standing problems by reading them together: a rising count
with a low oldest-age is a busy week, a flat count with a rising oldest-age is a queue nobody
is working.

**Why two numbers and not a dashboard.** A count alone hides a fault that has been open for
three weeks behind twenty that were opened this morning. An age alone hides volume. Neither is
useful without the other, and a third number would start to need explaining.

## 7. Assumptions

- Maintenance jobs are recorded somewhere today, even if only on paper or in a shift book.
- Front Office and Housekeeping can reach the same record.
- "Closed" means the guest-visible symptom is gone, not that a work order was raised.

## 8. Constraints

- No new system, no licence purchase, no integration project.
- Must survive a shift handover, including across languages.
- Must not add a step for the guest.

## 9. What this evidence cannot support

The review corpus is **26% of the reviews Booking held** for the subject property, and covers
only guests who booked through Booking and chose to write. Guests who booked direct, corporate
accounts and loyalty members are absent entirely.

The theme coding in `sql/coding_frame.py` is a judgement made by reading each review. Another
coder would tag some of them differently. The file exists so that disagreement is possible.

Three reported-and-still-broken cases are the reason for the questions in section 1. They are
not evidence of a systemic failure, and this document does not claim they are.

**Nothing here has been validated against the hotel's own data.** Every figure is derived from
public reviews. The first action on receiving this should be to check the two numbers in
section 6 against the actual maintenance record, which will either confirm the gap or close
the conversation.
