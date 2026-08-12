# CardVault — APIs Needed for the Home Screen

This is a request doc, not a spec — it lists what the mobile app's Home
screen needs from the backend so it can stop running on mock data. Written
against `MOBILE_API.md` (last updated 2026-07-31) — cross-reference the
status table there before starting anything below, since most of this is
blocked on pieces already marked "Not yet."

**Where this lives in the app:** `lib/presentation/screens/home_screen.dart`,
backed by a local `Store` (`lib/data/store.dart`) that's entirely seeded from
`lib/data/mock_db.dart`. Nothing on this screen calls the network today — the
header literally says "demo data · live ticker." The two quick-action
buttons (Scan, My binders) are the only things on this screen already wired
to real APIs, because they just navigate to other tabs that use them.

---

## Section-by-section: what's needed

| # | Home screen section | What it shows | Blocked on |
|---|---|---|---|
| 1 | Portfolio value card | Total $ value, today's % change, 90-point sparkline, breakdown by game | Card catalog + Collection |
| 2 | Today's movers | Top 4 owned cards by biggest daily price swing | Card catalog + Collection |
| 3 | Your listings | User's active/sold quick-sell listings | Listings |
| 4 | Signals card | "Hold or sell" advice on owned cards (nav only today, no data) | Signals |
| 5 | Deal radar card | Listings below market price (nav only today, no data) | Marketplace |
| 6 | Scan / My binders buttons | Navigation only | ✅ already real |
| 7 | Header / search bar | Static copy, navigation only | Nothing needed |

Rows 1–5 depend on backend pieces already listed as **Not yet** in
`MOBILE_API.md` (Card catalog, Collection, Listings, Signals, Marketplace).
This doc isn't asking for anything net-new beyond what's already on that
roadmap — it's scoping *which fields from each of those pieces* Home
specifically needs, so whoever builds Collection/Listings/etc. knows Home is
a consumer.

---

## 1. Portfolio value + Today's movers

These two sections share the same underlying data: the list of cards the
user owns, each with a current price and a "price at start of day" so we can
compute a % change.

### What we need, minimally

For each card in the user's collection:

```json
{
  "catalogCardId": "...",
  "name": "...",
  "setName": "...",
  "cardNumber": "...",
  "game": "MTG",
  "imageUrl": "...",
  "quantity": 2,
  "price": 12.50,
  "dayOpenPrice": 11.80
}
```

- `price` / `dayOpenPrice` → today's % change, both per-card ("Today's
  movers") and summed ("Portfolio value" header stat).
- `game` → grouping for the per-game breakdown chips.
- Summing `price * quantity` across all rows → total portfolio value.

This could be a single endpoint like:

```
GET /me/collection?withPricing=true
```

or two calls (plain collection list + a batch price lookup by catalog card
id) — whichever fits how Collection and Card catalog end up being designed.
Either works for Home; we just need current price + day-open price
available per owned card without one request per card.

### Sparkline (nice-to-have, not blocking)

The sparkline currently shows a fake "live" line built from a client-side
random walk every 3 seconds. We don't need real-time ticking from the
backend — a periodic snapshot is fine. Something like:

```
GET /me/portfolio/history?range=90d
```

returning `[{ "date": "...", "value": 1234.56 }, ...]` would let us show a
real trend line instead of a random walk. If this doesn't exist yet, we can
launch Home without the sparkline being "real" — that's the lowest-priority
item here.

---

## 2. Your listings

Shows the user's own quick-sell listings (active + sold), or an empty state
if they have none. Currently this is 100% local-only — created listings are
saved to on-device storage and never sent anywhere.

### What we need

```
POST   /listings              create a listing (card ref, condition, price, target marketplaces)
GET    /me/listings            list my listings (active + sold), for the Home feed
PATCH  /listings/:id           mark as sold (or update price/status)
```

Per listing, Home needs at least:

```json
{
  "id": "...",
  "catalogCardId": "...",
  "cardName": "...",
  "imageUrl": "...",
  "condition": "NM",
  "markets": ["TCGPLAYER", "EBAY"],
  "price": 5.00,
  "status": "ACTIVE"
}
```

`markets` is shown as a joined string ("TCGPlayer + eBay"), `status` drives
the active/sold chip.

---

## 3. Signals card

Right now this is just a static promo tile that navigates to a Signals
screen — no data is fetched from Home itself. Whenever Signals gets built,
Home doesn't need anything extra beyond what that screen needs; flagging it
here only so it's not forgotten as a Home dependency once that screen is
wired up (e.g. a count/badge like "3 cards flagged" could eventually show on
the tile, but that's optional polish, not a blocker).

## 4. Deal radar card

Same situation as Signals — static promo tile today, no data pulled on
Home. Once Marketplace exists, an optional "count of deals below market"
badge could be added here, but it's not required for launch.

---

## Suggested priority

1. **Collection + Card catalog pricing fields** — unlocks the portfolio
   value card and Today's movers, which are the two data-heavy sections on
   this screen.
2. **Listings** (create / list mine / mark sold) — unlocks "Your listings."
3. Portfolio history endpoint for the sparkline — nice-to-have, can ship
   without it.
4. Signals / Marketplace data on the promo tiles — optional badges only,
   not required to replace the static tiles that already navigate correctly.

Everything here follows the existing conventions in `MOBILE_API.md`: base
URL `https://api.tradingcard.idea8.cloud/api`, `Authorization: Bearer
<accessToken>` on every call, and the standard
`{ statusCode, error, message }` error shape.
