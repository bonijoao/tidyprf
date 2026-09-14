## Update

This is a minor update (0.1.1 -> 0.2.0). Cached data files are now refreshed
when the online catalog lists a newer version. If the catalog cannot be reached
or the download fails, the previously cached file is used, so the package keeps
working offline. The check can be disabled with
`options(tidyprf.check_updates = FALSE)`.

## Test environments

* local: Windows 11, R 4.5.3
* GitHub Actions: macOS (release), Windows (release),
  Ubuntu (devel, release, oldrel-1)
* win-builder: R-devel

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are currently no reverse dependencies on CRAN.

## Comments

* Examples for `get_accidents()`, `get_crashes()`, `get_violations()`,
  `prf_years()`, and `prf_cache_clear()` are wrapped in `\dontrun{}` because
  they download multi-megabyte data files from the internet (GitHub Releases)
  or delete files from the user's cache directory.
* All tests run offline: network access is mocked with `testthat`
  local mocked bindings, the catalog update check is disabled in tests via the
  `tidyprf.check_updates` option, and cached files are written to a temporary
  directory via the `tidyprf.cache_dir` option.
* Downloaded data are cached in `tools::R_user_dir("tidyprf", "cache")`,
  in line with CRAN policy on persistent user data.
