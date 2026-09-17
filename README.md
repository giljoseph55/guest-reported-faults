# Guest-reported faults — analysis and requirements

A business analysis end to end: 222 hand-collected hotel reviews, coded into an auditable
data set, queried in SQL, and turned into a requirements document with process maps, UML and
user stories.

The subject is a five-star Amsterdam hotel under a brand change. The method is the part
intended to transfer.

---

## The finding

Across 30 written reviews at the subject property, **9 guests reported that something did not
work** — 30% of everyone who wrote anything.

| Property | Written reviews | Raised a fault | Share |
|---|---|---|---|
| **Subject property** | 30 | **9** | **30.0%** |
| Waldorf Astoria | 17 | 1 | 5.9% |
| Rosewood | 31 | 1 | 3.2% |
| De L'Europe | 12 | 0 | 0.0% |

Three of the nine describe a fault that had **already been reported and was still broken** —
a room light, an engineer who came and left it working no better, a lift out of service for
three days.

Three cases is not a pattern. It is a reason to ask whether a guest-reported fault has an
owner and a closing date, which is what [`docs/01-requirements.md`](docs/01-requirements.md)
specifies.

## Why the sample can be trusted

The corpus is 26% of the reviews the platform held for the subject property, and less
elsewhere. That is worth nothing on its own, so it is tested rather than asserted:

| Property | Sample mean | Platform's published score | Difference |
|---|---|---|---|
| Rosewood | 9.00 | 8.9 | **+0.10** |
| Waldorf Astoria | 9.45 | 9.4 | **+0.05** |
| De L'Europe | 9.18 | 9.2 | **−0.02** |
| **Subject property** | 7.70 | 8.2 | **−0.50** |

**Three of the four reproduce the published score within a tenth of a point.** The same
collection method, applied the same way, at the same time. The fourth does not — and that is
the finding rather than a defect, precisely because the method demonstrably works on the
other three.

The subject's published score covers 36 months, most of it under previous management. The
sample covers only the months since the brand change.

## The coding frame

The weakest point of any thematic analysis is that the coding is invisible. A reader is asked
to accept "30% mentioned something broken" without being able to check a single one.

[`sql/coding_frame.py`](sql/coding_frame.py) is that coding, written down: every review, every
theme, positive or negative, with the rules that produced it. Anyone can open it, disagree
with a line, change it and re-run the queries to see what moves.

It also fixes an ambiguity in the original analysis. *"How many guests complained about X"*
and *"how many reviews mention X"* are different questions that were sitting in one table with
a footnote separating them. `review_theme.sentiment` now carries that distinction, so a query
states which question it is asking.

## What is here

```
data/
  mandarin_oriental.csv …      the four source collections, as gathered
  reviews_window.csv           222 reviews, cleaned, window applied, is_written flagged
  review_theme.csv             208 theme tags, generated from the coding frame

sql/
  schema.sql                   four tables, with the reasoning for each decision
  coding_frame.py              the coding rules and every tag assignment
  load.py                      builds the database and runs its own checks
  queries.sql                  seven queries, each mapped to a published figure
  query_results.txt            their output, checkable without running anything

docs/
  01-requirements.md           problem, scope, stakeholders, BR-01…BR-08, limitations
  02-process-and-uml.md        as-is and to-be flows, state diagram, sequence diagram, ERD
  03-user-stories.md           five stories, acceptance criteria, eight UAT scenarios
```

## Running it

```bash
pip install pandas
python sql/coding_frame.py     # regenerate data/review_theme.csv from the tags
python sql/load.py             # build sql/guest_reviews.db, run the checks
sqlite3 sql/guest_reviews.db < sql/queries.sql
```

Or open `sql/guest_reviews.db` in [DB Browser for SQLite](https://sqlitebrowser.org/) and
paste queries from `sql/queries.sql`.

`load.py` prints three checks before anything else: that every written review is coded, that
nothing is coded that was too short to code, and that each sample mean lands where the
published score says it should.

## Two bugs worth keeping

**Fan-out inflated a denominator.** The first version of Q5 counted written reviews with
`SUM(is_written)` alongside a join to `review_theme`. A review carrying four themes appears
four times after that join, so the subject property reported **80** written reviews instead
of 30. The percentage looked plausible and was wrong by a factor of two and a half. Fixed by
counting the denominator in its own CTE. Fan-out never raises an error — it just quietly
changes the answer.

**A semicolon inside a comment split a statement.** `-- Sixteen solo guests is thin; the
count is printed…` broke the query when the file was run statement by statement. Harmless,
and the kind of thing that only shows up when somebody other than the author runs the file.

Both are described in the comments where they happened, because the recovery is more useful
to a reader than a clean file would be.

## Limitations

**One platform, one channel.** Only guests who booked through this platform and chose to
write. Direct bookers, corporate accounts and loyalty members are absent entirely, and they
are likely to be the most loyal guests the hotel has.

**Small denominators.** De L'Europe's percentages rest on 12 written reviews, where a single
review is worth 8.3 points. Its 0% should not be read as a zero. The comparison that carries
weight is the subject property against Rosewood: 30 written reviews against 31.

**The coding is a judgement.** Documented, checkable, and still a judgement. A second coder
would move some rows.

**Nothing is validated against the hotel's own data.** Every figure comes from public reviews.
The requirements document says so in its own last section, and the first action it proposes is
to check its central claim against the actual maintenance record.

## Attribution

Analysis, coding frame, SQL and documentation by **Gilroy Joseph**
[gilroybjoseph@gmail.com](mailto:gilroybjoseph@gmail.com) ·
[linkedin.com/in/gilroy-joseph](https://www.linkedin.com/in/gilroy-joseph)

Review text is quoted from public listings for analysis and is the property of the guests who
wrote it and the platform that hosts it. The hotel is named in the analysis because the
figures are checkable only if it is.
