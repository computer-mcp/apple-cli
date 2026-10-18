# Reminders Shopping List Reference

## Contents

- Purpose
- Execution CLI
- Execution Workflow
- Item Schema
- Sections And Locations
- Parent And Subitems
- Covered Operations
- Validation Checklist

## Purpose

Use this reference whenever modifying or organizing a shopping list through
`apple reminders`. It defines the format standard and distinguishes shopping-list
types; it is not a separate selector.

Apply this standard to every Reminders list being treated as a shopping list.
Do not infer the intended shopping-list type from the list's current Reminders
metadata. Apple-native `listType=shopping` is app state to verify or correct
after the user's intent and item content establish that the list is a shopping
list; it is not evidence that the list should use Wishlist or Shopping
organization. If a list has shopping metadata but the content is actually
research, project planning, media watchlist, or another non-shopping workflow,
do not force this format onto it. The rule applies to both incomplete and
completed shopping items; completed history is not a separate structure.

The design reference is Apple Reminders Grocery/Shopping automatic sectioning:
Apple groups grocery items to reduce shopping friction, and the Reminders UI
exposes this as a list type. This reference generalizes that idea to things-to-buy
lists, but the section strategy depends on the shopping-list type. Wishlist
lists optimize for remembering what the user wants independent of where the
final checkout occurs. Shopping lists optimize for where and when buying happens.

Before reorganizing a list, identify its shopping-list type:

- Wishlist: a durable record of things the user might buy, used to avoid
  scattering intent across web stores, carts, wishlists, notes, and saved links.
  Buying depends mainly on whether the user still wants the item, not on being
  at a place or inside a specific shopping platform.
- Shopping: a plan where buying depends on being in a country, city, airport,
  store, venue, trip context, grocery aisle, marketplace, or merchant.

If explicit user intent and item content do not establish Wishlist or Shopping,
ask the user or leave the current organization unchanged. Never use current
Reminders metadata, current sections, sorting, or existing list shape as a
tiebreaker for choosing the intended shopping-list type.

Do not apply Shopping route or platform sections to a Wishlist list. Do not
apply Wishlist brand/source grouping to a Shopping list when the real buying
constraint is location, itinerary, or channel execution.

## Execution CLI

Use `apple reminders` for Reminders reads and writes. This reference does not
duplicate CLI help; use `apple reminders --help` and subcommand help for command
syntax.

Read current state before writing. Preview supported mutations with `--dry-run`
when available. Read back after writing and verify the intended shopping content
model.

Do not bypass `apple reminders`, and do not write CLI or implementation details
into reminder titles, notes, sections, or templates.

Set Reminders shopping-list metadata only after the content and user intent
establish a shopping-list workflow. Treat list metadata as app state to align
after the shopping-list type is chosen from user intent and item content, not as
an input for choosing Wishlist or Shopping organization.

## Execution Workflow

When creating, updating, auditing, reorganizing, merging, splitting, repairing,
or otherwise maintaining shopping items, apply this schema to every item that is
touched or intentionally retained. Do not stop after a placeholder write unless
the user explicitly asked for a lightweight capture. Treat user photos,
screenshots, social posts, videos, articles, and short notes as discovery
evidence, then normalize the item into the full schema.

For each concrete product item, resolve these fields before finishing:

1. official or trusted item title
2. primary display URL, plus any separate official store/source URL needed to
   act later
3. visible price, original price when shown, and visible date
4. section and purchase place, including exact store name and address for
   offline shopping when known
5. real location trigger when a real-world place is useful and coordinates are
   known
6. official or trusted product image attachment
7. notes in fixed field order, including source evidence and unresolved risks

If a field cannot be resolved from reliable sources, write the unresolved state
explicitly instead of omitting it. For example, write `价格：待确认` or
`购买地点：<specific terminal, store, venue, or route>；店名待确认` rather than
leaving the field out. In the final response, call out any unresolved required
field.

For travel, airport, venue, and store items, use the most specific known buying
context available from the user's memory and trusted venue directories. Prefer a
terminal, gate area, store, venue, city district, or route section over a broad
section such as `机场` when the specific context is known. If the exact store is
not confirmed, keep the specific route section and put the uncertainty in
`购买地点` or `备注`.

For trip or offline shopping, keep the section aligned to the intended real
buying route or store even when an online official store, brand site, or source
page is sold out, not directly purchasable, or only useful for verification.
Record sold-out, stock, display, or orderability uncertainty in `备注`; do not
move the item to an online-store, marketplace, or uncertainty section unless
the user's intended buying route actually changed.

