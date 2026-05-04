# tidyprf Package Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold and implement the `tidyprf` R package — 9 public functions providing tidy access to PRF traffic data via cached Parquet downloads from GitHub Releases.

**Architecture:** Static file distribution (GitHub Releases) with two-level cache (session env for catalog JSON, `tools::R_user_dir` disk cache for Parquet files). `get_accidents()`/`get_crashes()` return tibbles; `get_violations()` always returns an Arrow query. Arrow handles all pre-collect filtering internally. All downloads show a single-line in-place progress bar via `httr2::req_progress()`.

**Naming convention:** Public API is in English (`accidents`, `crashes`, `violations`). The catalog and Parquet filenames on GitHub Releases use Portuguese (`acidentes`, `datatran`, `infracoes` — they predate the English API). An internal mapping in `R/utils.R` translates English dataset names to Portuguese catalog keys / file prefixes. Cache filenames on disk use Portuguese (matching the URL filenames).

**Tech Stack:** R, `usethis`/`devtools` (scaffold), `testthat` + `httptest2` + `withr` (testing), `httr2` (HTTP + progress), `arrow` (Parquet + lazy eval), `dplyr`, `cli`, `fs`, `tibble`, `purrr`

---

## File Map

| File | Responsibility |
|---|---|
| `DESCRIPTION` | Package metadata and dependencies |
| `R/utils.R` | `cache_dir()`, `cache_path()`, `validate_year()`, `severity_to_pt()`, `dataset_to_pt()`, `dataset_from_pt()` — internal |
| `R/download.R` | `catalog_get()`, `fetch_parquet()` — internal HTTP + cache layer |
| `R/get_accidents.R` | `get_accidents()`, `get_crashes()`, `.get_road_data()` — public |
| `R/get_violations.R` | `get_violations()` — public, always returns Arrow query |
| `R/info.R` | `info_accidents()`, `info_crashes()`, `info_violations()`, `.info_for()` — public |
| `R/cache.R` | `prf_cache()`, `prf_cache_clear()`, `prf_years()` — public |
| `R/data.R` | Roxygen docs for `codebook` dataset |
| `data-raw/codebook.R` | Script to build embedded `codebook` data object |
| `data/codebook.rda` | Embedded PT/EN variable descriptions (generated) |
| `tests/testthat/test-utils.R` | Tests for internal utilities |
| `tests/testthat/test-download.R` | Tests for catalog fetch + file download |
| `tests/testthat/test-get_accidents.R` | Tests for get_accidents / get_crashes |
| `tests/testthat/test-get_violations.R` | Tests for get_violations |
| `tests/testthat/test-info.R` | Tests for info_* functions |
| `tests/testthat/test-cache.R` | Tests for prf_* utilities |

---

### Task 1: Rename repo + scaffold package

**Files:**
- Modify: `dados/consolidados/catalogo.json`
- Create: `DESCRIPTION`, `NAMESPACE`, `R/` (via usethis)
- Create: `tests/testthat/` (via usethis)
- Create: `data-raw/codebook.R` (via usethis)

- [ ] **Step 1: Rename GitHub repo in browser**

Go to: `https://github.com/bonijoao/tidypfr` → Settings → Repository name → type `tidyprf` → Rename.

- [ ] **Step 2: Update catalogo.json URLs**

Open `dados/consolidados/catalogo.json`. Do a search-and-replace of `tidypfr` → `tidyprf` throughout the entire file. The `repo`, `base_url`, and every `url` field inside `arquivos` must be updated.

After edit, the top of the file should read:
```json
{
  "atualizado_em": "2026-05-03",
  "repo": "bonijoao/tidyprf",
  "release_tag": "dados-v1",
  "base_url": "https://github.com/bonijoao/tidyprf/releases/download/dados-v1/",
```

- [ ] **Step 3: Scaffold package in D:/brtrafic**

Open R with working directory `D:/brtrafic` and run:

```r
usethis::create_package(".", open = FALSE)
usethis::use_roxygen_md()
usethis::use_testthat()
usethis::use_mit_license("João Boni")
usethis::use_data_raw("codebook")
```

- [ ] **Step 4: Add dependencies to DESCRIPTION**

```r
usethis::use_package("arrow")
usethis::use_package("cli")
usethis::use_package("dplyr")
usethis::use_package("fs")
usethis::use_package("httr2")
usethis::use_package("purrr")
usethis::use_package("tibble")
usethis::use_package("httptest2", type = "Suggests")
usethis::use_package("withr",     type = "Suggests")
```

- [ ] **Step 5: Edit DESCRIPTION title and description fields**

Open `DESCRIPTION` and set:
```
Package: tidyprf
Title: Tidy Access to Brazilian Federal Highway Police (PRF) Data
Description: Provides tidy-formatted access to Brazilian Federal Highway
    Police (PRF) open data: traffic accidents by person, accidents by
    occurrence, and infractions. Data is downloaded from GitHub Releases
    on demand and cached locally for reuse.
```

- [ ] **Step 6: Verify R CMD check passes**

```r
devtools::check()
```

Expected: 0 errors, 0 warnings (notes about empty package are OK at this stage).

- [ ] **Step 7: Commit**

```bash
git add DESCRIPTION NAMESPACE R/ tests/ data-raw/ .Rbuildignore dados/consolidados/catalogo.json
git commit -m "chore: rename repo to tidyprf and scaffold package"
```

---

### Task 2: Internal utilities (utils.R)

**Files:**
- Create: `R/utils.R`
- Create: `tests/testthat/test-utils.R`

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-utils.R`:

```r
test_that("cache_dir returns R_user_dir by default", {
  withr::with_options(list(tidyprf.cache_dir = NULL), {
    expect_equal(cache_dir(), tools::R_user_dir("tidyprf", "cache"))
  })
})

test_that("cache_dir respects option override", {
  withr::with_options(list(tidyprf.cache_dir = "/tmp/test_tidyprf"), {
    expect_equal(cache_dir(), "/tmp/test_tidyprf")
  })
})

