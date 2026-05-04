# tidyprf Package Design

## Goal

R package that provides clean, tidy access to Brazilian Federal Highway Police (PRF) traffic data — accidents by person, accidents by occurrence, and infractions — via annual Parquet files hosted on GitHub Releases.

## Architecture

The package wraps a static file distribution layer (GitHub Releases) with a two-level cache (session memory for the catalog, disk for Parquet files). Core data functions download on demand, cache to disk, and return tidy tibbles. Infractions are always returned as Arrow queries because files are 100–300 MB; the user calls `collect()` after filtering. All downloads show a single-line progress bar via `httr2::req_progress()`.

**Note:** GitHub repo is currently `bonijoao/tidypfr` — must be renamed to `bonijoao/tidyprf` before package scaffold. `catalogo.json` and release URLs must be updated accordingly.

## Tech Stack

`httr2` (HTTP + progress), `arrow` (Parquet + lazy eval), `dplyr`, `cli` (messages), `jsonlite` (catalog), `fs` (paths), `tools::R_user_dir` (cache location)

---

## Data Sources

| Dataset | Years | File size | Rows (typical) |
|---|---|---|---|
| accidents (by person) | 2007–2026 | 6–12 MB | 270k–600k |
| crashes (by occurrence) | 2007–2026 | 0.8–3.7 MB | 17k–190k |
| violations | 2019–2020, 2022–2026 | 27–298 MB | 1M–10M |

Catalog index: `catalogo.json` at GitHub Releases `dados-v1`. Contains URLs, row counts, and file sizes for all 47 Parquet files.

---

## Public API (9 functions)

### Core data functions

```r
get_accidents(
  year,              # int or vector: 2020 or c(2019:2022, 2024)
  uf       = NULL,   # "SP" or c("SP", "RJ") — NULL = all
  br       = NULL,   # 365 or c(101, 116)    — NULL = all
  severity = NULL    # "fatal" | "injured" | "no_victims" — NULL = all
)
# Returns: tibble. Arrow used internally before collect(); user never sees it.

get_crashes(
  year,
  uf       = NULL,
  br       = NULL,
  severity = NULL
)
# Returns: tibble. Same contract as get_accidents().

get_violations(
  year,
  uf = NULL,   # uf_infracao
  br = NULL    # num_br_infracao
)
# Returns: Arrow query. User must call collect() after any dplyr filtering.
# Files are 100–300 MB; lazy eval is not optional here.
# No severity param: violations are infractions (fines), not accidents —
# they have cod_infracao/enquadramento instead of classificacao_acidente.
```

**severity mapping** (applied internally before returning):

| `severity =` | `classificacao_acidente` |
|---|---|
| `"fatal"` | `"Com Vítimas Fatais"` |
| `"injured"` | `"Com Vítimas Feridas"` |
| `"no_victims"` | `"Sem Vítimas"` |

### Data dictionary functions

```r
info_accidents(lang = "en")   # tibble: variable | type | description
info_crashes(lang = "en")     # tibble: variable | type | description
info_violations(lang = "en")  # tibble: variable | type | description
```

- `lang`: `"en"` or `"pt"`. Descriptions are embedded in `data/codebook.rda` — no network call.
- Returns a tibble printed to the console; assign to keep.

### Utility functions

```r
prf_years(dataset = NULL)
# dataset: "accidents" | "crashes" | "violations" | NULL = all three
# Returns: tibble with columns dataset | year | rows | size_mb

prf_cache(dataset = NULL)
# Returns: tibble with columns dataset | year | size_mb | cached_at

prf_cache_clear(dataset = NULL, year = NULL)
# Deletes matching cached Parquet files from disk.
# Returns invisibly. Prints count of files deleted via cli.
```

---

## Download and Cache Flow

```
get_accidents(year = 2023, uf = "SP")
  │
  ├── 1. Read catalog (session cache via .tidyprf_env$catalog)
  │         First call: httr2 download → parse JSON → store in env
  │         Subsequent calls: read from env (no network)
  │
  ├── 2. For each year in vector:
  │     ├── Check R_user_dir("tidyprf", "cache") / accidents_2023.parquet
  │     │     EXISTS   → cli: "✔ Using cached accidents_2023.parquet (11 MB)"
  │     │     MISSING  → httr2::req_progress() download → save to cache
  │     │                 cli: "→ Downloading accidents_2023.parquet (11 MB)"
  │     │                 Progress bar: single line, updates in place
  │     └── arrow::open_dataset(cached_path)
  │
  ├── 3. Apply filters via Arrow (uf, br, severity) before collect()
  │
  ├── 4. dplyr::bind_rows() across years if multi-year
  │
  └── 5. Return tibble
```

Cache directory: `tools::R_user_dir("tidyprf", "cache")` by default.
Override: `options(tidyprf.cache_dir = "/my/path")`.

---

## File Structure

```
tidyprf/
├── R/
│   ├── get_accidents.R    # get_accidents(), get_crashes() — shared internal logic
│   ├── get_violations.R   # get_violations() — always returns Arrow query
│   ├── info.R             # info_accidents(), info_crashes(), info_violations()
│   ├── cache.R            # prf_cache(), prf_cache_clear(), prf_years()
│   ├── download.R         # internal: fetch_parquet(), catalog_get() — not exported
│   └── utils.R            # severity_map(), validate_year(), cache_path() — not exported
├── data/
│   └── codebook.rda       # embedded PT/EN dictionary tibble
├── tests/testthat/
│   ├── test-get_accidents.R
│   ├── test-get_violations.R
│   ├── test-info.R
│   └── test-cache.R
└── DESCRIPTION
```

---

## Error Handling

- Invalid year (outside available range): `cli::cli_abort()` with list of valid years from catalog
- Year with no data (e.g. violations 2021): `cli::cli_abort()` — not a warning, avoids silent empty tibbles
- Network failure: `httr2` surfaces the error; no partial file left on disk
- Unknown `severity` value: `cli::cli_abort()` showing valid options

---

## Testing Strategy

- `get_accidents()` / `get_crashes()`: mock HTTP with `httptest2`; test that filters reduce rows correctly; test multi-year bind; test cache hit path (no HTTP call on second invocation)
- `get_violations()`: test that return class is `ArrowTabularDataset` or `arrow_dplyr_query`; test that `collect()` works after `filter()`
- `info_*`: test both `lang = "en"` and `lang = "pt"`; test that all schema columns are present
- `prf_cache()` / `prf_cache_clear()`: use `withr::with_tempdir()` to isolate cache
- All tests: `skip_on_cran()` for any test touching network or disk cache
