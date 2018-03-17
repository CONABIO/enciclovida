class BusquedaAvanzada < Busqueda
  # REVISADO: Regresa la busqueda avanzada
  def resultados_avanzada
    paginado_y_offset
    estatus
    estado_conservacion
    tipo_distribucion
    solo_categoria

    return unless por_id

    # Saca los hijos de las categorias taxonomica que especifico , de acuerdo con el ID que escogio
    if taxon.present? && params[:cat].present? && params[:nivel].present?
      # Aplica el query para los descendientes
      self.taxones = taxones.where("#{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%,#{taxon.id},%'")

      # Se limita la busqueda al rango de categorias taxonomicas de acuerdo al nivel
      self.taxones = taxones.nivel_categoria(params[:nivel], params[:cat])
    end

    # Por si carga la pagina de un inicio, /busquedas/resultados
    if (pagina == 1 && params[:solo_categoria].blank?) || formato == 'xlsx'
      por_categoria_taxonomica if formato != 'xlsx'

      # Los totales del query
      self.totales = taxones.count
    end

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