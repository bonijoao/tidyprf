# Getting started with tidyprf

The Brazilian Federal Highway Police (Polícia Rodoviária Federal, PRF)
publishes open data on traffic accidents and traffic violations on
federal highways. **tidyprf** gives you these datasets directly in R,
already cleaned and consolidated, with a consistent schema across all
years.

``` r

library(tidyprf)
```

## The three datasets

| Dataset | Function | Unit | Available years |
|----|----|----|----|
| Accidents by person | [`get_accidents()`](https://bonijoao.github.io/tidyprf/reference/get_accidents.md) | 1 row per person involved | 2007–2026 |
| Accidents by occurrence | [`get_crashes()`](https://bonijoao.github.io/tidyprf/reference/get_crashes.md) | 1 row per accident | 2007–2026 |
| Traffic violations | [`get_violations()`](https://bonijoao.github.io/tidyprf/reference/get_violations.md) | 1 row per violation | 2019–2020, 2022–2026 |

Data are stored as one Parquet file per dataset per year, hosted on
GitHub Releases. The first time you request a year, the file is
downloaded and cached locally (in
`tools::R_user_dir("tidyprf", "cache")`); subsequent calls read from the
cache and require no internet connection.

## Downloading data

All chunks in this section require an internet connection, so they are
not evaluated when the vignette is built.

Fetch all accident occurrences from 2023:

``` r

crashes_2023 <- get_crashes(2023)
crashes_2023
```

You can request several years at once and filter by state (`uf`),
federal highway (`br`), and — for accident data — severity:

``` r

# Fatal accidents in São Paulo and Rio de Janeiro, 2020-2023
fatal <- get_crashes(2020:2023, uf = c("SP", "RJ"), severity = "fatal")

# People involved in accidents on the BR-101
people_101 <- get_accidents(2023, br = 101)

# Traffic violations in Minas Gerais
violations_mg <- get_violations(2024, uf = "MG")
```

To see which years are available (and how large each file is) without
downloading anything:

``` r

prf_years()
```

## Understanding the variables

Each dataset has a bilingual codebook available offline. This runs
without internet:

``` r

info_crashes()
#> # A tibble: 31 × 3
#>    variable       type  description             
#>    <chr>          <chr> <chr>                   
#>  1 id             int   Accident identifier     
#>  2 data_inversa   date  Accident date           
#>  3 dia_semana     chr   Day of week             
#>  4 horario        chr   Time of accident        
#>  5 uf             chr   State (UF)              
#>  6 br             int   Federal highway number  
#>  7 km             dbl   Highway kilometer marker
#>  8 municipio      chr   Municipality            
#>  9 causa_acidente chr   Accident cause          
#> 10 tipo_acidente  chr   Accident type           
#> # ℹ 21 more rows
```

Use `lang = "pt"` for descriptions in Portuguese:

``` r

head(info_violations(lang = "pt"))
#> # A tibble: 6 × 3
#>   variable                type  description                     
#>   <chr>                   <chr> <chr>                           
#> 1 numero_auto             chr   Número do auto de infração      
#> 2 dat_infracao            date  Data da infração                
#> 3 tip_abordagem           chr   Tipo de abordagem               
#> 4 ind_assinou_auto        chr   Indicador de assinatura do auto 
#> 5 ind_veiculo_estrangeiro chr   Indicador de veículo estrangeiro
#> 6 ind_sentido_trafego     chr   Sentido do tráfego
```

The full codebook is also available as a data object:

``` r

str(codebook)
#> tibble [97 × 5] (S3: tbl_df/tbl/data.frame)
#>  $ dataset       : chr [1:97] "accidents" "accidents" "accidents" "accidents" ...
#>  $ variable      : chr [1:97] "id" "pesid" "data_inversa" "dia_semana" ...
#>  $ type          : chr [1:97] "int" "int" "date" "chr" ...
#>  $ description_en: chr [1:97] "Record identifier" "Person identifier" "Accident date" "Day of week" ...
#>  $ description_pt: chr [1:97] "Identificador do registro" "Identificador da pessoa" "Data do acidente" "Dia da semana" ...
```

## Managing the cache

``` r

prf_cache()
#> # A tibble: 0 × 4
#> # ℹ 4 variables: dataset <chr>, year <int>, size_mb <dbl>, cached_at <date>
```

[`prf_cache()`](https://bonijoao.github.io/tidyprf/reference/prf_cache.md)
lists the files currently cached;
[`prf_cache_clear()`](https://bonijoao.github.io/tidyprf/reference/prf_cache_clear.md)
removes them (all of them, or a specific dataset/year):

``` r

prf_cache_clear("violations", year = 2024)
prf_cache_clear()  # everything
```

## Data sources

Raw data are published by the PRF on the [federal government open data
portal](https://www.gov.br/prf/pt-br/acesso-a-informacao/dados-abertos/dados-abertos-da-prf).
The consolidation pipeline (raw CSV to Parquet, schema unification
across years) is maintained at
[bonijoao/tidyprf-dados](https://github.com/bonijoao/tidyprf-dados).
