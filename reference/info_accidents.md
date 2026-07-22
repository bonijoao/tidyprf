# Variable descriptions for get_accidents()

Variable descriptions for get_accidents()

## Usage

``` r
info_accidents(lang = "en")
```

## Arguments

- lang:

  `"en"` (default) or `"pt"`.

## Value

A tibble with columns `variable`, `type`, `description`.

## Examples

``` r
info_accidents()
#> # A tibble: 40 × 3
#>    variable        type  description             
#>    <chr>           <chr> <chr>                   
#>  1 id              int   Record identifier       
#>  2 pesid           int   Person identifier       
#>  3 data_inversa    date  Accident date           
#>  4 dia_semana      chr   Day of week             
#>  5 horario         chr   Time of accident        
#>  6 uf              chr   State (UF)              
#>  7 br              int   Federal highway number  
#>  8 km              dbl   Highway kilometer marker
#>  9 municipio       chr   Municipality            
#> 10 causa_principal chr   Primary cause (2017+)   
#> # ℹ 30 more rows
info_accidents(lang = "pt")
#> # A tibble: 40 × 3
#>    variable        type  description              
#>    <chr>           <chr> <chr>                    
#>  1 id              int   Identificador do registro
#>  2 pesid           int   Identificador da pessoa  
#>  3 data_inversa    date  Data do acidente         
#>  4 dia_semana      chr   Dia da semana            
#>  5 horario         chr   Horário do acidente      
#>  6 uf              chr   Unidade federativa       
#>  7 br              int   Número da rodovia federal
#>  8 km              dbl   Quilômetro da rodovia    
#>  9 municipio       chr   Município                
#> 10 causa_principal chr   Causa principal (2017+)  
#> # ℹ 30 more rows
```