test_that("cache_path builds correct file path using Portuguese filename", {
  # Catalog uses Portuguese names; cache filenames mirror those
  withr::with_options(list(tidyprf.cache_dir = "/tmp/test_tidyprf"), {
    expect_equal(cache_path("accidents",  2023), fs::path("/tmp/test_tidyprf", "acidentes_2023.parquet"))
    expect_equal(cache_path("crashes",    2023), fs::path("/tmp/test_tidyprf", "datatran_2023.parquet"))
    expect_equal(cache_path("violations", 2024), fs::path("/tmp/test_tidyprf", "infracoes_2024.parquet"))
  })
})

test_that("dataset_to_pt maps English dataset names to Portuguese", {
  expect_equal(dataset_to_pt("accidents"),  "acidentes")
  expect_equal(dataset_to_pt("crashes"),    "datatran")
  expect_equal(dataset_to_pt("violations"), "infracoes")
})

test_that("dataset_to_pt aborts on invalid name", {
  expect_error(dataset_to_pt("bad"), class = "rlang_error")
})

test_that("dataset_from_pt reverses the mapping", {
  expect_equal(dataset_from_pt("acidentes"), "accidents")
  expect_equal(dataset_from_pt("datatran"),  "crashes")
  expect_equal(dataset_from_pt("infracoes"), "violations")
})

test_that("validate_year deduplicates and sorts", {
  expect_equal(validate_year(c(2023, 2020, 2023)), c(2020L, 2023L))
})

test_that("validate_year coerces numeric to integer", {
  expect_type(validate_year(2023), "integer")
})

test_that("validate_year aborts on non-numeric input", {
  expect_error(validate_year("2023"), class = "rlang_error")
})

test_that("severity_to_pt maps all three values correctly", {
  expect_equal(severity_to_pt("fatal"),      "Com Vítimas Fatais")
  expect_equal(severity_to_pt("injured"),    "Com Vítimas Feridas")
  expect_equal(severity_to_pt("no_victims"), "Sem Vítimas")
})

test_that("severity_to_pt returns NULL for NULL input", {
  expect_null(severity_to_pt(NULL))
})

test_that("severity_to_pt aborts with helpful message on invalid value", {
  expect_error(severity_to_pt("dead"), class = "rlang_error")
})

test_that("severity_to_pt accepts a vector", {
  result <- severity_to_pt(c("fatal", "injured"))
  expect_equal(result, c("Com Vítimas Fatais", "Com Vítimas Feridas"))
})
```

- [ ] **Step 2: Run to verify failure**

```r
devtools::load_all()
devtools::test(filter = "utils")
```

Expected: errors — `cache_dir`, `cache_path`, etc. not found.

- [ ] **Step 3: Implement utils.R**

Create `R/utils.R`:

```r
cache_dir <- function() {
  getOption("tidyprf.cache_dir", tools::R_user_dir("tidyprf", "cache"))
}

# Maps English public-API dataset names to the Portuguese keys used in
# catalogo.json and Parquet filenames on GitHub Releases.
.dataset_pt_map <- c(
  "accidents"  = "acidentes",
  "crashes"    = "datatran",
  "violations" = "infracoes"
)

dataset_to_pt <- function(dataset) {
  bad <- dataset[!dataset %in% names(.dataset_pt_map)]
  if (length(bad) > 0) {
    cli::cli_abort(c(
      "Invalid {.arg dataset}: {.val {bad}}",
      "i" = "Valid values: {.val {names(.dataset_pt_map)}}"
    ))
  }
  unname(.dataset_pt_map[dataset])
}

dataset_from_pt <- function(pt_name) {
  rev_map <- setNames(names(.dataset_pt_map), unname(.dataset_pt_map))
  unname(rev_map[pt_name])
}

cache_path <- function(dataset, year) {
  pt_name <- dataset_to_pt(dataset)
  fs::path(cache_dir(), paste0(pt_name, "_", year, ".parquet"))
}

validate_year <- function(year) {
  if (!is.numeric(year) && !is.integer(year)) {
    cli::cli_abort("{.arg year} must be numeric, not {.type {year}}.")
  }
  as.integer(unique(sort(year)))
}

severity_to_pt <- function(severity) {
  if (is.null(severity)) return(NULL)
  map <- c(
    "fatal"      = "Com Vítimas Fatais",
    "injured"    = "Com Vítimas Feridas",
    "no_victims" = "Sem Vítimas"
  )
  bad <- severity[!severity %in% names(map)]
  if (length(bad) > 0) {
    cli::cli_abort(c(
      "Invalid {.arg severity}: {.val {bad}}",
      "i" = "Valid values: {.val {names(map)}}"
    ))
  }
  unname(map[severity])
}
```

- [ ] **Step 4: Run tests to verify they pass**

```r
devtools::load_all()
devtools::test(filter = "utils")
```

Expected: all 10 tests pass.

- [ ] **Step 5: Commit**

```bash
git add R/utils.R tests/testthat/test-utils.R
git commit -m "feat: add internal cache path and severity utilities"
```

---

### Task 3: Internal download layer (download.R)

**Files:**
- Create: `R/download.R`
- Create: `tests/testthat/test-download.R`

The catalog is fetched once per session from:
`https://raw.githubusercontent.com/bonijoao/tidyprf/main/dados/consolidados/catalogo.json`

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-download.R`:

```r
# catalog_get() tests use withr::local_mocked_bindings to avoid real HTTP
# fetch_parquet() tests use a real temp dir to test the cache-hit path

test_that("catalog_get caches result in session env after first call", {
  catalog_env$catalog <- NULL  # reset session cache

  withr::local_mocked_bindings(
    .catalog_fetch = function() {
      list(datasets = list(
        accidents  = list(anos = 2023L, arquivos = list()),
        crashes    = list(anos = 2023L, arquivos = list()),
        violations = list(anos = 2024L, arquivos = list())
      ))
    },
    .package = "tidyprf"
  )

  result <- catalog_get()
  expect_type(result, "list")
  expect_true("datasets" %in% names(result))
  expect_false(is.null(catalog_env$catalog))
})

test_that("catalog_get returns cached value on second call without HTTP", {
  catalog_env$catalog <- list(datasets = list(test = TRUE))
  result <- catalog_get()
  expect_true(result$datasets$test)
  catalog_env$catalog <- NULL
})

