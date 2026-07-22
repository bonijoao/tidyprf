# Changelog

## tidyprf 0.1.0

- Initial release.
- [`get_accidents()`](https://bonijoao.github.io/tidyprf/reference/get_accidents.md),
  [`get_crashes()`](https://bonijoao.github.io/tidyprf/reference/get_crashes.md),
  and
  [`get_violations()`](https://bonijoao.github.io/tidyprf/reference/get_violations.md)
  download PRF open data as tidy tibbles, with filters by year, state
  (`uf`), federal highway (`br`), and severity.
- [`info_accidents()`](https://bonijoao.github.io/tidyprf/reference/info_accidents.md),
  [`info_crashes()`](https://bonijoao.github.io/tidyprf/reference/info_crashes.md),
  and
  [`info_violations()`](https://bonijoao.github.io/tidyprf/reference/info_violations.md)
  provide bilingual variable descriptions (English/Portuguese).
- [`prf_years()`](https://bonijoao.github.io/tidyprf/reference/prf_years.md)
  lists available years per dataset;
  [`prf_cache()`](https://bonijoao.github.io/tidyprf/reference/prf_cache.md)
  and
  [`prf_cache_clear()`](https://bonijoao.github.io/tidyprf/reference/prf_cache_clear.md)
  manage the local Parquet cache.
