---
project_issue: 1
repo: metaphorex/metaphorex
source_type: book
status: draft
---

# Lakoff & Johnson -- Metaphors We Live By

## Source Description

Lakoff, G. & Johnson, M. *Metaphors We Live By*. University of Chicago
Press, 1980. (2003 edition includes an Afterword.)

The foundational text of Conceptual Metaphor Theory (CMT). Argues that
metaphor is not a poetic flourish but the primary mechanism of human
thought. The book catalogs dozens of conceptual metaphors organized into
three types:

1. **Structural metaphors** -- one concept is metaphorically structured
   in terms of another (ARGUMENT IS WAR, TIME IS MONEY, LOVE IS A
   JOURNEY).

2. **Orientational metaphors** -- organizing a system of concepts via
   spatial orientation (HAPPY IS UP, RATIONAL IS UP, MORE IS UP).

3. **Ontological metaphors** -- understanding experiences, events, and
   activities as entities and substances (THE MIND IS A MACHINE, IDEAS
   ARE OBJECTS, INFLATION IS AN ENTITY).

The book also covers **personification** (a special case of ontological
metaphor) and **metonymy** (not metaphor, but a related systematic
mapping). We extract only genuine metaphors, not metonymies.

The 2003 Afterword introduces **primary metaphors** (grounded in bodily
experience) and **complex metaphors** (compositions of primaries), but
the main catalog comes from the 1980 text.

## Access Method

This is a published book in the Miner's training data. No API or
scraping needed. The Miner should work from:

- The metaphor name and its chapter context
- The expressions Lakoff & Johnson provide for each metaphor
- The structural analysis (what maps onto what)
- The Miner's own knowledge of the text

For verification, secondary sources include:
- Lakoff's 1993 paper "The Contemporary Theory of Metaphor"
- Kovecses, Z. *Metaphor: A Practical Introduction* (2002)
- The Master Metaphor List (Lakoff et al., UC Berkeley)

## Extraction Strategy

Each conceptual metaphor becomes one mapping entry. The extraction
approach:

1. **Name the metaphor** in the standard CMT format: TARGET IS SOURCE
   (e.g., ARGUMENT IS WAR, TIME IS MONEY). The slug converts this to
   kebab-case (argument-is-war, time-is-money).

2. **Identify the structural parallels** -- what features of the source
   domain carry over. Lakoff & Johnson call these "entailments." For
   TIME IS MONEY: time can be spent, wasted, saved, invested, budgeted.
   Each entailment is a structural parallel for "What It Brings."

3. **Find the breaks** -- where the metaphor hides or misleads. This is
   the highest-value section. TIME IS MONEY implies time is fungible and
   exchangeable, but time cannot actually be banked or transferred
   between people.

4. **Collect expressions** -- Lakoff & Johnson list example sentences
   for each metaphor. The Miner should reproduce these AND add
   contemporary examples the authors could not have known in 1980.

5. **Determine kind** -- almost all entries from this source are
   `conceptual-metaphor`. Orientational metaphors that are so embedded
   they no longer feel metaphorical (MORE IS UP) may qualify as
   `dead-metaphor`. The meta-level insight about metaphor itself
   (the conduit metaphor) might qualify as `paradigm`.

### Prioritization

Candidates are ordered by three criteria:
- **Metaphorical richness** -- how much structural depth the mapping has
- **Cultural impact** -- how widely the metaphor shapes behavior
- **Novelty in the catalog** -- whether the mapping adds something new

### Grouping

Several metaphors in the book form coherent systems. The Miner should
note these relationships in the `related:` field:

- TIME cluster: time-is-money, time-is-a-moving-object
- LOVE cluster: love-is-a-journey, love-is-war, love-is-madness,
  love-is-a-physical-force, love-is-a-collaborative-work-of-art
- IDEAS cluster: ideas-are-food, ideas-are-people, ideas-are-plants,
  ideas-are-products, ideas-are-cutting-instruments, ideas-are-fashions
- ARGUMENT cluster: argument-is-war (exists), argument-is-dance (exists),
  argument-is-a-journey, argument-is-a-building
- LIFE cluster: life-is-a-journey, life-is-a-gambling-game,
  life-is-a-container
- MIND cluster: the-mind-is-a-machine, the-mind-is-a-brittle-object

## Schema Mapping

