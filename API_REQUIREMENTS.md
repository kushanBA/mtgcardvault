# CardVault — Backend API Requirements

The Flutter app ("CardVault" — a trading card collection/marketplace app for Pokémon, MTG, One Piece, and Flesh and Blood) currently runs entirely on hardcoded mock data (`lib/data/mock_db.dart`). This document lists the data models and API endpoints needed to replace that mock layer. No auth or networking currently exists in the app — this is a from-scratch integration.

---

## 1. Enums

| Enum | Values | Notes |
|---|---|---|
| `Condition` | `NM`, `LP`, `MP`, `HP` | Near Mint / Lightly Played / Moderately Played / Heavily Played |
| `ListingStatus` | `active`, `sold` | personal listing (quick-sell) |
| `WantedStatus` | `open`, `offered` | |
| `MarketKind` | `card`, `binder` | marketplace listing type |
| `MarketStatus` | `available`, `purchased`, `mine` | `mine` = current user is the seller |
| `Game` | `Pokémon`, `Magic: The Gathering`, `One Piece`, `Flesh and Blood` | fixed set today; ideally not hardcoded server-side |

---

## 2. Data Models

### Card (catalog item)
```json
{
  "id": "zard",
  "name": "Charizard ex",
  "number": "199/165",
  "set": "Obsidian Flames",
  "game": "Pokémon",
  "language": "EN",
  "imageUrl": "https://.../zard.png",
  "dayOpen": 182.40,
  "price": 184.10,
  "history": [178.2, 179.0, "... 90 daily closes, oldest first"],
  "gradedPsa9": 310,
  "gradedPsa10": 748,
  "recentSolds": [
    { "source": "eBay", "condition": "NM", "date": "2026-07-14", "price": 186.05 }
  ]
}
```
- `imageUrl` replaces the app's current placeholder `art` (a hex color).
- `price` is the live/current market price; `dayOpen` is the price at start of day (used for 24h % change).
- `history` — 90-day daily close series for the price chart.

### Binder
```json
{
  "id": "b1",
  "name": "Obsidian Flames · Master",
  "game": "Pokémon",
  "isPublic": true,
  "pockets": [
    { "cardId": "zard", "paid": 120.00 },
    { "cardId": null, "paid": 0 }
  ]
}
```
- `pockets` is always exactly 9 entries (9-pocket binder page). Empty pocket = `cardId: null`.
- `paid` = cost basis (what the user paid for that copy), used for P/L — not the current market price.
- Binders are single-game: a card can only be assigned to a binder whose `game` matches the card's `game`.

### Listing (personal quick-sell listing)
```json
{
  "id": "l123",
  "cardId": "zard",
  "condition": "NM",
  "price": 178.50,
  "fees": 8.93,
  "markets": ["eBay", "TCGplayer"],
  "createdAt": "2026-07-22T14:30:00Z",
  "status": "active"
}
```

### ScanResult (card recognition response)
```json
{
  "card": { "...Card object as above" },
  "estimatedCondition": "NM",
  "confidence": 0.94
}
```

