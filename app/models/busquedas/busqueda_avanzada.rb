class BusquedaAvanzada < Busqueda

  attr_accessor :categorias_checklist

  # REVISADO: Regresa la busqueda avanzada
  def resultados_avanzada
    paginado_y_offset
    estatus unless params[:checklist] == '1'
    solo_publicos
    solo_vivos
    estado_conservacion
    tipo_distribucion
    uso
    formas_crecimiento
    ambiente
    region

    solo_categoria unless params[:checklist] == '1'
    return unless por_id_o_nombre
    categoria_por_nivel
    conteo_por_categoria_taxonomica unless params[:checklist] == '1'
    busca_estadisticas unless params[:checklist] == '1'
    dame_totales unless params[:checklist] == '1'
    resultados
  end

  # REVISADO: Saca los hijos de las categorias taxonomica que especifico , de acuerdo con el ID que escogio
  def categoria_por_nivel
    if taxon.present? && params[:cat].present? && params[:nivel].present?
      # Aplica el query para los descendientes
      if taxon.id == 286957
        taxon_ids =  [286957,286963]
        # Construye las condiciones LIKE para cada taxon_id
        like_conditions = taxon_ids.map do |id|
          "#{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE ?"
        end.join(' OR ')

        # Construye los valores para las condiciones LIKE
        like_values = taxon_ids.map { |id| "%,#{id},%" }

        # Aplica las condiciones a la consulta
        self.taxones = taxones.where(like_conditions, *like_values)
      else
        self.taxones = taxones.where("#{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%,#{taxon.id},%'")
      end
      # Se limita la busqueda al rango de categorias taxonomicas de acuerdo al nivel
      self.taxones = taxones.nivel_categoria(params[:nivel], params[:cat])
    elsif params[:cat].present? && params[:nivel].present?
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
    # Saca todos los IDS con los criterios y los ancestros
    ids_checklist = taxones.select_ancestry.where(estatus: 2).map{ |t| t.ancestry.split(',').reject { |c| c.empty? } }.flatten.uniq!
    self.taxones = Especie.select_basico.left_joins(:categoria_taxonomica, :adicional).datos_checklist.categorias_checklist.where(id: ids_checklist).includes(especies_estatus: :especie)

    # Saca el conteo de los taxones en las 7 categorias principales
    self.categorias_checklist = Especie.left_joins(:categoria_taxonomica).categorias_checklist.where(id: ids_checklist).select("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} AS nombre_categoria_taxonomica, COUNT(*) AS totales").select_nivel_categoria.order('nivel_categoria ASC').group("nombre_categoria_taxonomica, nivel_categoria")

    return unless params[:f_desc].present? && params[:f_desc].any?

    params[:f_desc].each do |campo|
      case campo
      when 'x_tipo_distribucion'
        self.taxones = taxones.includes(:tipos_distribuciones)
      when 'x_cat_riesgo', 'x_ambiente', 'x_formas', 'x_residencia'
        self.taxones = taxones.includes(:catalogos)
      when 'x_distribucion'
        self.taxones = taxones.includes(:regiones)
      when 'x_nombres_comunes'
        self.taxones = taxones.includes(:nombres_comunes)
      when 'x_bibliografia'
        self.taxones = taxones.includes(:bibliografias)
      when 'x_interaccion'
        self.taxones = taxones.includes(:regiones, especies_estatus: [especie: [:regiones]])
      end
    end

    if !params[:f_desc].include?('x_estatus') && !params[:f_desc].include?('x_interaccion')
      self.taxones = taxones.includes(especies_estatus: [:especie])
    end
  end

end