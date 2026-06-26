# BC EOQ Calculator

A free, open-source Business Central extension that computes the Economic Order Quantity (Wilson formula) from real Item Ledger Entries and writes the result into the field your Planning Worksheet already reads.

MIT licensed. Runtime 14.0 (BC v27+).

## What it does

For each item you select, the extension:

1. Pulls Item Ledger Entries of type Sale over the configurable demand window (default 365 days)
2. Counts observations and bails out if there are too few to be statistically meaningful
3. Computes annual demand (D), annualised from the window
4. Reads Unit Cost from the item (Last Direct Cost by default, configurable to Standard Cost or Unit Cost)
5. Computes holding cost (H) as Unit Cost x Holding Rate (Setup default: 25 percent)
6. Reads ordering cost (S) from Setup (default 50 in your local currency, configurable)
7. Applies the Wilson formula: **EOQ = sqrt( (2 x D x S) / H )**
8. Applies a maximum cap (default: 6 months of demand) and rounds to Item Order Multiple if set
9. Writes the result to either **Reorder Quantity** (and switches Reordering Policy to Fixed Reorder Qty.) or **Order Multiple** (for Lot-for-Lot setups), based on Setup
10. Logs every calculation for audit

## Why bother

Most BC implementations have order quantities that came from somewhere nobody remembers. Buyers order in round numbers. Lot sizes get copied from legacy systems. None of it is connected to the actual cost of ordering versus the actual cost of holding. The Wilson formula has been the textbook answer to this question for over a hundred years. This extension makes it trivial to apply.

The output goes directly into the field the BC Planning Worksheet already reads, so MPS and MRP runs immediately use the new quantities. No additional configuration. No third-party API. No subscription.

## How it integrates with MPS / MRP

The Planning Worksheet (for purchased items) and MPS/MRP runs respect three Item-level fields when generating supply suggestions:

| BC Field | What it does | EOQ writes here? |
|---|---|---|
| Reordering Policy | Algorithm used by the engine | Optional: switches None to Fixed Reorder Qty. |
| Reorder Point | When to trigger replenishment | No (use bc-safety-stock + Reorder Point math) |
| Reorder Quantity | How much to order (Fixed Reorder Qty.) | **Yes**, by default |
| Order Multiple | Quantity rounding for Lot-for-Lot | Optional alternative target |
| Minimum Order Quantity | Lower bound on suggestions | No |
| Maximum Inventory | Upper bound (Maximum Qty.) | No |

**Recommended pattern for stable demand:** Reordering Policy = Fixed Reorder Qty., EOQ goes into Reorder Quantity.

**Recommended pattern for volatile or seasonal demand:** Reordering Policy = Lot-for-Lot, EOQ goes into Order Multiple. The engine then computes net requirements and rounds up to economic batch sizes.

## What it adds (objects)

| Object | Type | ID |
|---|---|---|
| EOQ Setup | Table + Page | 50200 |
| EOQ Calculation Log | Table + Page | 50201 |
| EOQ Result Code | Enum | 50200 |
| EOQ Calculator | Codeunit | 50200 |
| EOQ Job Queue Run | Codeunit | 50201 |
| Item Card EOQ Ext | Page Extension | 50200 |
| Item List EOQ Ext | Page Extension | 50201 |
| EOQ Calculator | Permission Set | 50200 |

