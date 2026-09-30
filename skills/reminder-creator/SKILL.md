---
name: reminder-creator
description: Use when the intended output or mutation is Apple Reminders content: creating, updating, reorganizing, migrating, auditing, or polishing reminder items, lists, sections, and templates through apple reminders. Owns Reminders content modeling, item wording, source-to-reminder extraction, classification, field preservation, list and section information architecture, appearance hygiene, and scenario references such as shopping and wishlist work. This skill is not a CLI manual, implementation guide, standalone shopping or web research workflow, medical advice, financial advice, or product recommendation system.
---

# Reminder Creator

## Purpose

Use this skill whenever working on Apple Reminders content through
`apple reminders`. The atomic quality target is one high-quality reminder, but
the workflow can include lists, sections, subtasks, templates, completed
history, attachments, URLs, notes, priorities, repeat rules, alarms, locations,
and appearance.

This skill owns Reminders content modeling and migration quality. It does not
own CLI syntax, implementation details, or domain truth such as medical advice,
financial recommendations, product research, or webpage fetching/parsing
mechanics. Domain sources can inform the reminder, but the skill's job is to
turn evidence into a clear Reminders structure without losing existing app
state.

## When To Use

Use this skill for:

- creating a new reminder or list
- cleaning up a rough reminder title, URL, notes, or section
- extracting a shared link, article, social post, video, screenshot, SMS, or
  note into actionable Reminders items
- reorganizing lists, sections, parent items, and subtasks
- migrating items between lists while preserving important fields
- consolidating completed history without losing completion dates or
  attachments
- creating or maintaining reusable Reminders templates
- adjusting list type, color, icon, sorting, pinning, or attachment display
- auditing Reminders content after a previous migration or partial write

For shopping, wishlist, product, SKU, price, purchase channel, store,
location-shopping, or product-image work, read and apply
`references/shopping-list.md` in addition to this entrypoint. Shopping is a
scenario inside this skill package, not a separate user-facing skill.

## Execution CLI

Use `apple reminders` for Reminders reads and writes. This skill does not
duplicate CLI help; use `apple reminders --help` and subcommand help for
command syntax.

Read current state before writing. Preview supported mutations with `--dry-run`
when available. Read back after writing and verify the intended content model.
Do not bypass `apple reminders`, and do not write CLI or implementation details
into reminder titles, notes, sections, or templates.

When a command supports richer semantic operations, prefer it over delete and
recreate. Rebuild an item only when the target operation is not available and
field preservation has been planned explicitly.

## Information Architecture

Use Apple-style short, stable, noun-like list names. Lists are durable domain
boundaries, not temporary bins for every project or trip. Sections are for
scan-friendly organization inside a list. Parent reminders represent objects,
projects, dossiers, or durable intents. Subtasks represent actions, recurring
steps, candidate variants, checklist details, or historical steps that belong
under that parent.

Localized examples:

- `收件箱` is the unprocessed intake list.
- `待办事项` is for short-term actions and cross-domain backlog items that do
  not yet deserve a durable vertical list.
- Vertical lists such as health, finance, accounts, devices, home, developer,
  server, shopping, and wishlist own long-lived domain content.
- Do not create a durable top-level list for every short-lived trip or event.
  Prefer a reusable template when the workflow repeats and delete completed
  instances when the user wants only the template retained.
- Use sections to keep repeated workflows scannable; avoid overloading titles
  with category prefixes that sections should own.
- Use parent/subtask structures when multiple actions or variants belong to
  one object. Avoid vague parent items such as "research" or "整理" when a
  concrete object, account, policy, device, symptom, card, template, or project
  can own the work.

Use this ownership grammar before writing:

- List: long-lived domain, life area, or app workflow.
- Section: stable scan axis inside one list.
- Parent reminder: concrete object, project, dossier, template instance, or
  durable intent.
- Subtask: next action, checklist step, recurring action, candidate variant,
  detail under a parent, or historical step.
- Notes: short facts, source links, constraints, and verification caveats that
  help when acting.
- URL: the single page shown in the Reminders URL field; prefer a clean,
  human-recognizable canonical official, action, purchase, verification, or
  source page.

## Content Modeling Workflow

Model the user's intent before moving or writing anything. Do not let the
current list, source title, pasted URL, list metadata, or previous messy
structure decide the final shape.

1. Classify the input as action, object, dossier, source, template, product,
   recurring routine, completed history, or uncertain lead.
2. Choose the owning list by domain and long-term use. Create a new list only
   when the content has enough volume, repeated workflow, or a durable boundary
   that existing lists cannot express cleanly.
3. Choose the section by the way the user will scan the list later. Prefer
   short nouns over sentence-like section names. Avoid many slashes, temporary
   process labels, or sections that duplicate title prefixes.