test_that("fetch_parquet returns existing cached file without HTTP", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      dest <- cache_path("accidents", 2023)
      fs::file_create(dest)

      result <- fetch_parquet("accidents", 2023)
      expect_equal(result, dest)
    })
  })
})

test_that("fetch_parquet aborts when year not in catalog", {
  catalog_env$catalog <- list(
    datasets = list(
      acidentes = list(            # Portuguese key in catalog
        anos = 2023L,
        arquivos = list()          # no 2021 entry
      )
    )
  )

  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      expect_error(fetch_parquet("accidents", 2021), class = "rlang_error")
    })
  })

  catalog_env$catalog <- NULL
})
```

- [ ] **Step 2: Run to verify failure**

```r
devtools::load_all()
devtools::test(filter = "download")
```

Expected: errors — functions not found.

- [ ] **Step 3: Implement download.R**

Create `R/download.R`:

```r
catalog_env <- new.env(parent = emptyenv())

# Separated so tests can mock it without mocking httr2 directly
.catalog_fetch <- function() {
  url <- paste0(
    "https://raw.githubusercontent.com/bonijoao/tidyprf/main/",
    "dados/consolidados/catalogo.json"
  )
  resp <- httr2::request(url) |>
    httr2::req_error(is_error = \(r) FALSE) |>
    httr2::req_perform()

  if (httr2::resp_is_error(resp)) {
    cli::cli_abort(c(
      "Could not fetch tidyprf catalog.",
      "i" = "Check your internet connection.",
      "x" = "HTTP {httr2::resp_status(resp)} from {url}"
    ))
  }
  httr2::resp_body_json(resp)
}

catalog_get <- function() {
  if (!is.null(catalog_env$catalog)) return(catalog_env$catalog)
  catalog_env$catalog <- .catalog_fetch()
  catalog_env$catalog
}

fetch_parquet <- function(dataset, year) {
  pt_name  <- dataset_to_pt(dataset)
  filename <- paste0(pt_name, "_", year, ".parquet")
  dest     <- cache_path(dataset, year)

  if (fs::file_exists(dest)) {
    size_mb <- round(as.numeric(fs::file_size(dest)) / 1e6, 1)
    cli::cli_inform(c("v" = "Using cached {filename} ({size_mb} MB)"))
    return(dest)
  }

  catalog <- catalog_get()
  info    <- catalog$datasets[[pt_name]]$arquivos[[filename]]

  if (is.null(info)) {
    available <- catalog$datasets[[pt_name]]$anos
    cli::cli_abort(c(
      "No {dataset} data available for year {year}.",
      "i" = "Available years: {available}"
    ))
  }

  cli::cli_inform(c("i" = "Downloading {filename} ({info$tamanho_mb} MB)..."))
  fs::dir_create(fs::path_dir(dest), recurse = TRUE)

  httr2::request(info$url) |>
    httr2::req_progress() |>
    httr2::req_perform(path = dest)

  dest
}
```

- [ ] **Step 4: Run tests to verify they pass**

```r
devtools::load_all()
devtools::test(filter = "download")
```

Expected: all 4 tests pass.

- [ ] **Step 5: Commit**

```bash
git add R/download.R tests/testthat/test-download.R
git commit -m "feat: add catalog fetch and parquet download layer"
```

---

### Task 4: get_accidents() and get_crashes()

**Files:**
- Create: `R/get_accidents.R`
- Create: `tests/testthat/test-get_accidents.R`

Both functions share `.get_road_data()`. Tests pre-create Parquet files in a temp cache dir so `fetch_parquet()` returns immediately without HTTP.

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-get_accidents.R`:

```r
# Helper: write a minimal accidents-schema parquet to a temp cache dir
make_accidents_parquet <- function(dir, year, n = 5) {
  df <- tibble::tibble(
    id = seq_len(n), pesid = seq_len(n),
    data_inversa = as.Date(paste0(year, "-06-15")),
    dia_semana = "sexta-feira", horario = "14:30:00",
    uf = rep(c("SP", "SP", "RJ", "MG", "SP"), length.out = n),
    br = rep(c(101L, 101L, 116L, 40L, 101L), length.out = n),
    km = 10.5, municipio = "São Paulo",
    causa_principal = NA_character_,
    causa_acidente = "Falta de atenção",
    ordem_tipo_acidente = NA_integer_,
    tipo_acidente = "Colisão traseira",
    classificacao_acidente = rep(
      c("Com Vítimas Fatais", "Sem Vítimas", "Com Vítimas Feridas",
        "Com Vítimas Fatais", "Sem Vítimas"), length.out = n
    ),
    fase_dia = "Pleno dia", sentido_via = "Crescente",
    condicao_metereologica = "Céu claro", tipo_pista = "Simples",
    tracado_via = "Reta", uso_solo = "Rural",
    id_veiculo = seq_len(n), tipo_veiculo = "Automóvel", marca = "FIAT",
    ano_fabricacao_veiculo = 2020L,
    tipo_envolvido = "Condutor", estado_fisico = "Ileso",
    idade = 35L, sexo = "Masculino",
    nacionalidade = NA_character_, naturalidade = NA_character_,
    ilesos = 1L, feridos_leves = 0L, feridos_graves = 0L, mortos = 0L,
    latitude = -23.5, longitude = -46.6,
    regional = NA_character_, delegacia = NA_character_, uop = NA_character_,
    ano = as.integer(year)
  )
  arrow::write_parquet(df, fs::path(dir, paste0("acidentes_", year, ".parquet")))
}

test_that("get_accidents returns a tibble", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_accidents_parquet(getwd(), 2023)
      result <- get_accidents(2023)
      expect_s3_class(result, "tbl_df")
    })
  })
})

test_that("get_accidents returns all rows when no filters", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_accidents_parquet(getwd(), 2023, n = 5)
      expect_equal(nrow(get_accidents(2023)), 5L)
    })
  })
})

test_that("get_accidents filters by uf", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_accidents_parquet(getwd(), 2023)
      result <- get_accidents(2023, uf = "SP")
      expect_true(all(result$uf == "SP"))
      expect_gt(nrow(result), 0L)
    })
  })
})

test_that("get_accidents filters by br", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_accidents_parquet(getwd(), 2023)
      result <- get_accidents(2023, br = 101)
      expect_true(all(result$br == 101L))
    })
  })
})

test_that("get_accidents filters by severity = 'fatal'", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_accidents_parquet(getwd(), 2023)
      result <- get_accidents(2023, severity = "fatal")
      expect_true(all(result$classificacao_acidente == "Com Vítimas Fatais"))
    })
  })
})

test_that("get_accidents binds multiple years", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_accidents_parquet(getwd(), 2022, n = 5)
      make_accidents_parquet(getwd(), 2023, n = 5)
      result <- get_accidents(c(2022, 2023))
      expect_equal(nrow(result), 10L)
    })
  })
})

test_that("get_accidents aborts on invalid severity", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_accidents_parquet(getwd(), 2023)
      expect_error(get_accidents(2023, severity = "bad"), class = "rlang_error")
    })
  })
})

test_that("get_crashes returns a tibble with crashes schema", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      df <- tibble::tibble(
        id = 1L, data_inversa = as.Date("2023-06-15"),
        dia_semana = "sexta-feira", horario = "14:30:00",
        uf = "SP", br = 101L, km = 10.5, municipio = "São Paulo",
        causa_acidente = "Falta de atenção",
        tipo_acidente = "Colisão traseira",
        classificacao_acidente = "Sem Vítimas",
        fase_dia = "Pleno dia", sentido_via = "Crescente",
        condicao_metereologica = "Céu claro", tipo_pista = "Simples",
        tracado_via = "Reta", uso_solo = "Rural",
        pessoas = 2L, mortos = 0L, feridos_leves = 0L, feridos_graves = 0L,
        ilesos = 2L, ignorados = 0L, feridos = 0L, veiculos = 1L,
        latitude = -23.5, longitude = -46.6,
        regional = NA_character_, delegacia = NA_character_,
        uop = NA_character_, ano = 2023L
      )
      arrow::write_parquet(df, "datatran_2023.parquet")
      expect_s3_class(get_crashes(2023), "tbl_df")
    })
  })
})
```

