# Programmatic Reading of Safari Tab Groups on macOS

Research memo for the `apple-cli` SwiftPM CLI project.

Target commands:

```bash
apple safari tab-groups list --json
apple safari tab-groups read --id <id> --json
```

Date: 2026-05-26  
Scope: macOS Safari Tab Groups, read-only implementation, with emphasis on implementation evidence rather than user-facing Safari usage.

---

## Executive conclusion

A read-only implementation is feasible, but not through a stable public Safari API.

The strongest implementation path is to read Safari's private local SQLite database:

```text
~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db
```

The key table is:

```text
bookmarks
```

The database represents profiles, tab groups, and tabs as a parent-child hierarchy. A tab group is a folder-like row in `bookmarks`; tab rows point back to the group through `parent = <group bookmarks.id>` and are ordered by `order_index`.

This is a private schema. It is not documented by Apple as a stable API. The implementation should therefore expose stability/confidence metadata, perform schema detection before querying, and use a read-only snapshot rather than reading the live file in place.

AppleScript / JXA / SafariServices / WebKit do not provide a complete public API for enumerating and reading all Safari Tab Groups. Safari 17+ appears to expose a limited `current tab group of front window` AppleScript property, but that is only useful for current active-group detection, not for `list` or `read --id`.

---

## Source evidence summary

| Evidence | What it shows | Source |
|---|---|---|
| Ask Different Safari 15 answer | Tab Groups are in `~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db`; `bookmarks` has tab group rows and `parent` points to the tab group id. | <https://apple.stackexchange.com/questions/431888/where-safari-15-store-tabs-opened-in-groups> |
| `mokolabs/tabby` | Ruby tool exports Safari Tab Groups by copying and querying `SafariTabs.db`; supports default profile and additional profiles. | <https://github.com/mokolabs/tabby> and <https://github.com/mokolabs/tabby/blob/main/tabby.rb> |
| `dotsam/tabgroups.sh` gist | Minimal `sqlite3` query over `SafariTabs.db.bookmarks` to export groups/titles/URLs. | <https://gist.github.com/dotsam/8604d4def90c3eebf1981b0406889d9c> |
| `mikewaters/safari-raindrop-tabgroups` | TypeScript tool and schema memo for `SafariTabs.db`; documents `bookmarks`, `windows`, `windows_tab_groups`, `sync_properties`, `participant_presence`, plist blobs, profile hierarchy, WAL. | <https://github.com/mikewaters/safari-raindrop-tabgroups> and <https://github.com/mikewaters/safari-raindrop-tabgroups/blob/master/SAFARI_TABS_DB_SCHEMA.md> |
| Apple Safari Profiles support page | Safari 17+ Profiles have separate history, cookies, website data, extensions, Tab Groups, and favorites. | <https://support.apple.com/en-sg/105100> |
| Apple Full Disk Access support page | Full Disk Access grants access to other apps' data, including Safari; Automation and Accessibility are separate permissions. | <https://support.apple.com/en-sg/guide/mac-help/mchl211c911f/mac> |
| Apple SafariServices docs | Safari app extensions expose window/tab objects for extension contexts; no public Tab Group API was found there. | <https://developer.apple.com/documentation/safariservices/safari-app-extensions> and <https://developer.apple.com/documentation/safariservices/sfsafariwindow> |

---

## 1. Storage locations by data type and macOS generation

### 1.1 Primary local store: `SafariTabs.db`

Primary path:

```text
~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db
~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db-wal
~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db-shm
```

Safari Technology Preview path:

```text
~/Library/Containers/com.apple.SafariTechnologyPreview/Data/Library/SafariTechnologyPreview/SafariTabs.db
~/Library/Containers/com.apple.SafariTechnologyPreview/Data/Library/SafariTechnologyPreview/SafariTabs.db-wal
~/Library/Containers/com.apple.SafariTechnologyPreview/Data/Library/SafariTechnologyPreview/SafariTabs.db-shm
```

Implementation evidence:

- Ask Different identifies `SafariTabs.db` as the Safari 15 Tab Groups store and states that `bookmarks.parent` references the tab group id.
- `mokolabs/tabby` constructs the same path and queries `bookmarks` for tab groups and tabs.
- `dotsam/tabgroups.sh` uses one direct `sqlite3` query against the same path.
- `mikewaters/safari-raindrop-tabgroups` documents that Safari stores tab group, tab, window, and profile state in this SQLite database and that it uses WAL mode.

The database should be treated as a private Safari state database, not as a public API.

### 1.2 Key table: `bookmarks`

The `bookmarks` table is the primary table for Tab Groups.

Important columns observed in open-source schema notes and tools:

| Column | Meaning for CLI purposes | Required for baseline implementation |
|---|---|---:|
| `id` | Row id; use as raw backing id. | Yes |
| `parent` | Parent `bookmarks.id`; `0` means top-level. | Yes |
| `type` | Row type; observed `1` for folder/group and `0` for tab/leaf. | Yes |
| `subtype` | Observed `0` normal, `2` profile. | Yes |
| `title` | Group name or tab title. | Yes |
| `url` | Tab URL; group/profile rows usually have `NULL` or empty URL. | Yes |
| `num_children` | Number of child rows. | Yes |
| `hidden` | Whether row is hidden from UI. | Yes |
| `order_index` | Ordering inside the parent. | Yes |
| `external_uuid` | Candidate sync identity. | Optional |
| `server_id` | iCloud/sync candidate. | Optional |
| `sync_key` | iCloud/sync candidate. | Optional |
| `sync_data` | iCloud/sync payload candidate. | Optional |
| `syncable` | Whether row participates in sync, if present. | Optional |
| `deleted` | Soft-delete flag. | Optional |
| `extra_attributes` | Binary plist blob with timestamps/device/local title/local URL/profile data. | Optional |
| `local_attributes` | Binary plist blob with per-tab local state. | Optional |

Observed hierarchy:

