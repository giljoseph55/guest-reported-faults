"""
Coding frame and theme assignments for the Booking review corpus.

WHY THIS FILE EXISTS
--------------------
The original analysis tagged these reviews by reading them and deciding what
each one was about. That is the right method for 90 reviews — a keyword search
for "broken" misses "the aircon did not work" and catches "broken promises" —
but the tags themselves were never written down. The percentages could not be
checked by anyone, including the person who produced them.

This file is that record. Every assignment below is a judgement, made by
reading the text. Anyone can open it, disagree with a line, change it, and
re-run the queries to see what moves.

TWO KINDS OF TAG
----------------
The published complaint table mixed two different measures in one grid and
then needed a footnote to explain the difference. They are separated here:

    sentiment = 'neg'   the guest raised this as a problem
    sentiment = 'pos'   the guest praised it

A complaint count uses neg only. A "share of reviews that touch the topic"
uses both. Keeping sentiment on the row means the query says which one it
means, instead of a caption having to.

RULES APPLIED
-------------
1. Only reviews with 40 or more characters of guest-written text, after the
   auto-generated stay summary ("* 2 nights · August 2026 * Couple") is
   stripped. Below that there is nothing to code.
2. A theme is tagged when the guest refers to it, not when a word appears.
3. One review can carry several themes, and can be positive on one and
   negative on another. Review 31 praises the front desk and reports three
   things not working.
4. 'broken' means equipment that did not work. A television that is absent,
   or a bathroom the guest wanted to be larger, is 'room' or 'bathroom' —
   a preference, not a fault.
5. Where a fault sits in the bathroom, both 'broken' and 'bathroom' are
   tagged. The guest experienced one thing; the two questions "what broke"
   and "where" are both legitimate.

Gilroy Joseph, September 2026
"""

THEMES = {
    "waiting":  "Waiting, or no reply",
    "broken":   "Something broken",
    "billing":  "Billing",
    "food":     "Food & drink",
    "staff":    "Staff",
    "room":     "Room, or check-in",
    "value":    "Value for money",
    "clean":    "Cleanliness",
    "bathroom": "Bathroom",
    "noise":    "Noise",
}

