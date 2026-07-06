# Navigation design (milestone 4 — finalized)

## Routing library

go_router with a `StatefulShellRoute.indexedStack` for the three bottom-nav
tabs (Home / Search / Settings). Each of the five lists is a route pushed
from Home, not a tab of its own — five tabs doesn't fit comfortably in a MD3
bottom bar.

## Route table

```
/pin                                    — PIN gate, outside the shell (no bottom nav)

ShellRoute (StatefulShellRoute.indexedStack) — bottom nav: Home / Search / Settings
  Branch 0 (Home):
    /home                                — five list cards
    /home/grocery                        — pushed, full-screen, own back button
    /home/packing                        — trip picker (list of trips)
    /home/packing/:tripId                — packing items for one trip
    /home/admin                          — pushed
    /home/admin/:itemId                  — deep-linkable item detail (opens edit sheet)
    /home/products                       — pushed
    /home/wishlist                       — pushed
  Branch 1 (Search):
    /search                              — cross-list search
  Branch 2 (Settings):
    /settings                            — household members, PIN reset
```

### Packing → trip picker

`/home/packing` lists trips (from `/households/{householdId}/trips`), each
row navigating to `/home/packing/:tripId` for that trip's items. "Create
trip" is a modal, not a route (consistent with add/edit item below).

### Reserved deep link: `/home/admin/:itemId`

Reserved now, ahead of FCM (milestone 15), so a push notification for an
admin task can deep-link straight to it: the route resolves the item,
pushes the admin list underneath for back-navigation continuity, and
auto-opens the edit bottom sheet on top. No handler is wired yet — just the
route shape, so milestone 15 doesn't require re-plumbing navigation.

### Modals (not routes)

- Add/edit item (any list)
- Move-between-lists
- Trip create/edit

All open via `showModalBottomSheet`, keeping the back stack limited to the
routes above.

## PIN gate strategy

- **Cold start**: a `GoRouter` top-level `redirect` checks an in-memory/
  session "unlocked" flag. If unset, every route redirects to `/pin`
  regardless of the deep link originally requested; on successful PIN entry,
  redirect continues to the originally requested location.
- **Re-lock on inactivity**: an `AppLifecycleListener` (or
  `WidgetsBindingObserver`) records the timestamp when the app is
  backgrounded (`AppLifecycleState.paused`/`inactive`). On resume, if the
  elapsed time exceeds an inactivity threshold (TBD value, e.g. 5 minutes),
  the "unlocked" flag is cleared before the redirect check runs, forcing
  `/pin` again. Short backgrounding (e.g. switching to another app briefly)
  does not force re-entry.
- This is a design note for milestone 5 (authentication) to implement —
  no PIN/auth code is written yet, since the Flutter project itself hasn't
  been scaffolded (that's milestone 6).