### Buyer (any marketplace participant — seller or wanted-post buyer)
```json
{ "id": "u_123", "name": "Dana R.", "rating": 4.8, "trades": 122 }
```
Today this has no `id` field client-side (it's a display-only stub) — backend should add a stable user ID since these will become real user references once auth exists.

### WantedPost
```json
{
  "id": "w1",
  "cardId": "zard",
  "buyer": { "...Buyer" },
  "premium": 0.03,
  "createdAt": "2026-07-22T14:22:00Z",
  "status": "open"
}
```
- `premium`: fraction above (positive) or below (negative) live market price the buyer will pay, e.g. `0.03` = pays 3% over market.

### MarketListing (community marketplace feed entry)
```json
{
  "id": "m1",
  "kind": "card",
  "cardIds": ["iono"],
  "binderName": null,
  "condition": "NM",
  "discount": 0.04,
  "seller": { "...Buyer" },
  "createdAt": "2026-07-22T13:50:00Z",
  "status": "available",
  "askPrice": null
}
```
- `kind: "card"` → `cardIds` has 1 entry. `kind: "binder"` → `cardIds` has up to 9 (the lot), `binderName` set.
- `discount`: fraction below (positive) or above (negative, i.e. priced above market) live market price for the combined `cardIds`.
- `askPrice`: when set (e.g. for the current user's own binder-sale listings), this is a fixed price overriding the discount calculation.

### Pool (group-buy / pack-splitting pool — "rip mode" feature)
```json
{ "id": "p1", "slotsFilled": 17, "slotsTotal": 20, "yourCards": 0 }
```

### Portfolio / GameAllocation (derived, not stored — computed from collection + live prices)
```json
{ "game": "Pokémon", "value": 1024.30, "change": 0.021 }
```

---

## 3. Endpoints Needed

### Auth (net-new — nothing exists today)
| Method | Path | Notes |
|---|---|---|
| POST | `/auth/signup` | email/password (or provider) → user + token |
| POST | `/auth/login` | → token |
| POST | `/auth/refresh` | refresh token → new access token |
| GET | `/auth/me` | current user profile |

### Card Catalog
| Method | Path | Notes |
|---|---|---|
| GET | `/cards?query=&game=` | search/browse catalog. Powers search screen and card lookups. |
| GET | `/cards/:id` | full card detail incl. `history` and `recentSolds` |
| GET | `/cards/prices?ids=zard,iono,...` | batch live price lookup — used constantly (portfolio value, binder value, market listing price calc). |

### Collection (cards the user owns)
| Method | Path | Notes |
|---|---|---|
| GET | `/collection` | list of `{ cardId, quantity }` the user owns |
| POST | `/collection` | body `{ cardId, qty }` — add copies (default qty 1) |
| GET | `/portfolio` | `{ value, dayChange }` — total portfolio valuation + 24h % change |
| GET | `/portfolio/allocation` | list of `GameAllocation` — breakdown by game |
| GET | `/portfolio/history` | time series of portfolio value (for the trend chart) |

### Binders
| Method | Path | Notes |
|---|---|---|
| GET | `/binders` | list current user's binders |
| POST | `/binders` | body `{ name, game }` → creates with 9 empty pockets |
| GET | `/binders/:id` | detail |
| PATCH | `/binders/:id` | update `name`, `isPublic` |
| POST | `/binders/:id/pockets` | body `{ cardId }` → assign card to next empty pocket |
| DELETE | `/binders/:id/pockets/:index` | clear a pocket (e.g. after the card is sold) |
| POST | `/binders/:id/sell` | body `{ askPrice }` → creates a `MarketListing` (kind=binder) from all filled pockets, seller = current user |
| GET | `/binders/:id/compare?withUserId=` | community binder compare — returns the other user's public binder plus which cards are "their spares you need" / "your spares they need" |
| GET | `/binders/public?game=&nearMe=` | discovery feed for the compare/community feature |

### Listings (personal quick-sell)
| Method | Path | Notes |
|---|---|---|
| GET | `/listings` | current user's listings |
| POST | `/listings` | body `{ cardId, condition, price, fees, markets }` → creates `active` listing |
| PATCH | `/listings/:id/sold` | mark sold |
| GET | `/pricing/suggest?cardId=&condition=` | suggested listing price + estimated days-to-sell + `marketplaceFeeRate` |

### Marketplace (community feed — buy other users' listings)
| Method | Path | Notes |
|---|---|---|
| GET | `/marketplace?game=&kind=` | feed of `MarketListing`s (`available` status, exclude current user's own unless `status=mine`) |
| POST | `/marketplace/:id/buy` | current user purchases a card or binder-lot listing |

### Wanted Posts (buyer want-ads)
| Method | Path | Notes |
|---|---|---|
| GET | `/wanted?cardId=` | open want-ads, optionally filtered to cards the current user owns |
| POST | `/wanted` | buyer creates a want-ad: `{ cardId, premium }` |
| POST | `/wanted/:id/offer` | current user (seller) fulfills the want-ad, creating a `Listing` |

### Pool ("rip mode" group buy)
| Method | Path | Notes |
|---|---|---|
| GET | `/pool/:id` | pool status |
| POST | `/pool/:id/join` | body `{ slots }` → increments `slotsFilled` and `yourCards` for the current user |

### Scan (card recognition)
| Method | Path | Notes |
|---|---|---|
| POST | `/scan` | multipart image upload → `ScanResult` (identified card + estimated condition + confidence score) |

### Signals / Deal Radar
| Method | Path | Notes |
|---|---|---|
| GET | `/signals` | sell/hold/watch recommendation per card the user owns, with a reason string |
| GET | `/deals` | underpriced-listing alerts (discount vs. live market, source, recency) |
