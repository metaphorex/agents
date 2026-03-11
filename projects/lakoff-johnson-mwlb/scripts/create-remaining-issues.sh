#!/usr/bin/env bash
# Create remaining sub-issues (starting from ideas-are-people)
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
  sleep 2
}

create_issue "ideas-are-people" "conceptual-metaphor" "social-roles" "intellectual-inquiry" \
  "The theory of relativity gave birth to new ideas. Medieval ideas still live on. Cognitive science is in its infancy. Those ideas need to be resurrected. Personification of intellectual constructs -- ideas have lifecycles."

create_issue "ideas-are-plants" "conceptual-metaphor" "cultivation" "intellectual-inquiry" \
  "His ideas have come to fruition. Budding theory. Seeds of revolution. Fertile imagination. The flower of his genius. Organic growth as intellectual development."

create_issue "ideas-are-products" "conceptual-metaphor" "manufacturing" "intellectual-inquiry" \
  "We have been turning out new ideas. Intellectual production. Assembly-line thinking. That is a rough idea -- it needs refining. Ideas as manufactured goods."

create_issue "ideas-are-cutting-instruments" "conceptual-metaphor" "tools-and-instruments" "intellectual-inquiry" \
  "That is an incisive observation. He cuts right to the heart of the matter. Sharp mind. Piercing analysis. A keen intellect. Ideas as bladed tools -- precision as sharpness."

create_issue "ideas-are-fashions" "conceptual-metaphor" "fashion" "intellectual-inquiry" \
  "That idea went out of style. Marxism is fashionable in Western Europe. Old hat. The latest thing in cognitive science. That is so last century. Ideas subject to trend cycles."

create_issue "the-mind-is-a-brittle-object" "conceptual-metaphor" "embodied-experience" "cognition" \
  "Her ego is fragile. He cracked up. His mind snapped. She is on the verge of a breakdown. Shattered confidence. Mental health as structural integrity."

create_issue "life-is-a-gambling-game" "conceptual-metaphor" "gambling" "life-experience" \
  "I will take my chances. The odds are against me. He is holding all the aces. Wild card. Play your cards right. Life decisions as wagers with uncertain outcomes."

create_issue "life-is-a-container" "conceptual-metaphor" "containers" "life-experience" \
  "I have had a full life. Her life is crammed with activities. Get the most out of life. An empty existence. A rich, full life. Life as a vessel to be filled."

create_issue "love-is-madness" "conceptual-metaphor" "madness" "love-and-relationships" \
  "I am crazy about her. He has gone mad over her. She drives me wild. I am insane about her. Love as loss of rational control. Romantic culture celebrates this mapping."

create_issue "love-is-a-physical-force" "conceptual-metaphor" "physical-forces" "love-and-relationships" \
  "There were sparks between them. Magnetic attraction. Gravitational pull. Electric chemistry. Love as physics -- attraction, repulsion, and fields of force."

create_issue "love-is-a-collaborative-work-of-art" "conceptual-metaphor" "creative-process" "love-and-relationships" \
  "L&J proposed alternative to the dominant love metaphors in Chapter 22-23. They built something beautiful together. Emphasizes joint creative effort rather than combat or travel. The least conventional love metaphor they explore."

create_issue "time-is-a-moving-object" "conceptual-metaphor" "journeys" "time-and-temporality" \
  "Time flies. The weeks crept by. Time marches on. The deadline is approaching. Opposite orientation from TIME IS A LANDSCAPE WE MOVE THROUGH -- here, time moves past the stationary observer."

create_issue "inflation-is-an-entity" "conceptual-metaphor" "social-roles" "economics-and-markets" \
  "Inflation is eating into our savings. Inflation has attacked the dollar. Inflation is backing us into a corner. L&J primary example of personification in ontological metaphors -- an abstract economic phenomenon treated as an adversary."

create_issue "labor-is-a-resource" "conceptual-metaphor" "shared-resources" "economics-and-markets" \
  "Cheap labor. The cost of labor. Human resources. Labor market. Treating peoples work as a fungible commodity. The metaphor hides the human being behind the abstraction."

create_issue "communication-is-sending" "conceptual-metaphor" "containers" "communication" \
  "Part of the conduit metaphor system but separable. Get the idea across. Put your thoughts into words. His words carried meaning. I could not get through to him. The sender-receiver model of communication."

create_issue "the-visual-field-is-a-container" "conceptual-metaphor" "containers" "vision" \
  "He came into view. The ship is out of sight. I cannot get it in my field of vision. It is within my line of sight. Perception bounded by a container metaphor."

create_issue "causes-are-forces" "conceptual-metaphor" "physical-forces" "causation" \
  "She pushed him into quitting. He was driven by ambition. What propelled you to act? Social pressures. Causation understood through physical force dynamics -- push, pull, drive, compel."

create_issue "purposes-are-destinations" "conceptual-metaphor" "journeys" "purposive-action" \
  "We are getting closer to our goal. We have reached that milestone. She is on her way to success. We are not there yet. Composes with LIFE IS A JOURNEY and ARGUMENT IS A JOURNEY."

create_issue "difficulties-are-obstacles" "conceptual-metaphor" "journeys" "purposive-action" \
  "She got over her divorce. He hit a wall. She is bogged down. They sidestepped the problem. Stumbling block. Entailed by LIFE IS A JOURNEY -- obstacles on the path."

create_issue "activities-are-containers" "conceptual-metaphor" "containers" "activities-and-events" \
  "He is in the race. She got out of the business. I am deep in conversation. He is into meditation. She fell into a depression. Activities as bounded spaces you enter and exit."

create_issue "closeness-is-strength-of-effect" "dead-metaphor" "spatial-orientation" "causation" \
  "That is a far-fetched idea. It is close to my heart. The near future. Closely related. A remote possibility. Grounded in physical proximity correlating with perceptual and causal influence."

echo ""
echo "Done! Created 21 remaining sub-issues under parent #1."
