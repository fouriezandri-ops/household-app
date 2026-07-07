# Navigation design (milestone 4 — finalized)

## Routing library

go_router with a `StatefulShellRoute.indexedStack` for the three bottom-nav
tabs (Home / Search / Settings). Each of the five lists is a route pushed
from Home, not a tab of its own — five tabs doesn't fit comfortably in a MD3
bottom bar.

## Route table

```
/pick-member                            — first-run "who are you?" screen, outside the shell (no bottom nav)

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
    /settings                            — household members
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

## PIN gate — removed post-launch

Milestone 5 originally built a PIN gate here (cold-start redirect to `/pin`
plus an inactivity re-lock via `AppLifecycleListener`), but it was removed
later at your request: it added friction without protecting anything, since
Firestore's rules are already fully open for this private two-person app
(decision #2) — the PIN only ever gated the local UI, not the data. The
first-run gate is now just `/pick-member` (see the route table above),
unconditionally.
