# Get PRF infraction data

Downloads PRF infraction records and returns an Arrow query. Files are
100-300 MB; use
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html)
before
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html)
to avoid loading the full dataset into memory.

## Usage

``` r
get_violations(year, uf = NULL, br = NULL)
```

## Arguments

- year:

  Integer or vector of integers. Available: 2019-2020, 2022-2026.

- uf:

  Character or NULL. State of infraction (`uf_infracao`). NULL = all.

- br:

  Integer or NULL. Federal highway number (`num_br_infracao`). NULL =
  all.

## Value

An Arrow query. Call
[`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html)
to load into a tibble.

## Examples

``` r
if (FALSE) { # \dontrun{
# Filter before collecting to avoid loading 243 MB into RAM
get_violations(2024, uf = "SP") |>
  dplyr::filter(cod_infracao == "55412") |>
  dplyr::collect()
} # }
```
