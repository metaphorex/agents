#!/usr/bin/env bash
# Create sub-issues for Lakoff & Johnson — Metaphors We Live By
# Each candidate gets a sub-issue under parent issue #1
set -euo pipefail

PARENT_NODE_ID="I_kwDORg8h4c7wwK6Y"
REPO="metaphorex/metaphorex"
PROJECT="lakoff-johnson-mwlb"

create_issue() {
  local slug="$1"
  local kind="$2"
  local source_frame="$3"
  local target_frame="$4"
  local description="$5"

  local title="[${PROJECT}] ${slug}"

  local body
  body=$(cat <<EOF
**Slug:** \`${slug}\`
**Kind:** \`${kind}\`
**Source frame:** \`${source_frame}\`
**Target frame:** \`${target_frame}\`

${description}

---
Source: Lakoff, G. & Johnson, M. *Metaphors We Live By* (1980)
Parent project: #1
EOF
  )

  echo "Creating: ${title}"
  local url
  url=$(gh issue create --repo "$REPO" --title "$title" --body "$body" --label "import-project" 2>&1)
  local issue_number
  issue_number=$(echo "$url" | grep -o '[0-9]*$')

  # Get the child node ID
  local child_id
  child_id=$(gh api graphql -f query="{ repository(owner: \"metaphorex\", name: \"metaphorex\") { issue(number: ${issue_number}) { id } } }" --jq '.data.repository.issue.id')

  # Set as sub-issue
  gh api graphql -f query="mutation { addSubIssue(input: { issueId: \"${PARENT_NODE_ID}\", subIssueId: \"${child_id}\" }) { subIssue { number } } }" --silent

  echo "  Created #${issue_number}, linked as sub-issue"
}

# Tier 1: Major structural metaphors
create_issue "time-is-money" "conceptual-metaphor" "economics" "time-and-temporality" \
  "The book's second major example after ARGUMENT IS WAR. Time can be spent, wasted, saved, invested, budgeted, borrowed. Grounds the entailment system TIME IS A LIMITED RESOURCE and TIME IS A VALUABLE COMMODITY. Reveals how capitalism's logic colonizes temporal experience."

create_issue "love-is-a-journey" "conceptual-metaphor" "journeys" "love-and-relationships" \
  "Lovers as travelers, the relationship as a vehicle, difficulties as obstacles, goals as destinations. 'We're at a crossroads.' 'This relationship isn't going anywhere.' 'We've come a long way together.' One of L&J's most structurally developed examples."

create_issue "theories-are-buildings" "conceptual-metaphor" "architecture-and-building" "intellectual-inquiry" \
  "Foundations, frameworks, construction, collapse. 'That theory has no foundation.' 'The argument collapsed.' 'We need to buttress the theory.' Shows how we evaluate ideas by structural metaphors from construction."

create_issue "ideas-are-food" "conceptual-metaphor" "food-and-cooking" "intellectual-inquiry" \
  "Digestion as comprehension. 'Half-baked ideas.' 'Food for thought.' 'Raw facts.' 'Swallow that claim.' 'Let that idea simmer.' 'The meaty part of the paper.' Intellect as alimentary process."

create_issue "understanding-is-seeing" "conceptual-metaphor" "vision" "intellectual-inquiry" \
  "The dominant Western epistemological metaphor. 'I see what you mean.' 'Shed light on.' 'Illuminate.' 'Murky reasoning.' 'Brilliant insight.' Privileges visual perception as the model for knowing."

create_issue "the-conduit-metaphor" "paradigm" "containers" "communication" \
  "Reddy's conduit metaphor, adopted by L&J: IDEAS ARE OBJECTS + EXPRESSIONS ARE CONTAINERS + COMMUNICATION IS SENDING. The meta-metaphor for language itself. 'Get the idea across.' 'Put your thoughts into words.' 'His words carried meaning.' A paradigm-level mapping that shapes how we think about thinking."

create_issue "the-mind-is-a-machine" "conceptual-metaphor" "manufacturing" "cognition" \
  "'My mind isn't operating today.' 'I'm a little rusty.' 'We're trying to grind out the solution.' 'He just ran out of steam.' Mental processes as mechanical operations -- productive, breakable, requiring fuel."

create_issue "life-is-a-journey" "conceptual-metaphor" "journeys" "life-experience" \
  "The master narrative metaphor. 'She's at a crossroads.' 'He's gone down the wrong path.' 'Dead end.' 'Milestone.' Composes with PURPOSES ARE DESTINATIONS. Structures biography, career advice, and self-help discourse."

create_issue "argument-is-a-journey" "conceptual-metaphor" "journeys" "argumentation" \
  "'We've covered a lot of ground.' 'We've arrived at the conclusion.' 'We've come to a dead end.' Different from ARGUMENT IS WAR -- emphasizes progress and direction, not combat. Related to argument-is-war and argument-is-dance."

create_issue "argument-is-a-building" "conceptual-metaphor" "architecture-and-building" "argumentation" \
  "'Construct an argument.' 'Solid foundation.' 'The argument collapsed.' 'Framework.' Overlaps with THEORIES ARE BUILDINGS but applied specifically to argumentation. Related to argument-is-war and argument-is-dance."

create_issue "love-is-war" "conceptual-metaphor" "war" "love-and-relationships" \
  "'She conquered his heart.' 'He's besieged by admirers.' 'She fought for him.' 'He made an ally of her mother.' L&J show how multiple metaphors for the same target coexist and compete."

# Tier 2: Orientational metaphors
create_issue "happy-is-up" "dead-metaphor" "spatial-orientation" "emotion" \
  "'I'm feeling up.' 'My spirits rose.' 'I'm feeling down.' 'He fell into a depression.' Grounded in physical posture -- happy people stand erect, sad people droop. So embedded most speakers don't notice the spatial mapping."

create_issue "more-is-up" "dead-metaphor" "spatial-orientation" "quantity" \
  "'Prices are rising.' 'The number dropped.' 'Turn the volume up.' 'Stock prices hit bottom.' Grounded in physical experience of adding to a pile -- more stuff means a higher level."

create_issue "rational-is-up" "dead-metaphor" "spatial-orientation" "cognition" \
  "'The discussion fell to the emotional level.' 'He couldn't rise above his emotions.' 'High-minded.' 'Lofty ideals.' Maps a vertical hierarchy onto the reason/emotion divide, privileging reason."

create_issue "good-is-up" "dead-metaphor" "spatial-orientation" "morality" \
  "'Things are looking up.' 'Peak performance.' 'He fell from grace.' 'Low-down dirty trick.' 'Upstanding citizen.' The spatial basis for moral vocabulary."

create_issue "conscious-is-up" "dead-metaphor" "spatial-orientation" "cognition" \
  "'Wake up.' 'He fell asleep.' 'He sank into a coma.' 'He's under hypnosis.' 'She rose from the dead.' Based on physical uprightness correlating with consciousness."

create_issue "status-is-up" "dead-metaphor" "spatial-orientation" "social-dynamics" \
  "'She climbed to the top.' 'He's at the peak of his career.' 'Social climber.' 'Bottom of the hierarchy.' 'Upper management.' Physical elevation as social position."

# Tier 3: Ontological metaphors
create_issue "ideas-are-people" "conceptual-metaphor" "social-roles" "intellectual-inquiry" \
  "'The theory of relativity gave birth to new ideas.' 'Medieval ideas still live on.' 'Cognitive science is in its infancy.' 'Those ideas need to be resurrected.' Personification of intellectual constructs -- ideas have lifecycles."

create_issue "ideas-are-plants" "conceptual-metaphor" "cultivation" "intellectual-inquiry" \
  "'His ideas have come to fruition.' 'Budding theory.' 'Seeds of revolution.' 'Fertile imagination.' 'The flower of his genius.' Organic growth as intellectual development."

create_issue "ideas-are-products" "conceptual-metaphor" "manufacturing" "intellectual-inquiry" \
  "'We've been turning out new ideas.' 'Intellectual production.' 'Assembly-line thinking.' 'That's a rough idea -- it needs refining.' Ideas as manufactured goods."

create_issue "ideas-are-cutting-instruments" "conceptual-metaphor" "tools-and-instruments" "intellectual-inquiry" \
  "'That's an incisive observation.' 'He cuts right to the heart of the matter.' 'Sharp mind.' 'Piercing analysis.' 'A keen intellect.' Ideas as bladed tools -- precision as sharpness."

create_issue "ideas-are-fashions" "conceptual-metaphor" "fashion" "intellectual-inquiry" \
  "'That idea went out of style.' 'Marxism is fashionable in Western Europe.' 'Old hat.' 'The latest thing in cognitive science.' 'That's so last century.' Ideas subject to trend cycles."

create_issue "the-mind-is-a-brittle-object" "conceptual-metaphor" "embodied-experience" "cognition" \
  "'Her ego is fragile.' 'He cracked up.' 'His mind snapped.' 'She's on the verge of a breakdown.' 'Shattered confidence.' Mental health as structural integrity."

create_issue "life-is-a-gambling-game" "conceptual-metaphor" "gambling" "life-experience" \
  "'I'll take my chances.' 'The odds are against me.' 'He's holding all the aces.' 'Wild card.' 'Play your cards right.' Life decisions as wagers with uncertain outcomes."

create_issue "life-is-a-container" "conceptual-metaphor" "containers" "life-experience" \
  "'I've had a full life.' 'Her life is crammed with activities.' 'Get the most out of life.' 'An empty existence.' 'A rich, full life.' Life as a vessel to be filled."

# Tier 4: Love cluster and additional structural
create_issue "love-is-madness" "conceptual-metaphor" "madness" "love-and-relationships" \
  "'I'm crazy about her.' 'He's gone mad over her.' 'She drives me wild.' 'I'm insane about her.' Love as loss of rational control. Romantic culture celebrates this mapping."

create_issue "love-is-a-physical-force" "conceptual-metaphor" "physical-forces" "love-and-relationships" \
  "'There were sparks between them.' 'Magnetic attraction.' 'Gravitational pull.' 'Electric chemistry.' Love as physics -- attraction, repulsion, and fields of force."

create_issue "love-is-a-collaborative-work-of-art" "conceptual-metaphor" "creative-process" "love-and-relationships" \
  "L&J's proposed alternative to the dominant love metaphors in Chapter 22-23. 'They built something beautiful together.' Emphasizes joint creative effort rather than combat or travel. The least conventional love metaphor they explore."

create_issue "time-is-a-moving-object" "conceptual-metaphor" "journeys" "time-and-temporality" \
  "'Time flies.' 'The weeks crept by.' 'Time marches on.' 'The deadline is approaching.' Opposite orientation from TIME IS A LANDSCAPE WE MOVE THROUGH -- here, time moves past the stationary observer."

create_issue "inflation-is-an-entity" "conceptual-metaphor" "social-roles" "economics-and-markets" \
  "'Inflation is eating into our savings.' 'Inflation has attacked the dollar.' 'Inflation is backing us into a corner.' L&J's primary example of personification in ontological metaphors -- an abstract economic phenomenon treated as an adversary."

create_issue "labor-is-a-resource" "conceptual-metaphor" "shared-resources" "economics-and-markets" \
  "'Cheap labor.' 'The cost of labor.' 'Human resources.' 'Labor market.' Treating people's work as a fungible commodity. The metaphor hides the human being behind the abstraction."

create_issue "communication-is-sending" "conceptual-metaphor" "containers" "communication" \
  "Part of the conduit metaphor system but separable. 'Get the idea across.' 'Put your thoughts into words.' 'His words carried meaning.' 'I couldn't get through to him.' The sender-receiver model of communication."

create_issue "the-visual-field-is-a-container" "conceptual-metaphor" "containers" "vision" \
  "'He came into view.' 'The ship is out of sight.' 'I can't get it in my field of vision.' 'It's within my line of sight.' Perception bounded by a container metaphor."

# Tier 5: Causation and abstract structure
create_issue "causes-are-forces" "conceptual-metaphor" "physical-forces" "causation" \
  "'She pushed him into quitting.' 'He was driven by ambition.' 'What propelled you to act?' 'Social pressures.' Causation understood through physical force dynamics -- push, pull, drive, compel."

create_issue "purposes-are-destinations" "conceptual-metaphor" "journeys" "purposive-action" \
  "'We're getting closer to our goal.' 'We've reached that milestone.' 'She's on her way to success.' 'We're not there yet.' Composes with LIFE IS A JOURNEY and ARGUMENT IS A JOURNEY."

create_issue "difficulties-are-obstacles" "conceptual-metaphor" "journeys" "purposive-action" \
  "'She got over her divorce.' 'He hit a wall.' 'She's bogged down.' 'They sidestepped the problem.' 'Stumbling block.' Entailed by LIFE IS A JOURNEY -- obstacles on the path."

create_issue "activities-are-containers" "conceptual-metaphor" "containers" "activities-and-events" \
  "'He's in the race.' 'She got out of the business.' 'I'm deep in conversation.' 'He's into meditation.' 'She fell into a depression.' Activities as bounded spaces you enter and exit."

create_issue "closeness-is-strength-of-effect" "dead-metaphor" "spatial-orientation" "causation" \
  "'That's a far-fetched idea.' 'It's close to my heart.' 'The near future.' 'Closely related.' 'A remote possibility.' Grounded in physical proximity correlating with perceptual and causal influence."

echo ""
echo "Done! Created 38 sub-issues under parent #1."