```text
parent = 0, type = 1, subtype = 0
  -> Personal/default profile tab groups

parent = 0, subtype = 2
  -> Additional Safari profile definitions

parent = <profile_id>, type = 1, subtype = 0, num_children > 0
  -> Tab groups inside that profile

parent = <tab_group_id>, url IS NOT NULL
  -> Individual tabs inside a tab group
```

### 1.3 macOS Monterey / Ventura / Sonoma / Sequoia / newer macOS

There is no Apple-published schema contract for `SafariTabs.db`, so version support must be based on local validation and schema drift handling.

| macOS / Safari family | Evidence status | Implementation stance |
|---|---|---|
| Monterey / Safari 15 | Direct community evidence identifies `SafariTabs.db.bookmarks` as the Tab Group store. | Feasible, with schema check. |
| Ventura / Safari 16 | No Apple schema; path is expected to remain container-based. | Feasible if local `diagnose` confirms the table/columns. |
| Sonoma / Safari 17 | Safari Profiles begin in Safari 17; open-source schema notes include profile rows with `subtype = 2`. | Feasible; implement profile-aware grouping. |
| Sequoia / Safari 18 family | Open-source tools use the same path and schema pattern; exact minor-version validation is still required. | Feasible after local schema validation. |
| Any newer macOS / Safari | No stability guarantee. | Treat as unknown until `diagnose` validates required tables/columns. |

Do not hardcode a macOS-version decision tree as the primary mechanism. Prefer runtime schema detection:

1. Locate `SafariTabs.db`.
2. Confirm it is readable.
3. Confirm `bookmarks` exists.
4. Confirm required columns exist.
5. Run count-only smoke queries.
6. If all pass, enable `list` / `read`.

### 1.4 `Bookmarks.plist`

Traditional Safari bookmarks are stored under paths such as:

```text
~/Library/Safari/Bookmarks.plist
```

This file may contain bookmark folders and Safari concepts such as Tab Group Favorites. It should not be treated as the primary source for Tab Group membership.

Reason: Tab Group Favorites are bookmarks/favorites associated with a Tab Group start page. They are not the same as the current/restorable open tabs inside a Tab Group. For `apple safari tab-groups read --id`, the required data is group membership: tab title, tab URL, and tab order. The best evidence points to `SafariTabs.db.bookmarks`, not `Bookmarks.plist`.

Recommended use of `Bookmarks.plist`:

- Diagnostics only.
- Optional future command to report Tab Group Favorites, explicitly labeled as favorites/bookmarks rather than open/restorable Tab Group tabs.

### 1.5 `CloudTabs.db`

Potential paths:

```text
~/Library/Safari/CloudTabs.db
~/Library/Containers/com.apple.Safari/Data/Library/Safari/CloudTabs.db
```

`CloudTabs.db` is for iCloud Tabs / remote device open tabs. It is not the primary local Tab Groups membership store.

Evidence distinction:

- The Ask Different question notes that regular or iCloud-style tabs were seen in `CloudTabs.db`, but Tab Groups were not there.
- Older scripts query `CloudTabs.db` tables such as `cloud_tabs` and `cloud_tab_devices` to list tabs from iCloud devices.
- `SafariTabs.db` is where open-source Tab Group export tools read group membership.

Recommended use:

- Diagnostics only.
- Possible future `apple safari icloud-tabs ...` command, separate from `tab-groups`.

### 1.6 Profiles and profile-related storage

Apple documents that Safari 17+ Profiles have separate history, cookies, website data, extensions, Tab Groups, and favorites.

For Tab Groups specifically, open-source schema evidence points to profile information in `SafariTabs.db.bookmarks` rather than separate profile-specific Tab Group databases:

```text
parent = 0, subtype = 2
  -> additional profile definition row

parent = <profile_id>, subtype = 0, num_children > 0
  -> tab group inside that profile
```

The CLI should therefore expose a `profile` object in output, but should not assume each profile has a separate Tab Groups file.

### 1.7 Sync and shared tab group related data

Potential tables/fields in `SafariTabs.db`:

```text
bookmarks.server_id
bookmarks.sync_key
bookmarks.sync_data
bookmarks.syncable
bookmarks.external_uuid
sync_properties
participant_presence
```

Schema notes from `mikewaters/safari-raindrop-tabgroups` identify:

- `sync_properties` as an iCloud sync metadata key-value table.
- `participant_presence` as tracking iCloud Shared Tab Groups participant presence, including fields such as `participant_id`, `tab_group_server_id`, and `tab_server_id`.

These fields are useful as low-to-medium-confidence metadata signals. They should not be presented as a stable, Apple-documented sync API.

---

## 2. Public API / scripting / private storage options

### 2.1 AppleScript / SDEF / JXA

Baseline Safari scripting historically exposes windows, tabs, current tab, URL, name, text, source, and similar browser objects. It does not provide a complete public object model for enumerating all Tab Groups and their contents.

Safari 17+ appears to expose a limited `current tab group of front window` AppleScript property. The `mikewaters` active-tab-group detection note says this is useful to detect the name of the tab group currently assigned to Safari's frontmost window, and also states that earlier Safari versions expose tabs and windows but no scriptable way to identify the selected tab group.

This is insufficient for the target commands:

```bash
apple safari tab-groups list --json
apple safari tab-groups read --id <id> --json
```

Reason:

- It does not enumerate all groups.
- It does not return all tabs in a group by id.
- It is per-front-window, not a global persistent store.
- It depends on Safari being running/frontmost for active detection.

Recommended usage:

- Do not use AppleScript as the primary implementation.
- Consider a future `apple safari tab-groups current --json` command on Safari 17+.
- Use AppleScript only as an optional adjunct to mark the active group/window when requested.

### 2.2 SafariServices

SafariServices provides Safari app extension APIs such as `SFSafariWindow` and `SFSafariTab`, but no public Tab Group enumeration/read API was found in the official SafariServices documentation.

Limitations for this CLI:

- The API surface is extension-oriented, not a general local Safari state API for a standalone SwiftPM CLI.
- It exposes browser-window/tab operations in extension contexts, but not persistent Tab Group storage.
- It is not a good fit for a read-only CLI that needs all groups, profiles, and tabs.

