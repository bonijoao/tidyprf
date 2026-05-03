# Consolidação PRF em Parquet — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Converter os CSVs brutos da PRF (2007–2026) em arquivos Parquet anuais com schema unificado em `dados/consolidados/`, prontos para consumo pelo pacote tidypfr.

**Architecture:** Script standalone `scripts/consolidar.R` com uma função por dataset. Cada função detecta o ano, lê o(s) CSV(s) correto(s), aplica o schema unificado (colunas ausentes viram NA), normaliza tipos e strings, e escreve Parquet via `{arrow}`. `atualizar_catalogo()` regenera o índice JSON ao final.

**Tech Stack:** R — arrow, readr, dplyr, purrr, stringr, lubridate, jsonlite, fs, cli, glue

---

## Estrutura de arquivos

| Arquivo | Ação |
|---------|------|
| `docs/dicionario_consolidado.qmd` | Já criado — renderizar para PDF |
| `scripts/consolidar.R` | Criar — script principal |
| `dados/consolidados/acidentes/acidentes_{YYYY}.parquet` | Gerado em runtime |
| `dados/consolidados/datatran/datatran_{YYYY}.parquet` | Gerado em runtime |
| `dados/consolidados/infracoes/infracoes_{YYYY}.parquet` | Gerado em runtime |
| `dados/consolidados/catalogo.json` | Gerado em runtime |

---

## Task 1: Renderizar dicionário Quarto

**Files:**
- Render: `docs/dicionario_consolidado.qmd` → `docs/dicionario_consolidado.pdf`

- [ ] **Step 1: Instalar dependências R necessárias para o Quarto**

No console R (com working directory em `D:/brtrafic`):

```r
install.packages(c("knitr", "kableExtra"))
```

- [ ] **Step 2: Renderizar o PDF**

No terminal (a partir de `D:/brtrafic`):

```bash
quarto render docs/dicionario_consolidado.qmd --to pdf
```

Resultado esperado: arquivo `docs/dicionario_consolidado.pdf` criado sem erros.

- [ ] **Step 3: Verificar PDF**

Abrir `docs/dicionario_consolidado.pdf` e confirmar:
- Três tabelas de schema (acidentes 39 col, datatran 31 col, infrações 26 col)
- Seção de padronização de NA com tabela
- Sem erros de LaTeX ou células truncadas

---

## Task 2: Instalar dependências e criar skeleton do script

**Files:**
- Create: `scripts/consolidar.R`

- [ ] **Step 1: Instalar pacotes necessários**

```r
install.packages(c("arrow", "readr", "dplyr", "purrr",
                   "stringr", "lubridate", "jsonlite", "fs",
                   "cli", "glue"))
```

- [ ] **Step 2: Criar `scripts/consolidar.R` com skeleton**

```r
# scripts/consolidar.R
# Consolida CSVs brutos da PRF em arquivos Parquet anuais por dataset.
# Executar a partir do root do projeto: Rscript scripts/consolidar.R

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
  cli_abort("Execute a partir do root do projeto (D:/brtrafic).")
}

VALORES_NA       <- c("", "NA", "Ignorado", "Não informado",
                      "Não Informado", "NÃO INFORMADO", "-", "N/A")
BASE_PROCESSADOS <- "dados/processados"
BASE_CONSOLIDADOS <- "dados/consolidados"

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

# Mapeamento nomes originais infrações (após tolower) → snake_case
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

# ---- funções (serão adicionadas nas próximas tasks) ------------------------

# parse_data_prf()       — Task 3
# consolidar_acidentes() — Task 3
# consolidar_datatran()  — Task 5
# consolidar_infracoes() — Task 7
# atualizar_catalogo()   — Task 9
# consolidar_tudo()      — Task 10
```

- [ ] **Step 3: Verificar que o skeleton carrega sem erro**

```r
source("scripts/consolidar.R")
# Resultado esperado: sem mensagens de erro, apenas o aviso de que as funções ainda não existem
stopifnot(exists("SCHEMA_ACIDENTES"))
stopifnot(length(SCHEMA_ACIDENTES) == 40)
cat("Skeleton OK\n")
```

---

## Task 3: `parse_data_prf()` e `consolidar_acidentes(ano)`

