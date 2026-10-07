---
name: expense-log
description: Log spending, income and transfers to the xpenses MCP, plan purchases, and answer balance, budget and spending questions. Use whenever the user recaps their day or mentions buying, eating, paying or travelling, even without saying "expense" or "log" (e.g. "breakfast, bus to Mahidol, pizza", "spent 139 on pizza", "log my day"). Also use for "how much is left", "am I over budget", "got paid", "moved 500 to SCB", "plan to buy X". Applies the user's habitual prices and accounts and confirms before writing.
---

# Expense Log

Turn a daily recap into correctly categorized xpenses entries. Parse items,
apply stated prices or habits, show a summary, and wait for confirmation
before writing.

## Rules

- Never write before clear user confirmation of parsed items and total.
- Amounts are baht. Default date is today in Bangkok. Honor a stated date
  ("yesterday", "Monday") and resolve it to `YYYY-MM-DD` in the summary.
- Call `get_categories` once per session before mapping. Pass live names
  verbatim. The server also accepts unique prefix or substring matches; do
  not rely on that. Use `Other` when no mapping fits and flag it.
- Never create or edit categories or accounts. If a tool rejects a name as
  unknown or ambiguous, resolve it with the user; never silently substitute.
- Accounts: `KrungThai`, `Cash`, `TrueMoney`, `SCB`, `HOP`. Use
  `get_balances` if a write rejects one of these.
- `SCB` is savings only. Never offer it for spending.
- `HOP` is a transit card. Use it for rail fares (BTS, MRT, Airport Rail
  Link) and any fare the user says was paid by card or HOP. Buses stay
  `Cash` unless the user says otherwise.
- Account priority: stated account > 7/11 rule (`TrueMoney`) > habit map.
- Every read response is in satang (`money_unit: "satang"`). Divide by 100
  before showing baht. Write inputs (`amount_baht`) are baht.
- Compute totals, subtotals and budget sums with a quick script when a shell
  is available, not by hand. A wrong total breaks trust in every number.

## Writes and retries

- Write every confirmed batch with one `create_transactions` call (1-20
  entries, atomic). More than 20: split into confirmed batches of 20 max.
- One fresh UUID `request_id` per call. On a transient or uncertain failure,
  retry once with the identical payload, UUID, and explicit `date`.
- Never resend a failed or uncertain write under a new UUID. If still
  uncertain, call `list_transactions` for that month and check for the
  entries before doing anything else.
- Report confirmed successes, failures, and uncertain results separately.

## Habit map

Stated price overrides default. Ask when table says ask.

| Item | Baht | Category | Account |
| --- | ---: | --- | --- |
| breakfast; dinner; night meal | 20 | Groceries | Cash |
| rice + something; cheap street meal | ask, about 30 | Groceries | Cash |
| Big C lunch food | 50 | Eating Out | KrungThai |
| Big C lunch coffee | 5 | Coffee | KrungThai |
| pizza | 139 | Eating Out | KrungThai |
| hotpot; suki | 279 | Eating Out | KrungThai |
| Taobin coffee | ask, 5-10 | Coffee | KrungThai |
| branded cafe coffee | ask | Coffee | KrungThai |
| street-cart coffee | ask, 5-10 | Coffee | Cash |
| bus to Mahidol | 25 | Transport | Cash |
| bus home from Mahidol | 45 | Transport | Cash |
| bus; cycle; songthaew | ask, 10-40 | Transport | Cash |
| BTS; MRT; Airport Rail Link | ask | Transport | HOP |
| 7/11 snack; beer; drink | ask | Entertainment | TrueMoney |
| taxi; airport; intercity trip | ask | Travel | KrungThai |
| clothes | stated price | Clothing | KrungThai |
| skincare; grooming | stated price | Personal Care | KrungThai |
| phone case; cable; gadget | stated price | Tech | KrungThai |
| pharmacy; medicine; clinic | stated price | Health | KrungThai |
| laundry | stated price | Laundry | Cash |
| cleaning supplies; kitchenware; home items | stated price | Household | KrungThai |
| mobile plan; subscription | stated price | Bills | KrungThai |
| rent | stated price | Rent | KrungThai |
| university fee; academic supplies | stated price | Mahidol | KrungThai |