### 2.3 WebKit

WebKit APIs manage embedded web views, web content loading, and related browser engine functions. They do not expose Safari.app's private Tab Group state.

Verdict: not applicable.

### 2.4 Spotlight metadata

Spotlight can help discover files:

```bash
mdfind -onlyin "$HOME/Library" 'kMDItemFSName == "SafariTabs.db"c'
```

But Spotlight does not provide structured Tab Group membership.

Verdict: useful for diagnostics, not for implementation.

### 2.5 NSUserDefaults / preferences

Safari preferences may contain UI and profile settings. No evidence was found that `NSUserDefaults` contains complete Tab Group membership.

Verdict: not a viable primary source.

### 2.6 CoreData

No CoreData store evidence was found for Tab Group membership. Evidence points to SQLite `SafariTabs.db`.

Verdict: not a viable primary source.

### 2.7 SQLite / plist private data

This is the recommended route:

- Read `SafariTabs.db` as a private SQLite database.
- Query only known tables/columns after schema detection.
- Decode optional binary plist blobs with `PropertyListSerialization` where useful.
- Expose stability/confidence metadata.
- Do not modify source files.

Stability category: private / semi-stable.

### 2.8 UI scripting

UI scripting can theoretically select groups in the sidebar and inspect tabs through Safari UI or AppleScript tab lists. It should not be the primary implementation.

Problems:

- Requires Accessibility permission.
- Often requires Automation permission.
- Depends on Safari being open and foregrounded.
- Depends on UI state, sidebar visibility, localization, window focus, and timing.
- Hard to make deterministic and safe for CI.

Verdict: feasible only as a last-resort interactive fallback; not recommended for `apple-cli` core behavior.

---

## 3. Open-source implementations and methods

### 3.1 `mokolabs/tabby`

Links:

- Repository: <https://github.com/mokolabs/tabby>
- Main script: <https://github.com/mokolabs/tabby/blob/main/tabby.rb>

Core method:

1. Build path:

   ```ruby
   ~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db
   ```

   or Safari Technology Preview equivalent.

2. Copy `SafariTabs.db` to a temporary file.
3. Open the copy with SQLite.
4. Query personal profile groups:

   ```sql
   SELECT id, title
   FROM bookmarks
   WHERE type = 1
     AND parent = 0
     AND subtype == 0
     AND num_children > 0
     AND hidden == 0
   ORDER BY id DESC;
   ```

5. Query additional profiles:

   ```sql
   SELECT id, title
   FROM bookmarks
   WHERE subtype = '2'
     AND title != '';
   ```

6. Query tab groups inside each additional profile:

   ```sql
   SELECT id, title
   FROM bookmarks
   WHERE parent = <profile_id>
     AND subtype == 0
     AND num_children > 0
   ORDER BY id DESC;
   ```

7. Query tabs inside each group:

   ```sql
   SELECT title, url
   FROM bookmarks
   WHERE parent = <group_id>
     AND title NOT IN ('TopScopedBookmarkList', 'Untitled', 'Start Page')
   ORDER BY order_index ASC;
   ```

The implementation exports CSV and HTML, but the same data model maps directly to JSON.

Relevance for `apple-cli`:

- Strong proof that `SafariTabs.db.bookmarks` contains enough data for a working exporter.
- Good baseline SQL.
- Swift implementation should improve on it by copying WAL/SHM as well, detecting schema drift, and emitting confidence/source metadata.

### 3.2 `dotsam/tabgroups.sh`

Link:

- <https://gist.github.com/dotsam/8604d4def90c3eebf1981b0406889d9c>

Core method:

Single `sqlite3` command:

```sql
SELECT
  (SELECT title FROM bookmarks WHERE id = b.parent) AS tab_group,
  title,
  url
FROM bookmarks b
WHERE parent IN (
  SELECT id
  FROM bookmarks
  WHERE type = 1
    AND parent = 0
    AND subtype == 0
    AND num_children > 0
    AND hidden == 0
  ORDER BY id DESC
)
AND title NOT IN ('TopScopedBookmarkList', 'Untitled', 'Start Page')
ORDER BY parent DESC, order_index ASC;
```

Relevance:

- Minimal proof that the schema can be queried directly from the command line.
- Good smoke-test query.
- Only handles default-profile style grouping; not sufficient as a complete implementation.

### 3.3 `mikewaters/safari-raindrop-tabgroups`

Links:

- Repository: <https://github.com/mikewaters/safari-raindrop-tabgroups>
- Schema reference: <https://github.com/mikewaters/safari-raindrop-tabgroups/blob/master/SAFARI_TABS_DB_SCHEMA.md>
- Active tab group detection note: <https://github.com/mikewaters/safari-raindrop-tabgroups/blob/master/docs/active-tab-group-detection.md>

Core method:

- Reads Safari's local SQLite database.
- Uses `safari-sync` to copy Safari DB and checkpoint WAL into a cache.
- Uses `safari-tabgroups --json` to output profile / tabGroup / tab data.
- Documents `bookmarks`, `windows`, `windows_tab_groups`, `windows_profiles`, `sync_properties`, and `participant_presence`.
- Documents binary plist payloads in `extra_attributes` and `local_attributes`.

Relevance:

- Best available schema reference.
- Confirms `SafariTabs.db` uses WAL.
- Confirms profile and tab group hierarchy.
- Gives a path toward optional active-tab metadata through `windows_tab_groups.active_tab_id`.

### 3.4 `CloudTabs.db` scripts

Example link:

- <https://gist.github.com/sergiitk/6f1a67df8fbb1afc4b246d81105d524b>

Core method:

- Queries `CloudTabs.db` tables such as `cloud_tabs` and `cloud_tab_devices`.
- Exports iCloud tabs from other devices.

Relevance:

- Useful contrast source.
- This is not the Tab Groups membership implementation path.

---

## 4. Local verification commands, read-only and non-dumping

These commands are intended to validate file presence, permissions, schema, key paths, and counts without dumping all URLs.

