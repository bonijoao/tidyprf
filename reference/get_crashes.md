# Get PRF accident data by occurrence

Downloads and returns accident records at the occurrence level (one row
per accident, with aggregated person and vehicle counts). Files are
cached after first download.

## Usage

``` r
get_crashes(year, uf = NULL, br = NULL, severity = NULL)
```

## Arguments

- year:

  Integer or vector of integers. Year(s) to fetch (2007-2026).

- uf:

  Character or NULL. State abbreviation(s). NULL = all.

- br:

  Integer or NULL. Federal highway number(s). NULL = all.

- severity:

  Character or NULL. `"fatal"`, `"injured"`, or `"no_victims"`. NULL =
  all.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # \dontrun{
get_crashes(2023)
get_crashes(2020:2023, uf = c("SP", "RJ"))
} # }
```
