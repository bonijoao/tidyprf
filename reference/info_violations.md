# Variable descriptions for get_violations()

Variable descriptions for get_violations()

## Usage

``` r
info_violations(lang = "en")
```

## Arguments

- lang:

  `"en"` (default) or `"pt"`.

## Value

A tibble with columns `variable`, `type`, `description`.

## Examples

``` r
info_violations(lang = "pt")
#> # A tibble: 26 × 3
#>    variable                type  description                     
#>    <chr>                   <chr> <chr>                           
#>  1 numero_auto             chr   Número do auto de infração      
#>  2 dat_infracao            date  Data da infração                
#>  3 tip_abordagem           chr   Tipo de abordagem               
#>  4 ind_assinou_auto        chr   Indicador de assinatura do auto 
#>  5 ind_veiculo_estrangeiro chr   Indicador de veículo estrangeiro
#>  6 ind_sentido_trafego     chr   Sentido do tráfego              
#>  7 uf_placa                chr   UF da placa do veículo          
#>  8 uf_infracao             chr   UF da infração                  
#>  9 num_br_infracao         int   Número da BR                    
#> 10 num_km_infracao         dbl   Quilômetro da infração          
#> # ℹ 16 more rows
```