**Files:**
- Modify: `scripts/consolidar.R` (substituir comentário `# parse_data_prf()` e `# consolidar_acidentes()`)

- [ ] **Step 1: Adicionar `parse_data_prf` e `consolidar_acidentes` ao script**

Substituir o bloco de comentários `# parse_data_prf() — Task 3` e `# consolidar_acidentes() — Task 3` pelo código abaixo:

```r
parse_data_prf <- function(x) {
  lubridate::parse_date_time(
    x,
    orders = c("Ymd", "dmY", "dmy"),
    quiet  = TRUE
  ) |> as.Date()
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
    rename_with(tolower)

  df <- df |>
    mutate(data_inversa = parse_data_prf(data_inversa))

  if (ano >= 2017) {
    df <- df |>
      mutate(uso_solo = case_match(uso_solo,
        "Sim" ~ "Urbano", "Não" ~ "Rural", .default = uso_solo))
  }

  df <- df |>
    mutate(sexo = case_match(sexo,
      "M" ~ "Masculino", "F" ~ "Feminino", .default = sexo))

  if ("idade" %in% names(df)) {
    df <- df |>
      mutate(idade = if_else(as.integer(idade) == -1L, NA_integer_, as.integer(idade)))
  }

  if (ano < 2017) {
    df <- df |>
      mutate(
        causa_principal      = NA_character_,
        ordem_tipo_acidente  = NA_integer_,
        ilesos               = NA_integer_,
        feridos_leves        = NA_integer_,
        feridos_graves       = NA_integer_,
        mortos               = NA_integer_,
        latitude             = NA_real_,
        longitude            = NA_real_,
        regional             = NA_character_,
        delegacia            = NA_character_,
        uop                  = NA_character_
      )
  } else {
    df <- df |>
      mutate(nacionalidade = NA_character_, naturalidade = NA_character_)
  }

  df <- df |>
    mutate(ano = as.integer(year(data_inversa))) |>
    select(all_of(SCHEMA_ACIDENTES)) |>
    mutate(
      br                     = as.integer(br),
      km                     = as.double(km),
      ordem_tipo_acidente    = as.integer(ordem_tipo_acidente),
      ano_fabricacao_veiculo = as.integer(ano_fabricacao_veiculo),
      ilesos                 = as.integer(ilesos),
      feridos_leves          = as.integer(feridos_leves),
      feridos_graves         = as.integer(feridos_graves),
      mortos                 = as.integer(mortos),
      latitude               = as.double(latitude),
      longitude              = as.double(longitude),
      uf                     = toupper(uf),
      dia_semana             = tolower(dia_semana)
    )

  saida <- path(BASE_CONSOLIDADOS, "acidentes", glue("acidentes_{ano}.parquet"))
  dir_create(path_dir(saida), recurse = TRUE)
  write_parquet(df, saida)

  res <- list(linhas = nrow(df), tamanho_mb = round(file.size(saida) / 1e6, 2))
  cli_inform("acidentes_{ano}: {res$linhas} linhas, {res$tamanho_mb} MB")
  invisible(res)
}
```

- [ ] **Step 2: Testar `parse_data_prf` com os três formatos**

```r
source("scripts/consolidar.R")

datas_teste <- c("2023-03-15", "15/03/2023", "15/03/16")
resultado   <- parse_data_prf(datas_teste)

stopifnot(inherits(resultado, "Date"))
stopifnot(resultado[1] == as.Date("2023-03-15"))
stopifnot(resultado[2] == as.Date("2023-03-15"))
stopifnot(resultado[3] == as.Date("2016-03-15"))
cat("parse_data_prf OK\n")
```

Resultado esperado: `parse_data_prf OK`

- [ ] **Step 3: Rodar acidentes 2023 (pós-2017) e verificar**

