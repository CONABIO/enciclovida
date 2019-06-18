require 'docx'
require 'set'
require 'rubygems'
require 'trollop'


#Variables a utilizar en el codigo
parrafos = Array.new
parrafosSinEspacio = Array.new
estado = ""
buscar = Array.new
p = ""
respuestas = Array.new

#Se inicializa  el objeto doc el cual contiene el archivo .dcox
#en la función open se  proporciona la dirección del archivo
#doc = Docx::Document.open('Documents/Fichas/Plantas/Pueraria montana lobata.docx')
doc = Docx::Document.open('/home/sergiocg/test.docx')

#Se insertan los parrafos del archivo docx en un Array llamado parrafos
doc.paragraphs.each do |p|
  parrafos.append(p.to_s)
end

#Se inicia un parceo del de los arrays para poder manipular secciones del documento
parrafos.each_with_index { |k, i|
  if parrafos[i+1].class == NilClass
    break
  else
    if parrafos[i+1].empty? == true
      if estado.empty? == false
        parrafosSinEspacio.append(estado)
        estado = String.new
      else
        parrafosSinEspacio.append(parrafos[i])
      end
    else
      estado.concat(" ",parrafos[i+1])
    end
  end
}


#Se buscan ciertos campos de y se insertan en un array llamado buscar
parrafosSinEspacio.each do |m|
  if m.include?"Descripción de la especie" or
  m.include?"Distribución original" or
  m.include?"Distribución como exótica en el Mundo Estatus: Exótica presente en México" or
  m.include?"Reporte de invasora" or
  m.include?"Relación con taxones cercanos invasores"
    buscar.append(m)
  end
end

#Se buscan ciertos campos de la parte de respuestas y se insertan en un array llamado respuestas
parrafosSinEspacio.each do |m|
  if m.include?"Relación con taxones cercanos invasores" or m.include?"Reporte de invasora" or m.include?"Vector de otras especies invasoras" or
    m.include?"Impactos sanitarios" or m.include?"Impactos económicos y sociales" or m.include?"Impactos al ecosistema" or m.include?"Impactos a la biodiversidad"
    n = m
    if n.include?"Muy Alto:"
      respuestas.append(n.partition("Muy Alto:").last)
    elsif n.include?"Alto:"
      respuestas.append(n.partition("Alto:").last)
    elsif n.include?"Medio:"
      respuestas.append(n.partition("Medio:").last)
    elsif n.include?"Bajo:"
      respuestas.append(n.partition("Bajo:").last)
    elsif n.include?"Se desconoce."
      respuestas.append(n.partition("Se desconoce.").last)
    elsif n.include?"No:"
      respuestas.append(n.partition("No:").last)
    end
  end
end



#Las siguientes variables almacenan la información a buscar se especifica
#el valor que contiene cada una

parrafos[2] #nombre cientifico
parrafosSinEspacio[3] #primera descripcion va a fespecies.taxon.resumenEspecie
buscar #primeras busquedas
respuestas #seccion respuestas
parrafosSinEspacio.last.split("\n") #referencias refernciabibliografica

OPTS = Trollop::options do
  banner <<-EOS
Hola aqui esta pasando algo


Usage:
  rails r tools/dockParser/newParser.rb

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'

end


v = Validacion.new
v.nombre_cientifico = parrafos[2]
v.encuentra_por_nombre

if v.validacion[:estatus]
  #v.validacion[:taxon][:IdNombre]
  e = Especie.find(v.validacion[:taxon][:IdNombre])
  puts e.scat[:IDCAT]
  f = Fichas::Taxon.where( "IdCAT = ?" , e.scat[:IDCAT]).first
  #f = Fichas::Taxon.where( "IdCAT = ?" , "1370REPTI")
  puts "Valor de F #{f.inspect}"
  #Si encontro nada en fespecies.taxon
  if f
  else
    f = Fichas::Taxon.new
    f.IdCAT =  e.scat[:IDCAT]
    f.distribuciones
    end
end

