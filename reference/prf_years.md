# Show years available in the PRF catalog

Show years available in the PRF catalog

## Usage

``` r
prf_years(dataset = NULL)
```

## Arguments

- dataset:

  Character or NULL. One of `"accidents"`, `"crashes"`, `"violations"`.
  NULL (default) returns all three.

## Value

A tibble with columns `dataset`, `year`, `rows`, `size_mb`.

## Examples

``` r
if (FALSE) { # \dontrun{
prf_years()
prf_years("accidents")
} # }
```