```r
source("scripts/consolidar.R")
consolidar_acidentes(2023)

df <- read_parquet("dados/consolidados/acidentes/acidentes_2023.parquet")

stopifnot(nrow(df) > 0)
stopifnot(ncol(df) == 40)
stopifnot(all(SCHEMA_ACIDENTES %in% names(df)))
stopifnot(inherits(df$data_inversa, "Date"))
stopifnot(is.integer(df$br))
stopifnot(is.double(df$km))
stopifnot(is.integer(df$ano))
stopifnot(all(df$ano == 2023, na.rm = TRUE))
stopifnot(!any(c("Sim", "Não") %in% df$uso_solo, na.rm = TRUE))
stopifnot(all(is.na(df$nacionalidade)))
stopifnot(!all(is.na(df$ilesos)))          # pós-2017: binários presentes

na_ruins <- c("Ignorado","Não informado","Não Informado","NÃO INFORMADO","-","N/A")
char_cols <- names(df)[sapply(df, is.character)]
for (col in char_cols) {
  found <- na_ruins[na_ruins %in% unique(df[[col]])]
  if (length(found) > 0) cat("AVISO:", col, "→", found, "\n")
}
cat("acidentes_2023 OK:", nrow(df), "linhas\n")
```

- [ ] **Step 4: Rodar acidentes 2015 (pré-2017, vírgula) e verificar**

```r
consolidar_acidentes(2015)

df15 <- read_parquet("dados/consolidados/acidentes/acidentes_2015.parquet")

stopifnot(nrow(df15) > 0)
stopifnot(all(SCHEMA_ACIDENTES %in% names(df15)))
stopifnot(inherits(df15$data_inversa, "Date"))
stopifnot(all(is.na(df15$causa_principal)))     # ausente pré-2017
stopifnot(all(is.na(df15$ilesos)))              # ausente pré-2017
stopifnot(is.character(df15$nacionalidade))     # presente pré-2017
cat("acidentes_2015 OK:", nrow(df15), "linhas\n")
```

---

## Task 4: Rodar todos os anos de acidentes

**Files:**
- Modify: nenhum — apenas execução

- [ ] **Step 1: Consolidar acidentes 2007–2026**

```r
source("scripts/consolidar.R")
walk(2007:2026, consolidar_acidentes)
```

Resultado esperado: 20 linhas de output no formato `acidentes_{ano}: N linhas, X.XX MB`

- [ ] **Step 2: Verificar que todos os Parquets foram criados**

```r
parquets <- dir_ls("dados/consolidados/acidentes", glob = "*.parquet")
stopifnot(length(parquets) == 20)
cat("Todos os", length(parquets), "Parquets de acidentes criados\n")
```

---

## Task 5: `consolidar_datatran(ano)`

**Files:**
- Modify: `scripts/consolidar.R` (substituir `# consolidar_datatran() — Task 5`)

- [ ] **Step 1: Adicionar `consolidar_datatran` ao script**

```r
consolidar_datatran <- function(ano) {
  arquivo <- path(BASE_PROCESSADOS, glue("datatran{ano}.csv"))

  df <- read_delim(arquivo, delim = ";",
                   locale = locale(encoding = "latin1", decimal_mark = ","),
                   na = VALORES_NA, name_repair = "minimal",
                   show_col_types = FALSE) |>
    rename_with(tolower)

  if (ano <= 2011 && "ano" %in% names(df)) {
    df <- df |> select(-ano)
  }

  df <- df |>
    mutate(data_inversa = parse_data_prf(data_inversa))

  if (ano >= 2017) {
    df <- df |>
      mutate(uso_solo = case_match(uso_solo,
        "Sim" ~ "Urbano", "Não" ~ "Rural", .default = uso_solo))
  }

  if (ano <= 2011) {
    df <- df |>
      mutate(
        latitude  = NA_real_,  longitude = NA_real_,
        regional  = NA_character_, delegacia = NA_character_, uop = NA_character_
      )
  }

  df <- df |>
    mutate(ano = as.integer(year(data_inversa))) |>
    select(all_of(SCHEMA_DATATRAN)) |>
    mutate(
      br             = as.integer(br),
      km             = as.double(km),
      pessoas        = as.integer(pessoas),
      mortos         = as.integer(mortos),
      feridos_leves  = as.integer(feridos_leves),
      feridos_graves = as.integer(feridos_graves),
      ilesos         = as.integer(ilesos),
      ignorados      = as.integer(ignorados),
      feridos        = as.integer(feridos),
      veiculos       = as.integer(veiculos),
      latitude       = as.double(latitude),
      longitude      = as.double(longitude),
      uf             = toupper(uf),
      dia_semana     = tolower(dia_semana)
    )

  saida <- path(BASE_CONSOLIDADOS, "datatran", glue("datatran_{ano}.parquet"))
  dir_create(path_dir(saida), recurse = TRUE)
  write_parquet(df, saida)

  res <- list(linhas = nrow(df), tamanho_mb = round(file.size(saida) / 1e6, 2))
  cli_inform("datatran_{ano}: {res$linhas} linhas, {res$tamanho_mb} MB")
  invisible(res)
}
```

