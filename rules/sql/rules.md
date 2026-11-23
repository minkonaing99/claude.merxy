# SQL Rules

Source: supabase/agent-skills `supabase-postgres-best-practices` (Postgres anywhere).
MySQL (e.g. Hostinger) notes marked [MySQL]. Existing projects: no migrations; write SQL to `docs/new-changes-db.sql` (see CLAUDE.md).

## Queries (CRITICAL)
- Index columns used in `WHERE`, `JOIN`, `ORDER BY` on large tables.
- Composite index order: equality columns first, then range/sort.
- Partial indexes for filtered subsets (`WHERE deleted_at IS NULL`).
- Covering indexes (`INCLUDE`) for hot read paths. Right index type: B-tree default, GIN for JSONB/arrays/full-text, BRIN for huge append-only time data.
- Select only needed columns. Never `SELECT *` in app code.
- Check slow queries with `EXPLAIN (ANALYZE, BUFFERS)` [MySQL: `EXPLAIN ANALYZE`].

## Connections (CRITICAL)
- Use a pool (pgbouncer / Supavisor / driver pool). Never open a connection per request.
- Set connection limits and idle timeouts.
- Transaction-mode poolers: no session prepared statements, or use the driver's pooler-safe mode.

## Security (CRITICAL)
- Parameterized queries only. Never concatenate user input into SQL.
- Multi-tenant tables: enable RLS with policies per tenant [MySQL: enforce tenant filter in a data layer].
- RLS performance: wrap `auth.uid()` as `(select auth.uid())`, index policy columns.
- Least privilege: app role gets only the grants it needs; no superuser from the app.

## Schema (HIGH)
- Lowercase `snake_case` identifiers. No quoted mixed case.
- Primary keys: `bigint generated always as identity`, or UUIDv7 when IDs are public or distributed. Avoid random UUIDv4 as clustered key.
- Types: `text` over `varchar(n)` [MySQL: sized `VARCHAR`], `timestamptz` for time, `numeric` for money, `boolean`, `jsonb` not `json`.
- Index every foreign key column.
- `NOT NULL`, `CHECK`, `UNIQUE` and FK constraints in the DB, not only app code.
- Add constraints safely: `NOT VALID` then `VALIDATE CONSTRAINT`; `CREATE INDEX CONCURRENTLY` on live tables. Idempotent DDL (`IF NOT EXISTS`).
- Partition very large time-series tables.

## Locking (MEDIUM-HIGH)
- Keep transactions short. No network calls inside a transaction.
- Lock rows in consistent order to avoid deadlocks.
- Job queues: `FOR UPDATE SKIP LOCKED`.
- App-level mutex: advisory locks [MySQL: `GET_LOCK`].

## Data access (MEDIUM)
- No N+1: batch with `IN`/`ANY($1)` or joins.
- Cursor (keyset) pagination, not deep `OFFSET`.
- Bulk insert in batches or `COPY`.
- Upsert with `INSERT ... ON CONFLICT` [MySQL: `ON DUPLICATE KEY UPDATE`].

## Maintenance
- Enable `pg_stat_statements` to find heavy queries.
- Keep autovacuum on; `ANALYZE` after big loads.
- Full-text: `tsvector` + GIN, not `LIKE '%x%'`. JSONB: GIN index on queried paths.

## Style
- Uppercase keywords, one clause per line for non-trivial queries.
- Explicit `JOIN ... ON`, never comma joins. Explicit column lists in `INSERT`.
- Comment non-obvious queries with intent.
