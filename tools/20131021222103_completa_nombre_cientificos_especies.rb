class CompletaNombreCientificosEspecies < ActiveRecord::Migration
  def up
    Especie.all.each do |taxon|
      if taxon.depth == 7
        generoID=taxon.ancestry_acendente_obligatorio.split("/")[5]
        genero=Especie.find(generoID).nombre
        taxon.nombre_cientifico="#{genero} #{taxon.nombre}"
      elsif taxon.depth == 8
        generoID=taxon.ancestry_acendente_obligatorio.split("/")[5]
        genero=Especie.find(generoID).nombre
        especieID=taxon.ancestry_acendente_obligatorio.split("/")[6]
        especie=Especie.find(especieID).nombre
        taxon.nombre_cientifico="#{genero} #{especie} #{taxon.nombre}"
      else
        taxon.nombre_cientifico="#{taxon.nombre}"
      end
      taxon.save
    end
  end
end
