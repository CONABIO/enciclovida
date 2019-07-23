require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo ancestry_ascendente_obligatorio.

*** Este script tiene que correrse cada vez que se ingresa una nueva base.


Usage:

  rails r tools/ancestry_ascendente_obligatorio.rb -d
  rails r tools/ancestry_ascendente_obligatorio.rb -d 02-Arthropoda    #para correr solo un conjunto de bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def completa
  EspecieBio.order('Nombre ASC').find_each do |e|
    Rails.logger.debug "#{e.id}-#{e.nombre}" if OPTS[:debug]
    e.ancestry_obligatorio            # no es necesario evitar el ancestry ya que este campo no lo tiene
    e.evita_before_save = true        # evita el metodo before_save
    e.save
  end
end

start_time = Time.now

if ARGV.any?
  ARGV.each do |base|
    if CONFIG.bases.include?(base)
      Bases.conecta_a base
      Rails.logger.debug "Conectando a: #{base}" if OPTS[:debug]
      completa
    end
  end
else
  CONFIG.bases.each do |base|
    Bases.conecta_a base
    completa
  end
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]