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
