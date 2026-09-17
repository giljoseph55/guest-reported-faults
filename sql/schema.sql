-- =====================================================================
--  guest_reviews.db schema
--
--  Booking.com reviews for four Amsterdam five-star hotels, 14 January
--  to 8 September 2026, collected by hand.
--
--  The source is four flat CSVs, one per hotel, with the hotel identified
--  only by the filename. Everything below exists to make the four
--  comparable and the coding auditable.
-- =====================================================================

DROP TABLE IF EXISTS review_theme;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS theme;
DROP TABLE IF EXISTS property;


-- Dimension: the four hotels, with what Booking published about each at
-- the time of collection. published_score and published_count are kept
-- so that the sample can be checked against the population it came from
-- that check is the whole basis for trusting the sample at all.
CREATE TABLE property (
    property_key      TEXT PRIMARY KEY,
    name              TEXT    NOT NULL,
    published_score   REAL    NOT NULL,   -- Booking's own 36-month score
    published_count   INTEGER NOT NULL,   -- reviews Booking held, 8 Sep 2026
    is_subject        INTEGER NOT NULL    -- 1 for the hotel under study
);


-- Dimension: the coding frame. Ten themes, defined in sql/coding_frame.py.
CREATE TABLE theme (
    theme_key   TEXT PRIMARY KEY,
    theme_name  TEXT NOT NULL
);


-- Fact: one row per review.
--
-- text_raw is kept alongside text_clean because the cleaning step is a
-- decision, not a given. Booking appends an auto-generated stay summary
-- ("* 2 nights · August 2026 * Couple") to every review, and whether the
-- minimum-length rule is applied before or after stripping it changes
-- which reviews count as written. Keeping both columns means the rule can
-- be re-applied differently without re-collecting anything.
--
-- is_written is that rule made explicit: 40 or more characters of guest
-- text after the summary is stripped.
CREATE TABLE review (
    review_id       INTEGER PRIMARY KEY,
    property_key    TEXT    NOT NULL REFERENCES property(property_key),
    review_date     TEXT    NOT NULL,     -- ISO date
    rating          REAL    NOT NULL,     -- 1-10 as published by Booking
    traveller_type  TEXT,                 -- Solo / Couple / Family / Group
    nights          INTEGER,
    text_raw        TEXT,
    text_clean      TEXT,
    n_chars_clean   INTEGER NOT NULL,
    is_written      INTEGER NOT NULL
);


-- Fact: the coding. One row per (review, theme, sentiment).
--
-- sentiment is the column that resolves an ambiguity the original
-- analysis had to explain in a footnote. "How many guests complained
-- about X" and "how many reviews mention X" are different questions;
-- with sentiment on the row, the query states which one it is asking
-- instead of a caption having to.
CREATE TABLE review_theme (
    review_id   INTEGER NOT NULL REFERENCES review(review_id),
    theme_key   TEXT    NOT NULL REFERENCES theme(theme_key),
    sentiment   TEXT    NOT NULL CHECK (sentiment IN ('neg', 'pos')),
    PRIMARY KEY (review_id, theme_key, sentiment)
);


CREATE INDEX ix_review_property ON review(property_key, is_written);
CREATE INDEX ix_theme_key       ON review_theme(theme_key, sentiment);