- [ ] **Step 2: Testar datatran 2023 (pós-2017)**

```r
source("scripts/consolidar.R")
consolidar_datatran(2023)

df <- read_parquet("dados/consolidados/datatran/datatran_2023.parquet")
stopifnot(nrow(df) > 0)
stopifnot(ncol(df) == 31)
stopifnot(all(SCHEMA_DATATRAN %in% names(df)))
stopifnot(inherits(df$data_inversa, "Date"))
stopifnot(is.integer(df$pessoas))
stopifnot(is.integer(df$mortos))    # contagem, não binário
stopifnot(all(df$ano == 2023, na.rm = TRUE))
cat("datatran_2023 OK:", nrow(df), "linhas\n")
```

- [ ] **Step 3: Testar datatran 2009 (sem lat/lon)**

```r
consolidar_datatran(2009)

df09 <- read_parquet("dados/consolidados/datatran/datatran_2009.parquet")
stopifnot(nrow(df09) > 0)
stopifnot(all(SCHEMA_DATATRAN %in% names(df09)))
stopifnot(all(is.na(df09$latitude)))
stopifnot(all(is.na(df09$regional)))
cat("datatran_2009 OK:", nrow(df09), "linhas\n")
```

- [ ] **Step 4: Consolidar todos os anos**

```r
walk(2007:2026, consolidar_datatran)
parquets <- dir_ls("dados/consolidados/datatran", glob = "*.parquet")
stopifnot(length(parquets) == 20)
cat("Todos os", length(parquets), "Parquets de datatran criados\n")
```

---

## Task 6: `consolidar_infracoes(ano)`

**Files:**
- Modify: `scripts/consolidar.R` (substituir `# consolidar_infracoes() — Task 7`)

- [ ] **Step 1: Adicionar `consolidar_infracoes` ao script**

```r
consolidar_infracoes <- function(ano) {
  if (ano == 2021) {
    cli_warn("Infrações 2021 ausentes — pulando.")
    return(invisible(NULL))
  }

  if (ano %in% c(2019, 2020)) {
    arquivos <- dir_ls(BASE_PROCESSADOS,
                       regexp = glue("infracoes_{ano}_\\d+\\.csv$"))
  } else {
    pasta    <- path(BASE_PROCESSADOS, glue("ajustados_{ano}"))
    arquivos <- dir_ls(pasta, regexp = "\\.csv$", ignore.case = TRUE)
  }

  if (length(arquivos) == 0) {
    cli_warn("Nenhum arquivo para infrações {ano}.")
    return(invisible(NULL))
  }

  df <- map_dfr(arquivos, function(arq) {
    read_delim(arq, delim = ";",
               locale = locale(encoding = "UTF-8", decimal_mark = ","),
               na = VALORES_NA, name_repair = "minimal",
               show_col_types = FALSE) |>
      rename_with(tolower) |>
      rename(any_of(MAPA_INFRACOES))
  })

  if (ano %in% c(2019, 2020)) {
    df <- df |>
      mutate(tipo_veiculo       = NA_character_,
             nom_modelo_veiculo = NA_character_,
             qtd_infracoes      = NA_integer_)
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

  res <- list(linhas = nrow(df), tamanho_mb = round(file.size(saida) / 1e6, 2))
  cli_inform("infracoes_{ano}: {res$linhas} linhas, {res$tamanho_mb} MB")
  invisible(res)
}
```

- [ ] **Step 2: Testar infrações 2023 (formato 2022+)**