- [ ] **Step 2: Run to verify failure**

```r
devtools::load_all()
devtools::test(filter = "get_accidents")
```

Expected: errors — `get_accidents` and `get_crashes` not found.

- [ ] **Step 3: Implement get_accidents.R**

Create `R/get_accidents.R`:

```r
#' Get PRF accident data by person
#'
#' Downloads and returns accident records at the person level (one row per
#' person involved in each accident). Files are cached after first download.
#'
#' @param year Integer or vector of integers. Year(s) to fetch (2007–2026).
#' @param uf Character or NULL. State abbreviation(s), e.g. `"SP"`. NULL = all.
#' @param br Integer or NULL. Federal highway number(s), e.g. `101`. NULL = all.
#' @param severity Character or NULL. `"fatal"`, `"injured"`, or `"no_victims"`. NULL = all.
#' @return A tibble.
#' @export
#' @examples
#' \dontrun{
#' get_accidents(2023)
#' get_accidents(2020:2023, uf = "SP", severity = "fatal")
#' df <- get_accidents(c(2019:2021, 2023), br = 101)
#' }
get_accidents <- function(year, uf = NULL, br = NULL, severity = NULL) {
  .get_road_data("accidents", year, uf = uf, br = br, severity = severity)
}

#' Get PRF accident data by occurrence
#'
#' Downloads and returns accident records at the occurrence level (one row
#' per accident, with aggregated person and vehicle counts). Files are cached
#' after first download.
#'
#' @param year Integer or vector of integers. Year(s) to fetch (2007–2026).
#' @param uf Character or NULL. State abbreviation(s). NULL = all.
#' @param br Integer or NULL. Federal highway number(s). NULL = all.
#' @param severity Character or NULL. `"fatal"`, `"injured"`, or `"no_victims"`. NULL = all.
#' @return A tibble.
#' @export
#' @examples
#' \dontrun{
#' get_crashes(2023)
#' get_crashes(2020:2023, uf = c("SP", "RJ"))
#' }
get_crashes <- function(year, uf = NULL, br = NULL, severity = NULL) {
  .get_road_data("crashes", year, uf = uf, br = br, severity = severity)
}

.get_road_data <- function(dataset, year, uf, br, severity) {
  year   <- validate_year(year)
  sev_pt <- severity_to_pt(severity)

  paths <- vapply(year, function(y) fetch_parquet(dataset, y), character(1))
  ds    <- arrow::open_dataset(paths)

  if (!is.null(uf))     ds <- dplyr::filter(ds, .data$uf %in% !!uf)
  if (!is.null(br))     ds <- dplyr::filter(ds, .data$br %in% !!as.integer(br))
  if (!is.null(sev_pt)) ds <- dplyr::filter(ds, .data$classificacao_acidente %in% !!sev_pt)

  dplyr::collect(ds)
}
```

- [ ] **Step 4: Run tests to verify they pass**

```r
devtools::load_all()
devtools::test(filter = "get_accidents")
```

Expected: all 8 tests pass.

- [ ] **Step 5: Commit**

```bash
git add R/get_accidents.R tests/testthat/test-get_accidents.R
git commit -m "feat: implement get_accidents() and get_crashes()"
```

---

### Task 5: get_violations()

**Files:**
- Create: `R/get_violations.R`
- Create: `tests/testthat/test-get_violations.R`

