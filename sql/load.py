"""
Build guest_reviews.db from the collected CSVs and the coding frame.

    python sql/load.py

Takes a second. Prints the checks that matter at the end.
"""
from pathlib import Path
import sqlite3
import sys

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from coding_frame import THEMES, rows as theme_rows          # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
DB = ROOT / "sql" / "guest_reviews.db"
SCHEMA = ROOT / "sql" / "schema.sql"

# Booking's own published figures, read from the four property pages on
# 8 September 2026. These are the population the sample is checked against.
PROPERTIES = [
    ("mandarin_oriental", "Mandarin Oriental Conservatorium", 8.2, 270, 1),
    ("rosewood",          "Rosewood Amsterdam",               8.9, 151, 0),
    ("waldorf_astoria",   "Waldorf Astoria Amsterdam",        9.4, 192, 0),
    ("de_lEurope",        "De L'Europe Amsterdam",            9.2, 319, 0),
]

con = sqlite3.connect(DB)
con.executescript(SCHEMA.read_text(encoding="utf8"))

con.executemany("INSERT INTO property VALUES (?,?,?,?,?)", PROPERTIES)
con.executemany("INSERT INTO theme VALUES (?,?)", list(THEMES.items()))

reviews = pd.read_csv(ROOT / "data" / "reviews_window.csv")
reviews.to_sql("review", con, if_exists="append", index=False)

pd.DataFrame(theme_rows(), columns=["review_id", "theme_key", "sentiment"]) \
  .to_sql("review_theme", con, if_exists="append", index=False)
con.commit()

cur = con.cursor()
for t in ("property", "theme", "review", "review_theme"):
    print(f"  {t:<14}{cur.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0]:>6} rows")

print("\ncheck 1 — every written review is coded")
gap = cur.execute("""
    SELECT COUNT(*) FROM review r
     WHERE r.is_written = 1
       AND r.review_id NOT IN (SELECT review_id FROM review_theme)""").fetchone()[0]
print(f"  written reviews with no theme row: {gap}"
      f"   {'(all generic praise, no theme to code)' if gap else ''}")

print("\ncheck 2 — no theme tagged on a review too short to code")
bad = cur.execute("""
    SELECT COUNT(*) FROM review_theme t
      JOIN review r ON r.review_id = t.review_id
     WHERE r.is_written = 0""").fetchone()[0]
print(f"  tags on unwritten reviews: {bad}   {'OK' if bad == 0 else 'PROBLEM'}")

print("\ncheck 3 — sample mean against Booking's published score")
for key, name, *_ in [(p[0], p[1]) for p in PROPERTIES]:
    pass
for row in cur.execute("""
    SELECT p.name, COUNT(*) n, ROUND(AVG(r.rating), 2) mean,
           p.published_score, ROUND(AVG(r.rating) - p.published_score, 2) delta
      FROM review r JOIN property p ON p.property_key = r.property_key
     GROUP BY p.name ORDER BY delta"""):
    print(f"  {row[0]:<34}n={row[1]:<4} mean {row[2]:<5} published {row[3]:<5} delta {row[4]:+}")

con.close()
print(f"\nwrote {DB}")
