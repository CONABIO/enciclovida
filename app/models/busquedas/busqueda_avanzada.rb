class BusquedaAvanzada < Busqueda

  attr_accessor :sinonimos_basonimos

  # REVISADO: Regresa la busqueda avanzada
  def resultados_avanzada
    paginado_y_offset
    estatus
    solo_publicos
    estado_conservacion
    tipo_distribucion
    uso
    ambiente
    region
    solo_categoria

    return unless por_id_o_nombre
    categoria_por_nivel

    conteo_por_categoria_taxonomica

    busca_estadisticas

    dame_totales
    resultados
  end

  # REVISADO: Saca los hijos de las categorias taxonomica que especifico , de acuerdo con el ID que escogio
  def categoria_por_nivel
    if taxon.present? && params[:cat].present? && params[:nivel].present?
      # Aplica el query para los descendientes
      self.taxones = taxones.where("#{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%,#{taxon.id},%'")

      # Se limita la busqueda al rango de categorias taxonomicas de acuerdo al nivel
      self.taxones = taxones.nivel_categoria(params[:nivel], params[:cat])
    end
  end

  # REVISADO: Regresa en formato de cheklist o para consulta en busqueda avanzada
  def resultados
    if params[:checklist] == '1'
      checklist
    else
      self.taxones = taxones.select_basico.order(:nombre_cientifico)
      return if formato == 'xlsx'

      self.taxones = taxones.offset(offset).limit(por_pagina)

      # Si solo escribio un nombre
      if params[:id].blank? && params[:nombre].present?
        taxones.each do |t|
          t.cual_nombre_comun_coincidio(params[:nombre])
        end
      end
    end  # End checklist
  end


  private

  def checklist
    ids_checklist = taxones.where(estatus: 2).select_ancestry.map{ |t| t.ancestry.split(',') }.flatten.uniq!
    self.taxones = Especie.select_basico.left_joins(:categoria_taxonomica, :adicional).datos_checklist.where(id: ids_checklist)

    return unless params[:f_check].present? && params[:f_check].any?

    params[:f_check].each do |campo|
      case campo
      when 'tipo_dist'
        self.taxones = taxones.includes(:tipos_distribuciones)
      when 'cat_riesgo', 'amb', 'formas', 'residencia'
        self.taxones = taxones.includes(:catalogos)
      when 'dist'
        self.taxones = taxones.includes(:regiones)
      when 'nom_com'
        self.taxones = taxones.includes(:nombres_comunes)
      when 'biblio'
        self.taxones = taxones.includes(:bibliografias)
      when 'interac'
        self.taxones = taxones.includes(:regiones, especies_estatus: [especie: [:regiones]])
      end
    end

    if !params[:f_check].include?('val') && !params[:f_check].include?('interac')
      self.taxones = taxones.includes(especies_estatus: [:especie])
    end

  end

end