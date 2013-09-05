module EspeciesHelper
  def enlacesDeTaxonomia(taxa)
    enlaces ||=''
    taxa.ancestor_ids.push(taxa.id).each do |a|
      e=Especie.find(a)
      enlaces+="#{link_to(e.nombre, e)} (#{e.categoria_taxonomica.nombre_categoria_taxonomica}) > "
    end
    enlaces[0..-3].html_safe
  end
end
