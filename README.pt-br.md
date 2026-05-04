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
