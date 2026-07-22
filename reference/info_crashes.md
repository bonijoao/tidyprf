# Variable descriptions for get_crashes()

Variable descriptions for get_crashes()

## Usage

``` r
info_crashes(lang = "en")
```

## Arguments

- lang:

  `"en"` (default) or `"pt"`.

## Value

A tibble with columns `variable`, `type`, `description`.

## Examples

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
