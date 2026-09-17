# Process and UML

Companion to [`01-requirements.md`](01-requirements.md). Diagrams are Mermaid, which GitHub
renders in place, so no image files to go stale against the text.

---

## 1. As-is: how a guest-reported fault travels today

Reconstructed from what guests describe in the reviews, not from observation inside the hotel.
It is a hypothesis to be corrected in the first working session, and the point of drawing it
is to have something specific to be corrected.

```mermaid
flowchart TD
    G([Guest notices a fault]) --> C{How do they report it?}
    C -->|Tells the desk| D[Front Office hears it]
    C -->|Phones reception| D
    C -->|Tells housekeeping| H[Housekeeper hears it]
    C -->|Says nothing| X([Appears in a review after checkout])

    D --> N[Noted in the shift book<br/>or passed verbally]
    H --> N
    N --> M{Maintenance available now?}
    M -->|Yes| F[Engineer attends]
    M -->|No| Q[Waits for the next shift]
    Q --> R{Remembered at handover?}
    R -->|Yes| F
    R -->|No| L([Lost])
    F --> S{Fixed?}
    S -->|Yes| Z([Closed, but nobody tells the guest])
    S -->|No, needs parts| Q

    style X fill:#f4dede,stroke:#a33
    style L fill:#f4dede,stroke:#a33
    style Z fill:#f6eedd,stroke:#a86
```

**Three exits, and two of them are silent.** A fault can end in a review the hotel reads a
week later, or in nothing at all. Even the good exit leaves the guest uninformed, which is
the one a guest can actually observe, and the one they write about.

## 2. To-be: the same journey with a state and an owner

```mermaid
flowchart TD
    G([Guest reports a fault]) --> L[Logged once:<br/>room, symptom, who reported, timestamp]
    L --> O[State = OPEN]
    O --> V[Visible on the morning report:<br/>count and age of oldest]
    V --> A[Assigned to Maintenance]
    A --> P[State = IN PROGRESS]
    P --> S{Symptom gone?}
    S -->|No| P
    S -->|Yes| CL[State = CLOSED<br/>closed by, closed at]
    CL --> T{Guest still in house?}
    T -->|Yes| I([Guest told it is fixed])
    T -->|No| E([Closed silently])
    O -.->|open beyond threshold| ESC[Escalated to Duty Manager]
    ESC --> A

    style V fill:#dfeee4,stroke:#4a7
    style I fill:#dfeee4,stroke:#4a7
```

**One change carries the rest.** Every fault has a state, and the open ones are counted where
somebody is already looking. Everything else (assignment, escalation, telling the guest)
becomes possible only because the fault is visibly open.

## 3. Activity diagram: closing a fault

The decision points a Duty Manager actually faces on a shift.

```mermaid
stateDiagram-v2
    [*] --> Open : guest reports
    Open --> InProgress : assigned to engineer
    Open --> Open : still unassigned at shift end<br/>(age keeps counting)
    InProgress --> Closed : symptom gone
    InProgress --> Open : parts needed, released back
    InProgress --> Deferred : cannot be fixed in service<br/>(room taken out of inventory)
    Deferred --> InProgress : scheduled
    Closed --> [*]
    note right of Open
        Age is measured from the guest report,
        not from assignment. A fault nobody has
        picked up is the one that matters most.
    end note
```

**Age runs from the guest's report, not from assignment.** Measuring from assignment would
make an unassigned fault look young, which is exactly backwards.

## 4. Sequence diagram: the reporting and closing interaction

```mermaid
sequenceDiagram
    actor Guest
    participant FO as Front Office
    participant Log as Fault log
    participant Eng as Maintenance
    participant DM as Duty Manager

    Guest->>FO: "The television does not work"
    FO->>Log: create(room, symptom, reported_by, at)
    Log-->>FO: fault_id, state = OPEN
    FO-->>Guest: "Logged, reference given"

    Note over Log,DM: Morning report reads the log:<br/>open count, age of oldest

    DM->>Log: read open faults
    Log-->>DM: 14 open, oldest 6 days
    DM->>Eng: assign(fault_id)
    Eng->>Log: state = IN PROGRESS

    alt Symptom gone
        Eng->>Log: close(fault_id, closed_by, closed_at)
        Log-->>FO: fault closed
        FO-->>Guest: "It is fixed"
    else Parts needed
        Eng->>Log: state = OPEN, note
        Log-->>DM: age keeps counting
    end
```

**The line that does not exist today is the last one.** Every review quoted in section 1 of
the requirements is a guest who never received it.

## 5. Data model behind the analysis

The review corpus that produced the evidence, as built in [`../sql/schema.sql`](../sql/schema.sql).

```mermaid
erDiagram
    property ||--o{ review : "has"
    review   ||--o{ review_theme : "coded with"
    theme    ||--o{ review_theme : "applied to"

    property {
        text property_key PK
        text name
        real published_score
        int  published_count
        int  is_subject
    }
    review {
        int  review_id PK
        text property_key FK
        text review_date
        real rating
        text traveller_type
        int  nights
        text text_raw
        text text_clean
        int  n_chars_clean
        int  is_written
    }
    theme {
        text theme_key PK
        text theme_name
    }
    review_theme {
        int  review_id FK
        text theme_key FK
        text sentiment
    }
```

`review_theme.sentiment` carries `neg` or `pos`. It is the column that lets one query ask
*"how many guests complained about this"* and another ask *"how many reviews mention it at
all"*, without either having to be explained in a caption. The published version of this
analysis put both measures in one table and needed a footnote to separate them.