Returns an Arrow query — never calls `collect()`. The user chains dplyr operations before collecting.

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-get_violations.R`:

```r
make_violations_parquet <- function(dir, year, n = 4) {
  df <- tibble::tibble(
    numero_auto = paste0("1234", seq_len(n)),
    dat_infracao = as.Date(paste0(year, "-03-15")),
    tip_abordagem = "Ativa",
    ind_assinou_auto = "Sim",
    ind_veiculo_estrangeiro = "Não",
    ind_sentido_trafego = "Crescente",
    uf_placa = "SP",
    uf_infracao = rep(c("SP", "SP", "RJ", "MG"), length.out = n),
    num_br_infracao = rep(c(101L, 101L, 116L, 40L), length.out = n),
    num_km_infracao = 50.0,
    nom_municipio = "São Paulo",
    cod_infracao = "55412",
    descricao_abreviada = "Excesso de velocidade",
    enquadramento = "CTB Art. 218 III",
    data_inicio_vigencia = as.Date("2020-01-01"),
    data_fim_vigencia = as.Date("2025-12-31"),
    med_realizada = 100.0, med_considerada = 95.0, exc_verificado = 15.0,
    especie = "Automóvel", nome_veiculo_marca = "FIAT",
    tipo_veiculo = "Automóvel", nom_modelo_veiculo = "Argo",
    hora = "14:30:00", qtd_infracoes = 1L,
    ano = as.integer(year)
  )
  arrow::write_parquet(df, fs::path(dir, paste0("infracoes_", year, ".parquet")))
}

test_that("get_violations does NOT return a tibble", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_violations_parquet(getwd(), 2024)
      result <- get_violations(2024)
      expect_false(inherits(result, "tbl_df"))
    })
  })
})

test_that("get_violations returns an Arrow object", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_violations_parquet(getwd(), 2024)
      result <- get_violations(2024)
      expect_true(
        inherits(result, "arrow_dplyr_query") || inherits(result, "Dataset")
      )
    })
  })
})

test_that("get_violations can be collected after filter", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_violations_parquet(getwd(), 2024, n = 4)
      result <- get_violations(2024, uf = "SP") |> dplyr::collect()
      expect_s3_class(result, "tbl_df")
      expect_true(all(result$uf_infracao == "SP"))
      expect_gt(nrow(result), 0L)
    })
  })
})

test_that("get_violations filters by br before returning", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_violations_parquet(getwd(), 2024, n = 4)
      result <- get_violations(2024, br = 101) |> dplyr::collect()
      expect_true(all(result$num_br_infracao == 101L))
    })
  })
})

test_that("get_violations supports multi-year vector", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      make_violations_parquet(getwd(), 2023, n = 4)
      make_violations_parquet(getwd(), 2024, n = 4)
      result <- get_violations(c(2023, 2024)) |> dplyr::collect()
      expect_equal(nrow(result), 8L)
    })
  })
})
```

- [ ] **Step 2: Run to verify failure**

```r
devtools::load_all()
devtools::test(filter = "get_violations")
```

Expected: errors — `get_violations` not found.

- [ ] **Step 3: Implement get_violations.R**

Create `R/get_violations.R`:

```r
#' Get PRF infraction data
#'
#' Downloads PRF infraction records and returns an Arrow query.
#' Files are 100–300 MB; use [dplyr::filter()] before [dplyr::collect()]
#' to avoid loading the full dataset into memory.
#'
#' @param year Integer or vector of integers. Available: 2019–2020, 2022–2026.
#' @param uf Character or NULL. State of infraction (`uf_infracao`). NULL = all.
#' @param br Integer or NULL. Federal highway number (`num_br_infracao`). NULL = all.
#' @return An Arrow query. Call [dplyr::collect()] to load into a tibble.
#' @export
#' @examples
#' \dontrun{
#' # Filter before collecting to avoid loading 243 MB into RAM
#' get_violations(2024, uf = "SP") |>
#'   dplyr::filter(cod_infracao == "55412") |>
#'   dplyr::collect()
#' }
get_violations <- function(year, uf = NULL, br = NULL) {
  year  <- validate_year(year)
  paths <- vapply(year, function(y) fetch_parquet("violations", y), character(1))
  ds    <- arrow::open_dataset(paths)

  if (!is.null(uf)) ds <- dplyr::filter(ds, .data$uf_infracao    %in% !!uf)
  if (!is.null(br)) ds <- dplyr::filter(ds, .data$num_br_infracao %in% !!as.integer(br))

  ds
}
```

- [ ] **Step 4: Run tests to verify they pass**

```r
devtools::load_all()
devtools::test(filter = "get_violations")
```

Expected: all 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add R/get_violations.R tests/testthat/test-get_violations.R
git commit -m "feat: implement get_violations() returning Arrow query"
```

---

### Task 6: Codebook data + info_* functions

**Files:**
- Modify: `data-raw/codebook.R`
- Create: `data/codebook.rda` (generated)
- Create: `R/info.R`
- Create: `R/data.R`
- Create: `tests/testthat/test-info.R`

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-info.R`:

```r
test_that("info_accidents returns tibble with variable/type/description columns", {
  result <- info_accidents()
  expect_s3_class(result, "tbl_df")
  expect_named(result, c("variable", "type", "description"))
})

test_that("info_accidents covers all 40 schema columns", {
  expected_cols <- c(
    "id", "pesid", "data_inversa", "dia_semana", "horario",
    "uf", "br", "km", "municipio", "causa_principal", "causa_acidente",
    "ordem_tipo_acidente", "tipo_acidente", "classificacao_acidente",
    "fase_dia", "sentido_via", "condicao_metereologica", "tipo_pista",
    "tracado_via", "uso_solo", "id_veiculo", "tipo_veiculo", "marca",
    "ano_fabricacao_veiculo", "tipo_envolvido", "estado_fisico", "idade",
    "sexo", "nacionalidade", "naturalidade", "ilesos", "feridos_leves",
    "feridos_graves", "mortos", "latitude", "longitude",
    "regional", "delegacia", "uop", "ano"
  )
  expect_true(all(expected_cols %in% info_accidents()$variable))
})

test_that("info_accidents lang = 'pt' returns Portuguese descriptions", {
  result <- info_accidents(lang = "pt")
  expect_false(any(is.na(result$description)))
  # Portuguese descriptions contain Portuguese characters
  expect_true(any(grepl("ção|ário|ê|ú", result$description)))
})

test_that("info_accidents aborts on unknown lang", {
  expect_error(info_accidents(lang = "fr"), class = "rlang_error")
})