# review_id: { "neg": [...themes...], "pos": [...themes...] }
TAGS = {
    # ---------- Mandarin Oriental Conservatorium ----------
    16: {"neg": ["waiting", "broken", "billing", "noise", "bathroom"]},
    51: {"neg": ["waiting", "billing", "staff", "room"]},
    35: {"neg": ["waiting", "billing", "room", "staff"], "pos": ["food"]},
    7:  {"neg": ["room", "clean", "broken", "value"]},
    61: {"neg": ["room"]},
    41: {"neg": ["staff", "waiting"]},
    1:  {"neg": ["broken", "waiting", "room"]},
    29: {"neg": ["room", "food"], "pos": ["staff"]},
    26: {"neg": ["waiting", "room"]},
    53: {"neg": ["value", "food"]},
    70: {"neg": ["broken", "bathroom", "room"], "pos": ["staff"]},
    30: {"neg": ["food"], "pos": ["staff"]},
    31: {"neg": ["broken", "bathroom"], "pos": ["staff", "food"]},
    23: {"neg": ["broken"], "pos": ["staff", "food"]},
    9:  {"neg": ["bathroom", "room"]},
    6:  {"neg": ["staff"]},
    67: {"neg": ["room", "staff"], "pos": ["food"]},
    55: {"neg": ["clean", "room"]},
    57: {"neg": ["waiting", "staff"], "pos": ["food"]},
    37: {"neg": ["value", "staff"]},
    49: {"neg": ["room"], "pos": ["staff"]},
    22: {"neg": ["bathroom", "clean", "broken", "staff"]},
    4:  {"neg": ["billing"], "pos": ["staff"]},
    33: {"pos": ["staff", "room"]},
    60: {"neg": ["food", "waiting", "value"], "pos": ["staff"]},
    54: {"neg": ["room"], "pos": ["staff"]},
    11: {"neg": ["broken"], "pos": ["staff"]},
    19: {"pos": ["staff"]},
    32: {"neg": ["broken", "bathroom"]},
    39: {"pos": ["staff", "food"]},

    # ---------- Rosewood Amsterdam ----------
    103: {"neg": ["room", "value", "staff", "waiting", "food"]},
    117: {"neg": ["staff", "value"]},
    97:  {"neg": ["room", "staff", "clean"]},
    84:  {"neg": ["food", "waiting", "staff"], "pos": ["room"]},
    140: {"neg": ["noise", "room"], "pos": ["staff"]},
    109: {"neg": ["food", "waiting", "staff", "room"]},
    82:  {"pos": ["room"]},
    122: {"neg": ["food", "waiting", "staff"], "pos": ["clean"]},
    118: {"neg": ["food", "waiting"], "pos": ["room"]},
    135: {"neg": ["food"]},
    146: {"neg": ["value", "staff", "room"]},
    101: {"neg": ["billing", "waiting"], "pos": ["clean", "room"]},
    96:  {"neg": ["bathroom"]},
    108: {"neg": ["clean", "waiting"], "pos": ["staff", "room"]},
    92:  {"pos": ["staff"]},
    91:  {"neg": ["broken"], "pos": ["food"]},
    112: {"pos": ["staff", "room", "food"]},
    110: {"pos": ["staff"]},
    107: {"pos": ["staff"]},
    83:  {"neg": ["food"], "pos": ["room", "staff"]},
    85:  {"pos": ["staff"]},
    87:  {"pos": ["room"]},
    121: {},
    119: {"neg": ["food", "waiting"]},
    134: {},
    131: {"pos": ["staff", "room"]},
    127: {"neg": ["food", "waiting"], "pos": ["staff", "bathroom", "room"]},
    137: {"pos": ["room", "food"]},
    139: {"pos": ["staff"]},
    143: {"pos": ["food"]},
    144: {"pos": ["room"]},

    # ---------- Waldorf Astoria Amsterdam ----------
    157: {"neg": ["room"]},
    155: {"neg": ["broken", "room"]},
    184: {"neg": ["bathroom"]},
    167: {"pos": ["room"]},
    153: {"neg": ["room", "value"], "pos": ["clean"]},
    152: {"neg": ["food"], "pos": ["room", "food"]},
    158: {"pos": ["staff", "room"]},
    160: {"pos": ["staff", "food"]},
    162: {"pos": ["staff", "room"]},
    161: {"pos": ["staff", "clean"]},
    174: {"pos": ["staff"]},
    168: {"pos": ["food"]},
    175: {"neg": ["room"], "pos": ["staff"]},
    178: {"pos": ["staff", "food", "noise"]},
    180: {"pos": ["staff", "clean", "food"]},
    182: {},
    189: {"pos": ["staff", "bathroom", "room"]},

    # ---------- De L'Europe Amsterdam ----------
    195: {"neg": ["clean", "room"]},
    198: {"neg": ["food", "waiting"], "pos": ["staff"]},
    199: {"neg": ["waiting", "food"], "pos": ["staff"]},
    204: {"pos": ["staff"]},
    194: {"neg": ["noise"], "pos": ["room"]},
    192: {"pos": ["staff", "food", "room", "bathroom"]},
    191: {"pos": ["room", "staff", "food"]},
    201: {"neg": ["room"], "pos": ["staff"]},
    211: {"pos": ["staff", "room"]},
    215: {"pos": ["staff", "room"]},
    217: {"pos": ["staff", "room"]},
    219: {"pos": ["staff"]},
}


def rows():
    """Flatten TAGS into (review_id, theme_key, sentiment) tuples."""
    for review_id, buckets in TAGS.items():
        for sentiment, themes in buckets.items():
            for theme in themes:
                if theme not in THEMES:
                    raise ValueError(f"review {review_id}: unknown theme {theme!r}")
                yield review_id, theme, sentiment


if __name__ == "__main__":
    import csv
    import collections
    from pathlib import Path

    out = Path(__file__).resolve().parent.parent / "data" / "review_theme.csv"
    data = list(rows())
    with out.open("w", newline="", encoding="utf8") as fh:
        w = csv.writer(fh)
        w.writerow(["review_id", "theme_key", "sentiment"])
        w.writerows(data)

    coded = len(TAGS)
    counts = collections.Counter(t for _, t, s in data if s == "neg")
    print(f"{coded} reviews coded, {len(data)} tags written to {out.name}")
    print("\nmost complained about, all four properties:")
    for theme, n in counts.most_common():
        print(f"  {THEMES[theme]:<24}{n:>4}")