### 4.1 Define paths

```bash
SAFARI_DIR="$HOME/Library/Containers/com.apple.Safari/Data/Library/Safari"
DB="$SAFARI_DIR/SafariTabs.db"
BM="$HOME/Library/Safari/Bookmarks.plist"
CLOUD_DB_OLD="$HOME/Library/Safari/CloudTabs.db"
CLOUD_DB_NEW="$SAFARI_DIR/CloudTabs.db"
```

### 4.2 Discover candidate files

```bash
mdfind -onlyin "$HOME/Library" \
  'kMDItemFSName == "SafariTabs.db"c || kMDItemFSName == "CloudTabs.db"c || kMDItemFSName == "Bookmarks.plist"c'

ls -l "$SAFARI_DIR"/SafariTabs.db* 2>/dev/null || true
ls -l "$SAFARI_DIR"/CloudTabs.db* 2>/dev/null || true
ls -l "$BM" 2>/dev/null || true
```

### 4.3 Confirm Full Disk Access / TCC failure mode

```bash
if test -r "$DB"; then
  echo "SafariTabs.db is readable"
else
  echo "SafariTabs.db is NOT readable; likely Full Disk Access/TCC denial or path mismatch"
fi

sqlite3 "$DB" 'SELECT COUNT(*) FROM bookmarks;' 2> /tmp/safari-tabs.err \
  && echo "sqlite ok" \
  || { echo "sqlite failed"; cat /tmp/safari-tabs.err; }
```

Likely TCC/FDA failure signals:

```text
Operation not permitted
unable to open database file
authorization denied
```

Resolution:

- Grant Full Disk Access to the actual host process.
- In development this is often Terminal, iTerm, VS Code, Xcode, or a wrapper app.
- For a distributed CLI, the process that launches the executable must have access. A bare CLI binary cannot reliably self-grant Full Disk Access.

Apple's Privacy & Security settings page describes Full Disk Access as allowing apps to access all files on the computer, including data from other apps such as Safari. The same page lists Accessibility and Automation as separate permissions.

### 4.4 Inspect SQLite schema without dumping URLs

```bash
sqlite3 "$DB" '.tables'

sqlite3 "$DB" '
PRAGMA database_list;
PRAGMA journal_mode;
PRAGMA table_info(bookmarks);
'

sqlite3 "$DB" "
SELECT name
FROM sqlite_schema
WHERE type = 'table'
ORDER BY name;
"

sqlite3 "$DB" "
SELECT COUNT(*) AS bookmark_rows
FROM bookmarks;
"
```

### 4.5 Count candidate groups and profiles without URLs

```bash
sqlite3 "$DB" "
SELECT
  SUM(type=1 AND parent=0 AND subtype=0 AND hidden=0 AND num_children>0) AS personal_groups,
  SUM(type=1 AND parent=0 AND subtype=2) AS profile_rows,
  SUM(url IS NOT NULL AND url <> '') AS url_rows
FROM bookmarks;
"
```

### 4.6 List groups with tab counts only

```bash
sqlite3 "$DB" "
SELECT
  g.id,
  g.title AS name,
  g.parent,
  g.order_index,
  COUNT(t.id) AS tab_count
FROM bookmarks g
LEFT JOIN bookmarks t
  ON t.parent = g.id
 AND t.url IS NOT NULL
 AND t.url <> ''
 AND t.title NOT IN ('TopScopedBookmarkList', 'Untitled', 'Start Page')
WHERE g.type = 1
  AND g.subtype = 0
  AND g.hidden = 0
  AND g.num_children > 0
GROUP BY g.id
ORDER BY g.parent, g.order_index;
"
```

### 4.7 List profile rows and group counts

```bash
sqlite3 "$DB" "
SELECT
  p.id AS profile_id,
  p.title AS profile_name,
  COUNT(g.id) AS group_count
FROM bookmarks p
LEFT JOIN bookmarks g
  ON g.parent = p.id
 AND g.type = 1
 AND g.subtype = 0
 AND g.num_children > 0
 AND g.hidden = 0
WHERE p.parent = 0
  AND p.subtype = 2
GROUP BY p.id
ORDER BY p.order_index, p.id;
"
```

### 4.8 Inspect one group without dumping URLs

```bash
GROUP_ID=123

sqlite3 "$DB" "
SELECT
  id,
  parent,
  order_index,
  title,
  CASE WHEN url IS NULL OR url = '' THEN 0 ELSE 1 END AS has_url
FROM bookmarks
WHERE parent = $GROUP_ID
ORDER BY order_index, id;
"
```

### 4.9 Create a read-only byte snapshot including WAL/SHM

```bash
TMP="$(mktemp -d)"
cp "$SAFARI_DIR"/SafariTabs.db "$TMP"/
cp "$SAFARI_DIR"/SafariTabs.db-wal "$TMP"/ 2>/dev/null || true
cp "$SAFARI_DIR"/SafariTabs.db-shm "$TMP"/ 2>/dev/null || true

sqlite3 "$TMP/SafariTabs.db" '
PRAGMA query_only=ON;
SELECT COUNT(*) FROM bookmarks;
'
```

Rationale:

- `SafariTabs.db` uses WAL mode.
- Recent changes may live in `SafariTabs.db-wal` until Safari checkpoints.
- Copying only the main database can produce stale results.
- Copying DB/WAL/SHM into a temp directory lets SQLite merge the snapshot view without modifying Safari's source database.

### 4.10 Inspect binary plist keys from a single row

Use XML output to avoid JSON conversion issues with plist dates.

```bash
ROW_ID="$(sqlite3 "$DB" "SELECT id FROM bookmarks WHERE type=1 AND extra_attributes IS NOT NULL LIMIT 1;")"

sqlite3 "$DB" "SELECT hex(extra_attributes) FROM bookmarks WHERE id=$ROW_ID;" \
  | xxd -r -p \
  | plutil -convert xml1 -o - -- -
```

For a tab row:

