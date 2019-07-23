#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Llena los campos icono y nombre_icono.

*** Este script debe usuarse cada vez que se cree el volcado.


Usage:

  rails r tools/grupos_iconicos.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


start_time = Time.now

Busqueda.asigna_grupo_iconico

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]