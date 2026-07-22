# Get PRF accident data by person

Downloads and returns accident records at the person level (one row per
person involved in each accident). Files are cached after first
download.

## Usage

``` r
get_accidents(year, uf = NULL, br = NULL, severity = NULL)
```

## Arguments

- year:

  Integer or vector of integers. Year(s) to fetch (2007-2026).

- uf:

  Character or NULL. State abbreviation(s), e.g. `"SP"`. NULL = all.

- br:

  Integer or NULL. Federal highway number(s), e.g. `101`. NULL = all.

- severity:

  Character or NULL. `"fatal"`, `"injured"`, or `"no_victims"`. NULL =
  all.

## Value

A tibble.

## Examples

``` r
if (FALSE) { # \dontrun{
get_accidents(2023)
get_accidents(2020:2023, uf = "SP", severity = "fatal")
df <- get_accidents(c(2019:2021, 2023), br = 101)
} # }
```