test_that("info_crashes returns tibble with correct columns", {
  result <- info_crashes()
  expect_named(result, c("variable", "type", "description"))
  expect_true("pessoas" %in% result$variable)   # crashes-specific column
})

test_that("info_violations returns tibble with correct columns", {
  result <- info_violations()
  expect_named(result, c("variable", "type", "description"))
  expect_true("cod_infracao" %in% result$variable)  # violations-specific
})
```

- [ ] **Step 2: Run to verify failure**

```r
devtools::load_all()
devtools::test(filter = "info")
```

Expected: errors — functions not found.

- [ ] **Step 3: Build codebook data object**

Replace the contents of `data-raw/codebook.R` with:

```r
library(tibble)
library(dplyr)

codebook <- bind_rows(

  # ── accidents (40 columns) ────────────────────────────────────────────────
  tibble(
    dataset = "accidents",
    variable = c(
      "id","pesid","data_inversa","dia_semana","horario",
      "uf","br","km","municipio",
      "causa_principal","causa_acidente","ordem_tipo_acidente","tipo_acidente",
      "classificacao_acidente","fase_dia","sentido_via",
      "condicao_metereologica","tipo_pista","tracado_via","uso_solo",
      "id_veiculo","tipo_veiculo","marca","ano_fabricacao_veiculo",
      "tipo_envolvido","estado_fisico","idade","sexo",
      "nacionalidade","naturalidade",
      "ilesos","feridos_leves","feridos_graves","mortos",
      "latitude","longitude","regional","delegacia","uop","ano"
    ),
    type = c(
      "int","int","date","chr","chr",
      "chr","int","dbl","chr",
      "chr","chr","int","chr",
      "chr","chr","chr",
      "chr","chr","chr","chr",
      "int","chr","chr","int",
      "chr","chr","int","chr",
      "chr","chr",
      "int","int","int","int",
      "dbl","dbl","chr","chr","chr","int"
    ),
    description_en = c(
      "Record identifier","Person identifier","Accident date","Day of week","Time of accident",
      "State (UF)","Federal highway number","Highway kilometer marker","Municipality",
      "Primary cause (2017+)","Accident cause","Accident type sequence (2017+)","Accident type",
      "Accident classification","Time of day","Traffic direction",
      "Weather condition","Road type","Road alignment","Land use (Urban/Rural)",
      "Vehicle identifier","Vehicle type","Vehicle make","Vehicle manufacturing year",
      "Person role in accident","Physical condition after accident","Age","Sex",
      "Nationality (pre-2017 only)","Place of birth (pre-2017 only)",
      "Uninjured count","Slightly injured count","Seriously injured count","Death count",
      "Latitude","Longitude","Regional unit (2017+)","Police precinct (2017+)","Operational unit (2017+)","Year"
    ),
    description_pt = c(
      "Identificador do registro","Identificador da pessoa","Data do acidente","Dia da semana","Horário do acidente",
      "Unidade federativa","Número da rodovia federal","Quilômetro da rodovia","Município",
      "Causa principal (2017+)","Causa do acidente","Ordem do tipo de acidente (2017+)","Tipo do acidente",
      "Classificação do acidente","Fase do dia","Sentido da via",
      "Condição meteorológica","Tipo de pista","Traçado da via","Uso do solo (Urbano/Rural)",
      "Identificador do veículo","Tipo do veículo","Marca do veículo","Ano de fabricação do veículo",
      "Tipo de envolvido","Estado físico após o acidente","Idade","Sexo",
      "Nacionalidade (apenas pré-2017)","Naturalidade (apenas pré-2017)",
      "Número de ilesos","Número de feridos leves","Número de feridos graves","Número de mortos",
      "Latitude","Longitude","Regional (2017+)","Delegacia (2017+)","UOP (2017+)","Ano"
    )
  ),

  # ── crashes (31 columns) ─────────────────────────────────────────────────
  tibble(
    dataset = "crashes",
    variable = c(
      "id","data_inversa","dia_semana","horario",
      "uf","br","km","municipio",
      "causa_acidente","tipo_acidente","classificacao_acidente",
      "fase_dia","sentido_via","condicao_metereologica",
      "tipo_pista","tracado_via","uso_solo",
      "pessoas","mortos","feridos_leves","feridos_graves",
      "ilesos","ignorados","feridos","veiculos",
      "latitude","longitude","regional","delegacia","uop","ano"
    ),
    type = c(
      "int","date","chr","chr",
      "chr","int","dbl","chr",
      "chr","chr","chr",
      "chr","chr","chr",
      "chr","chr","chr",
      "int","int","int","int",
      "int","int","int","int",
      "dbl","dbl","chr","chr","chr","int"
    ),
    description_en = c(
      "Accident identifier","Accident date","Day of week","Time of accident",
      "State (UF)","Federal highway number","Highway kilometer marker","Municipality",
      "Accident cause","Accident type","Accident classification",
      "Time of day","Traffic direction","Weather condition",
      "Road type","Road alignment","Land use (Urban/Rural)",
      "Total persons involved","Deaths","Slightly injured","Seriously injured",
      "Uninjured","Unknown status","Total injured","Vehicles involved",
      "Latitude","Longitude","Regional unit (2017+)","Police precinct (2017+)","Operational unit (2017+)","Year"
    ),
    description_pt = c(
      "Identificador do acidente","Data do acidente","Dia da semana","Horário do acidente",
      "Unidade federativa","Número da rodovia federal","Quilômetro da rodovia","Município",
      "Causa do acidente","Tipo do acidente","Classificação do acidente",
      "Fase do dia","Sentido da via","Condição meteorológica",
      "Tipo de pista","Traçado da via","Uso do solo (Urbano/Rural)",
      "Total de pessoas envolvidas","Mortos","Feridos leves","Feridos graves",
      "Ilesos","Ignorados","Total de feridos","Veículos envolvidos",
      "Latitude","Longitude","Regional (2017+)","Delegacia (2017+)","UOP (2017+)","Ano"
    )
  ),

  # ── violations (26 columns) ──────────────────────────────────────────────
  tibble(
    dataset = "violations",
    variable = c(
      "numero_auto","dat_infracao","tip_abordagem","ind_assinou_auto",
      "ind_veiculo_estrangeiro","ind_sentido_trafego",
      "uf_placa","uf_infracao","num_br_infracao","num_km_infracao","nom_municipio",
      "cod_infracao","descricao_abreviada","enquadramento",
      "data_inicio_vigencia","data_fim_vigencia",
      "med_realizada","med_considerada","exc_verificado",
      "especie","nome_veiculo_marca","tipo_veiculo","nom_modelo_veiculo",
      "hora","qtd_infracoes","ano"
    ),
    type = c(
      "chr","date","chr","chr",
      "chr","chr",
      "chr","chr","int","dbl","chr",
      "chr","chr","chr",
      "date","date",
      "dbl","dbl","dbl",
      "chr","chr","chr","chr",
      "chr","int","int"
    ),
    description_en = c(
      "Infraction notice number","Infraction date","Approach type","Signed by driver indicator",
      "Foreign vehicle indicator","Traffic direction",
      "Vehicle plate state","State of infraction","Federal highway number","Highway kilometer","Municipality",
      "Infraction code","Abbreviated infraction description","Legal provision (CTB article)",
      "Validity start date","Validity end date",
      "Measured value","Considered measurement","Verified excess",
      "Vehicle category","Vehicle make","Vehicle type","Vehicle model",
      "Time of infraction","Number of infractions","Year"
    ),
    description_pt = c(
      "Número do auto de infração","Data da infração","Tipo de abordagem","Indicador de assinatura do auto",
      "Indicador de veículo estrangeiro","Sentido do tráfego",
      "UF da placa do veículo","UF da infração","Número da BR","Quilômetro da infração","Município",
      "Código da infração","Descrição abreviada da infração","Enquadramento legal (artigo do CTB)",
      "Data de início de vigência","Data de fim de vigência",
      "Medição realizada","Medição considerada","Excesso verificado",
      "Espécie do veículo","Marca do veículo","Tipo do veículo","Modelo do veículo",
      "Hora da infração","Quantidade de infrações","Ano"
    )
  )
)

