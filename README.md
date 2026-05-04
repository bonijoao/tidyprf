# tidyprf <img src="Logo/logo_tidyprf.png" align="right" height="139" />

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/bonijoao/tidyprf/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bonijoao/tidyprf/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

*[Leia em Português](README.pt-br.md)*

**tidyprf** gives you direct access to Brazilian Federal Highway Police (PRF)
road safety data — traffic accidents by person, accidents by occurrence, and
traffic violations — all from within R. No manual downloads, no navigating
government portals: just pick a dataset, choose the year, and get a clean,
analysis-ready tibble.

Data is distributed as Parquet files via GitHub Releases and cached locally
after the first download.

## Quick example

Compare accidents and traffic violations on BR-116 throughout 2024:

```r
library(tidyprf)
library(dplyr)
library(ggplot2)
library(lubridate)

# Accidents on BR-116 in 2024 (one row per person involved)
acc <- get_accidents(2024, br = 116) |>
  mutate(mes = month(data_inversa)) |>
  count(mes, name = "acidentes")

# Violations on BR-116 in 2024 — filter before collect(), files are ~243 MB
vio <- get_violations(2024, br = 116) |>
  collect() |>
  mutate(mes = month(dat_infracao)) |>
  count(mes, name = "infracoes")

# Monthly comparison
left_join(acc, vio, by = "mes") |>
  tidyr::pivot_longer(-mes, names_to = "tipo", values_to = "n") |>
  ggplot(aes(mes, n, color = tipo)) +
  geom_line(linewidth = 1) +
  geom_point() +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  labs(title = "BR-116 in 2024: Accidents vs. Violations",
       x = NULL, y = "Count", color = NULL) +
  theme_minimal()
```

## Installation

Install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("bonijoao/tidyprf")
```

## Datasets

| Dataset | Function | Unit | Available Years |
|---|---|---|---|
| Accidents by person | `get_accidents()` | 1 row per person | 2007–2026 |
| Accidents by occurrence | `get_crashes()` | 1 row per accident | 2007–2026 |
| Traffic violations | `get_violations()` | 1 row per violation | 2019–2020, 2022–2026 |

All three functions support filtering by:
- `uf` — state abbreviation(s), e.g. `"SP"`, `c("SP", "RJ")`
- `br` — federal highway number(s), e.g. `101`, `116`
- `severity` — `"fatal"`, `"injured"`, or `"no_victims"` (accidents only)

Use `info_accidents()`, `info_crashes()`, or `info_violations()` to see all
variable descriptions in English or Portuguese.

## Cache

Parquet files are cached locally after first download:

```r
prf_cache()               # show cached files and sizes
prf_cache_clear()         # delete all cached files
prf_years("accidents")    # available years and row counts per dataset
```

## License

MIT
