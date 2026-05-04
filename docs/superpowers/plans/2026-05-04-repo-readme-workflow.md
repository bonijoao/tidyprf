# Repo Cleanup, README, and Pipeline Repo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up the `bonijoao/tidyprf` package repo, write bilingual READMEs, and initialize the `tidyprf-dados` pipeline repo on disk.

**Architecture:** Three independent phases executed sequentially. Phase 1 moves development files out of the package repo into a new local folder (`D:\tidyprf-dados`). Phase 2 writes the bilingual READMEs in the package repo. Phase 3 sets up `D:\tidyprf-dados` as a git repo with the adapted pipeline scripts.

**Tech Stack:** R, git, arrow, jsonlite, fs, cli, dplyr, lubridate — no new dependencies.

---

## Files Created / Modified

**Package repo (`D:\brtrafic`):**
- Delete: `baixar_dados.R`, `descompactar.R`, `plano_B.R`, `Diretrizes_pacote.txt`, `pagina/pagina_principal.txt`, `scripts/consolidar.R`, `dicionario/` (5 PDFs), `referencias/` (3 PDFs), `docs/dicionario_consolidado.qmd`, `docs/dicionario_consolidado.pdf`, `teste.R`
- Create: `README.md`, `README.pt-br.md`

**Pipeline repo (`D:\tidyprf-dados`):**
- Create: `scripts/consolidar.R` (adapted from package repo)
- Create: `scripts/update_acidentes.R`
- Create: `scripts/update_datatran.R`
- Create: `scripts/update_infracoes.R`
- Create: `scripts/atualizar_catalogo.R`
- Create: `README.md`
- Move: `dicionario/`, `referencias/`, `docs/`, `pagina/`, `Diretrizes_pacote.txt`

---

## Phase 1 — Package Repo Cleanup

### Task 1: Create tidyprf-dados folder structure on disk

**Files:**
- Create folder: `D:\tidyprf-dados\` with subfolders

- [ ] **Step 1: Create the folder tree**

Run in PowerShell (outside the brtrafic repo):
```powershell
New-Item -ItemType Directory -Path "D:\tidyprf-dados\scripts"
New-Item -ItemType Directory -Path "D:\tidyprf-dados\dados\brutos"
New-Item -ItemType Directory -Path "D:\tidyprf-dados\dados\processados"
New-Item -ItemType Directory -Path "D:\tidyprf-dados\dados\consolidados"
New-Item -ItemType Directory -Path "D:\tidyprf-dados\dicionario"
New-Item -ItemType Directory -Path "D:\tidyprf-dados\referencias"
New-Item -ItemType Directory -Path "D:\tidyprf-dados\docs"
New-Item -ItemType Directory -Path "D:\tidyprf-dados\pagina"
```

- [ ] **Step 2: Verify structure**

```powershell
Get-ChildItem -Path "D:\tidyprf-dados" -Recurse -Directory | Select-Object FullName
```

Expected output: 8 directories listed.

---

### Task 2: Copy development files to tidyprf-dados

**Files:**
- Copy from `D:\brtrafic\` to `D:\tidyprf-dados\`

- [ ] **Step 1: Copy scripts**

```powershell
Copy-Item "D:\brtrafic\scripts\consolidar.R"      "D:\tidyprf-dados\scripts\consolidar.R"
Copy-Item "D:\brtrafic\baixar_dados.R"             "D:\tidyprf-dados\scripts\baixar_dados.R"
Copy-Item "D:\brtrafic\descompactar.R"             "D:\tidyprf-dados\scripts\descompactar.R"
Copy-Item "D:\brtrafic\plano_B.R"                  "D:\tidyprf-dados\scripts\plano_B.R"
```

- [ ] **Step 2: Copy reference material**

```powershell
Copy-Item "D:\brtrafic\Diretrizes_pacote.txt"      "D:\tidyprf-dados\Diretrizes_pacote.txt"
Copy-Item "D:\brtrafic\dicionario\*"               "D:\tidyprf-dados\dicionario\" -Recurse
Copy-Item "D:\brtrafic\referencias\*"              "D:\tidyprf-dados\referencias\" -Recurse
Copy-Item "D:\brtrafic\docs\dicionario_consolidado.qmd" "D:\tidyprf-dados\docs\"
Copy-Item "D:\brtrafic\docs\dicionario_consolidado.pdf" "D:\tidyprf-dados\docs\"
Copy-Item "D:\brtrafic\pagina\pagina_principal.txt" "D:\tidyprf-dados\pagina\"
```

- [ ] **Step 3: Verify copies exist**

```powershell
Get-ChildItem "D:\tidyprf-dados\" -Recurse -File | Select-Object FullName
```

Expected: at least 12 files listed (5 PDFs in dicionario, 3 in referencias, scripts, docs, etc.).

---

### Task 3: Remove development files from the package repo and commit

**Files:**
- Modify: `D:\brtrafic` (git rm + delete)

- [ ] **Step 1: Remove tracked development files from git**

Run from `D:\brtrafic`:
```bash
git rm baixar_dados.R descompactar.R plano_B.R Diretrizes_pacote.txt
git rm pagina/pagina_principal.txt
git rm scripts/consolidar.R
git rm "dicionario/acidentes_por_ocorrencia_ate_2016.pdf"
git rm "dicionario/acidentes_por_pessoa_2017_em_diante.pdf"
git rm "dicionario/acidentes_por_pessoa_ate_2016.pdf"
git rm "dicionario/dicionario-de-variaveis-infracoes.pdf"
git rm "dicionario/dicionario_variaveis_ocorrencia_2017.pdf"
git rm "dicionario/dicionario_variaveis_pessoa_2017.pdf"
git rm "referencias/educabR.pdf" "referencias/sidrar.pdf" "referencias/tidy-data.pdf"
git rm "docs/dicionario_consolidado.qmd" "docs/dicionario_consolidado.pdf"
```

- [ ] **Step 2: Delete untracked scratch files from disk**

```bash
rm -f teste.R
rm -f scripts/_test_infracoes_2019.R scripts/_test_infracoes_2020.R
rm -f scripts/_test_infracoes_2023.R scripts/_test_infracoes_all.R scripts/_test_infracoes_all2.R
rm -f scripts/.Rhistory
rmdir scripts   # only if scripts/ is now empty
```

- [ ] **Step 3: Verify nothing extra is staged**

```bash
git status
```

Expected: only deletions staged (the files removed in Step 1). No unintended changes.

- [ ] **Step 4: Commit**

```bash
git commit -m "chore: remove development scripts and reference files (moved to tidyprf-dados)"
```

---

## Phase 2 — README Files

### Task 4: Write README.md (English)

**Files:**
- Create: `D:\brtrafic\README.md`

- [ ] **Step 1: Create README.md**

Create `D:\brtrafic\README.md` with the following content:

```markdown
# tidyprf <img src="Logo/logo_tidyprf.png" align="right" height="139" />

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/bonijoao/tidyprf/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bonijoao/tidyprf/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