4. Choose parent/subtask structure when one object has multiple actions,
   variants, historical steps, or supporting checks. Do not flatten related
   details into unrelated top-level items.
5. Rewrite titles into official names, concrete objects, or concrete actions.
   Source titles are not reminder titles after extraction.
6. Keep notes brief. They should answer "what do I need to know when acting?"
   not "how did this migration happen?"
7. Keep collaboration and processing details out of final Reminders content.
   The assistant may organize, extract, and migrate, but titles and notes should
   show the arranged result, not phrases such as "user said", "user provided",
   "extract source", or "confirm whether this source is useful".
8. Preserve completed items under the same taxonomy as incomplete items.
   Completed history is still useful context, not a dumping ground.
9. After writing, read back and inspect whether the list would still make sense
   if the conversation context disappeared.

Use an "action + dossier" model for complex domains. The parent item is the
dossier or durable object; subtasks are current actions, recurring actions,
checks, and completed history. Avoid generic parent items such as "资料",
"推荐", "调研", or "整理" unless the real object is still unknown.

For broad reorganizations, inventory the affected lists, sections, parent-child
relationships, completed items, URLs, attachments, repeat rules, and dates
before writing. Build a source-to-target mapping first, then apply changes in
small verifiable batches. Do not create migration-process reminders just to
explain the move; report migration limitations outside Reminders content.

## Reminder Quality Standard

Write reminders for repeated use inside the Reminders app, not as mini
documents.

- Title should be a concrete object or action. Avoid raw article titles,
  opaque source titles, category prefixes, or migration-process wording.
- URL should be the most representative official or trusted page for the
  reminder. If a discovery source is not the canonical target, keep it in notes
  instead of the URL field.
- Notes should be short, scan-friendly, and useful at action time. Avoid
  migration logs, "extracted from" process prose, and long reports.
- When notes use field labels such as `来源`, `参考`, `图片`, `官方`, `备注`,
  or scenario-specific labels, put each label on its own line. Do not pack
  multiple labeled fields into one sentence.
- Source links may be preserved when they explain why the reminder exists, but
  they should serve the reminder rather than turn the list into a source
  archive.
- For high-stakes domains, write actions to verify or gather evidence rather
  than unsourced conclusions.
- Keep completed history meaningful. Completed items can be reorganized, but
  completion state and completion date matter.

Use the user's language and naming style for item content. Use official or
trusted names when normalizing titles for cards, accounts, products, devices,
services, institutions, templates, and documents.

## Classification Patterns

Use existing domain lists before creating new top-level lists. A new list is
usually justified only when items have their own recurring workflow, dedicated
sections, or enough ongoing volume. Otherwise use a section or parent item in an
existing list.

- Intake: use an inbox-style list only for unprocessed external captures.
  Processed content should leave the inbox.
- Short-term action: use a todo/backlog list for cross-domain actions that are
  not yet a durable domain.
- Travel and repeating procedures: use templates for reusable checklists; keep
  trip instances disposable if the user wants only the template retained.
- Shopping: separate daily/grocery-style purchasing from wishlist/big-ticket
  desire tracking. Regional or trip shopping is a route/channel workflow, not a
  wishlist.
- Health: classify by person when responsibilities differ. Inside each health
  list, prefer stable sections such as health record, problems to confirm,
  appointments/tests, treatment follow-up, medication/supplements, lifestyle,
  and reimbursement. Informal sources create verification actions, not medical
  conclusions.
- Finance: classify by financial object: bank, card, account, brokerage,
  fund/product, insurance, social security, tax, or planning project. Prefer
  one card, account, policy, or product per parent item. Use official names and
  keep recommendation/source posts as notes after extraction.
- Accounts: classify by service provider or account domain when that is how the
  user will manage renewals, security, identity, and subscriptions. Avoid
  over-abstract buckets that hide the provider.
- Devices: classify by device owner or manufacturer/product family when model,
  service, warranty, repair, accessories, and history belong to one device.
  Put repair, warranty, accessories, and service tasks under the device rather
  than as disconnected operation buckets.
- Home: classify renovation and household systems by space or system. Keep
  home server/NAS/network infrastructure in the server or homelab domain, and
  ordinary shopping in shopping or wishlist domains.
- Developer: classify developer tools, references, workflows, and technical
  research separately from personal devices and server operations.

These are placement heuristics, not fixed user taxonomy. Keep the user's
current naming decisions when they are explicit and internally consistent.

## Source Extraction

Treat shared sources as evidence, not as final Reminders structure.

- Read source content when the user asks to extract or reorganize it and a
  supported source reader is available.