```r
source("scripts/consolidar.R")
consolidar_infracoes(2023)

df <- read_parquet("dados/consolidados/infracoes/infracoes_2023.parquet")
stopifnot(nrow(df) > 0)
stopifnot(ncol(df) == 26)
stopifnot(all(SCHEMA_INFRACOES %in% names(df)))
stopifnot(inherits(df$dat_infracao, "Date"))
stopifnot(inherits(df$data_inicio_vigencia, "Date"))
stopifnot(is.integer(df$num_br_infracao))
stopifnot(!all(is.na(df$tipo_veiculo)))   # presente em 2022+
cat("infracoes_2023 OK:", nrow(df), "linhas\n")
```

- [ ] **Step 3: Testar infrações 2019 (formato antigo, com BOM)**

```r
consolidar_infracoes(2019)

df19 <- read_parquet("dados/consolidados/infracoes/infracoes_2019.parquet")
stopifnot(nrow(df19) > 0)
stopifnot(all(SCHEMA_INFRACOES %in% names(df19)))
stopifnot(inherits(df19$dat_infracao, "Date"))
stopifnot(all(is.na(df19$tipo_veiculo)))       # ausente em 2019
stopifnot(all(is.na(df19$qtd_infracoes)))
cat("infracoes_2019 OK:", nrow(df19), "linhas\n")
```

- [ ] **Step 4: Consolidar todos os anos de infrações**

```r
walk(c(2019, 2020, 2022:2026), consolidar_infracoes)
parquets <- dir_ls("dados/consolidados/infracoes", glob = "*.parquet")
stopifnot(length(parquets) == 7)
cat("Todos os", length(parquets), "Parquets de infrações criados\n")
```

---

## Task 7: `atualizar_catalogo()`

**Files:**
- Modify: `scripts/consolidar.R` (substituir `# atualizar_catalogo() — Task 9`)

- [ ] **Step 1: Adicionar `atualizar_catalogo` ao script**

```r
atualizar_catalogo <- function() {
  datasets <- c("acidentes", "datatran", "infracoes")

  info_datasets <- map(set_names(datasets), function(dataset) {
    pasta    <- path(BASE_CONSOLIDADOS, dataset)
    if (!dir_exists(pasta)) return(list(anos = integer(0), arquivos = list()))

    arquivos <- dir_ls(pasta, glob = "*.parquet")
    if (length(arquivos) == 0) return(list(anos = integer(0), arquivos = list()))

    anos <- sort(as.integer(str_extract(path_file(arquivos), "\\d{4}")))

    info_arq <- map(set_names(path_file(arquivos)), function(arq) {
      caminho <- path(pasta, arq)
      list(
        tamanho_mb    = round(file.size(caminho) / 1e6, 2),
        linhas        = nrow(open_dataset(caminho)),
        atualizado_em = as.character(Sys.Date())
      )
    })

    list(anos = anos, arquivos = info_arq)
  })

  catalogo <- list(
    atualizado_em = as.character(Sys.Date()),
    datasets      = info_datasets
  )

  saida <- path(BASE_CONSOLIDADOS, "catalogo.json")
  write_json(catalogo, saida, pretty = TRUE, auto_unbox = TRUE)
  cli_inform("Catálogo escrito: {saida}")
  invisible(saida)
}
```

- [ ] **Step 2: Gerar e verificar catálogo**

```r
source("scripts/consolidar.R")
atualizar_catalogo()

cat_json <- read_json("dados/consolidados/catalogo.json")
stopifnot(!is.null(cat_json$atualizado_em))
stopifnot(length(cat_json$datasets$acidentes$anos) == 20)
stopifnot(length(cat_json$datasets$datatran$anos)  == 20)
stopifnot(length(cat_json$datasets$infracoes$anos) == 7)

# Verificar que todos os arquivos têm tamanho e linhas preenchidos
for (arq in names(cat_json$datasets$acidentes$arquivos)) {
  meta <- cat_json$datasets$acidentes$arquivos[[arq]]
  stopifnot(!is.null(meta$tamanho_mb))
  stopifnot(!is.null(meta$linhas))
  stopifnot(meta$linhas > 0)
}
cat("catalogo.json OK\n")
```

---

## Task 8: `consolidar_tudo()` e execução completa