### Frames needed (create if missing)

| Frame slug | Description |
|---|---|
| economics | Money, investment, budgets, commodities, exchange |
| food-and-cooking | Consumption, digestion, nourishment, recipes |
| physical-forces | Gravity, magnetism, electricity, momentum |
| madness | Insanity, irrationality, loss of control |
| fashion | Trends, styles, what's in/out |
| spatial-orientation | Up/down, in/out, front/back, center/periphery |
| vision | Seeing, light, clarity, blindness, perspective |
| journeys | Travel, paths, destinations, obstacles, crossroads |
| gambling | Odds, stakes, bets, luck, risk |
| cultivation | Planting, growing, harvesting, pruning |

Existing frames that will be reused:
- `war` (for ARGUMENT IS WAR -- already mapped)
- `architecture-and-building` (for THEORIES ARE BUILDINGS)
- `containers` (for LIFE IS A CONTAINER, THE VISUAL FIELD IS A CONTAINER)
- `manufacturing` (for IDEAS ARE PRODUCTS)
- `social-roles` (for IDEAS ARE PEOPLE)
- `dance` (for ARGUMENT IS DANCE -- already mapped)

### Categories

All entries from this project get:
- `cognitive-science` (mandatory -- this is CMT's home discipline)
- `linguistics` (mandatory -- the data is linguistic)

Additional categories as appropriate:
- `philosophy` (for entries touching epistemology, truth, causation)
- `psychology` (for emotion and mind metaphors)
- `social-dynamics` (for love and argument metaphors)

### Kind assignments

- Structural metaphors with rich entailment systems: `conceptual-metaphor`
- Orientational metaphors where the spatial basis is invisible to most
  speakers: `dead-metaphor`
- The conduit metaphor (communication-is-sending): `paradigm` -- it is
  a foundational framework for how we think about language itself

## Candidates

### Already in catalog (skip)

- `argument-is-war` -- exists as seed entry
- `argument-is-dance` -- exists as seed entry

### Tier 1: Major structural metaphors (11)

These are the book's most developed and impactful metaphors.

| # | Slug | Name | Kind | Source Frame | Target Frame | Chapter | Notes |
|---|---|---|---|---|---|---|---|
| 1 | time-is-money | Time Is Money | conceptual-metaphor | economics | time-and-temporality | 2-3 | The book's second major example after ARGUMENT IS WAR. Entailment system: spend, waste, save, invest, budget, borrow time. Grounds TIME IS A LIMITED RESOURCE and TIME IS A VALUABLE COMMODITY. |
| 2 | love-is-a-journey | Love Is A Journey | conceptual-metaphor | journeys | love-and-relationships | 11, 21-23 | Lovers as travelers, relationship as vehicle, difficulties as obstacles, goals as destinations. "We're at a crossroads." "This relationship isn't going anywhere." |
| 3 | theories-are-buildings | Theories Are Buildings | conceptual-metaphor | architecture-and-building | intellectual-inquiry | 3-4 | Foundations, frameworks, construction, collapse. "That theory has no foundation." "The argument collapsed." |
| 4 | ideas-are-food | Ideas Are Food | conceptual-metaphor | food-and-cooking | intellectual-inquiry | 10 | Digestion as comprehension. "Half-baked ideas." "Food for thought." "Raw facts." "Swallow that claim." |
| 5 | understanding-is-seeing | Understanding Is Seeing | conceptual-metaphor | vision | intellectual-inquiry | 10 | The dominant Western epistemological metaphor. "I see what you mean." "Shed light on." "Illuminate." "Murky reasoning." |
| 6 | the-conduit-metaphor | The Conduit Metaphor | paradigm | containers | communication | 10 | Redich's conduit metaphor, adopted by L&J: IDEAS ARE OBJECTS + EXPRESSIONS ARE CONTAINERS + COMMUNICATION IS SENDING. The meta-metaphor for language itself. |
| 7 | the-mind-is-a-machine | The Mind Is A Machine | conceptual-metaphor | manufacturing | cognition | 6 | "My mind isn't operating today." "I'm rusty." "We're trying to grind out a solution." Mental processes as mechanical operations. |
| 8 | life-is-a-journey | Life Is A Journey | conceptual-metaphor | journeys | life-experience | 11 | The master narrative metaphor. "She's at a crossroads." "He's gone down the wrong path." "Dead end." Composes with PURPOSES ARE DESTINATIONS. |
| 9 | argument-is-a-journey | Argument Is A Journey | conceptual-metaphor | journeys | argumentation | 3 | "We've covered a lot of ground." "We've arrived at the conclusion." Different from ARGUMENT IS WAR -- emphasizes progress, not combat. |
| 10 | argument-is-a-building | Argument Is A Building | conceptual-metaphor | architecture-and-building | argumentation | 3-4 | "Construct an argument." "Solid foundation." "The argument collapsed." Overlaps with THEORIES ARE BUILDINGS but focuses on argumentation specifically. |
| 11 | love-is-war | Love Is War | conceptual-metaphor | war | love-and-relationships | 21 | "She conquered his heart." "He's besieged by admirers." "She fought for him." L&J show how multiple metaphors for the same target coexist. |

### Tier 2: Orientational metaphors (6)

Spatial metaphors grounded in bodily experience. Several are so embedded
they qualify as dead metaphors.

| # | Slug | Name | Kind | Source Frame | Target Frame | Notes |
|---|---|---|---|---|---|---|
| 12 | happy-is-up | Happy Is Up | dead-metaphor | spatial-orientation | emotion | "I'm feeling up." "My spirits rose." "I'm feeling down." "He fell into a depression." Grounded in physical posture -- happy people stand erect, sad people droop. |
| 13 | more-is-up | More Is Up | dead-metaphor | spatial-orientation | quantity | "Prices are rising." "The number dropped." "Turn the volume up." Grounded in physical experience of adding to a pile. |
| 14 | rational-is-up | Rational Is Up | dead-metaphor | spatial-orientation | cognition | "The discussion fell to the emotional level." "He couldn't rise above his emotions." "High-minded." "Lofty ideals." |
| 15 | good-is-up | Good Is Up | dead-metaphor | spatial-orientation | morality | "Things are looking up." "Peak performance." "He fell from grace." "Low-down dirty trick." |
| 16 | conscious-is-up | Conscious Is Up | dead-metaphor | spatial-orientation | cognition | "Wake up." "He fell asleep." "He sank into a coma." "He's under hypnosis." Based on physical uprightness correlating with consciousness. |
| 17 | status-is-up | Status Is Up | dead-metaphor | spatial-orientation | social-dynamics | "She climbed to the top." "He's at the peak of his career." "Social climber." "Bottom of the hierarchy." |

### Tier 3: Ontological metaphors (8)

Treating abstractions as entities, substances, or containers.

| # | Slug | Name | Kind | Source Frame | Target Frame | Notes |
|---|---|---|---|---|---|---|
| 18 | ideas-are-people | Ideas Are People | conceptual-metaphor | social-roles | intellectual-inquiry | "The theory of relativity gave birth to new ideas." "Medieval ideas still live on." "Cognitive science is in its infancy." Personification of intellectual constructs. |
| 19 | ideas-are-plants | Ideas Are Plants | conceptual-metaphor | cultivation | intellectual-inquiry | "His ideas have come to fruition." "Budding theory." "Seeds of revolution." "Fertile imagination." |
| 20 | ideas-are-products | Ideas Are Products | conceptual-metaphor | manufacturing | intellectual-inquiry | "We've been turning out new ideas." "Intellectual production." "Assembly-line thinking." |
| 21 | ideas-are-cutting-instruments | Ideas Are Cutting Instruments | conceptual-metaphor | tools-and-instruments | intellectual-inquiry | "That's an incisive observation." "He cuts right to the heart of the matter." "Sharp mind." "Piercing analysis." |
| 22 | ideas-are-fashions | Ideas Are Fashions | conceptual-metaphor | fashion | intellectual-inquiry | "That idea went out of style." "Marxism is fashionable." "Old hat." "The latest thing in cognitive science." |
| 23 | the-mind-is-a-brittle-object | The Mind Is A Brittle Object | conceptual-metaphor | embodied-experience | cognition | "Her ego is fragile." "He cracked up." "His mind snapped." "She's on the verge of a breakdown." |
| 24 | life-is-a-gambling-game | Life Is A Gambling Game | conceptual-metaphor | gambling | life-experience | "I'll take my chances." "The odds are against me." "He's holding all the aces." "Wild card." |
| 25 | life-is-a-container | Life Is A Container | conceptual-metaphor | containers | life-experience | "I've had a full life." "Her life is crammed with activities." "Get the most out of life." "An empty existence." |

### Tier 4: Love cluster and additional structural metaphors (8)

| # | Slug | Name | Kind | Source Frame | Target Frame | Notes |
|---|---|---|---|---|---|---|
| 26 | love-is-madness | Love Is Madness | conceptual-metaphor | madness | love-and-relationships | "I'm crazy about her." "He's gone mad over her." "She drives me wild." Chapter 10. |
| 27 | love-is-a-physical-force | Love Is A Physical Force | conceptual-metaphor | physical-forces | love-and-relationships | "There were sparks between them." "Magnetic attraction." "Gravitational pull." Chapter 10. |
| 28 | love-is-a-collaborative-work-of-art | Love Is A Collaborative Work of Art | conceptual-metaphor | creative-process | love-and-relationships | L&J's proposed alternative to the dominant love metaphors. Chapter 22-23. "They built something beautiful together." Novel creation, not combat or travel. |
| 29 | time-is-a-moving-object | Time Is A Moving Object | conceptual-metaphor | journeys | time-and-temporality | "Time flies." "The weeks crept by." "Time marches on." Opposite orientation from TIME IS A LANDSCAPE WE MOVE THROUGH. |
| 30 | inflation-is-an-entity | Inflation Is An Entity | conceptual-metaphor | social-roles | economics-and-markets | "Inflation is eating into our savings." "Inflation has attacked the dollar." "Inflation is backing us into a corner." Personification example. |
| 31 | labor-is-a-resource | Labor Is A Resource | conceptual-metaphor | shared-resources | economics-and-markets | "Cheap labor." "The cost of labor." "Human resources." Treating people's work as a fungible commodity. |
| 32 | communication-is-sending | Communication Is Sending | conceptual-metaphor | containers | communication | Part of the conduit metaphor system but separable. "Get the idea across." "Put your thoughts into words." "His words carried meaning." |
| 33 | the-visual-field-is-a-container | The Visual Field Is A Container | conceptual-metaphor | containers | vision | "He came into view." "The ship is out of sight." "I can't get it in my field of vision." |

### Tier 5: Causation and abstract structure (5)

| # | Slug | Name | Kind | Source Frame | Target Frame | Notes |
|---|---|---|---|---|---|---|
| 34 | causes-are-forces | Causes Are Forces | conceptual-metaphor | physical-forces | causation | "She pushed him into quitting." "He was driven by ambition." "What propelled you to act?" Chapter 14. |
| 35 | purposes-are-destinations | Purposes Are Destinations | conceptual-metaphor | journeys | purposive-action | "We're getting closer to our goal." "We've reached that milestone." "She's on her way to success." Composes with LIFE IS A JOURNEY. |
| 36 | difficulties-are-obstacles | Difficulties Are Obstacles | conceptual-metaphor | journeys | purposive-action | "She got over her divorce." "He hit a wall." "She's bogged down." Entailed by LIFE IS A JOURNEY. |
| 37 | activities-are-containers | Activities Are Containers | conceptual-metaphor | containers | activities-and-events | "He's in the race." "She got out of the business." "I'm deep in conversation." Chapter 6. |
| 38 | closeness-is-strength-of-effect | Closeness Is Strength of Effect | dead-metaphor | spatial-orientation | causation | "That's a far-fetched idea." "It's close to my heart." "The near future." Grounded in physical proximity correlating with perceptual and causal influence. |

**Total: 38 candidates** (plus 2 already in catalog = 40 metaphors from the text)

## Frames to Create

The Miner will need to create or verify these frames alongside the
mapping entries:

| Frame slug | Name | Roles |
|---|---|---|
| economics | Economics | buyer, seller, commodity, price, market, investment |
| food-and-cooking | Food and Cooking | cook, eater, ingredient, dish, recipe, digestion |
| physical-forces | Physical Forces | agent, patient, force, direction, resistance |
| madness | Madness | sufferer, delusion, loss-of-control, obsession |
| fashion | Fashion | trend, trendsetter, follower, style, obsolescence |
| spatial-orientation | Spatial Orientation | up, down, center, periphery, front, back |
| vision | Vision | seer, scene, light, darkness, focus, perspective |
| journeys | Journeys | traveler, path, destination, obstacle, crossroads |
| gambling | Gambling | player, bet, odds, stakes, outcome, luck |
| cultivation | Cultivation | gardener, seed, soil, growth, harvest, pruning |
| cognition | Cognition | thinker, thought, reasoning, understanding, insight |
| love-and-relationships | Love and Relationships | lover, beloved, bond, attraction, commitment |
| time-and-temporality | Time and Temporality | moment, duration, past, present, future |
| intellectual-inquiry | Intellectual Inquiry | theorist, theory, evidence, argument, insight |
| life-experience | Life Experience | person, experience, phase, milestone, meaning |
| communication | Communication | speaker, listener, message, channel, meaning |
| emotion | Emotion | experiencer, feeling, intensity, trigger, expression |
| quantity | Quantity | amount, increase, decrease, measure, scale |
| morality | Morality | actor, action, virtue, vice, judgment |
| social-dynamics | Social Dynamics | actor, status, power, hierarchy, mobility |
| causation | Causation | cause, effect, agent, mechanism, outcome |
| purposive-action | Purposive Action | agent, goal, plan, obstacle, achievement |
| activities-and-events | Activities and Events | participant, activity, boundary, duration |
| economics-and-markets | Economics and Markets | buyer, seller, commodity, price, market |
| tools-and-instruments | Tools and Instruments | user, tool, function, edge, precision |

Note: many of these may already exist or overlap with existing frames.
The Miner should check `catalog/frames/` before creating new ones and
prefer reusing existing frames where the mapping is reasonable.

## Gotchas

1. **ARGUMENT IS WAR and ARGUMENT IS DANCE already exist.** Do not
   create duplicates. New argument metaphors (ARGUMENT IS A JOURNEY,
   ARGUMENT IS A BUILDING) should link to them via `related:`.

2. **The IDEAS cluster is large.** Six metaphors for IDEAS may feel
   redundant, but Lakoff & Johnson explicitly argue that multiple
   metaphors for the same target illuminate different aspects. Each
   entry should note what THIS metaphor highlights that the others
   don't.

3. **Orientational metaphors are thin.** HAPPY IS UP, MORE IS UP, etc.
   have simple structure. The Miner should keep these entries short but
   focus on the grounding -- WHY up=good (physical posture, piles
   growing upward). The "Where It Breaks" section should note cultural
   variation (not all languages map good=up).

4. **The conduit metaphor is the richest entry.** It's actually a
   composition of three metaphors (IDEAS ARE OBJECTS, EXPRESSIONS ARE
   CONTAINERS, COMMUNICATION IS SENDING). The Miner can either write
   it as one `paradigm` entry or split it. I recommend one entry with
   the components explained, since the insight is in the composition.

5. **Avoid pattern-tutorial mode.** Each entry is about the metaphorical
   mapping, not a summary of CMT. The Miner should not explain what
   conceptual metaphor theory IS -- the reader can look that up. Focus
   on what THIS specific metaphor reveals and conceals.

6. **The 2003 Afterword.** The Afterword introduces primary metaphors
   (KNOWING IS SEEING, INTIMACY IS CLOSENESS, etc.) and neural binding
   theory. These are interesting but the core candidates come from the
   1980 text. A few Afterword insights (like the primary metaphor
   concept) can enrich individual entries but should not generate a
   whole new batch.

7. **Dead metaphor vs. conceptual metaphor for orientational entries.**
   Most speakers don't realize "things are looking up" is a spatial
   metaphor. These genuinely qualify as `dead-metaphor` -- the spatial
   origin is forgotten by most users.

8. **Frame proliferation.** This project requires many new frames.
   The Miner should batch-create frames as needed but keep descriptions
   minimal -- a frame is a conceptual domain, not an essay. One
   paragraph plus roles is sufficient.

9. **Metonymy is not metaphor.** The book discusses FACE FOR PERSON,
   PRODUCER FOR PRODUCT, etc. These are metonymies (part-for-whole or
   associated-thing-for-thing) and should NOT be extracted as mappings.
   The candidates list above excludes them.

10. **Chapter references are approximate.** The chapter numbers in the
    candidates table indicate where the metaphor is primarily discussed
    but most metaphors recur throughout the book. The Miner should not
    limit their analysis to a single chapter.
