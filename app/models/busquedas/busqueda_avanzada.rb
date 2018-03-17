class BusquedaAvanzada < Busqueda
  # REVISADO: Regresa la busqueda avanzada
  def resultados_avanzada
    paginado_y_offset
    estatus
    estado_conservacion
    tipo_distribucion
    solo_categoria

    return unless por_id
    categoria_por_nivel

    conteo_por_categoria_taxonomica
    totales
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
      self.taxones = taxones.datos_arbol_con_filtros
      checklist
    else
      self.taxones = taxones.select_basico.order(:nombre_cientifico)
      return if formato == 'xlsx'

      self.taxones = taxones.offset(offset).limit(por_pagina)

      # Si solo escribio un nombre
      if params[:id].blank? && params[:nombre].present?
        self.taxones = taxones.caso_nombre_comun_y_cientifico(params[:nombre].limpia_sql).left_joins(:nombres_comunes)

        taxones.each do |t|
          t.cual_nombre_comun_coincidio(params[:nombre])
        end
      end
    end  # End checklist
  end

end