usethis::use_data(codebook, overwrite = TRUE)
```

Run the script to generate the `.rda`:

```r
source("data-raw/codebook.R")
```

Verify `data/codebook.rda` exists.

- [ ] **Step 4: Implement info.R**

Create `R/info.R`:

```r
#' Variable descriptions for get_accidents()
#' @param lang `"en"` (default) or `"pt"`.
#' @return A tibble with columns `variable`, `type`, `description`.
#' @export
info_accidents <- function(lang = "en") {
  .info_for("accidents", lang)
}

#' Variable descriptions for get_crashes()
#' @param lang `"en"` (default) or `"pt"`.
#' @return A tibble with columns `variable`, `type`, `description`.
#' @export
info_crashes <- function(lang = "en") {
  .info_for("crashes", lang)
}

#' Variable descriptions for get_violations()
#' @param lang `"en"` (default) or `"pt"`.
#' @return A tibble with columns `variable`, `type`, `description`.
#' @export
info_violations <- function(lang = "en") {
  .info_for("violations", lang)
}

.info_for <- function(dataset, lang) {
  lang <- tryCatch(
    match.arg(lang, c("en", "pt")),
    error = function(e) cli::cli_abort(
      "{.arg lang} must be {.val en} or {.val pt}, not {.val {lang}}.",
      class = "rlang_error"
    )
  )
  desc_col <- if (lang == "en") "description_en" else "description_pt"

  dplyr::filter(codebook, .data$dataset == !!dataset) |>
    dplyr::select("variable", "type", description = !!desc_col)
}
```

- [ ] **Step 5: Add codebook documentation**

Create `R/data.R`:

```r
#' Variable codebook for tidyprf datasets
#'
#' Bilingual (English/Portuguese) variable descriptions for all three PRF
#' datasets. Used internally by [info_accidents()], [info_crashes()], and
#' [info_violations()].
#'
#' @format A tibble with 97 rows and 5 columns:
#' \describe{
#'   \item{dataset}{Dataset name: `"accidents"`, `"crashes"`, or `"violations"`}
#'   \item{variable}{Variable name as returned by the `get_*()` functions}
#'   \item{type}{R type abbreviation (chr, int, dbl, date)}
#'   \item{description_en}{Description in English}
#'   \item{description_pt}{Description in Portuguese}
#' }
"codebook"
```

- [ ] **Step 6: Run tests to verify they pass**

```r
devtools::load_all()
devtools::test(filter = "info")
```

Expected: all 6 tests pass.

- [ ] **Step 7: Commit**

```bash
git add R/info.R R/data.R data-raw/codebook.R data/codebook.rda
git commit -m "feat: add codebook data and info_accidents/crashes/violations"
```

---

### Task 7: Cache utilities (prf_cache, prf_cache_clear, prf_years)

**Files:**
- Create: `R/cache.R`
- Create: `tests/testthat/test-cache.R`

- [ ] **Step 1: Write failing tests**

Create `tests/testthat/test-cache.R`:

```r
test_that("prf_cache returns empty tibble when cache dir is empty", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      result <- prf_cache()
      expect_s3_class(result, "tbl_df")
      expect_equal(nrow(result), 0L)
    })
  })
})

test_that("prf_cache detects cached files and returns English dataset names", {
  # Files on disk use Portuguese names; prf_cache converts back to English
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      fs::file_create("acidentes_2023.parquet")
      fs::file_create("datatran_2022.parquet")

      result <- prf_cache()
      expect_named(result, c("dataset", "year", "size_mb", "cached_at"))
      expect_equal(nrow(result), 2L)
      expect_setequal(result$dataset, c("accidents", "crashes"))
    })
  })
})

test_that("prf_cache filters by English dataset argument", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      fs::file_create("acidentes_2023.parquet")
      fs::file_create("datatran_2022.parquet")

      result <- prf_cache(dataset = "accidents")
      expect_equal(nrow(result), 1L)
      expect_equal(result$dataset, "accidents")
    })
  })
})