When an official or trusted page exposes an obvious store address, store URL,
route URL, product URL, coordinates, or product image, do not omit it. Put the
actionable page in the URL field, put supporting source/store/image-reference
pages in `来源` or `备注`, attach the image as a Reminders attachment, and add a
location trigger when coordinates are reliable. Do not finish with only a naked
image URL, a broad district, or a store name when the exact address and
coordinates are available.

For price evidence, use the price from the intended purchase place when it is
visible. If the intended place has no public price, a trusted same-SKU retail
price may be recorded only with its source and visible date, and notes must say
that the intended-place price is still unconfirmed. Do not convert a pack price
into a single-unit price unless the page itself provides that unit price and the
unit matches the intended item.

## Item Schema

Apply the same item schema regardless of shopping-list type. Wishlist and
Shopping change the section axis, purchase-context interpretation, and where
candidate purchase channels are recorded; they do not change the item fields,
field order, source/price/image requirements, or completion standard.

Apply the same schema to parent items and subitems.

### Title

Use the official or trusted product, series, or source-backed item name:

```text
<official/trusted name>[（necessary qualifier）]
```

Use suffixes only when they disambiguate condition, place, channel, model, SKU,
color, or variant:

```text
<brand> <model>（中古）
<series> <variant>（<SKU> / <color>）
<venue-exclusive item>（<place or channel qualifier>）
```

Do not use category prefixes such as `[美妆]`, `[游戏]`, or `[机场]`. Sections
carry organization; titles carry item identity.

### URL

The URL field is the URL shown by the Reminders UI. Use one clean,
human-recognizable page that best represents the item at action time:

- official product page
- official store page
- trusted purchase page
- trusted verification page

Discovery sources such as social posts, videos, articles, and user notes belong
in `来源`, not in the URL field, unless they are the only credible verification
source.

Prefer official or brand-direct pages over marketplaces and resellers. This
workflow is not a cross-platform price comparison system. Use marketplace or
reseller pages only when the official page is not useful for action,
verification, or item identity.

When the official purchase or stock-status URL is a long query URL, session-like
URL, or otherwise poor as the visible Reminders URL, use the clean official
product or canonical page in the URL field and put the long operational link in
notes as `购买页`, `商品页`, `库存`, or another natural flat field.

This reference is not permission to perform open-ended shopping research. Use
user-provided sources or sources the user explicitly authorized for the task. If
reliable source access is not available, leave URL or price fields as
`待确认` and do not download or attach images.

In a Wishlist list, the URL may be the official verification page even when
that page is not directly purchasable. Candidate purchase links then belong in
notes. In a Shopping list, prefer a page useful at buying time, but do not make
the visible URL ugly just to preserve an operational purchase query; keep that
query in notes when the clean official page is the better displayed URL.

When an official or brand-direct page is the primary purchase page, keep
marketplace or reseller links out of the URL field and out of section choice.
Record them in `备注` only when they are useful alternative purchase options or
price-availability context. Record them in `来源` only when that marketplace or
reseller page is the reason the item exists.

Parent items may use an official series page. Subitems should use concrete
product, SKU, or variant pages when available.

### Notes

Use fixed field order. Omit irrelevant fields, but do not reorder fields. Use
the user's or list's language for field labels; the labels below are the default
Chinese template for Chinese-language lists.

```text
价格：<currency> ...（tax/discount status，YYYY-MM-DD 可见）
原价：<currency> ...（only if shown）
商品番号：...
SKU：...
颜色：...
尺寸：...
购买地点：...
来源：...
参考：...
商品页：...
门店：...
图片：...
备注：...
```

Rules:

- Put each field label on its own line. Do not write multiple labeled fields in
  one sentence such as `来源：商品页...；门店...；图片...`.
- Avoid empty grouping labels that make notes feel like a source tree. Prefer
  flat fields such as `来源：Bilibili 视频 https://...`,
  `商品页：https://...`, and `门店：https://...` over
  `来源：` followed by nested labels like `Bilibili：...`.
- `来源` records why the item exists or what evidence supports it, including
  discovery sources such as videos, social posts, articles, or user-provided
  leads. Keep it as a complete single-line field, for example
  `来源：Bilibili 视频 https://...`, not as a parent label for nested source
  rows.
- Use `参考` only when a link is a secondary optional reference rather than the
  reason the item exists.
