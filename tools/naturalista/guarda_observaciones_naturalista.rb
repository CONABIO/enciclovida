OPTS = Trollop::options do
  banner <<-EOS
Guarda en disco las observaciones de naturalista en .json, .kml y .kmz

*** Este script se debería correr solo una vez, ya que el cache_services lo actualizará paulatianmente

Usage:

rails r tools/guarda_observaciones_naturalista.rb -d 1000000 2000000

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def guarda_observaciones(lim_inf = nil, lim_sup = nil)
  Especie.find_each do |taxon|
    next if lim_inf.present? && taxon.id < lim_inf
    next if lim_sup.present? && taxon.id > lim_sup
    #next unless taxon.especie_o_inferior?
    Rails.logger.debug "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]

    if p = taxon.proveedor
      p.guarda_observaciones_naturalista
    end
  end
end


start_time = Time.now

guarda_observaciones(ARGV[0].to_i, ARGV[1].to_i)

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