*[Leia em Português](README.pt-br.md)*

**tidyprf** gives you direct access to Brazilian Federal Highway Police (PRF)
road safety data — traffic accidents by person, accidents by occurrence, and
traffic violations — all from within R. No manual downloads, no navigating
government portals: just pick a dataset, choose the year, and get a clean,
analysis-ready tibble.

Data is distributed as Parquet files via GitHub Releases and cached locally
after the first download.

## Quick example

Compare accidents and traffic violations on BR-116 throughout 2024:

```r
library(tidyprf)
library(dplyr)
library(ggplot2)
library(lubridate)

# Accidents on BR-116 in 2024 (one row per person involved)
acc <- get_accidents(2024, br = 116) |>
  mutate(mes = month(data_inversa)) |>
  count(mes, name = "acidentes")

# Violations on BR-116 in 2024 — filter before collect(), files are ~243 MB
vio <- get_violations(2024, br = 116) |>
  collect() |>
  mutate(mes = month(dat_infracao)) |>
  count(mes, name = "infracoes")

# Monthly comparison
left_join(acc, vio, by = "mes") |>
  tidyr::pivot_longer(-mes, names_to = "tipo", values_to = "n") |>
  ggplot(aes(mes, n, color = tipo)) +
  geom_line(linewidth = 1) +
  geom_point() +
  scale_x_continuous(breaks = 1:12, labels = month.abb) +
  labs(title = "BR-116 in 2024: Accidents vs. Violations",
       x = NULL, y = "Count", color = NULL) +
  theme_minimal()
```

## Installation

Install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("bonijoao/tidyprf")
```

## Datasets

| Dataset | Function | Unit | Available Years |
|---|---|---|---|
| Accidents by person | `get_accidents()` | 1 row per person | 2007–2026 |
| Accidents by occurrence | `get_crashes()` | 1 row per accident | 2007–2026 |
| Traffic violations | `get_violations()` | 1 row per violation | 2019–2020, 2022–2026 |

All three functions support filtering by:
- `uf` — state abbreviation(s), e.g. `"SP"`, `c("SP", "RJ")`
- `br` — federal highway number(s), e.g. `101`, `116`
- `severity` — `"fatal"`, `"injured"`, or `"no_victims"` (accidents only)

Use `info_accidents()`, `info_crashes()`, or `info_violations()` to see all
variable descriptions in English or Portuguese.

## Cache

Parquet files are cached locally after first download:

```r
prf_cache()               # show cached files and sizes
prf_cache_clear()         # delete all cached files
prf_years("accidents")    # available years and row counts per dataset
```

## License

MIT
```