```bash
TAB_ID="$(sqlite3 "$DB" "SELECT id FROM bookmarks WHERE url IS NOT NULL AND local_attributes IS NOT NULL LIMIT 1;")"

sqlite3 "$DB" "SELECT hex(local_attributes) FROM bookmarks WHERE id=$TAB_ID;" \
  | xxd -r -p \
  | plutil -convert xml1 -o - -- -
```

### 4.11 Verify `Bookmarks.plist` role without full dump

```bash
plutil -convert xml1 -o - "$BM" 2>/dev/null \
  | grep -n -E 'Tab Group Favorites|Tab Group Favourites|WebBookmarkType|Title' \
  | head -80
```

### 4.12 Verify `CloudTabs.db` role

```bash
for CDB in "$CLOUD_DB_NEW" "$CLOUD_DB_OLD"; do
  if test -r "$CDB"; then
    echo "== $CDB =="
    sqlite3 "$CDB" '.tables'
    sqlite3 "$CDB" "SELECT name FROM sqlite_schema WHERE type='table' ORDER BY name;"
    sqlite3 "$CDB" "SELECT COUNT(*) FROM cloud_tabs;" 2>/dev/null || true
  fi
done
```

### 4.13 SDEF inspection

```bash
sdef /Applications/Safari.app \
  | grep -i -A4 -B4 'tab group'

sdef /Applications/Safari.app \
  | grep -i -E 'current tab group|tab group|class name="tab"|class name="window"'
```

Safari 17+ active group probe:

```bash
osascript <<'APPLESCRIPT'
tell application "Safari"
  if (count of windows) is 0 then return "__NO_WINDOW__"
  try
    set tg to current tab group of front window
    return name of tg
  on error errMsg number errNum
    return "__NO_TAB_GROUP_OR_UNSUPPORTED__: " & errNum & " " & errMsg
  end try
end tell
APPLESCRIPT
```

This is only an active/front-window probe. It is not the implementation for `list` or `read --id`.

---

## 5. CLI output model

The output should expose data, source, and stability/confidence. This is important because the implementation depends on a private Safari database schema.

### 5.1 `list --json`

Recommended shape:

```json
{
  "schemaVersion": "apple-cli.safari.tab-groups.v1",
  "source": {
    "kind": "safariTabsDb",
    "app": "Safari",
    "container": "com.apple.Safari",
    "databasePath": "~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db",
    "readMode": "snapshot-readonly",
    "databaseTablesUsed": ["bookmarks"],
    "stability": "private-sqlite"
  },
  "groups": [
    {
      "id": "safari:personal:row:123",
      "rawId": 123,
      "externalUUID": "optional-uuid-if-present",
      "name": "Research",
      "profile": {
        "id": "personal",
        "rawId": null,
        "name": "Personal",
        "type": "default"
      },
      "container": "com.apple.Safari",
      "tabCount": 12,
      "groupOrder": 0,
      "kind": "unknown",
      "source": {
        "file": "SafariTabs.db",
        "table": "bookmarks",
        "rowId": 123
      },
      "confidence": {
        "membership": "high",
        "profile": "medium",
        "syncKind": "low",
        "stability": "private"
      }
    }
  ],
  "warnings": []
}
```

### 5.2 `read --id <id> --json`

Recommended shape:

```json
{
  "schemaVersion": "apple-cli.safari.tab-group.v1",
  "source": {
    "kind": "safariTabsDb",
    "app": "Safari",
    "container": "com.apple.Safari",
    "databasePath": "~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db",
    "readMode": "snapshot-readonly",
    "databaseTablesUsed": ["bookmarks"],
    "stability": "private-sqlite"
  },
  "group": {
    "id": "safari:personal:row:123",
    "rawId": 123,
    "externalUUID": "optional-uuid-if-present",
    "name": "Research",
    "profile": {
      "id": "personal",
      "rawId": null,
      "name": "Personal",
      "type": "default"
    },
    "tabCount": 12,
    "source": {
      "file": "SafariTabs.db",
      "table": "bookmarks",
      "rowId": 123
    }
  },
  "tabs": [
    {
      "id": "safari-tab:row:456",
      "rawId": 456,
      "externalUUID": "optional-uuid-if-present",
      "title": "Example Page",
      "url": "https://example.com/",
      "order": 0,
      "active": false,
      "metadata": {
        "localTitle": null,
        "localURL": null,
        "dateAdded": null,
        "lastViewed": null,
        "deviceIdentifier": null,
        "windowUUID": null,
        "tabIndex": null
      },
      "source": {
        "file": "SafariTabs.db",
        "table": "bookmarks",
        "rowId": 456
      },
      "confidence": {
        "title": "high",
        "url": "high",
        "order": "high",
        "active": "low"
      }
    }
  ],
  "warnings": []
}
```

### 5.3 ID strategy

Do not use only the raw SQLite row id as the public id. Recommended public id forms:

```text
safari:<profile-key>:row:<bookmarks.id>
safari:<profile-key>:uuid:<external_uuid>
```

Examples:

```text
safari:personal:row:123
safari:profile-456:row:789
safari:personal:uuid:5A18E0F2-4D5C-4E1D-9A7B-5F47F38AABCD
```

Resolution behavior:

1. `list` returns both `id` and `rawId`.
2. `read --id` accepts structured ids.
3. Optionally accept a bare integer id only as a compatibility shortcut, and mark it as ambiguous/deprecated in docs.
4. If `external_uuid` exists, return it but do not promise it is globally or permanently stable; it is still private schema metadata.

### 5.4 `kind` and sync/shared/favorites classification

Suggested enum:

```text
local | synced | shared | favoritesOnly | unknown
```

Recommended confidence rules:

| Kind | Candidate signal | Confidence |
|---|---|---:|
| `favoritesOnly` | Data came from `Bookmarks.plist` or Tab Group Favorites, not from `SafariTabs.db` group membership. | High |
| `shared` | `participant_presence` can be linked to group `server_id` / `tab_group_server_id`. | Low to medium |
| `synced` | `syncable = 1` or sync fields such as `server_id`, `sync_key`, `sync_data` are populated. | Low to medium |
| `local` | `syncable = 0` and sync fields absent. | Medium |
| `unknown` | Schema or fields do not support classification. | High-confidence unknown |

