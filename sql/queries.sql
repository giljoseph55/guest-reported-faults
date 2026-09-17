-- =====================================================================
--  Guest review analysis: every published figure, as a query
--  Database : guest_reviews.db (SQLite)
--  Corpus   : 222 Booking.com reviews, four Amsterdam five-star hotels,
--             14 January – 8 September 2026, collected by hand
--  Author   : Gilroy Joseph
--
--    property      (property_key PK, name, published_score, published_count, is_subject)
--    theme         (theme_key PK, theme_name)
--    review        (review_id PK, property_key FK, review_date, rating,
--                   traveller_type, nights, text_raw, text_clean,
--                   n_chars_clean, is_written)
--    review_theme  (review_id FK, theme_key FK, sentiment)  PK all three
--
--  14 January 2026 is the day the Conservatorium became a Mandarin
--  Oriental. Everything here is bounded by that date on one side and the
--  collection date on the other.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Q1.  DOES THE SAMPLE LOOK LIKE THE POPULATION?
--      Run this before anything else. It is the only reason to believe
--      the rest.
--
--      Three of the four sample means land within 0.10 of the score
--      Booking publishes over its own 36-month window. The fourth does
--      not, and that gap is the finding, not a fault in the method,
--      precisely because the same method reproduced the other three.
-- ---------------------------------------------------------------------
SELECT  p.name                                              AS property,
        p.published_count                                   AS booking_holds,
        COUNT(*)                                            AS i_read,
        ROUND(COUNT(*) * 100.0 / p.published_count, 0)       AS coverage_pct,
        ROUND(AVG(r.rating), 2)                             AS sample_mean,
        p.published_score                                   AS booking_score,
        ROUND(AVG(r.rating) - p.published_score, 2)          AS delta
FROM review r
JOIN property p ON p.property_key = r.property_key
GROUP BY p.name, p.published_count, p.published_score
ORDER BY delta;


-- ---------------------------------------------------------------------
-- Q2.  PROMOTERS AND DETRACTORS
--      Booking's scale is 1-10. Promoter 9 or above, detractor below 7,
--      the usual NPS cut applied to the scale as published.
-- ---------------------------------------------------------------------
SELECT  p.name                                                      AS property,
        COUNT(*)                                                    AS reviews,
        ROUND(SUM(CASE WHEN r.rating >= 9 THEN 1 ELSE 0 END) * 100.0
              / COUNT(*), 1)                                        AS promoter_pct,
        ROUND(SUM(CASE WHEN r.rating <  7 THEN 1 ELSE 0 END) * 100.0
              / COUNT(*), 1)                                        AS detractor_pct
FROM review r
JOIN property p ON p.property_key = r.property_key
GROUP BY p.name
ORDER BY detractor_pct DESC;


-- ---------------------------------------------------------------------
-- Q3.  WHAT THE UNHAPPY GUESTS COMPLAINED ABOUT
--      Subject property only, reviews scoring below 7 that carry enough
--      written text to code. Negative tags only: this is a complaint
--      count, not a mention count.
-- ---------------------------------------------------------------------
SELECT  t.theme_name                            AS complaint,
        COUNT(DISTINCT rt.review_id)            AS guests
FROM review_theme rt
JOIN review r   ON r.review_id = rt.review_id
JOIN theme  t   ON t.theme_key = rt.theme_key
JOIN property p ON p.property_key = r.property_key
WHERE p.is_subject = 1
  AND r.rating < 7
  AND r.is_written = 1
  AND rt.sentiment = 'neg'
GROUP BY t.theme_name
ORDER BY guests DESC, complaint;


-- ---------------------------------------------------------------------
-- Q4.  HOW THE SUBJECT COMPARES ON EACH THEME
--      A different question from Q3, and the reason sentiment sits on
--      the row rather than in a footnote: this counts every written
--      review that raises a theme as a problem, at all four hotels.
--
--      The full grid is built first and missing combinations coalesced
--      to zero. A hotel with no complaints under a theme has no rows in
--      review_theme, and would otherwise drop out of the comparison
--      instead of counting as a zero.
-- ---------------------------------------------------------------------
WITH written AS (
    SELECT property_key, COUNT(*) AS n
    FROM review WHERE is_written = 1
    GROUP BY property_key
),
grid AS (
    SELECT w.property_key, t.theme_key, w.n
    FROM written w CROSS JOIN theme t
),
tagged AS (
    SELECT r.property_key, rt.theme_key, COUNT(DISTINCT rt.review_id) AS k
    FROM review_theme rt
    JOIN review r ON r.review_id = rt.review_id
    WHERE rt.sentiment = 'neg' AND r.is_written = 1
    GROUP BY r.property_key, rt.theme_key
),
pct AS (
    SELECT g.property_key, g.theme_key,
           COALESCE(t.k, 0) * 100.0 / g.n AS share
    FROM grid g
    LEFT JOIN tagged t
           ON t.property_key = g.property_key AND t.theme_key = g.theme_key
)
SELECT  th.theme_name                                                AS theme,
        ROUND(MAX(CASE WHEN p.is_subject = 1 THEN pct.share END), 1)  AS subject_pct,
        ROUND(MIN(CASE WHEN p.is_subject = 0 THEN pct.share END), 1)  AS peers_low,
        ROUND(MAX(CASE WHEN p.is_subject = 0 THEN pct.share END), 1)  AS peers_high