- [ ] **Step 2: Verify file was created**

```bash
wc -l README.md
```

Expected: roughly 80 lines.

---

### Task 5: Write README.pt-br.md (Portuguese)

**Files:**
- Create: `D:\brtrafic\README.pt-br.md`

- [ ] **Step 1: Create README.pt-br.md**

Create `D:\brtrafic\README.pt-br.md` with the following content:

```markdown
# tidyprf <img src="Logo/logo_tidyprf.png" align="right" height="139" />

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/bonijoao/tidyprf/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bonijoao/tidyprf/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

*[Read in English](README.md)*

O **tidyprf** oferece acesso direto aos dados de segurança viária da Polícia
Rodoviária Federal (PRF) — acidentes por pessoa, acidentes por ocorrência e
infrações de trânsito — diretamente no R. Sem downloads manuais, sem navegar
em portais do governo: escolha o dataset, o ano, e receba uma tabela limpa e
pronta para análise.

Os dados são distribuídos como arquivos Parquet via GitHub Releases e
armazenados em cache local após o primeiro download.

## Exemplo rápido

Compare acidentes e infrações na BR-116 ao longo de 2024:

```r
library(tidyprf)
library(dplyr)
library(ggplot2)
library(lubridate)

# Acidentes na BR-116 em 2024 (uma linha por pessoa envolvida)
acid <- get_accidents(2024, br = 116) |>
  mutate(mes = month(data_inversa)) |>
  count(mes, name = "acidentes")

# Infrações na BR-116 em 2024 — filtre antes do collect(), arquivos têm ~243 MB
infr <- get_violations(2024, br = 116) |>
  collect() |>
  mutate(mes = month(dat_infracao)) |>
  count(mes, name = "infracoes")

# Comparação mensal
left_join(acid, infr, by = "mes") |>
  tidyr::pivot_longer(-mes, names_to = "tipo", values_to = "n") |>
  ggplot(aes(mes, n, color = tipo)) +
  geom_line(linewidth = 1) +
  geom_point() +
  scale_x_continuous(breaks = 1:12, labels = c("Jan","Fev","Mar","Abr","Mai","Jun",
                                                "Jul","Ago","Set","Out","Nov","Dez")) +
  labs(title = "BR-116 em 2024: Acidentes vs. Infrações",
       x = NULL, y = "Contagem", color = NULL) +
  theme_minimal()
```

## Instalação

Instale a versão de desenvolvimento do GitHub:

```r
# install.packages("remotes")
remotes::install_github("bonijoao/tidyprf")
```

## Datasets

| Dataset | Função | Unidade | Anos disponíveis |
|---|---|---|---|
| Acidentes por pessoa | `get_accidents()` | 1 linha por pessoa | 2007–2026 |
| Acidentes por ocorrência | `get_crashes()` | 1 linha por acidente | 2007–2026 |
| Infrações de trânsito | `get_violations()` | 1 linha por infração | 2019–2020, 2022–2026 |

As três funções aceitam filtros por:
- `uf` — sigla do estado, ex.: `"SP"`, `c("SP", "RJ")`
- `br` — número da rodovia federal, ex.: `101`, `116`
- `severity` — `"fatal"`, `"injured"` ou `"no_victims"` (somente acidentes)

Use `info_accidents()`, `info_crashes()` ou `info_violations()` para ver a
descrição de todas as variáveis em inglês ou português.

## Cache

Os arquivos Parquet são armazenados localmente após o primeiro download:

```r
prf_cache()               # exibe arquivos em cache e tamanhos
prf_cache_clear()         # apaga todos os arquivos em cache
prf_years("accidents")    # anos disponíveis e contagem de linhas por dataset
```

## Licença

MIT
```

---

### Task 6: Commit the READMEs

**Files:**
- Modify: `D:\brtrafic` (git add + commit)

- [ ] **Step 1: Stage and commit**

```bash
git add README.md README.pt-br.md
git commit -m "docs: add bilingual README (EN + PT-BR)"
```

- [ ] **Step 2: Verify**

```bash
git log --oneline -3
```

Expected: top commit is `docs: add bilingual README (EN + PT-BR)`.

---