The CLI should prefer a conservative `unknown` over overclaiming sync/shared state.

---

## 6. Swift implementation recommendations

### 6.1 Proposed module layout

```text
Sources/AppleCLI/Safari/TabGroups/
  SafariTabGroupsCommand.swift
  SafariTabGroupsReader.swift
  SafariTabsDBLocator.swift
  SafariTabsDBSnapshot.swift
  SafariTabsSchema.swift
  SafariTabsQueries.swift
  SafariTabsModels.swift
  SafariPlistBlobParser.swift
  SafariTabGroupsDiagnostics.swift
```

### 6.2 Data source locator

Support at least:

```text
Safari default:
~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db

Safari Technology Preview:
~/Library/Containers/com.apple.SafariTechnologyPreview/Data/Library/SafariTechnologyPreview/SafariTabs.db

Manual override:
--db /path/to/SafariTabs.db
```

Suggested CLI flags:

```bash
apple safari tab-groups list --json
apple safari tab-groups read --id safari:personal:row:123 --json
apple safari tab-groups diagnose --json
apple safari tab-groups list --json --db ~/Backups/SafariTabs.db
apple safari tab-groups list --json --technology-preview
```

### 6.3 Read-only snapshot strategy

Use a temp snapshot rather than querying the live database in place.

Steps:

1. Create temp directory.
2. Copy `SafariTabs.db`.
3. Copy `SafariTabs.db-wal` if it exists.
4. Copy `SafariTabs.db-shm` if it exists.
5. Open the temp copy with SQLite read-only.
6. Set `PRAGMA query_only=ON`.
7. Query only known tables/columns.
8. Remove temp directory at the end.

Swift sketch:

```swift
struct SafariTabsSnapshot {
    let originalDB: URL
    let snapshotDB: URL
    let tempDir: URL
    let copiedWAL: Bool
    let copiedSHM: Bool
}

func createSafariTabsSnapshot(from safariDir: URL) throws -> SafariTabsSnapshot {
    let fm = FileManager.default
    let tempDir = fm.temporaryDirectory
        .appendingPathComponent("apple-cli-safari-\(UUID().uuidString)")

    try fm.createDirectory(at: tempDir, withIntermediateDirectories: true)

    let db = safariDir.appendingPathComponent("SafariTabs.db")
    let wal = safariDir.appendingPathComponent("SafariTabs.db-wal")
    let shm = safariDir.appendingPathComponent("SafariTabs.db-shm")

    let dstDB = tempDir.appendingPathComponent("SafariTabs.db")
    try fm.copyItem(at: db, to: dstDB)

    var copiedWAL = false
    var copiedSHM = false

    if fm.fileExists(atPath: wal.path) {
        try? fm.copyItem(at: wal, to: tempDir.appendingPathComponent("SafariTabs.db-wal"))
        copiedWAL = true
    }

    if fm.fileExists(atPath: shm.path) {
        try? fm.copyItem(at: shm, to: tempDir.appendingPathComponent("SafariTabs.db-shm"))
        copiedSHM = true
    }

    return SafariTabsSnapshot(
        originalDB: db,
        snapshotDB: dstDB,
        tempDir: tempDir,
        copiedWAL: copiedWAL,
        copiedSHM: copiedSHM
    )
}
```

SQLite open settings:

```swift
// Conceptual flags; exact wrapper depends on SQLite package.
SQLITE_OPEN_READONLY
SQLITE_OPEN_FULLMUTEX // or NOMUTEX if access is single-threaded
```

Then execute:

```sql
PRAGMA query_only=ON;
PRAGMA busy_timeout=1000;
```

Avoid `immutable=1` if you rely on WAL contents. `immutable=1` can interfere with normal WAL handling because SQLite assumes the file cannot change and may skip journal/WAL behavior. For a copied temp directory, use normal read-only SQLite open.

### 6.4 Baseline SQL queries

#### Personal/default profile groups

```sql
SELECT
  id,
  title,
  parent,
  order_index,
  num_children,
  external_uuid,
  server_id,
  sync_key,
  syncable
FROM bookmarks
WHERE type = 1
  AND parent = 0
  AND subtype = 0
  AND num_children > 0
  AND hidden = 0
  AND COALESCE(deleted, 0) = 0
ORDER BY order_index ASC, id ASC;
```

#### Additional profiles

```sql
SELECT
  id,
  title,
  order_index,
  external_uuid
FROM bookmarks
WHERE parent = 0
  AND subtype = 2
  AND title IS NOT NULL
  AND title <> ''
  AND COALESCE(deleted, 0) = 0
ORDER BY order_index ASC, id ASC;
```

#### Groups inside a profile

```sql
SELECT
  id,
  title,
  parent,
  order_index,
  num_children,
  external_uuid,
  server_id,
  sync_key,
  syncable
FROM bookmarks
WHERE parent = ?
  AND type = 1
  AND subtype = 0
  AND num_children > 0
  AND hidden = 0
  AND COALESCE(deleted, 0) = 0
ORDER BY order_index ASC, id ASC;
```

#### Tabs inside a group

```sql
SELECT
  id,
  title,
  url,
  order_index,
  external_uuid,
  extra_attributes,
  local_attributes,
  server_id,
  sync_key,
  syncable
FROM bookmarks
WHERE parent = ?
  AND COALESCE(deleted, 0) = 0
  AND url IS NOT NULL
  AND url <> ''
  AND title NOT IN ('TopScopedBookmarkList', 'Untitled', 'Start Page')
ORDER BY order_index ASC, id ASC;
```

#### Optional active tab by group

Only if `windows_tab_groups` exists:

```sql
SELECT active_tab_id
FROM windows_tab_groups
WHERE tab_group_id = ?
ORDER BY id
LIMIT 1;
```

Treat this as low-to-medium confidence because it represents window state, and a group may appear in zero or more windows depending on live/restored state.

