# Delete locally cached PRF data files

Delete locally cached PRF data files

## Usage

``` r
prf_cache_clear(dataset = NULL, year = NULL)
```

## Arguments

- dataset:

  Character or NULL. Dataset to clear. NULL = all.

- year:

  Integer or NULL. Year(s) to clear. NULL = all years.

## Value

Invisible NULL.

## Examples

``` r
if (FALSE) { # \dontrun{
prf_cache_clear("violations", year = 2024)
prf_cache_clear()
} # }
```