## Phase 3 — Pipeline Repo Initialization

### Task 7: Initialize tidyprf-dados git repo

**Files:**
- Create: `D:\tidyprf-dados\.gitignore`
- Initialize git repo

- [ ] **Step 1: Initialize git**

```powershell
Set-Location D:\tidyprf-dados
git init
git branch -m master
```

- [ ] **Step 2: Create .gitignore**

Create `D:\tidyprf-dados\.gitignore`:

```
# Raw and processed data — too large for git
dados/brutos/
dados/processados/

# Parquets go to GitHub Releases, not git
dados/consolidados/**/*.parquet

# R
.Rproj.user/
.Rhistory
.RData
.Rprofile
*.Rproj

# OS
.DS_Store
Thumbs.db
```

---

### Task 8: Create adapted consolidar.R for tidyprf-dados

**Files:**
- Create: `D:\tidyprf-dados\scripts\consolidar.R`

This replaces the copied `baixar_dados.R`/`descompactar.R`/original `consolidar.R` with a single, self-contained pipeline file. The key change from the package-repo version is that `atualizar_catalogo()` now writes to the tidyprf package repo path and includes the GitHub Release URLs in the catalog.

- [ ] **Step 1: Overwrite scripts/consolidar.R with the adapted version**

Create `D:\tidyprf-dados\scripts\consolidar.R`:

```r
# scripts/consolidar.R
# Pipeline principal: CSV brutos da PRF → Parquet consolidados.
# Executar a partir do root de tidyprf-dados: Rscript scripts/consolidar.R
#
# Para atualizar o catalogo.json no repo do pacote, configure:
#   TIDYPRF_REPO=D:/brtrafic  (variável de ambiente ou edite TIDYPRF_REPO abaixo)

suppressPackageStartupMessages({
  library(arrow)
  library(readr)
  library(dplyr)
  library(purrr)
  library(stringr)
  library(lubridate)
  library(jsonlite)
  library(fs)
  library(cli)
  library(glue)
})

if (!dir_exists("dados/processados")) {
  cli_abort("Execute a partir do root do projeto (D:/tidyprf-dados).")
}

VALORES_NA        <- c("", "NA", "Ignorado", "Não informado",
                       "Não Informado", "NÃO INFORMADO", "-", "N/A")
BASE_PROCESSADOS  <- "dados/processados"
BASE_CONSOLIDADOS <- "dados/consolidados"
BASE_URL          <- "https://github.com/bonijoao/tidyprf/releases/download/dados-v1/"

# ---- schemas ---------------------------------------------------------------

SCHEMA_ACIDENTES <- c(
  "id", "pesid", "data_inversa", "dia_semana", "horario",
  "uf", "br", "km", "municipio",
  "causa_principal", "causa_acidente", "ordem_tipo_acidente", "tipo_acidente",
  "classificacao_acidente", "fase_dia", "sentido_via",
  "condicao_metereologica", "tipo_pista", "tracado_via", "uso_solo",
  "id_veiculo", "tipo_veiculo", "marca", "ano_fabricacao_veiculo",
  "tipo_envolvido", "estado_fisico", "idade", "sexo",
  "nacionalidade", "naturalidade",
  "ilesos", "feridos_leves", "feridos_graves", "mortos",
  "latitude", "longitude",
  "regional", "delegacia", "uop",
  "ano"
)

SCHEMA_DATATRAN <- c(
  "id", "data_inversa", "dia_semana", "horario",
  "uf", "br", "km", "municipio",
  "causa_acidente", "tipo_acidente", "classificacao_acidente",
  "fase_dia", "sentido_via", "condicao_metereologica",
  "tipo_pista", "tracado_via", "uso_solo",
  "pessoas", "mortos", "feridos_leves", "feridos_graves",
  "ilesos", "ignorados", "feridos", "veiculos",
  "latitude", "longitude",
  "regional", "delegacia", "uop",
  "ano"
)

SCHEMA_INFRACOES <- c(
  "numero_auto", "dat_infracao", "tip_abordagem", "ind_assinou_auto",
  "ind_veiculo_estrangeiro", "ind_sentido_trafego",
  "uf_placa", "uf_infracao", "num_br_infracao", "num_km_infracao", "nom_municipio",
  "cod_infracao", "descricao_abreviada", "enquadramento",
  "data_inicio_vigencia", "data_fim_vigencia",
  "med_realizada", "med_considerada", "exc_verificado",
  "especie", "nome_veiculo_marca",
  "tipo_veiculo", "nom_modelo_veiculo",
  "hora", "qtd_infracoes",
  "ano"
)

MAPA_INFRACOES <- c(
  "numero_auto"             = "número do auto",
  "dat_infracao"            = "data da infração (dd/mm/aaaa)",
  "tip_abordagem"           = "indicador de abordagem",
  "ind_assinou_auto"        = "assinatura do auto",
  "ind_veiculo_estrangeiro" = "indicador veiculo estrangeiro",
  "ind_sentido_trafego"     = "sentido trafego",
  "uf_placa"                = "uf placa",
  "uf_infracao"             = "uf infração",
  "num_br_infracao"         = "br infração",
  "num_km_infracao"         = "km infração",
  "nom_municipio"           = "município",
  "cod_infracao"            = "código da infração",
  "descricao_abreviada"     = "descrição abreviada infração",
  "enquadramento"           = "enquadramento da infração",
  "data_inicio_vigencia"    = "início vigência da infração",
  "data_fim_vigencia"       = "fim vigência infração",
  "med_realizada"           = "medição infração",
  "med_considerada"         = "medição considerada",
  "exc_verificado"          = "excesso verificado",
  "especie"                 = "descrição especie veículo",
  "nome_veiculo_marca"      = "descrição marca veículo",
  "tipo_veiculo"            = "descrição tipo veículo",
  "nom_modelo_veiculo"      = "descrição modelo veiculo",
  "hora"                    = "hora infração",
  "qtd_infracoes"           = "qtd infrações"
)

# ---- funções ---------------------------------------------------------------

parse_data_prf <- function(x) {
  lubridate::parse_date_time(x, orders = c("Ymd", "dmY", "dmy"), quiet = TRUE) |>
    as.Date()
}

consolidar_acidentes <- function(ano) {
  if (ano <= 2015) {
    arquivo    <- path(BASE_PROCESSADOS, glue("acidentes{ano}.csv"))
    sep        <- ","
    locale_csv <- locale(encoding = "latin1")
  } else if (ano == 2016) {
    arquivo    <- path(BASE_PROCESSADOS, "acidentes2016_atual.csv")
    sep        <- ";"
    locale_csv <- locale(encoding = "latin1", decimal_mark = ",")
  } else {
    arquivo    <- path(BASE_PROCESSADOS, glue("acidentes{ano}_todas_causas_tipos.csv"))
    sep        <- ";"
    locale_csv <- locale(encoding = "latin1", decimal_mark = ",")
  }

  df <- read_delim(arquivo, delim = sep, locale = locale_csv,
                   na = VALORES_NA, name_repair = "minimal",
                   show_col_types = FALSE) |>
    rename_with(tolower) |>
    mutate(data_inversa = parse_data_prf(data_inversa))

  if (ano >= 2017) {
    df <- mutate(df, uso_solo = case_match(uso_solo,
      "Sim" ~ "Urbano", "Não" ~ "Rural", .default = uso_solo))
  }

  df <- mutate(df, sexo = case_match(sexo,
    "M" ~ "Masculino", "F" ~ "Feminino", .default = sexo))

  if ("idade" %in% names(df)) {
    df <- mutate(df, idade = if_else(as.integer(idade) == -1L, NA_integer_, as.integer(idade)))
  }

  if (ano < 2017) {
    df <- mutate(df,
      causa_principal = NA_character_, ordem_tipo_acidente = NA_integer_,
      ilesos = NA_integer_, feridos_leves = NA_integer_,
      feridos_graves = NA_integer_, mortos = NA_integer_,
      latitude = NA_real_, longitude = NA_real_,
      regional = NA_character_, delegacia = NA_character_, uop = NA_character_)
  } else {
    df <- mutate(df, nacionalidade = NA_character_, naturalidade = NA_character_)
  }

  df <- df |>
    mutate(ano = as.integer(year(data_inversa))) |>
    select(all_of(SCHEMA_ACIDENTES)) |>
    mutate(
      br = as.integer(br), km = as.double(km),
      ordem_tipo_acidente = as.integer(ordem_tipo_acidente),
      ano_fabricacao_veiculo = as.integer(ano_fabricacao_veiculo),
      ilesos = as.integer(ilesos), feridos_leves = as.integer(feridos_leves),
      feridos_graves = as.integer(feridos_graves), mortos = as.integer(mortos),
      latitude = as.double(latitude), longitude = as.double(longitude),
      uf = toupper(uf), dia_semana = tolower(dia_semana)
    )

  saida <- path(BASE_CONSOLIDADOS, "acidentes", glue("acidentes_{ano}.parquet"))
  dir_create(path_dir(saida), recurse = TRUE)
  write_parquet(df, saida)

  cli_inform("acidentes_{ano}: {nrow(df)} linhas, {round(file.size(saida)/1e6,2)} MB")
  invisible(list(linhas = nrow(df), tamanho_mb = round(file.size(saida)/1e6, 2)))
}

consolidar_datatran <- function(ano) {
  arquivo <- path(BASE_PROCESSADOS, glue("datatran{ano}.csv"))

  df <- read_delim(arquivo, delim = ";",
                   locale = locale(encoding = "latin1", decimal_mark = ","),
                   na = VALORES_NA, name_repair = "minimal",
                   show_col_types = FALSE) |>
    rename_with(tolower)

  if (ano <= 2015 && "ano" %in% names(df)) df <- select(df, -ano)

  df <- mutate(df, data_inversa = parse_data_prf(data_inversa))

  if (ano >= 2017) {
    df <- mutate(df, uso_solo = case_match(uso_solo,
      "Sim" ~ "Urbano", "Não" ~ "Rural", .default = uso_solo))
  }

  if (ano <= 2016) {
    df <- mutate(df,
      latitude = NA_real_, longitude = NA_real_,
      regional = NA_character_, delegacia = NA_character_, uop = NA_character_)
  }

  df <- df |>
    mutate(ano = as.integer(year(data_inversa))) |>
    select(all_of(SCHEMA_DATATRAN)) |>
    mutate(
      br = as.integer(br), km = as.double(km),
      pessoas = as.integer(pessoas), mortos = as.integer(mortos),
      feridos_leves = as.integer(feridos_leves),
      feridos_graves = as.integer(feridos_graves),
      ilesos = as.integer(ilesos), ignorados = as.integer(ignorados),
      feridos = as.integer(feridos), veiculos = as.integer(veiculos),
      latitude = as.double(latitude), longitude = as.double(longitude),
      uf = toupper(uf), dia_semana = tolower(dia_semana)
    )

  saida <- path(BASE_CONSOLIDADOS, "datatran", glue("datatran_{ano}.parquet"))
  dir_create(path_dir(saida), recurse = TRUE)
  write_parquet(df, saida)

  cli_inform("datatran_{ano}: {nrow(df)} linhas, {round(file.size(saida)/1e6,2)} MB")
  invisible(list(linhas = nrow(df), tamanho_mb = round(file.size(saida)/1e6, 2)))
}

consolidar_infracoes <- function(ano) {
  if (ano == 2021) {
    cli_warn("Infrações 2021 ausentes na fonte PRF — pulando.")
    return(invisible(NULL))
  }

  if (ano %in% c(2019, 2020)) {
    arquivos <- dir_ls(BASE_PROCESSADOS,
                       regexp = glue("infracoes_{ano}_\\d+\\.csv$"))
    enc_csv <- if (ano == 2019) "UTF-8" else "latin1"
  } else {
    pasta    <- path(BASE_PROCESSADOS, glue("ajustados_{ano}"))
    arquivos <- dir_ls(pasta, regexp = "\\.csv$", ignore.case = TRUE)
    enc_csv  <- "latin1"
  }

  if (length(arquivos) == 0) {
    cli_warn("Nenhum arquivo encontrado para infrações {ano}.")
    return(invisible(NULL))
  }

  df <- map_dfr(arquivos, function(arq) {
    read_delim(arq, delim = ";",
               locale = locale(encoding = enc_csv, decimal_mark = ","),
               na = VALORES_NA, name_repair = "minimal",
               col_types = cols(.default = "c"),
               show_col_types = FALSE) |>
      rename_with(tolower) |>
      rename(any_of(MAPA_INFRACOES))
  })

  if (ano == 2019) {
    df <- mutate(df, tipo_veiculo = NA_character_,
                 nom_modelo_veiculo = NA_character_,
                 qtd_infracoes = NA_integer_)
  } else if (ano == 2020) {
    df <- mutate(df, tipo_veiculo = NA_character_,
                 nom_modelo_veiculo = NA_character_)
  }

  df <- df |>
    mutate(
      dat_infracao         = parse_data_prf(dat_infracao),
      data_inicio_vigencia = parse_data_prf(data_inicio_vigencia),
      data_fim_vigencia    = parse_data_prf(data_fim_vigencia),
      ano                  = as.integer(year(dat_infracao))
    ) |>
    select(all_of(SCHEMA_INFRACOES)) |>
    mutate(
      num_br_infracao = as.integer(num_br_infracao),
      num_km_infracao = as.double(num_km_infracao),
      med_realizada   = as.double(med_realizada),
      med_considerada = as.double(med_considerada),
      exc_verificado  = as.double(exc_verificado),
      qtd_infracoes   = as.integer(qtd_infracoes)
    )

  saida <- path(BASE_CONSOLIDADOS, "infracoes", glue("infracoes_{ano}.parquet"))
  dir_create(path_dir(saida), recurse = TRUE)
  write_parquet(df, saida)

  cli_inform("infracoes_{ano}: {nrow(df)} linhas, {round(file.size(saida)/1e6,2)} MB")
  invisible(list(linhas = nrow(df), tamanho_mb = round(file.size(saida)/1e6, 2)))
}

atualizar_catalogo <- function(dest_repo = Sys.getenv("TIDYPRF_REPO", unset = "D:/brtrafic")) {
  datasets <- c("acidentes", "datatran", "infracoes")

  info_datasets <- map(set_names(datasets), function(dataset) {
    pasta <- path(BASE_CONSOLIDADOS, dataset)
    if (!dir_exists(pasta)) return(list(anos = integer(0), arquivos = list()))

    arquivos <- dir_ls(pasta, glob = "*.parquet")
    if (length(arquivos) == 0) return(list(anos = integer(0), arquivos = list()))

    anos <- sort(as.integer(str_extract(path_file(arquivos), "\\d{4}")))

    info_arq <- map(set_names(path_file(arquivos)), function(arq) {
      caminho <- path(pasta, arq)
      list(
        url           = paste0(BASE_URL, arq),
        tamanho_mb    = round(file.size(caminho) / 1e6, 2),
        linhas        = nrow(open_dataset(caminho)),
        atualizado_em = as.character(Sys.Date())
      )
    })

    list(anos = anos, arquivos = info_arq)
  })

  catalogo <- list(
    atualizado_em = as.character(Sys.Date()),
    repo          = "bonijoao/tidyprf",
    release_tag   = "dados-v1",
    base_url      = BASE_URL,
    datasets      = info_datasets
  )

  saida <- path(dest_repo, "dados/consolidados/catalogo.json")
  write_json(catalogo, saida, pretty = TRUE, auto_unbox = TRUE)
  cli_inform("Catálogo escrito em: {saida}")
  invisible(saida)
}
```

