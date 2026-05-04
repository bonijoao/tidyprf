# Design: Repo Organization, README, and Update Workflow

**Date:** 2026-05-04  
**Status:** Approved  
**Scope:** Three parallel improvements to the tidyprf package ecosystem

---

## 1. Repository Organization

### Goal

Separate the R package (`bonijoao/tidyprf`) from the data pipeline, which was used to build the parquet files during development. The package repo becomes a clean R package; the pipeline lives in a dedicated repo.

### New repo: `bonijoao/tidyprf-dados`

A separate GitHub repository and a separate local folder (e.g., `D:\tidyprf-dados\`) containing everything related to building and updating the parquet datasets.

**Files migrated from `bonijoao/tidyprf`:**

| File/Folder | Notes |
|---|---|
| `baixar_dados.R` | Download script for raw PRF files |
| `descompactar.R` | Decompression script |
| `scripts/consolidar.R` | CSV → parquet consolidation |
| `plano_B.R` | Alternative pipeline approach |
| `dicionario/` | PDF data dictionaries |
| `referencias/` | Reference PDFs (tidy-data, sidrar, educabR) |
| `docs/dicionario_consolidado.qmd` + `.pdf` | Consolidated dictionary |
| `pagina/pagina_principal.txt` | Web page draft |
| `Diretrizes_pacote.txt` | Development guidelines |

**Files deleted from `bonijoao/tidyprf`:**

- `scripts/_test_*.R` (already gitignored)
- `teste.R`
- `verify_temp.R`

**Files that stay in `bonijoao/tidyprf`:**

- All R package files (`R/`, `man/`, `tests/`, `data/`, `data-raw/`, `DESCRIPTION`, `NAMESPACE`, etc.)
- `dados/consolidados/catalogo.json` — the package reads this at runtime
- `Logo/` — used in README and future pkgdown site
- `docs/superpowers/` — planning docs and specs

### Local folder structure for `tidyprf-dados`

```
tidyprf-dados/
├── scripts/
│   ├── update_acidentes.R
│   ├── update_datatran.R
│   ├── update_infracoes.R
│   └── atualizar_catalogo.R
├── dicionario/
├── referencias/
├── docs/
│   ├── dicionario_consolidado.qmd
│   └── dicionario_consolidado.pdf
├── dados/
│   ├── brutos/
│   └── processados/
└── README.md
```

---

## 2. README

### Strategy

Two files, following the `educabR` pattern:

- `README.md` — English (primary, shown on GitHub)
- `README.pt-br.md` — Portuguese (linked from the English README)

### `README.md` structure

1. **Badges:** CRAN status, CRAN downloads, R-CMD-check, codecov, lifecycle
2. **Language link:** *"Leia em Português"* → `README.pt-br.md`
3. **Introduction paragraph:** What the package is, what it covers (accidents by person, accidents by occurrence, violations), how data is delivered (parquet files cached locally from GitHub Releases)
4. **Quick example:** Combined analysis of accidents + violations on a specific federal highway (BR-116, 2024) — one plot showing accidents over time and violations by month
5. **Installation:** CRAN (future) + `remotes::install_github("bonijoao/tidyprf")`
6. **Datasets table:** Three sections — Accidents (`get_accidents`), Crashes (`get_crashes`), Violations (`get_violations`) — with available years per dataset
7. **Cache section:** `prf_cache()`, `prf_cache_clear()`, `prf_years()`
8. **Documentation:** Link to future pkgdown site

### `README.pt-br.md` structure

Identical structure, translated to Portuguese.

### Quick example sketch

```r
library(tidyprf)
library(dplyr)
library(ggplot2)

# Accidents and violations on BR-116 in 2024
acidentes <- get_accidents(2024) |> filter(br == 116)
infracoes <- get_violations(2024) |> filter(num_br_infracao == 116)
```

Output: combined plot — line chart of accidents per month + bar chart of violations per month on the same highway.

---

## 3. Update Workflow (Manual)

### Context

The PRF publishes new data periodically. For 2026, data arrives monthly. Older years are stable. The current data lives in GitHub Releases under the tag `dados-v1` in `bonijoao/tidyprf`.

The workflow is **manual for now**, with automation planned via GitHub Actions in the future (see memory: `project_update_workflow.md`).

### Scripts (live in `tidyprf-dados/scripts/`)

**`update_acidentes.R`**
1. Download new CSVs from the PRF portal for updated years
2. Convert to parquet via `{arrow}`
3. Save to `dados/consolidados/acidentes/`
4. Print summary: rows, file size, years updated

**`update_datatran.R`** — same logic for occurrence-level accidents

**`update_infracoes.R`** — same logic for violations

**`atualizar_catalogo.R`**
1. Read all parquet files in `dados/consolidados/`
2. Recalculate `tamanho_mb`, `linhas`, `atualizado_em` for each file
3. Rewrite `dados/consolidados/catalogo.json` in the `tidyprf` package repo
4. Print a diff summary of what changed

### Full update flow

```
1. Run update_<dataset>.R for the dataset(s) that changed
2. Run atualizar_catalogo.R → updates catalogo.json in the tidyprf repo
3. git commit + push catalogo.json in bonijoao/tidyprf
4. Manual upload of new parquet files to GitHub Releases (dados-v1 tag)
```

### Future automation

When ready to automate: each script becomes a GitHub Actions job in `bonijoao/tidyprf-dados`, triggered on a monthly schedule. Jobs: download → convert → upload to Release → update catalog → open PR for review.

---

## Open items

- `infracoes` data has gaps (2007–2018, 2021 missing) — pipeline repo README should document why
- DESCRIPTION still has placeholder author (`First Last`) — needs updating before CRAN submission
- Logo at `Logo/logo_tidyprf.png` — integrate into README and pkgdown when site is built
