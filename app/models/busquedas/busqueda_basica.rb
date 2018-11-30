class BusquedaBasica < Busqueda

  attr_accessor :fuzzy_match

  # REVISADO: Regresa la busqueda basica
  def resultados_basica
    paginado_y_offset
    estatus
    solo_publicos
    solo_categoria

    return unless por_id_o_nombre

    conteo_por_categoria_taxonomica
    dame_totales
    resultados

    resultados_fuzzy_match if totales == 0 && pagina == 1 && params[:solo_categoria].blank?
  end

  # Devuelve los resultados de una busqueda normal
  def resultados
    self.taxones = taxones.select_basico.order(:nombre_cientifico)
    return if formato == 'xlsx'

    self.taxones = taxones.offset(offset).limit(por_pagina)

    # Si solo escribio un nombre
    if params[:id].blank? && params[:nombre].present?
      taxones.each do |t|
        t.cual_nombre_comun_coincidio(params[:nombre])
      end
    end
  end

  # REVISADO: Si no hubo resultados, tratamos de encontrarlos con el fuzzy match
  def resultados_fuzzy_match
    if Rails.env.development_mac?
      self.taxones = Especie.none
      self.totales = 0
      return
    end

    ids_comun = FUZZY_NOM_COM.find(params[:nombre].strip, limit=CONFIG.limit_fuzzy).map{|n| id_referencia_a_nombre_comun(n.first) }.flatten.compact.uniq
    ids_cientifico = FUZZY_NOM_CIEN.find(params[:nombre].strip, limit=CONFIG.limit_fuzzy).map(&:first).flatten.compact.uniq
    ids_totales = []

    if ids_comun.empty? && ids_cientifico.empty?
      self.taxones = Especie.none
      self.totales = 0
      return
    end

    self.taxones = Especie.left_joins(:categoria_taxonomica, :adicional).select_basico.order(:nombre_cientifico).offset(offset).limit(por_pagina).distinct

    if ids_comun.any? && ids_cientifico.any?
      self.taxones = taxones.where(id: (ids_comun + ids_cientifico).uniq)
    elsif ids_comun.any?
      self.taxones = taxones.where(id: ids_comun)
    elsif ids_cientifico.any?
      self.taxones = taxones.where(id: ids_cientifico)
    end

    taxones.each do |taxon|
      # Para el nombre cientifico
      distancia = Levenshtein.distance(params[:nombre].limpiar.downcase, taxon.nombre_cientifico.limpiar.downcase)
      ids_totales <<= taxon if distancia < 3

      # Para los nombres comunes
      if taxon.nombres_comunes_adicionales.present?
        taxon.nombre_comun_principal = []

        taxon.nombres_comunes_adicionales.split(',').each do |nombre|
          distancia = Levenshtein.distance(params[:nombre].limpiar.downcase, nombre.downcase)

          if distancia < 3
            ids_totales << taxon
            taxon.nombre_comun_principal << nombre
          end
        end

        taxon.nombre_comun_principal = taxon.nombre_comun_principal.join(', ')
      end
    end

    # Para mantener el valor en taxones
    self.taxones = ids_totales.uniq
    self.totales = taxones.length
    self.fuzzy_match = '¿Quizás quiso decir algunos de los siguientes taxones?' if totales > 0
  end

end