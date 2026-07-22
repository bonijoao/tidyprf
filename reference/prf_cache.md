# Show locally cached PRF data files

Show locally cached PRF data files

## Usage

``` r
prf_cache(dataset = NULL)
```

## Arguments

- dataset:

  Character or NULL. One of `"accidents"`, `"crashes"`, `"violations"`.
  NULL (default) shows all.

## Value

A tibble with columns `dataset`, `year`, `size_mb`, `cached_at`.

## Examples

``` r
prf_cache()
#> # A tibble: 0 × 4
#> # ℹ 4 variables: dataset <chr>, year <int>, size_mb <dbl>, cached_at <date>
```