- Convert source-heavy items into concrete reminders, subtasks, or short notes.
- Do not leave article titles, naked URLs, or social/video titles as ordinary
  incomplete todos when the content has been processed.
- Do not preserve process items whose only job was to extract, inspect, or
  migrate a source. If the source is useful, merge its useful facts and links
  into the real parent reminder as `参考`, `来源`, or another natural field. If
  action is still needed, write a real action such as screening options,
  verifying rules, checking stock, or comparing models.
- XHS, Bilibili, comments, social posts, and personal blogs are directional
  evidence. They can suggest investigation directions, but they are not
  authoritative conclusions for health, finance, legal, or safety-sensitive
  reminders.
- In health, finance, insurance, legal, and other high-stakes domains, prefer
  official, institutional, or primary sources for conclusions. If only informal
  sources are available, create verification actions and put the informal
  source in short notes.
- If source reading fails, do not create a process reminder about source
  usefulness. Keep the original item unchanged and report the blocker, or turn
  it into a natural user action only when the lead itself is valuable.

Do not delete a source item merely because its content was extracted unless the
user authorized deletion. Marking source items complete is acceptable when the
source has been fully represented in target reminders and readback confirms the
target state.

## Field Preservation

Before moving, rebuilding, completing, deleting, or merging reminders, identify
which fields must survive:

- title
- notes
- URL
- attachments
- priority
- due date and alarms
- repeat rules
- location triggers
- list and section
- parent/subtask relationships
- tags when present
- completed state and completed date
- template identity, source template, and template-instance relationship when
  working with reusable workflows

Prefer direct move/update operations that preserve fields. Be conservative with
copy/delete workflows because they can lose attachments, completion dates,
repeat rules, or parent-child relationships. If an attachment-bearing item
cannot be moved safely, keep the original as archive evidence and link or note
the target reminder instead of deleting it.

For completed history migration, preserve the original completion date when the
CLI supports it. If completion date cannot be preserved, do not force a
cosmetic migration that destroys historical value.

## Lists, Templates, And Appearance

List type and appearance are Reminders metadata. Treat them as app state, not
as the primary source of content meaning.

- Set `listType=shopping` only after the content and user intent establish a
  shopping-list workflow.
- Keep shopping, wishlist, daily purchase, regional shopping, and brand/store
  lists aligned with `references/shopping-list.md`.
- Use templates for reusable workflows such as business travel checklists.
  Keep the template as the durable source when the user deletes trip instances
  after use.
- When editing templates, use `apple reminders templates` commands rather than
  draft-list workarounds unless a capability gap is explicit.
- When changing appearance only, do not change list title, list type, display
  order, pinning, sorting, large attachment display, sections, or items.
- Respect user-adjusted icons. Do not overwrite icons during color-only work.
  For color-only changes, do not pass or rewrite icon values.
- Colors should form a coherent palette across related lists. Avoid semantic
  rainbow palettes, muddy low-contrast palettes, and one-off colors that do not
  fit the set. Store exact color values as task decisions, not reusable skill
  rules.

## Scenario Routing

Apply the base workflow first, then use scenario-specific rules when the
content demands them:

- Shopping, wishlist, products, prices, SKUs, purchase channels, product
  images, route shopping, daily purchases, and shopping list sections:
  read `references/shopping-list.md`.
- Health reminders: turn informal sources into verification actions; keep
  symptoms, appointments, tests, treatment follow-up, medication/supplement
  checks, lifestyle work, and reimbursement in scan-friendly structures.
- Finance reminders: organize by financial object such as bank, card,
  brokerage, account, insurance, tax, social security, medical insurance, or
  planning project. Do not keep recommendation articles as todos after their
  actionable checks are extracted.
- Devices, home, servers, accounts, and developer work: keep domain boundaries
  clear. A server/NAS/network infrastructure item belongs with server or
  homelab content; ordinary personal hardware belongs with devices; renovation
  and household systems belong with home.

These scenario notes are placement rules, not domain advice.

## Validation Checklist

Before finishing a Reminders write:

- Dry-run passed for every mutation that supports dry-run.
- The target list, section, template, parent, or item resolved unambiguously.
- System and private lists were not modified unless explicitly requested and
  supported.
- List type, display order, pinning, sorting, and large attachment display are
  unchanged unless the user requested those fields.
- URLs, notes, attachments, priority, repeat rules, alarms, location triggers,
  completion state, completion date, and parent/subtask relationships were
  preserved or any limitation was reported.
- Source-heavy items are no longer unprocessed ordinary todos when extraction
  was completed.
- Shopping scenarios applied `references/shopping-list.md`.
- Readback confirms the expected state after writing.

If verification cannot prove a high-risk field, state the residual risk instead
of claiming the migration is complete.