FROM pct
JOIN property p  ON p.property_key = pct.property_key
JOIN theme   th  ON th.theme_key   = pct.theme_key
GROUP BY th.theme_name
ORDER BY subject_pct DESC;


-- ---------------------------------------------------------------------
-- Q5.  THE ONE THEME THAT SEPARATES THE SUBJECT
--      Denominators printed alongside, because a percentage out of 12
--      reviews and a percentage out of 31 are not the same evidence.
--
--      The denominator is counted in its own CTE rather than with
--      SUM(is_written) alongside the join. A review carrying four themes
--      appears four times after joining review_theme, so summing the flag
--      across the joined rows counts it four times: the first version of
--      this query reported 80 written reviews at the subject property
--      instead of 30. Fan-out is silent, and it inflates denominators
--      without ever raising an error.
-- ---------------------------------------------------------------------
WITH written AS (
    SELECT property_key, COUNT(*) AS n
    FROM review WHERE is_written = 1
    GROUP BY property_key
),
raised AS (
    SELECT r.property_key, COUNT(DISTINCT r.review_id) AS k
    FROM review r
    JOIN review_theme rt ON rt.review_id = r.review_id
    WHERE r.is_written = 1
      AND rt.theme_key = 'broken'
      AND rt.sentiment = 'neg'
    GROUP BY r.property_key
)
SELECT  p.name                                        AS property,
        w.n                                           AS written_reviews,
        COALESCE(x.k, 0)                              AS raised_it,
        ROUND(COALESCE(x.k, 0) * 100.0 / w.n, 1)      AS pct
FROM written w
JOIN property p ON p.property_key = w.property_key
LEFT JOIN raised x ON x.property_key = w.property_key
ORDER BY pct DESC;


-- ---------------------------------------------------------------------
-- Q6.  WHO IT HAPPENED TO
--      Detractor rate by traveller type at the subject property.
--      Sixteen solo guests is thin. The count is printed alongside so the
--      reader sees how thin before reading the percentage.
-- ---------------------------------------------------------------------
SELECT  r.traveller_type                                          AS traveller,
        COUNT(*)                                                  AS guests,
        SUM(CASE WHEN r.rating < 7 THEN 1 ELSE 0 END)             AS unhappy,
        ROUND(SUM(CASE WHEN r.rating < 7 THEN 1 ELSE 0 END) * 100.0
              / COUNT(*), 1)                                      AS unhappy_pct
FROM review r
JOIN property p ON p.property_key = r.property_key
WHERE p.is_subject = 1 AND r.traveller_type IS NOT NULL AND r.traveller_type <> ''
GROUP BY r.traveller_type
HAVING COUNT(*) >= 5
ORDER BY unhappy_pct DESC;


-- ---------------------------------------------------------------------
-- Q7.  FAULTS THE GUEST SAYS WERE ALREADY REPORTED
--      The reason for the whole requirements document in docs/.
--      These are read out in full rather than counted, because three
--      cases is a reason to ask a question, not a rate.
-- ---------------------------------------------------------------------
SELECT  r.review_id,
        r.rating,
        r.text_clean
FROM review r
JOIN review_theme rt ON rt.review_id = r.review_id
JOIN property p      ON p.property_key = r.property_key
WHERE p.is_subject = 1
  AND rt.theme_key = 'broken'
  AND rt.sentiment = 'neg'
  AND (r.text_clean LIKE '%reported%'
    OR r.text_clean LIKE '%never fixed%'
    OR r.text_clean LIKE '%still had not%'
    OR r.text_clean LIKE '%engineers%')
ORDER BY r.rating;
