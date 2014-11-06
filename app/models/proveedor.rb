class Proveedor < ActiveRecord::Base
  belongs_to :especie

  # Saca los nombres comunes del campo naturalista_info
  def nombres_comunes
    datos = eval(naturalista_info)
    datos = datos.first if datos.is_a?(Array)
    return [] unless datos['taxon_names'].present?
    nombres_comunes_faltan = []

    # Nombres comunes de la base de catalogos
    nom_comunes = especie.nombres_comunes
    nom_comunes = nom_comunes.map(&:nombre_comun).map{ |nom| I18n.transliterate(nom).downcase }.sort if nom_comunes

    datos['taxon_names'].each do |datos_nombres|
      next unless datos_nombres['is_valid']
      next if datos_nombres['lexicon'] == 'Scientific Names'

      # Nombre comun de NaturaLista
      nombre = I18n.transliterate(datos_nombres['name']).downcase
      lengua = datos_nombres['lexicon']

      if nom_comunes.present?
        next if nom_comunes.include?(nombre)
      end
      nombres_comunes_faltan << "#{especie.id},\"#{datos_nombres['name']}\",#{lengua},#{especie.nombre_cientifico},#{especie.categoria_taxonomica.nombre_categoria_taxonomica}"
    end

    nombres_comunes_faltan
  end
end
