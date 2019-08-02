#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Pone los campos que hacen falta en las tablas correspondientes, para cada base.

*** Este script puede usuarse para crear los campos adicionales o quitarlos.


Usage:

  rails r tools/atributos_adicionales.rb -d create    #para crear los campos adicionales en todas las bases
  rails r tools/atributos_adicionales.rb -d drop      #para borrar los campos adicionales en todas las bases

  rails r tools/atributos_adicionales.rb -d create 03-Hongos-Sept14    #para crear los campos adicionales en un conjunto de bases
  rails r tools/atributos_adicionales.rb -d drop 03-Hongos-Sept14      #para borrar los campos adicionales en un conjunto de bases
where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

@campos = {
    'especies' =>
        {
            'nombre_cientifico' =>  'varchar(255) NULL,',
            'ancestry_ascendente_directo' => 'varchar(255) NULL,',
            'ancestry_ascendente_obligatorio' => 'varchar(255) NULL,'
        },
    'regiones' =>
        {
            'ancestry' => 'varchar(255) NULL,',
        }
}

def accion_a_campos(accion)
  @campos.each do |tabla, campos|
    query = ''

    if accion == 'create'
      Rails.logger.debug 'Ejecutando con argumento: create' if OPTS[:debug]
      query+= "ALTER TABLE #{Bases::EQUIVALENCIA[tabla]} ADD "

      campos.each do |campo, valor|
        query+= "#{campo} #{valor}"
      end
    else
      Rails.logger.debug 'Ejecutando con argumento: drop' if OPTS[:debug]
      query+= "ALTER TABLE #{Bases::EQUIVALENCIA[tabla]} DROP COLUMN "

      campos.each do |campo, valor|
        query+= "#{campo},"
      end
    end

    Bases.ejecuta query[0..-2]
    Rails.logger.debug "Query: #{query[0..-2]}" if OPTS[:debug]
  end
end

start_time = Time.now

acciones = %w(create drop)                #posibles acciones
if ARGV.any? && acciones.include?(ARGV[0].downcase)
  if ARGV.count > 1
    ARGV.each_with_index do |base, index|
      next if index == 0
      if CONFIG.bases.include?(base)
        Bases.conecta_a base
        Rails.logger.debug "Con base: #{base}" if OPTS[:debug]
        accion_a_campos(ARGV[0].downcase)
      end
    end
  elsif ARGV.count == 1
    CONFIG.bases.each do |base|
      Bases.conecta_a base
      Rails.logger.debug "Con base: #{base}" if OPTS[:debug]
      accion_a_campos(ARGV[0].downcase)
    end
  end
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]