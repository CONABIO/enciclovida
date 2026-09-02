class BusquedaBasica < Busqueda

  attr_accessor :fuzzy_match

  # REVISADO: Regresa la busqueda basica
  def resultados_basica
    paginado_y_offset
    estatus
    solo_publicos
    solo_vivos
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

    ids_comun = FUZZY_NOM_COM.find(
      params[:nombre].strip,
      limit=CONFIG.limit_fuzzy
    ).map { |n| id_referencia_a_nombre_comun(n.first) }.flatten.compact.uniq

    ids_cientifico = FUZZY_NOM_CIEN.find(
      params[:nombre].strip,
      limit=CONFIG.limit_fuzzy
    ).map(&:first).flatten.compact.uniq

    ids_totales = (ids_comun + ids_cientifico).uniq

    if ids_totales.empty?
      self.taxones = Especie.none
      self.totales = 0
      return
    end

    self.taxones = Especie.
      left_joins(:categoria_taxonomica, :adicional).
      select_basico.
      where(id: ids_totales).
      distinct

    # Para los nombres comunes
    taxones.each do |taxon|
      if taxon.nombres_comunes_adicionales.present?
        taxon.nombre_comun_principal = []

        taxon.nombres_comunes_adicionales.split(',').each do |nombre|
          taxon.nombre_comun_principal << nombre
        end

        taxon.nombre_comun_principal = taxon.nombre_comun_principal.join(', ')
      end
    end

    self.taxones = taxones.order(:nombre_cientifico)
    self.totales = taxones.length

    # Aplicamos la paginación al final
    self.taxones = taxones.first(por_pagina)

    self.fuzzy_match = '¿Quizás quiso decir algunos de los siguientes taxones?' if totales > 0
  end

end
