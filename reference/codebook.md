# Variable codebook for tidyprf datasets

Bilingual (English/Portuguese) variable descriptions for all three PRF
datasets. Used internally by
[`info_accidents()`](https://bonijoao.github.io/tidyprf/reference/info_accidents.md),
[`info_crashes()`](https://bonijoao.github.io/tidyprf/reference/info_crashes.md),
and
[`info_violations()`](https://bonijoao.github.io/tidyprf/reference/info_violations.md).

## Usage

``` r
codebook
```

## Format

A tibble with 97 rows and 5 columns:

- dataset:

  Dataset name: `"accidents"`, `"crashes"`, or `"violations"`

- variable:

  Variable name as returned by the `get_*()` functions

- type:

  R type abbreviation (chr, int, dbl, date)

- description_en:

  Description in English

- description_pt:

  Description in Portuguese

## Source

Compiled from the official PRF variable dictionaries published at
<https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/dados-abertos-da-prf>.
