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
  puts "Termine jalar cosos de la BD, tarde: "+(Time.now-@start).to_s+" segundos =S: "

  File.open('eval_eco_optimo_vertebrados.txt', "a+") do |f|

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

      print "Escribiendo linea: #{n}... "

      f.puts eval(p.naturalista_obs).flatten[0]["taxon"]["name"].inspect+"\t"+
                 p.nombre_cientifico.inspect+"\t"+
                 p.catalogo_id.inspect+"\t"+
                 eval(p.naturalista_obs).flatten[0]["latitude"].inspect+"\t"+
                 eval(p.naturalista_obs).flatten[0]["longitude"].inspect+"\t"+
                 eval(p.naturalista_obs).flatten[0]["quality_grade"].inspect+"\t"+
                 eval(p.naturalista_obs).flatten[0]["num_identification_agreements"].inspect+"\t"+
                 eval(p.naturalista_obs).flatten[0]["num_identification_disagreements"].inspect+"\t"+
                 eval(p.naturalista_obs).flatten[0]["captive"].inspect+"\t"+
                 x[0]["nombre_cientifico"].inspect+"\t"+
                 x[1]["nombre_cientifico"].inspect

      puts "  done :D"
      n=n+1
    end
  end
end

@start = Time.now
puts "Empezando en: " + (@start).to_s

hace_magia
puts "Terminamos en: "+(Time.now).to_s
puts"Total: "+(Time.now-@start).to_s+" segundos =S: "