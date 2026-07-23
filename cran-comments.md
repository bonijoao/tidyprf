## Resubmission

This is a resubmission. In the previous submission (0.1.0), CRAN reported:

    Found the following (possibly) invalid file URI:
      URI: README.pt-br.md
        From: README.md

Fixed: the link to the Portuguese-language README (a file not shipped in the
package tarball) now uses the absolute GitHub URL
<https://github.com/bonijoao/tidyprf/blob/master/README.pt-br.md> instead of a
relative file URI.

## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release, so win-builder reports the usual
  "CRAN incoming feasibility ... NOTE: New submission".
* The "possibly misspelled" words flagged in that NOTE ("cia", "ria") are
  fragments of "Polícia Rodoviária Federal" — the official Portuguese name
  of the Brazilian Federal Highway Police — split by the spell checker at
  the accented characters. They are not misspellings.

## Comments

* Examples for `get_accidents()`, `get_crashes()`, `get_violations()`,
  `prf_years()`, and `prf_cache_clear()` are wrapped in `\dontrun{}` because
  they download multi-megabyte data files from the internet (GitHub Releases)
  or delete files from the user's cache directory.
* All tests run offline: network access is mocked with `testthat`
  local mocked bindings, and cached files are written to a temporary
  directory via the `tidyprf.cache_dir` option.
* Downloaded data are cached in `tools::R_user_dir("tidyprf", "cache")`,
  in line with CRAN policy on persistent user data.