Object ID range: 50200 to 50299. Does not conflict with [bc-safety-stock](https://github.com/GmsoftLtd/bc-safety-stock) which uses 50100 to 50199.

## Installation

### Developer or sandbox

```bash
git clone https://github.com/GmsoftLtd/bc-eoq-calculator
```

Open the folder in VS Code with the AL Language extension. Confirm the app.json ID range does not conflict with anything else in your tenant. Press F5 to publish and launch.

### Production tenant

1. Download a release `.app` file from the [Releases page](https://github.com/GmsoftLtd/bc-eoq-calculator/releases), or build one from source
2. Upload via Extension Management → Manage → Upload Extension
3. Open **Search → EOQ Setup**, configure Ordering Cost, Holding Rate, and Write Target
4. Open one item, click **Calculate EOQ (Wilson)** on the Item Card, verify the calculation looks sensible
5. Filter the Item List to a small set (e.g. one Item Category), run **Calculate EOQ (Bulk)**
6. Review the EOQ Calculation Log

## Usage

### Single item

Open any Item Card. In the action area you will see a new **EOQ** group with:

- **Calculate EOQ (Wilson)** runs the formula, shows the result in a confirmation dialog, asks if you want to apply
- **View EOQ Log** opens the calculation log filtered to this item

### Bulk

Open the Item List. Filter to the set you want (Item Category Code, Vendor No., a saved view of A-class items), then in Actions → EOQ:

- **Calculate EOQ (Bulk)** processes every item in the filter
- **EOQ Calculation Log** opens the full log
- **EOQ Setup** opens the setup card

### Scheduled (Job Queue)

The included `EOQ Job Queue Run` codeunit (object 50201) accepts a Parameter String. Example for quarterly recalc of finished-goods items:

- Object Type: Codeunit
- Object ID: 50201
- Parameter String: `FILTER=Item Category Code:FERT`
- Recurring: Quarterly

Other supported filter fields: `Vendor No.`, `No.`, `Inventory Posting Group`, `Gen. Prod. Posting Group`.

## Setup options

| Field | Default | Meaning |
|---|---|---|
| Ordering Cost | 50 | S in the formula. Per-order admin cost in your local currency. |
| Holding Rate | 0.25 | H rate. Multiplied by Unit Cost to get annual holding cost per unit. |
| Demand Window Days | 365 | History window for demand observations. |
| Min Observations | 60 | Skip items with fewer ILE Sale entries in the window. |
| Write Target | Reorder Quantity | Which field receives the calculated EOQ. |
| Update Reordering Policy | true | Switch policy to Fixed Reorder Qty. when currently None. |
| Max EOQ Months | 6 | Cap on EOQ as months of demand (prevents extreme values for slow movers). |
| Default Cost Source | Last Direct Cost | Which Item field is used as Unit Cost. |

## When EOQ is not the right answer

The Wilson formula assumes steady demand and a constant unit cost. It is not appropriate for:

- **Intermittent demand** (long gaps, occasional bursts). Use Croston's method or category defaults.
- **Make-to-order items.** No inventory to optimise.
- **Heavy seasonality.** Run the calculation in the relevant season window, or use a manual quantity.
- **Quantity discount tiers.** The formula assumes a single unit cost. Compare total cost at EOQ versus total cost at the discount tier directly.
- **Joint replenishment items** that ship together. EOQ treats each item separately; this overestimates ordering cost.
- **Capacity- or capital-constrained items.** EOQ does not know your warehouse cap or working capital ceiling. The Max EOQ Months cap helps but does not replace judgement.

## Companion projects

This is the second extension in a planned replenishment trio:

- [bc-safety-stock](https://github.com/GmsoftLtd/bc-safety-stock) — Z-score safety stock calculator
- **bc-eoq-calculator** (you are here) — Wilson EOQ calculator
- bc-reorder-point (planned) — combines Safety Stock and lead-time demand to compute the Reorder Point

Together they cover the full deterministic-replenishment math for BC.

## Contributing

Issues and PRs welcome. Particularly interested in:

- Croston's method for intermittent demand
- Per-location calculations (rather than aggregate per item)
- Joint replenishment when multiple items share a vendor
- Quantity discount handling
- Currency / local price conversion when items have multiple cost currencies

## License

MIT. See [LICENSE](LICENSE).

## Related reading

Full theory and practical guide on the blog:

[insidebusinesscentral.com/eoq-in-business-central-calculator/](https://insidebusinesscentral.com/eoq-in-business-central-calculator/)
