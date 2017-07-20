OPTS = Trollop::options do
  banner <<-EOS
Guarda en disco las observaciones de naturalista en .json, .kml y .kmz

*** Este script se debería correr solo una vez, ya que el cache_services lo actualizará paulatianmente

Usage:

rails r tools/guarda_observaciones_naturalista.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def guarda_observaciones
  Especie.find_each do |taxon|
    #next if taxon.id < 8003302
    #next unless taxon.species_or_lower?
    puts "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]

    if p = taxon.proveedor
      p.guarda_observaciones_naturalista
    end
  end
end


start_time = Time.now

guarda_observaciones

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
