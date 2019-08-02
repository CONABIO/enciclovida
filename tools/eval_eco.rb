require 'rubygems'
require 'trollop'


OPTS = Trollop::options do
  banner <<-EOS
Corre las consultas necesarias para generar las asociaciones que pide vcontreras

Usage:

  rails r tools/eval_eco.rb -d              #Corre los scripts

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

@start

def dame_relacion_naturalista
  Especie.select("especies.id",:ancestry_ascendente_obligatorio, :nombre_cientifico, :categoria_taxonomica_id, :catalogo_id, :naturalista_obs).categoria_taxonomica_join.joins('left join proveedores on especies.id = especie_id').where("naturalista_obs is not null").where("nivel1 = 7").where("especies.id between 8000000 and 9000000")
end

def hace_magia
  n=1
  relacion = dame_relacion_naturalista
  Rails.logger.debug "Jalando cosos de la BD: "+(Time.now-@start).to_s+ " =S: "

  File.open('eval_eco_optimo_vertebrados_observaciones.txt', "a+") do |f|

    f.puts '"Nombre de la ssp Naturalista (taxon[name])"'+"\t"+
               '"Nombre válido de la spp con base en Catálogos de Autoridades Taxonómicas"'+"\t"+
               '"IDCAT"'+"\t"+
               '"Latitud"'+"\t"+
               '"Longitud"'+"\t"+
               '"Research?"'+"\t"+
               '"Identificaciones en acuerdo"'+"\t"+
               '"Identificaciones en desacuerdo"'+"\t"+
               '"Es captiva/cultivada"'+"\t"+
               '"clase"'+"\t"+
               '"género"'

    relacion.find_each do |p|
      x = Especie.select("especies.id", :nombre_cientifico, :categoria_taxonomica_id, :nombre_categoria_taxonomica, "concat(nivel1,nivel2,nivel3,nivel4) as orden").categoria_taxonomica_join.where("especies.id in (#{p.ancestry_ascendente_obligatorio.gsub('/', ',')})").where("categorias_taxonomicas.nombre_categoria_taxonomica in ('género','clase')").order("orden")

      print "Escribiendo taxón num: #{n} (#{p.id}) ... con "
      m=1
      eval(p.naturalista_obs).flatten.each do |h|

        print " #{m}, "

        #print "--- #{h.length}"
        #h = h.length==1 ? h.first : h

        f.puts(h["taxon"] ? h["taxon"]["name"] : (h["species_guess"] ? h["species_guess"] : p.nombre_cientifico)).inspect+"\t"+
                   p.nombre_cientifico.inspect+"\t"+
                   p.catalogo_id.inspect+"\t"+
                   h["latitude"].inspect+"\t"+
                   h["longitude"].inspect+"\t"+
                   h["quality_grade"].inspect+"\t"+
                   h["num_identification_agreements"].inspect+"\t"+
                   h["num_identification_disagreements"].inspect+"\t"+
                   h["captive"].inspect+"\t"+
                   x[0]["nombre_cientifico"].inspect+"\t"+
                   x[1]["nombre_cientifico"].inspect
        m=m+1
      end
      print "observaciones totales."
      n=n+1
    end
  end
end

@start = Time.now
Rails.logger.debug "Empezando en: " + (@start).to_s

hace_magia
Rails.logger.debug "Terminamos en: "+(Time.now).to_s
Rails.logger.debug"Total: "+(Time.now-@start).to_s+" segundos =S: "