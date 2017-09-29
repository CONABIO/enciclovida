require 'rubygems'
require 'trollop'
# ************************OJO los metodos de este archivo cambiaron********************************
OPTS = Trollop::options do
  banner <<-EOS
Exporta a un archivo .csv los nombres comunes que no son de catalogos, i.e.
los que vienen de NaturaLista y se han metido desde EncicloVida.


Usage:

  rails r tools/nombres_comunes_dist_a_cat.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def datos
  puts 'Procesando los taxones...' if OPTS[:debug]

  Adicional.where('nombre_comun_principal IS NOT NULL').find_each do |ad|
    # Evita los taxones que ya no estan asociados
    next unless taxon = ad.especie

    nombre_comun_principal_original = ad.nombre_comun_principal

    puts "#{ad.especie_id}-#{nombre_comun_principal_original}" if OPTS[:debug]

    # El nombre comun en catalogos
    ad.nombre_comun_principal_catalogos
    nombre_comun_principal_catalogos = ad.nombre_comun_principal

    # Si es el de catalogos entonces no se manda
    next if nombre_comun_principal_original == nombre_comun_principal_catalogos

    # El nombre comun en NaturaLista
    ad.nombre_comun_principal_naturalista
    nombre_comun_principal_naturalista = ad.nombre_comun_principal

    # Se mete a la bitacora
    if nombre_comun_principal_original == nombre_comun_principal_naturalista
      @bitacora.puts "#{taxon.catalogo_id}\t#{nombre_comun_principal_naturalista}\tNaturaLista"
    else  # Vienen de enciclovida
      @bitacora.puts "#{taxon.catalogo_id}\t#{nombre_comun_principal_original}\tEncicloVida"
    end
  end
end

def creando_carpeta
  puts "Creando carpeta \"#{@path}\" si es que no existe..." if OPTS[:debug]
  FileUtils.mkpath(@path, :mode => 0755) unless File.exists?(@path)
end

def bitacoras
  puts 'Iniciando bitacoras ...' if OPTS[:debug]
  @bitacora = File.new("#{@path}/#{Time.now.strftime("%Y_%m_%d_%H-%M-%S")}_nombres_comunes.csv", 'w:UTF-8')
  @bitacora.puts "IdCAT\tNombreComun\tReferencia"
end


start_time = Time.now

@path = 'tools/bitacoras/nombres_comunes_dist_a_cat'
creando_carpeta
bitacoras
datos
@bitacora.close

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]