**Files:**
- Modify: `scripts/consolidar.R` (substituir `# consolidar_tudo() — Task 10` e descomente bloco final)

- [ ] **Step 1: Adicionar `consolidar_tudo` ao final do script e descomentar execução**

```r
consolidar_tudo <- function() {
  cli_h1("Acidentes (2007-2026)")
  walk(2007:2026, consolidar_acidentes)

  cli_h1("Datatran (2007-2026)")
  walk(2007:2026, consolidar_datatran)

  cli_h1("Infrações (2019-2020, 2022-2026)")
  walk(c(2019, 2020, 2022:2026), consolidar_infracoes)

  cli_h1("Atualizando catálogo")
  atualizar_catalogo()

  cli_inform("Consolidação completa.")
  invisible(NULL)
}

# Executar ao rodar via Rscript
if (!interactive()) consolidar_tudo()
```

- [ ] **Step 2: Rodar o script completo via terminal**

```bash
Rscript scripts/consolidar.R
```

Resultado esperado: ~47 linhas de log (`acidentes_YYYY: N linhas, X MB`), terminando com `Consolidação completa.`

---

## Task 9: Verificação final de schema

**Files:**
- Nenhum — apenas verificação

- [ ] **Step 1: Verificar schema idêntico entre todos os anos de cada dataset**

```r
source("scripts/consolidar.R")

# Acidentes: todos os anos devem ter schema idêntico
schemas_ac <- map(dir_ls("dados/consolidados/acidentes", glob = "*.parquet"),
                  \(f) names(read_parquet(f, as_data_frame = FALSE)$schema))
stopifnot(length(unique(schemas_ac)) == 1)
cat("Acidentes: schema uniforme em todos os anos\n")

# Datatran
schemas_dt <- map(dir_ls("dados/consolidados/datatran", glob = "*.parquet"),
                  \(f) names(read_parquet(f, as_data_frame = FALSE)$schema))
stopifnot(length(unique(schemas_dt)) == 1)
cat("Datatran: schema uniforme em todos os anos\n")

# Infrações
schemas_in <- map(dir_ls("dados/consolidados/infracoes", glob = "*.parquet"),
                  \(f) names(read_parquet(f, as_data_frame = FALSE)$schema))
stopifnot(length(unique(schemas_in)) == 1)
cat("Infrações: schema uniforme em todos os anos\n")
```

- [ ] **Step 2: Verificar tamanho máximo por arquivo**

```r
todos_parquets <- c(
  dir_ls("dados/consolidados/acidentes",  glob = "*.parquet"),
  dir_ls("dados/consolidados/datatran",   glob = "*.parquet"),
  dir_ls("dados/consolidados/infracoes",  glob = "*.parquet")
)

tamanhos <- file.size(todos_parquets) / 1e6
cat("Maior arquivo:", round(max(tamanhos), 1), "MB\n")
cat("Média:", round(mean(tamanhos), 1), "MB\n")
stopifnot(max(tamanhos) < 15)   # critério do spec: < 15 MB
cat("Todos os arquivos dentro do limite de 15 MB\n")
```

- [ ] **Step 3: Confirmar critérios de sucesso do spec**

```r
# Leitura de um Parquet retorna tibble com tipos corretos sem conversão manual
df_ac <- read_parquet("dados/consolidados/acidentes/acidentes_2023.parquet")
df_dt <- read_parquet("dados/consolidados/datatran/datatran_2023.parquet")
df_in <- read_parquet("dados/consolidados/infracoes/infracoes_2023.parquet")

stopifnot(inherits(df_ac, "data.frame"))
stopifnot(inherits(df_ac$data_inversa, "Date"))
stopifnot(inherits(df_dt$data_inversa, "Date"))
stopifnot(inherits(df_in$dat_infracao, "Date"))
stopifnot(inherits(df_in$data_inicio_vigencia, "Date"))

cat("Verificação final: PASSOU\n")
cat("Acidentes 2023:", nrow(df_ac), "linhas x", ncol(df_ac), "colunas\n")
cat("Datatran 2023:", nrow(df_dt), "linhas x", ncol(df_dt), "colunas\n")
cat("Infrações 2023:", nrow(df_in), "linhas x", ncol(df_in), "colunas\n")
```
