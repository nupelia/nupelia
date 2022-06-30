
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nupelia

<!-- badges: start -->
<!-- badges: end -->

Pacote de auxílio para relatórios do PELD

## Instalação

Você pode instalar esse pacote pelo github utilizando o código:

``` r
# install.packages("devtools")
devtools::install_github("Nupelia/nupelia")
```

## Uso

## Funções PELD

Antes de começar, é necessário ter o arquivo de uma tabela do PELD com o
seguinte formato:

**(É necessário que o nome das colunas seja escrito dessa forma)**

| especie                   | lab | lfe | rio |
|:--------------------------|----:|----:|----:|
| Acestrorhynchus lacustris |   7 |     |   5 |
| Aequidens plagiozonatus   |   2 |   2 |     |
| Ageneiosus inermis        |   8 |     |   7 |
| Ageneiosus ucayalensis    |   3 |     |     |
| Astyanax lacustris        |  16 |  38 |  12 |

### Função `peld_abrevia_especie()`

Essa função tem como objetivo abreviar o gênero em nomes científicos
para facilitar a leitura posterior. Caso os nomes abreviados fiquem
idênticos (como A. lacustris para Acestrorhynchus lacustris e Astyanax
lacustris, por exemplo), são utilizadas as 3 primeiras letras do gênero.

A tabela apresentada acima ficaria da seguinte forma:

``` r
tabela_peld_exemplo %>% 
  peld_abrevia_especie()
```

| especie          | lab | lfe | rio |
|:-----------------|----:|----:|----:|
| Ace. lacustris   |   7 |     |   5 |
| A. plagiozonatus |   2 |   2 |     |
| A. inermis       |   8 |     |   7 |
| A. ucayalensis   |   3 |     |     |
| Ast. lacustris   |  16 |  38 |  12 |

### Função `peld_abund_rel()`

Essa função permite calcular a abundância relativa de espécies, seja
considerando todos os subsistemas ou algum em específico

Existem alguns argumento nessa função:

-   `dados`: A tabela de dados
-   `subsistema`: O subsistema indicado para análise. Pode ser “lab”,
    “lfe”, “rio” ou “geral” caso seja para todos. O padrão é “geral”.
-   `top_n`: O número de espécies a serem apresentadas, além disso serão
    consideradas como **“Outros”**. O padrão é 14.

``` r
tabela_peld_exemplo %>% 
  peld_abrevia_especie() %>% 
  peld_abund_rel(top_n = 3)
```

| especie        | total_sp | total_geral | rank | abund_rel |
|:---------------|---------:|------------:|-----:|----------:|
| Ast. lacustris |       66 |         100 |    1 |      0.66 |
| A. inermis     |       15 |         100 |    2 |      0.15 |
| Ace. lacustris |       12 |         100 |    3 |      0.12 |
| Outros         |        7 |         100 |    4 |      0.07 |

Caso queira fazer para um subsistema específico, utilize o argumento
`subsistema`:

``` r
tabela_peld_exemplo %>% 
  peld_abrevia_especie() %>% 
  peld_abund_rel(subsistema = "lab", top_n = 3)
```

| especie        | subsistema | total_sp | total_geral | rank | abund_rel |
|:---------------|:-----------|---------:|------------:|-----:|----------:|
| Ast. lacustris | lab        |       16 |          36 |    1 | 0.4444444 |
| A. inermis     | lab        |        8 |          36 |    2 | 0.2222222 |
| Ace. lacustris | lab        |        7 |          36 |    3 | 0.1944444 |
| Outros         | lab        |        5 |          36 |    4 | 0.1388889 |

### Função `peld_riqueza()`

Utilize essa função para calcular a riqueza (S) em cada subsistema.

``` r
tabela_peld_exemplo %>% 
  peld_abrevia_especie() %>% 
  peld_riqueza()
```

| subsistema | riqueza |
|:-----------|--------:|
| lab        |       5 |
| lfe        |       2 |
| rio        |       3 |

### Função `peld_shannon()`

Essa função retorna o índice de diversidade Shannon (H’) para cada
subsistema.

``` r
tabela_peld_exemplo %>% 
  peld_abrevia_especie() %>% 
  peld_shannon()
```

| subsistema |   shannon |
|:-----------|----------:|
| lab        | 1.3807285 |
| lfe        | 0.1985152 |
| rio        | 1.0327438 |

### Função `peld_equitabilidade()`

Também é possível calcular o índice de Equitabilidade de Pielou (J’)
para cada subsistema.

``` r
tabela_peld_exemplo %>% 
  peld_abrevia_especie() %>% 
  peld_equitabilidade()
```

| subsistema |     equit |
|:-----------|----------:|
| lab        | 0.3852996 |
| lfe        | 0.0538145 |
| rio        | 0.3249611 |
