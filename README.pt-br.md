# tidyprf <img src="img/logo.png" align="right" height="139" />

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

*[Read in English](README.md)*

O **tidyprf** fornece acesso, a partir do R, aos conjuntos de dados públicos de segurança viária disponibilizados pela Polícia Rodoviária Federal (PRF). Estão incluídos dados de acidentes por pessoa, acidentes por ocorrência e infrações de trânsito.

O pacote permite selecionar o conjunto e o ano desejado, retornando os dados em formato tabular. Os arquivos são distribuídos em formato Parquet por meio do GitHub Releases e armazenados em cache local após o primeiro download.

## Exemplo rápido

Mapeie acidentes fatais por estado brasileiro em 2024:

```r
library(tidyprf)
library(geobr)
library(dplyr)
library(ggplot2)

fatal <- get_crashes(2024, severity = "fatal") |>
  count(uf, name = "acidentes")

read_state(year = 2020, showProgress = FALSE) |>
  left_join(fatal, by = c("abbrev_state" = "uf")) |>
  ggplot() +
  geom_sf(aes(fill = acidentes), color = "white", linewidth = 0.3) +
  scale_fill_distiller(palette = "Reds", direction = 1, name = "Acidentes") +
  labs(title = "Acidentes fatais por estado (2024)") +
  theme_void(base_size = 13) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
```

![](Logo/quick_example.png)

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