`Mahidol` category is university costs only. Bus fares use `Transport`.
Every coffee is a separate `Coffee` entry. Split Big C lunch into food and
coffee only when the user mentions coffee. Keep notes short: the item, with
meal or context in parens, e.g. `bread (dinner)`. Put a named shop or
source in parens, e.g. "taobin coffee" -> `coffee (Taobin)`. Preserve
user-supplied parentheticals verbatim, e.g. `powerbank (shopee)`. Do not repeat the account or "7/11" in the note.

## Workflow

1. Parse one-off expense items from the message. Do not infer recurring
   spending.
2. Assign date, amount, category, account, and note. Apply the habit map.
   Ask all unknown prices or genuine account coin-flips in one batch.
3. If any item uses `Cash`, call `get_balances` and compare. Show item,
   note, baht, category, account, total, per-account subtotals, and every
   assumption or `Other` mapping. Ask for confirmation.
4. On confirmation, write with `create_transactions`.
5. After a successful write, call `get_budgets` for each logged `YYYY-MM`.
   Warn only when a touched category is at or above 80% of its budget.
   Ignore categories without a budget. Report count and total.

If the user says an item may already be logged, call `list_transactions`
for that month and show matches before asking to confirm.

## Other xpenses requests

Use only the tools the request needs. Read-only questions need no
confirmation and must never trigger a write.

| Request | Tool | Inputs |
| --- | --- | --- |
| Account balances | `get_balances` | none |
| Category list | `get_categories` | none |
| Transaction history; duplicate check | `list_transactions` | `month` |
| Budget status | `get_budgets` | `month` |
| Budget burn and velocity flags | `get_anomalies` | `month` |
| Vs last month and trailing average | `get_comparisons` | `month` |
| Month-end projection | `get_forecast` | `month` |
| Planned purchases | `get_plans` | `month` |

Month inputs use `YYYY-MM`. Default an unspecified month to the current
Bangkok month and state the period. Forecasts are projections, not recorded
spending. For balances, show `available` and mention `reserved` when it is
non-zero.

### Income and transfers

For explicit income or transfer requests, use `create_transactions`.
Income requires `type: income`, `account`, `amount_baht`. Transfer requires
`type: transfer`, `from_account`, `to_account`, `amount_baht`. Both accept
`date` and `note`; neither takes a category. Show type, amount, date, and
accounts for confirmation. SCB is allowed for an explicitly requested
savings transfer.

Cash top-ups are transfers `KrungThai` -> `Cash`, never income. Treat
"took out 500", "withdrew 500", "ATM 500", or "moved 500 to cash" as that
transfer. Topping up HOP or TrueMoney from KrungThai is also a transfer.
If a recap's Cash items exceed the Cash `available` balance, say so in the
summary and ask whether a top-up is missing. Still log the expenses; the
check is a heads-up, not a gate. Do not count transfers or income as expenses. Mixed
batches may include expenses; apply budget warnings only to those.

### Planned purchases

Use `create_plan` only when the user wants a planned purchase. Resolve
`name`, `amount_baht`, `category`, `account`, and `planned_date`
(`YYYY-MM-DD`). Include `wait_days` (0-30) only when supplied or clarified.
Confirm these fields, then write with a fresh UUID `request_id`. A plan is
not a recorded expense; never also charge it.

When the user buys a non-habit item (gadget, clothes, anything not in the
daily habit rows), call `get_plans` for that month. If `get_plans` errors,
say the plan check failed and continue. If a plan matches by name, log it as a normal expense
and tell the user the plan still exists and may still reserve money. No
tool links or closes plans, so the user must remove it in the app.

### Recurring expenses

No recurring tools are exposed. If asked to set up a recurring expense,
say so. Do not substitute a plan or a one-off expense. If recurring tools
appear later, inspect their schemas, check existing rules for duplicates,
ask for the first run date, and never back-charge the current period.

## Example

Input: `today breakfast, bus to Mahidol and back, Big C lunch, 7/11 beer 60,
pizza for dinner`

Summary before write (date 2026-10-06):

| Item | Note | Baht | Category | Account |
| --- | --- | ---: | --- | --- |
| breakfast | breakfast | 20 | Groceries | Cash |
| bus to Mahidol | bus (Mahidol) | 25 | Transport | Cash |
| bus home | bus (home) | 45 | Transport | Cash |
| Big C lunch | Big C (lunch) | 50 | Eating Out | KrungThai |
| 7/11 beer | beer | 60 | Entertainment | TrueMoney |
| pizza | pizza (dinner) | 139 | Eating Out | KrungThai |

Total: 339 baht. Cash 90; KrungThai 189; TrueMoney 60. Ask user to confirm.