- Product, store, tax-free, image-reference, or other official/trusted pages
  should normally be their own flat fields, such as `商品页`, `门店`, `免税`, or
  `图片`, when they are needed to understand or act on the item.
- Currency follows the purchase page. Do not hardcode JPY.
- If no reliable price is visible, write `价格：待确认`.
- Write `原价` only when the page explicitly shows it.
- Keep `备注` short. Use it for risks, ambiguity, constraints, or human review
  points.
- Do not paste raw direct image CDN URLs into notes by default. If the attached
  image comes from a secondary official/trusted product page rather than the
  primary item URL, record the trusted page as `图片：<page URL>` under `来源`
  or mention it naturally in `备注`.
- For offline shopping, `购买地点` should name the exact store and address when
  known; put inventory, route, or "store not confirmed" uncertainty in `备注`.

### Attachments

High-confidence product items should have at least one high-quality official or
trusted product image attachment.

- Prefer product-page gallery images, official store images, or trusted
  purchase-page product images. A secondary official/trusted same-product or
  same-SKU page is acceptable for the image when the primary page is the right
  URL but its image cannot be downloaded or attached.
- Download or otherwise materialize the image as a local file and attach it to
  the reminder; do not treat an image URL in notes as a substitute for an
  attachment.
- Avoid thumbnails, logos, placeholder images, and social-media screenshots.
- Treat user-provided photos and screenshots as discovery/source evidence, not
  the default final product image. Replace them with official or trusted product
  images when available; keep a user image only when it is the best available
  evidence and note the limitation in `备注`.
- Parent items get representative images when available.
- SKU, color, model, or variant subitems get item-specific images when
  available.
- After attachment writes, read back and verify attachment count and type.

## Sections And Locations

Sections implement Apple-style shopping-list organization. The correct section
axis follows the list's shopping-list type.

### Wishlist Type

Use sections to group the object of intent: brand, product family, official
source, or canonical verification source. The list exists because the user wants
to remember the item, not because the user is already shopping in a specific
cart.

Rules for Wishlist lists:

- Prefer concrete brand, product-family, or official-source sections, such as
  `<Brand> Store`, `<Brand> 官网`, `<Brand> 官方商店`, or `<Product Family>`.
- Third-party marketplaces and resellers are usually alternative purchase options
  or price evidence. Keep those links in `备注`, not as the section driver,
  unless the marketplace itself is the only known primary source.
- A marketplace section is appropriate only when the item has no stronger
  official/source grouping, the user's intent is specifically tied to that
  marketplace, or the marketplace itself is the only known primary source.
- Completed items follow the same section rule as incomplete items. Preserve
  the historical purchase channel in `备注`, not as a marketplace section, when
  a stronger brand, product-family, official-source, or canonical verification
  section exists.
- `购买地点` may name a marketplace, reseller, official store, or `待确认`; it
  does not have to match the section when the section represents item/source
  grouping and the purchase channel is only a candidate.
- In a Wishlist list, "where to buy" is usually candidate execution information
  and belongs in notes, while the section and URL should preserve the item
  identity or official verification source.
- Use `备注` for candidate purchase channels, old marketplace links, unavailable
  price pages, or alternative vendors.

### Shopping Type

Use sections to group purchase execution context: real-world place, travel
route, store, venue, online channel for that trip, or concrete seller.
In a Shopping list, "where to buy" is an execution constraint, so it should
drive the section and often the primary URL.

Shopping lists include trip/location shopping lists, grocery or daily-procurement
lists, and platform/channel execution lists. For grocery or daily-procurement
lists, Apple-style grocery categories or real store aisles are valid sections,
such as `Produce`, `Dairy`, `Pantry`, `Household`, `冷藏`, or `日用品`. Generic
grocery items such as `milk`, `eggs`, or `bananas` do not need URL, price,
image, or SKU metadata unless the user means a specific brand, SKU, size, or
vendor.

For offline shopping, choose section names from the real buying route or place.
For online shopping, physical route is not meaningful; choose section names from
the primary buying channel. When an official or brand-direct page is the primary
URL, use the concrete official store/site as the section, not a vague company
label. Do not collapse different official stores into a generic official bucket.
Use grouped reseller sections such as `<specialist reseller>` only when the
primary purchase channel is a reseller class rather than a specific official
store.

Apple Reminders shopping-list type may auto-classify newly written items into
Apple grocery-style sections. Treat that as app behavior to correct after the
write, not as taxonomy evidence. Preserve the shopping-list type when the list
is intentionally a shopping list, but read back touched items and sections; if
Apple-created categories conflict with the user's shopping route or channel
model, move the items back to the intended section and delete any empty
auto-created sections after dry-run validation.

