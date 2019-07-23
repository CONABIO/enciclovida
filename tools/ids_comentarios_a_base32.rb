require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Pasa a base 32 los ids de los comentarios

Usage:

  rails r tools/ids_comentarios_a_base32.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


start_time = Time.now

Comentario.find_each do |c|

  # Cambiamos a base 32 el ID
  c.id = c.id.to_i.to_s(32)

  if c.save
    Rails.logger.debug "Guardo ID: #{c.id}" if OPTS[:debug]
  else
    Rails.logger.debug "No guardo ID: #{c.id}" if OPTS[:debug]
  end
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]