#!/usr/bin/env ruby
# encoding: UTF-8

require 'watir'
require 'watir-webdriver'
require 'io/console'
require_relative 'wait-until-new-file'

class Watir::Element
  def wait_and_click
    self.wait_until_present
    self.click
  end
end

BB_MESES = {
  '01' => 'Jan',
  '02' => 'Fev',
  '03' => 'Mar',
  '04' => 'Abr',
  '05' => 'Mai',
  '06' => 'Jun',
  '07' => 'Jul',
  '08' => 'Ago',
  '09' => 'Set',
  '10' => 'Out',
  '11' => 'Nov',
  '12' => 'Dez',
}

class BancoBrasil
  attr_reader :agencia, :conta, :download_directory, :browser

  def initialize(agencia, conta, download_directory="#{Dir.pwd}/downloads", browser=nil)
    @agencia = agencia
    @conta = conta.upcase
    @download_directory = download_directory

    FileUtils.mkdir(@download_directory) unless File.exist?(@download_directory)
    @download_directory.gsub!("/", "\\") if Selenium::WebDriver::Platform.windows?
    
    if (browser.nil?)
      profile = Selenium::WebDriver::Firefox::Profile.new
      profile['download.prompt_for_download'] = false
      profile['browser.download.dir'] = @download_directory
      profile['browser.download.folderList'] = 2 # custom location
      profile['browser.helperApps.neverAsk.saveToDisk'] = "text/csv,text/plain"

      browser = Watir::Browser.new :firefox, :profile => profile
    end
    @browser = browser
  end

  def rename_downloaded_file_to(filename, &block)
    path = File.join(@download_directory, "#{@agencia}__#{@conta}__#{filename}")
    if !File.exist?(path)
      wait_file_and_rename_to("#{@agencia}__#{@conta}__#{filename}", directory: @download_directory, &block)
    end
  end

  def renomeia_mes_para_aba(mes)
    # 2013-10
    return "#{BB_MESES[mes[5..6]]}/#{mes[2..3]}"
  end

  def entra(senha)
    @browser.goto 'http://www.bb.com.br'
    @browser.text_field(name: 'dependenciaOrigem').set @agencia
    @browser.text_field(name: 'numeroContratoOrigem').set @conta
    @browser.a(title: 'Entrar').click

    @browser.text_field(name: 'senhaConta').wait_until_present
    @browser.text_field(name: 'senhaConta').set senha
    @browser.button(id: 'botaoEntrar').click
  end

  def abre_opcao_na_busca_rapida(busca)
    @browser.text_field(name: 'inpAcheFacil').wait_until_present
    @browser.text_field(name: 'inpAcheFacil').set busca
    @browser.div(id: 'selAcheFacil').wait_until_present
    @browser.a(id: 'link0').click
  end

  def salva_fatura_cartao(mes)
    rename_downloaded_file_to "#{mes}__cartao.txt" do
      abre_opcao_na_busca_rapida('extrato fatura cart')
      @browser.img(class: 'carousel-center').wait_until_present
      @browser.img(class: 'carousel-center').click
      @browser.a(text: renomeia_mes_para_aba(mes)).wait_and_click
      @browser.img(id: 'salvarTXT').wait_and_click
    end
  end

  def salva_conta(mes)
    rename_downloaded_file_to "#{mes}__conta.csv" do
      abre_opcao_na_busca_rapida('extrato conta corrente')
      @browser.element(css: '.ui-tabs-paging-prev > a').wait_and_click
      @browser.a(text: renomeia_mes_para_aba(mes)).wait_and_click
      @browser.element(title: 'salvar extrato').wait_and_click
      @browser.element(text: 'csv').wait_and_click
    end
  end

  def salva_pagamentos(mes)
    data_inicial = "01/#{mes[5..6]}/#{mes[0..3]}"
    data_final = "31/#{mes[5..6]}/#{mes[0..3]}"
    
    rename_downloaded_file_to "#{mes}__pagamentos.txt" do
      abre_opcao_na_busca_rapida('pagamentos 2 via de comprovantes')
      @browser.text_field(name: 'dataInicial').set data_inicial
      @browser.text_field(name: 'dataFinal').set data_final
      @browser.input(id: 'botaoContinua1').click
      @browser.checkboxes(name: 'opcao').each { |checkbox| checkbox.set }
      @browser.input(id: 'botaoContinua2').click
      @browser.input(id: 'botaoSalvarComprovante').click
      @browser.li(text: 'txt').wait_and_click
    end
  end

  def salva_poupanca(mes, variacao)
    rename_downloaded_file_to "#{mes}__poupanca-#{variacao}.csv" do
      abre_opcao_na_busca_rapida('extrato consulta poupanca')
      @browser.select_list(id: 'variacao').select /#{variacao}/
      @browser.element(css: '.ui-tabs-paging-prev > a').wait_and_click
      @browser.a(text: renomeia_mes_para_aba(mes)).wait_and_click
      @browser.element(title: 'salvar extrato').wait_and_click
      @browser.element(text: 'csv').wait_and_click
    end
  end

  def sai
    @browser.a(class: 'sair').click
    @browser.close
  end

  def salva_tudo(mes)
    salva_conta mes
    salva_poupanca mes, '01'
    salva_poupanca mes, '51'
    salva_fatura_cartao mes
    salva_pagamentos mes
  end
end

#############################################################################

if __FILE__ == $0
  @agencia = ENV['AGENCIA']
  @conta = ENV['CONTA']

  if !@agencia
    print "Agencia: "
    @agencia = gets.strip
  end

  if !@conta
    print "Conta: "
    @conta = gets.strip
  end

  print "Senha da Internet: "
  @senha = STDIN.noecho(&:gets).strip
  puts

  print "Mes (ex.: 2013-09): "
  mes = gets.strip

  @bb = BancoBrasil.new(@agencia, @conta)
  @bb.entra(@senha)
  @bb.salva_tudo mes
  @bb.sai
end