- [ ] **Step 2: Delete the placeholder copies of the old scripts**

```powershell
Remove-Item "D:\tidyprf-dados\scripts\baixar_dados.R"
Remove-Item "D:\tidyprf-dados\scripts\descompactar.R"
Remove-Item "D:\tidyprf-dados\scripts\plano_B.R"
```

---

### Task 9: Create update wrapper scripts

**Files:**
- Create: `D:\tidyprf-dados\scripts\update_acidentes.R`
- Create: `D:\tidyprf-dados\scripts\update_datatran.R`
- Create: `D:\tidyprf-dados\scripts\update_infracoes.R`
- Create: `D:\tidyprf-dados\scripts\atualizar_catalogo.R`

- [ ] **Step 1: Create update_acidentes.R**

Create `D:\tidyprf-dados\scripts\update_acidentes.R`:

```r
# update_acidentes.R
# Converte CSVs de acidentes → Parquet.
# Pré-requisito: CSVs já em dados/processados/
# Uso: Rscript scripts/update_acidentes.R

source("scripts/consolidar.R", local = TRUE)

# Altere os anos conforme necessário
ANOS <- 2026

purrr::walk(ANOS, consolidar_acidentes)

cli_inform("Concluído. Rode atualizar_catalogo.R para atualizar o catalogo.json.")
```

