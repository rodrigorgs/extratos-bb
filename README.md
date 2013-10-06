Salva extratos de meses anteriores de uma conta do Banco do Brasil.

## Requisitos

* [Ruby](https://www.ruby-lang.org/) 1.9.3 ou superior
* [Bundler](http://bundler.io/)
* Navegador [Mozilla Firefox](http://www.mozilla.org/firefox)
* Você deve conseguir acessar o Banco do Brasil usando o Firefox.

## Instalação

Abra um terminal na pasta onde o script está localizado e execute

    bundle install

## Execução

Execute o script `banco-go.rb`.

Informe sua agência (no formato `1234-5`), conta (no formato `9876-5`), sua senha de 8 dígitos e o mês do qual serão baixados os extratos (no formato `2013-09`).

O script vai abrir uma janela do Firefox e navegar pelo site do Banco do Brasil, salvando os extratos na pasta "downloads", criada dentro da pasta de onde você executou o script.

## Observações

Atualmente o script só funciona para meses recentes e anteriores ao atual.