Examples:

```text
<city district>
<department store>
<airport or terminal>
<airline in-flight>
<marketplace or regional marketplace>
<brand store>
<brand official site>
<specialist reseller>
<grocery category>
<household category>
<store aisle>
<used/secondhand>
<uncertain purchase channel>
```

These examples are non-exhaustive and must not drive type inference.

Rules:

- Do not encode sections in title prefixes.
- Do not use brand categories as sections unless the brand is also the buying
  channel, such as an official store or official site.
- If an official or brand-direct page is the primary URL, use that concrete
  official store/site as the section. Prefer concrete names such as
  `<Brand> Store`, `<Brand> 官方商店`, or `<Brand> 官网` over vague company labels
  such as `<Brand> 官方`. Avoid a generic `官网/官方商城` section for mixed official
  sites.
- If the URL and price come from a marketplace or reseller, the section should
  reflect that marketplace or reseller in a Shopping list even when the title is
  a branded item. In a Wishlist list, prefer the brand or official source section
  and put marketplace/reseller candidates in notes.
- If an official or brand-direct page is purchasable and shows a reliable price,
  prefer that page and section over marketplace/reseller pages even when the
  marketplace is cheaper.
- If an official or brand-direct page is the primary URL, third-party
  marketplace or reseller links belong in notes, not in the URL field or as a
  section driver.
- If a page is only a verification source and not the intended purchase place,
  record that in notes and keep the section aligned to the intended purchase
  channel.
- If the intended purchase place is a real store or route, stock uncertainty,
  online sold-out status, or source-page availability does not change the
  section by itself. Keep the item under the intended store or route and record
  the uncertainty in `备注`.
- If a trusted venue or store page gives coordinates through a directions link,
  use those coordinates for the location trigger after dry-run validation.
- Create or reorder sections when that improves the buying flow.
- Put uncertain items in `待确认购买渠道` or a local-language equivalent.
- Use real location triggers only for real places with coordinates.
- Section and location are separate: section is organization; location is an
  arrival reminder.
- For grouped parent/subitem structures, the parent usually owns the visible
  route section and location unless a child truly has a different route or
  real-world place.

## Parent And Subitems

Use parent plus subitems for series, model families, candidate choices, SKUs,
colors, sizes, or variants.

- Parent: shopping intent, series, range, source summary, representative URL,
  representative image, and shared purchase route.
- Subitem: concrete SKU, variant URL, exact price when visible, product number,
  SKU, color, size, source, and image.
- The same item schema applies to both levels.

## Covered Operations

This reference is a format standard. Apply it to any shopping-list operation:

- create or update items
- add URLs, prices, sources, notes, images, and locations
- create, rename, reorder, or clean sections
- move items between sections
- split source items into concrete products
- merge clear duplicates
- create parent/subitem structures
- audit and improve an existing list

Deletion is conservative and requires explicit user approval. Delete only
consumed source items or clear duplicates after stable identity/readback,
`--dry-run` preview, and any required `--allow-*` flag. Confidence alone is not
authorization. Otherwise keep the item in an uncertainty section with explicit
notes.

## Validation Checklist

Before finishing:

- Target list only; unrelated lists are unchanged.
- Reminders list metadata matches the confirmed shopping-list intent when
  appropriate; current metadata was not used to infer the intended type.
- Large attachment display is preserved or changed only when user intent or an
  image-first shopping workflow requires it.
- Completed and incomplete items follow the same title, section, URL, notes,
  and attachment rules.
- Wishlist and Shopping items follow the same item schema; type differences
  affect organization and purchase-context interpretation only.
- Sections reflect the list's shopping-list type: brand/source for Wishlist
  lists, route/channel/place for Shopping lists, not title category prefixes.
- High-confidence product items have URL, source, visible price when available,
  and product image attachment.
- Offline shopping items include exact store/address details when available,
  and a location trigger when reliable coordinates are available.
- Product image work is verified by readback attachment count and type, not by
  the presence of an image URL in notes.
- All touched or intentionally retained product items, including newly captured
  items and existing maintained items, have been enriched into the full schema,
  or unresolved required fields are explicitly written and reported.
- Parent and subitems follow the same schema.
- Parent/subtask count matches the intended structure.
- Real places have location triggers where useful.
- Ambiguous items remain explicitly uncertain instead of being overfit.