- [ ] **Step 2: Create update_datatran.R**

Create `D:\tidyprf-dados\scripts\update_datatran.R`:

```r
# update_datatran.R
# Converte CSVs de acidentes por ocorrência → Parquet.
# Pré-requisito: CSVs já em dados/processados/
# Uso: Rscript scripts/update_datatran.R

source("scripts/consolidar.R", local = TRUE)

# Altere os anos conforme necessário
ANOS <- 2026

purrr::walk(ANOS, consolidar_datatran)

cli_inform("Concluído. Rode atualizar_catalogo.R para atualizar o catalogo.json.")
```

- [ ] **Step 3: Create update_infracoes.R**

Create `D:\tidyprf-dados\scripts\update_infracoes.R`:

```r
# update_infracoes.R
# Converte CSVs de infrações → Parquet.
# Pré-requisito: CSVs já em dados/processados/ (ou ajustados_YYYY/)
# Uso: Rscript scripts/update_infracoes.R

source("scripts/consolidar.R", local = TRUE)

# Altere os anos conforme necessário (2021 é ignorado automaticamente)
ANOS <- 2026

purrr::walk(ANOS, consolidar_infracoes)

cli_inform("Concluído. Rode atualizar_catalogo.R para atualizar o catalogo.json.")
```

- [ ] **Step 4: Create atualizar_catalogo.R**

