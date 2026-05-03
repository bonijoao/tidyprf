# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is the development workspace for `tidypfr`, an R package that provides tidy-formatted Brazilian Federal Highway Police (PRF — Polícia Rodoviária Federal) traffic accident and infraction data. The package will eventually fetch data from the PRF open data API; local CSV files are used for development and testing.

## Package Structure (to be created)

No R package scaffold exists yet. Use `usethis` to initialize:

```r
usethis::create_package("tidypfr")
usethis::use_roxygen_md()
usethis::use_testthat()
usethis::use_mit_license()
usethis::use_readme_rmd()
usethis::use_github_actions()
```

## Common Development Commands

```r
# Load and check package
devtools::load_all()
devtools::check()

# Run tests
devtools::test()
testthat::test_file("tests/testthat/test-<file>.R")  # single test file

# Style and lint
styler::style_pkg()
lintr::lint_package()

# Documentation
devtools::document()  # regenerates Rd files from roxygen2
pkgdown::build_site()

# Coverage
covr::package_coverage()
```

## Data Sources and Structure

### Local data (for development)

All CSVs use **semicolon separator** (`;`) and **Latin-1/Windows-1252 encoding** (common in Portuguese government data).

| Folder | Description |
|---|---|
| `dados/processados/` | Clean CSV files ready for use |
| `dados/brutos/` | Compressed raw files (ZIP/RAR) |
| `dicionario/` | PDF data dictionaries |
| `referencias/` | Reference PDFs (tidy-data, sidrar, educabR) |

### Dataset types

**1. Accidents by person (`acidentes*.csv`)** — one row per person involved, ~32 columns including:
- Identifiers: `id`, `pesid`, `id_veiculo`
- Temporal: `data_inversa`, `dia_semana`, `horario`, `fase_dia`
- Location: `uf`, `br`, `km`, `municipio`, `latitude`, `longitude`, `regional`, `delegacia`, `uop`
- Accident: `causa_acidente`, `tipo_acidente`, `classificacao_acidente`, `sentido_via`, `condicao_metereologica`, `tipo_pista`, `tracado_via`, `uso_solo`
- Vehicle: `tipo_veiculo`, `marca`, `ano_fabricacao_veiculo`
- Person: `tipo_envolvido`, `estado_fisico`, `idade`, `sexo`
- Counts: `ilesos`, `feridos_leves`, `feridos_graves`, `mortos`

Files: `acidentes2007.csv` … `acidentes2026.csv` (annual), plus `acidentes*_todas_causas_tipos.csv` variants.

**2. Accidents by occurrence (`datatran*.csv`)** — one row per accident event, ~31 columns (aggregated counts instead of per-person fields). Files: `datatran2007.csv` … `datatran2026.csv`.

**3. Infractions (`infracoes_*.csv`, `ajustados_*/infraçoes*.csv`)** — one row per infraction, ~22 columns including:
- `dat_infracao`, `hora`, `uf_infracao`, `num_br_infracao`, `num_km_infracao`, `nom_municipio`
- `cod_infracao`, `descricao_abreviada`, `enquadramento`
- Vehicle: `especie`, `nome_veiculo_marca`, `nom_modelo_veiculo`, `uf_placa`
- Measured values: `med_realizada`, `med_considerada`, `exc_verificado`

File layout varies by year (monthly files under `ajustados_YYYY/` for 2022+, annual files before).

### Data dictionaries (dicionario/)

- `Dicionário de Variáveis_ocorrencia_2017.pdf` — accidents by occurrence, 2017+
- `Dicionário de Variáveis_pessoa_2017_todas_causas_tipos.pdf` — accidents by person, 2017+
- `acidentes agrupados por ocorrência (até 2016).pdf` — occurrence format before 2017
- `acidentes agrupados por pessoa (até 2016).pdf` — person format before 2017
- `dicionario-de-variaveis-infracoes.pdf` — infraction variables

## Architecture and Design Principles

### Tidy data output

Every exported function must return a tidy tibble (one observation per row, one variable per column). See `referencias/tidy-data.pdf`.

### Function naming

Follow `objeto_verbo()` convention in `snake_case`:
```r
acidentes_obter()   # fetch accident data
datatran_obter()    # fetch occurrence-level accident data
infracoes_obter()   # fetch infraction data
```

Data parameter always comes **first** to support pipe (`|>`) usage.

### Local vs. API mode

During development, functions read from `dados/processados/`. In production, they will call the PRF open data API. Abstract this behind a single access layer so the switch is transparent to callers.

### Dependencies to use

- HTTP requests: `httr2`
- JSON: `jsonlite`
- Tidy data: `dplyr`, `tidyr`, `readr`
- Spatial: `sf` (not `sp`)
- Messages/warnings: `cli` (not `print()` or `cat()`)

## Package Development Standards (from Diretrizes_pacote.txt)

- **Roxygen2** mandatory for all exported functions: include `@param`, `@return`, `@examples`.
- **Tests** with `testthat`; target >75% coverage tracked via Codecov.
- **API/HTTP tests**: use `httptest2` or `vcr` for mocking; always `skip_on_cran()` for network-dependent tests.
- **Graph tests**: use `vdiffr`.
- **CI**: GitHub Actions via `r-lib/actions`, test against R release, oldrel, and devel.
- **Pkgdown** site with functions grouped by `@family` tag.
- **No global assignments** inside functions; never use `print()` or `cat()` for output.
- CRAN checklist items: Title Case title, no trailing period, all URLs in `< >`, examples runnable offline.
