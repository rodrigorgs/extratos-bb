#!/usr/bin/env ruby
# encoding: UTF-8

require 'watir'
require 'watir-webdriver'
require 'io/console'

class Watir::Element
  def wait_and_click
    self.wait_until_present
    self.click
  end
end

class Watir::Browser
  def entra_bb(agencia, conta, senha)
    self.goto 'http://www.bb.com.br'
    self.text_field(name: 'dependenciaOrigem').set agencia
    self.text_field(name: 'numeroContratoOrigem').set conta
    self.a(title: 'Entrar').click

    self.text_field(name: 'senhaConta').wait_until_present
    self.text_field(name: 'senhaConta').set senha
    self.button(id: 'botaoEntrar').click
  end

  def abre_opcao_na_busca_rapida(busca)
    self.text_field(name: 'inpAcheFacil').wait_until_present
    self.text_field(name: 'inpAcheFacil').set busca
    self.div(id: 'selAcheFacil').wait_until_present
    self.a(id: 'link0').click
  end

  def salva_fatura_cartao(mes='Set/13')
    self.abre_opcao_na_busca_rapida('extrato fatura cart')
    self.img(class: 'carousel-center').wait_until_present
    self.img(class: 'carousel-center').click
    self.a(text: mes).wait_until_present
    self.a(text: mes).click
    self.img(id: 'salvarTXT').wait_until_present
    self.img(id: 'salvarTXT').click
  end

  def salva_extrato_conta(mes='Set/13')
    self.abre_opcao_na_busca_rapida('extrato conta corrente')
    self.element(css: '.ui-tabs-paging-prev > a').wait_and_click
    self.a(text: mes).wait_and_click
    self.element(title: 'salvar extrato').wait_and_click
    self.element(text: 'csv').wait_and_click
  end

  def salva_pagamentos(data_inicial, data_final)
    self.abre_opcao_na_busca_rapida('pagamentos 2 via de comprovantes')
    self.text_field(name: 'dataInicial').set data_inicial
    self.text_field(name: 'dataFinal').set data_final
    self.input(id: 'botaoContinua1').click
    self.checkboxes(name: 'opcao').each do |checkbox|
      checkbox.set
    end
    self.input(id: 'botaoContinua2').click
    self.input(id: 'botaoSalvarComprovante').click
    self.li(text: 'txt').wait_and_click
  end

  def salva_poupanca(mes, variacao)
    self.abre_opcao_na_busca_rapida('extrato consulta poupanca')
    self.select_list(id: 'variacao').select /#{variacao}/
    self.element(css: '.ui-tabs-paging-prev > a').wait_and_click
    self.a(text: mes).wait_and_click
    self.element(title: 'salvar extrato').wait_and_click
    self.element(text: 'csv').wait_and_click
  end
end

def novo_navegador
  download_directory = "#{Dir.pwd}/downloads"
  FileUtils.mkdir(download_directory) unless File.exist?(download_directory)
  download_directory.gsub!("/", "\\") if Selenium::WebDriver::Platform.windows?
   
  profile = Selenium::WebDriver::Firefox::Profile.new
  #profile['browser.download.folderList'] = 2 # custom location
  profile['download.prompt_for_download'] = false
  profile['browser.download.dir'] = download_directory
  #profile['browser.helperApps.neverAsk.saveToDisk'] = "text/csv,application/pdf,*"

  return Watir::Browser.new :firefox, :profile => profile
end

print "Agencia: "
@agencia = gets.strip

print "Conta: "
@conta = gets.strip

print "Senha: "
@senha = STDIN.noecho(&:gets).strip
puts
 
@browser = novo_navegador
@browser.entra_bb(@agencia, @conta, @senha)
@browser.salva_fatura_cartao('Set/13')
@browser.salva_extrato_conta('Set/13')
@browser.salva_pagamentos('01/09/2013', '31/09/2013')
@browser.salva_poupanca('Set/13', '01')
@browser.salva_poupanca('Set/13', '51')