Create `D:\tidyprf-dados\scripts\atualizar_catalogo.R`:

```r
# atualizar_catalogo.R
# Recalcula catalogo.json a partir dos Parquets locais e escreve no repo do pacote.
#
# Configure o caminho do repo do pacote via variável de ambiente:
#   $env:TIDYPRF_REPO = "D:/brtrafic"
# Ou edite o valor padrão em consolidar.R → atualizar_catalogo().
#
# Uso: Rscript scripts/atualizar_catalogo.R

source("scripts/consolidar.R", local = TRUE)

atualizar_catalogo()

cli_inform(c(
  "",
  "Próximos passos:",
  "1. git commit + push de dados/consolidados/catalogo.json no repo bonijoao/tidyprf",
  "2. Upload dos novos parquets para o GitHub Release 'dados-v1'"
))
```

---

### Task 10: Create pipeline README and make initial commit

**Files:**
- Create: `D:\tidyprf-dados\README.md`
- Create: first git commit

- [ ] **Step 1: Create pipeline README**

Create `D:\tidyprf-dados\README.md`:

```markdown
# tidyprf-dados

Scripts de pipeline para geração e atualização dos dados do pacote
[tidyprf](https://github.com/bonijoao/tidyprf).

## Fluxo de atualização

### 1. Baixar novos dados da PRF

Acesse o portal de dados abertos da PRF e baixe os arquivos de interesse:
- Acidentes: https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/dados-abertos-acidentes
- Infrações: https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/dados-abertos-da-prf

Salve os ZIPs em `dados/brutos/`. Descompacte os CSVs em `dados/processados/`,
mantendo a estrutura de nomes esperada pelos scripts.

### 2. Converter para Parquet

Edite o vetor `ANOS` no script correspondente e execute:

```r
# A partir da raiz do projeto (D:/tidyprf-dados)
Rscript scripts/update_acidentes.R
Rscript scripts/update_datatran.R
Rscript scripts/update_infracoes.R
```

### 3. Atualizar o catálogo

```r
# Configure o caminho do repo do pacote
$env:TIDYPRF_REPO = "D:/brtrafic"
Rscript scripts/atualizar_catalogo.R
```

### 4. Publicar

1. No repo `bonijoao/tidyprf`: `git commit + git push` do `catalogo.json` atualizado
2. Faça upload dos novos `.parquet` para o GitHub Release `dados-v1`

## Estrutura

```
scripts/
  consolidar.R          # funções de conversão CSV → Parquet
  update_acidentes.R    # wrapper para acidentes
  update_datatran.R     # wrapper para datatran
  update_infracoes.R    # wrapper para infrações
  atualizar_catalogo.R  # recalcula e escreve catalogo.json

dados/
  brutos/               # ZIPs/RARs originais (gitignored)
  processados/          # CSVs descompactados (gitignored)
  consolidados/         # Parquets gerados (gitignored — vão para GitHub Releases)

dicionario/             # PDFs de dicionário de variáveis PRF
referencias/            # PDFs de referência
docs/                   # Dicionário consolidado (QMD + PDF)
```

## Nota sobre infrações

Os dados de infrações para 2021 não estão disponíveis na fonte PRF.
Os anos 2007–2018 têm formato diferente e ainda não foram incorporados ao pipeline.
```

- [ ] **Step 2: Initial commit of tidyprf-dados**

```powershell
Set-Location D:\tidyprf-dados
git add .
git commit -m "feat: initialize tidyprf-dados pipeline repo"
```

- [ ] **Step 3: Verify commit**

```powershell
git log --oneline
git status
```

Expected: one commit, clean working tree.

---

## Verificação final

Após completar todas as tasks, verifique:

- [ ] `D:\brtrafic` não contém mais `baixar_dados.R`, `descompactar.R`, `plano_B.R`, `Diretrizes_pacote.txt`, `dicionario/`, `referencias/`, `scripts/`, `pagina/`, `docs/dicionario_consolidado.*`
- [ ] `D:\brtrafic\README.md` e `README.pt-br.md` existem
- [ ] `D:\tidyprf-dados\scripts\` contém `consolidar.R`, `update_acidentes.R`, `update_datatran.R`, `update_infracoes.R`, `atualizar_catalogo.R`
- [ ] `D:\tidyprf-dados` tem pelo menos um commit git

```bash
# Verificação rápida no repo do pacote
cd /d/brtrafic && git log --oneline -5 && ls
```