### 6.5 Schema drift detection

Before querying groups, inspect tables and columns.

```sql
SELECT name FROM sqlite_schema WHERE type = 'table';
PRAGMA table_info(bookmarks);
```

Required columns for baseline `list` / `read`:

```text
id
parent
type
subtype
title
url
num_children
hidden
order_index
```

Optional columns:

```text
external_uuid
server_id
sync_key
sync_data
syncable
deleted
extra_attributes
local_attributes
last_modified
date_closed
read
```

If a required column is missing, return a structured error rather than guessing:

```json
{
  "error": {
    "code": "safari_tab_groups_schema_unsupported",
    "message": "SafariTabs.db exists but the bookmarks schema does not match the known Tab Groups layout.",
    "source": {
      "path": "~/Library/Containers/com.apple.Safari/Data/Library/Safari/SafariTabs.db",
      "stability": "private-sqlite"
    },
    "observed": {
      "tables": ["bookmarks", "windows"],
      "bookmarksColumns": ["id", "title", "..."]
    },
    "suggestedAction": "Run apple safari tab-groups diagnose --json and attach the schema output."
  }
}
```

### 6.6 Binary plist parsing

Use `PropertyListSerialization` for `extra_attributes` and `local_attributes`.

Do not shell out to `plutil` in the main implementation unless used as a diagnostic fallback.

Potentially useful plist fields, based on observed schema notes:

| Blob | Candidate keys | Use |
|---|---|---|
| `bookmarks.extra_attributes` on group rows | `com.apple.Bookmark.DateAdded`, `com.apple.bookmarks.OmitFromUI` | group creation metadata / UI omission flag |
| `bookmarks.extra_attributes` on tab rows | `DateLastViewed`, `DeviceIdentifier`, `LocalTitle`, `LocalURL`, `com.apple.Bookmark.DateAdded` | tab metadata, local title/URL, timestamps |
| `bookmarks.extra_attributes` on profile rows | `SymbolImageName`, background/profile UI fields | optional profile metadata |
| `bookmarks.local_attributes` on tab rows | `LastVisitTime`, `WindowUUID`, `TabIndex`, `IsMuted`, `ShowingReader`, `SessionState` | local tab/window/session metadata |

`SessionState` is not a standard plist object to fully decode as part of baseline implementation. Treat it as opaque bytes or omit it.

### 6.7 File locking and concurrent read risk

Risks:

1. Safari can write while the CLI is copying.
2. WAL may contain newer data than the main DB.
3. A DB-only copy can be stale.
4. DB/WAL/SHM byte copy is not a strict transactionally consistent snapshot.
5. Opening the live DB can interact with WAL/SHM behavior.

Recommended mitigation:

- Copy DB/WAL/SHM into temp.
- Open only the temp copy.
- Retry snapshot creation if SQLite returns `database disk image is malformed` or a related transient error.
- Include snapshot metadata in diagnostics:
  - copied main DB: yes/no
  - copied WAL: yes/no
  - copied SHM: yes/no
  - source mtime/size
  - snapshot open status
- Never run `UPDATE`, `INSERT`, `DELETE`, `VACUUM`, or `wal_checkpoint` on the source database.

### 6.8 Unit test fixtures

Build synthetic SQLite fixtures. Do not use real user browsing data in tests.

Minimal fixture schema:

```sql
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY,
  parent INTEGER,
  type INTEGER,
  subtype INTEGER,
  title TEXT,
  url TEXT,
  num_children INTEGER,
  hidden INTEGER,
  order_index INTEGER,
  external_uuid TEXT,
  deleted INTEGER DEFAULT 0,
  server_id TEXT,
  sync_key TEXT,
  syncable INTEGER,
  extra_attributes BLOB,
  local_attributes BLOB
);
```

Recommended fixtures:

1. Personal profile with one group and three tabs.
2. Personal profile with multiple groups and ordering.
3. Additional profile row (`subtype = 2`) with child groups.
4. Hidden group (`hidden = 1`) excluded from output.
5. Sentinel tab rows named `TopScopedBookmarkList`, `Untitled`, `Start Page` excluded from tab output.
6. Missing optional columns accepted.
7. Missing required column returns `schema_unsupported`.
8. WAL mode fixture with uncheckpointed rows; verify snapshot includes `-wal`.
9. Binary plist fixture containing dates; verify `PropertyListSerialization` handles it.
10. Duplicate group names across profiles; verify structured ids remain distinct.

### 6.9 Fallback behavior

| Failure or variant | Recommended behavior |
|---|---|
| `SafariTabs.db` not found | Return `not_found` with checked paths. |
| DB found but not readable | Return `permission_denied` and mention Full Disk Access/TCC. |
| `bookmarks` missing | Return `schema_unsupported`. |
| Required column missing | Return `schema_unsupported` with observed schema. |
| Optional column missing | Continue without that metadata; include warning if relevant. |
| `Bookmarks.plist` exists but DB missing | Do not fake Tab Groups; optionally report bookmarks/favorites-only source in `diagnose`. |
| `CloudTabs.db` exists | Do not use for Tab Groups; optionally report separate iCloud tabs source in `diagnose`. |
| AppleScript active group available | Use only for optional `current`/active metadata, not list/read baseline. |
| UI scripting requested explicitly | Implement as opt-in experimental route only, with Accessibility/Automation warnings. |

---

## 7. Permissions and privacy surface

Even if the user explicitly authorizes local Safari reading, macOS still enforces TCC permissions.

### 7.1 Full Disk Access

Needed for reading Safari container data from a terminal/CLI host in many configurations:

```text
System Settings -> Privacy & Security -> Full Disk Access
```

Grant access to the actual host process:

- Terminal.app
- iTerm.app
- VS Code
- Xcode
- A packaged app wrapper that launches the CLI

A plain SwiftPM CLI binary cannot reliably self-request or self-grant Full Disk Access. The error handling should explain which host process likely needs permission.

### 7.2 Automation

