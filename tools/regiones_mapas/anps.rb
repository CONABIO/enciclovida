OPTS = Trollop::options do
  banner <<-EOS
Importa a la base las Áreas Naturales Protegidas

*** Este script solo es necesario correrlo una vez para generar las ANPs

Usage:

  rails r tools/regiones_mapas/anps.rb

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


def guarda_anp(linea)
  @datos = linea.gsub("\"", '').split("\t")
  @reg = RegionMapa.new
  @reg.nombre_region = @datos[1]
  @reg.geo_id = @datos[22]
  @reg.tipo_region = 'ANP'

  if @datos[15].blank?
    puts "El campo de municipio esta vacio: #{@datos[22]}"
    return
  end

  # Puede tener asociado muchos municipios
  @datos[15].strip.split(',').each do |mun|
    @municipios = RegionMapa.where(nombre_region: mun.strip, tipo_region: 'municipio')

    if @municipios.blank?
      mun_y = mun.strip.split(' y ')

      mun_y.each do |m|
        @municipios = RegionMapa.where(nombre_region: m, tipo_region: 'municipio')

        if @municipios.blank?
          puts "No coincidio ningún municipio: #{@datos[22]} - #{mun}"
          break
        end

        coincide_mun?
      end
    else
      coincide_mun?
    end

  end
end

def coincide_mun?
  @municipios.each do |m|
    if m.parent.nombre_region == @datos[4]  # Ver si coinciden los estados
      reg_clon = @reg.clone
      reg_clon.ancestry = m.path_ids.join('/')
      reg_clon.save
      puts "encontro sin problema: #{reg_clon.inspect} - #{@reg.nombre_region}"
      break
    else
      if @municipios.length == 1  # Si fue un municipio el de la base entonces que lo asigne
        reg_clon = @reg.clone
        reg_clon.ancestry = m.path_ids.join('/')
        reg_clon.save
        puts "encontro con otro estado #{reg_clon.inspect} - orig: #{@datos[4]}, base: #{m.parent.nombre_region}"
        break
      else
        puts "Encontró municipio, más no coincidio con el estado, - #{@reg.nombre_region}, orig: #{@datos[4]}, base: #{m.parent.nombre_region}"
      end

    end
  end
end

def lee_archivo
  num_linea = 0

  archivo = 'tools/regiones_mapas/anp.txt'
  f = File.open(archivo, 'r').read

  f.each_line do |linea|
    num_linea+=1
    next if num_linea == 1
    guarda_anp(linea)
  end
end


start_time = Time.now

lee_archivo

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]