test_that("prf_cache_clear deletes only the specified file", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      fs::file_create("acidentes_2023.parquet")
      fs::file_create("acidentes_2022.parquet")

      prf_cache_clear(dataset = "accidents", year = 2023)

      expect_false(fs::file_exists("acidentes_2023.parquet"))
      expect_true(fs::file_exists("acidentes_2022.parquet"))
    })
  })
})

test_that("prf_cache_clear returns invisibly", {
  withr::with_tempdir({
    withr::with_options(list(tidyprf.cache_dir = getwd()), {
      fs::file_create("acidentes_2023.parquet")
      expect_invisible(prf_cache_clear(dataset = "accidents", year = 2023))
    })
  })
})

test_that("prf_years returns tibble with English dataset names", {
  # Catalog uses Portuguese keys; prf_years exposes English names
  withr::local_mocked_bindings(
    catalog_get = function() list(datasets = list(
      acidentes = list(
        anos = 2023L,
        arquivos = list(
          `acidentes_2023.parquet` = list(linhas = 571052L, tamanho_mb = 11.04)
        )
      ),
      datatran  = list(anos = integer(0), arquivos = list()),
      infracoes = list(anos = integer(0), arquivos = list())
    )),
    .package = "tidyprf"
  )
  result <- prf_years()
  expect_s3_class(result, "tbl_df")
  expect_named(result, c("dataset", "year", "rows", "size_mb"))
  expect_equal(result$dataset, "accidents")
  expect_equal(result$year, 2023L)
})

test_that("prf_years filters by English dataset argument", {
  withr::local_mocked_bindings(
    catalog_get = function() list(datasets = list(
      acidentes = list(
        anos = 2023L,
        arquivos = list(
          `acidentes_2023.parquet` = list(linhas = 571052L, tamanho_mb = 11.04)
        )
      ),
      datatran = list(
        anos = 2023L,
        arquivos = list(
          `datatran_2023.parquet` = list(linhas = 67766L, tamanho_mb = 2.47)
        )
      ),
      infracoes = list(anos = integer(0), arquivos = list())
    )),
    .package = "tidyprf"
  )
  result <- prf_years(dataset = "accidents")
  expect_true(all(result$dataset == "accidents"))
})
```

- [ ] **Step 2: Run to verify failure**

```r
devtools::load_all()
devtools::test(filter = "cache")
```

Expected: errors — functions not found.

- [ ] **Step 3: Implement cache.R**

Create `R/cache.R`:

```r
#' Show locally cached PRF data files
#'
#' @param dataset Character or NULL. One of `"accidents"`, `"crashes"`,
#'   `"violations"`. NULL (default) shows all.
#' @return A tibble with columns `dataset`, `year`, `size_mb`, `cached_at`.
#' @export
prf_cache <- function(dataset = NULL) {
  dir <- cache_dir()

  if (!fs::dir_exists(dir)) return(.empty_cache_tibble())

  files <- fs::dir_ls(dir, glob = "*.parquet")
  if (length(files) == 0L) return(.empty_cache_tibble())

  nms     <- fs::path_file(files)
  pt_name <- sub("_\\d{4}\\.parquet$", "", nms)
  result <- tibble::tibble(
    dataset   = dataset_from_pt(pt_name),
    year      = as.integer(regmatches(nms, regexpr("\\d{4}", nms))),
    size_mb   = round(as.numeric(fs::file_size(files)) / 1e6, 2),
    cached_at = as.Date(fs::file_info(files)$modification_time)
  ) |>
    dplyr::filter(!is.na(.data$dataset))   # drop unknown parquet files

  if (!is.null(dataset)) result <- dplyr::filter(result, .data$dataset == !!dataset)
  result
}

#' Delete locally cached PRF data files
#'
#' @param dataset Character or NULL. Dataset to clear. NULL = all.
#' @param year Integer or NULL. Year(s) to clear. NULL = all years.
#' @return Invisible NULL.
#' @export
prf_cache_clear <- function(dataset = NULL, year = NULL) {
  cached <- prf_cache(dataset = dataset)
  if (!is.null(year)) cached <- dplyr::filter(cached, .data$year %in% !!as.integer(year))

  if (nrow(cached) == 0L) {
    cli::cli_inform("No cached files matched.")
    return(invisible(NULL))
  }

  paths <- cache_path(cached$dataset, cached$year)
  fs::file_delete(paths)
  cli::cli_inform("Deleted {nrow(cached)} file{?s}.")
  invisible(NULL)
}

#' Show years available in the PRF catalog
#'
#' @param dataset Character or NULL. One of `"accidents"`, `"crashes"`,
#'   `"violations"`. NULL (default) returns all three.
#' @return A tibble with columns `dataset`, `year`, `rows`, `size_mb`.
#' @export
prf_years <- function(dataset = NULL) {
  catalog  <- catalog_get()
  datasets <- if (is.null(dataset)) c("accidents", "crashes", "violations") else dataset

  purrr::map_dfr(datasets, function(ds) {
    pt_name  <- dataset_to_pt(ds)
    arquivos <- catalog$datasets[[pt_name]]$arquivos
    if (is.null(arquivos) || length(arquivos) == 0L) return(tibble::tibble())

    purrr::map_dfr(names(arquivos), function(filename) {
      info <- arquivos[[filename]]
      year <- as.integer(regmatches(filename, regexpr("\\d{4}", filename)))
      tibble::tibble(
        dataset = ds,
        year    = year,
        rows    = as.integer(info$linhas),
        size_mb = info$tamanho_mb
      )
    })
  })
}

.empty_cache_tibble <- function() {
  tibble::tibble(
    dataset   = character(),
    year      = integer(),
    size_mb   = double(),
    cached_at = as.Date(character())
  )
}
```

- [ ] **Step 4: Run tests to verify they pass**

```r
devtools::load_all()
devtools::test(filter = "cache")
```

Expected: all 7 tests pass.

- [ ] **Step 5: Run full check**

```r
devtools::check()
```

Expected: 0 errors, 0 warnings.

- [ ] **Step 6: Commit**

```bash
git add R/cache.R tests/testthat/test-cache.R
git commit -m "feat: implement prf_cache(), prf_cache_clear(), prf_years()"
```