Needed if the CLI controls Safari through AppleScript/JXA/`osascript`:

```text
System Settings -> Privacy & Security -> Automation
```

The baseline `SafariTabs.db` implementation does not need Automation.

### 7.3 Accessibility

Needed if the CLI performs UI scripting through System Events:

```text
System Settings -> Privacy & Security -> Accessibility
```

The baseline `SafariTabs.db` implementation does not need Accessibility.

---

## 8. Recommended implementation route for `apple-cli`

### 8.1 Target design

Implement the commands as a private-schema, read-only adapter:

```bash
apple safari tab-groups list --json
apple safari tab-groups read --id <id> --json
apple safari tab-groups diagnose --json
```

Do not present this as an Apple-supported API. Present it as a local Safari state reader with stability metadata.

### 8.2 Execution plan

#### Phase 1: Diagnostics and schema detection

Deliver:

- Path locator.
- Permission check.
- Snapshot creation.
- SQLite open check.
- Table/column introspection.
- Count-only queries.
- JSON diagnostics.

Acceptance:

- No URL dump.
- Clear permission error if TCC blocks access.
- Clear schema error if unsupported.

#### Phase 2: `list --json`

Deliver:

- Personal/default profile groups.
- Additional profile rows and their groups.
- `tabCount` per group.
- `source` object per group.
- `confidence` object per group.

Acceptance:

- Correct order by `order_index`.
- Duplicate group names across profiles handled.
- Hidden groups excluded.

#### Phase 3: `read --id --json`

Deliver:

- Structured id resolver.
- Group metadata.
- Ordered tabs with title/url/order.
- Per-tab source metadata.
- Optional external UUID.

Acceptance:

- Does not crash on empty groups.
- Sentinel rows excluded.
- Missing optional columns do not fail the command.

#### Phase 4: Optional metadata

Deliver:

- Binary plist parser for date/local title/local URL/device/window/tab index where available.
- Optional active tab marker from `windows_tab_groups` if table exists.
- Conservative sync/shared classification.

Acceptance:

- All optional fields can be absent.
- Confidence remains explicit.

---

## 9. Conclusion matrix

| Route | `list --json` | `read --id --json` | Stability | Permissions | Recommendation |
|---|---:|---:|---|---|---|
| AppleScript / SDEF | No complete support | No complete support | Public but insufficient; Safari 17+ only partial current-group support | Automation | Do not use as primary route. |
| JXA | No complete support | No complete support | Same scripting dictionary limitations | Automation | Do not use as primary route. |
| SafariServices | No evidence of Tab Group enumeration API | No evidence of Tab Group read API | Public but wrong API surface for this CLI | Extension/app context | Do not use. |
| WebKit | Not applicable | Not applicable | Public but unrelated to Safari.app state | N/A | Do not use. |
| Spotlight metadata | No | No | Public but only file discovery | Usually none/FDA for some paths | Diagnostics only. |
| `Bookmarks.plist` | Not reliable for groups | Not reliable for group tabs | More stable file format, wrong data source for membership | FDA may be needed | Diagnostics / Tab Group Favorites only. |
| `CloudTabs.db` | Not reliable for groups | Not reliable for group tabs | Private iCloud tabs DB, wrong data source for Tab Groups | FDA may be needed | Separate future iCloud-tabs command only. |
| Local `SafariTabs.db` SQLite | Yes | Yes | Private/semi-stable; requires schema detection | Full Disk Access often required | Recommended. |
| UI scripting | Possible but brittle | Possible but brittle | Very unstable: UI/localization/focus dependent | Accessibility + Automation | Last-resort opt-in only. |
| iCloud synced data materialized locally | Yes if materialized in `SafariTabs.db` | Yes if materialized in `SafariTabs.db` | Sync/shared classification is private and lower confidence | Full Disk Access | Use only through local DB reader. |

Final recommendation:

1. Implement `SafariTabs.db` read-only snapshot reader.
2. Query `bookmarks` for profiles, groups, and tabs.
3. Add `diagnose --json` before shipping `list` / `read` broadly.
4. Include `source.stability = "private-sqlite"` and per-field confidence.
5. Avoid UI scripting and AppleScript except for future active/current group metadata.
6. Treat `Bookmarks.plist` and `CloudTabs.db` as diagnostic or separate-feature data sources, not Tab Group membership sources.

---

## 10. Direct source links

- Ask Different: "Where Safari 15 store tabs opened in groups?"  
  <https://apple.stackexchange.com/questions/431888/where-safari-15-store-tabs-opened-in-groups>

- `mokolabs/tabby` repository  
  <https://github.com/mokolabs/tabby>

- `mokolabs/tabby` main Ruby implementation  
  <https://github.com/mokolabs/tabby/blob/main/tabby.rb>

- `dotsam/tabgroups.sh` gist  
  <https://gist.github.com/dotsam/8604d4def90c3eebf1981b0406889d9c>

- `mikewaters/safari-raindrop-tabgroups` repository  
  <https://github.com/mikewaters/safari-raindrop-tabgroups>

- `SafariTabs.db` schema reference in `mikewaters/safari-raindrop-tabgroups`  
  <https://github.com/mikewaters/safari-raindrop-tabgroups/blob/master/SAFARI_TABS_DB_SCHEMA.md>

- Active Safari Tab Group detection note  
  <https://github.com/mikewaters/safari-raindrop-tabgroups/blob/master/docs/active-tab-group-detection.md>

- Apple Support: Use profiles in Safari on Mac  
  <https://support.apple.com/en-sg/105100>

- Apple Support: Change Privacy & Security settings on Mac  
  <https://support.apple.com/en-sg/guide/mac-help/mchl211c911f/mac>

- Apple Developer: Safari app extensions  
  <https://developer.apple.com/documentation/safariservices/safari-app-extensions>

- Apple Developer: `SFSafariWindow`  
  <https://developer.apple.com/documentation/safariservices/sfsafariwindow>

- Example CloudTabs script  
  <https://gist.github.com/sergiitk/6f1a67df8fbb1afc4b246d81105d524b>
