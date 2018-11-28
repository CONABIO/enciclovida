class Metamares::BusquedaProyecto
  attr_accessor :params, :proyectos, :proyecto, :totales, :pagina, :por_pagina, :offset

  POR_PAGINA = [50, 100, 200]
  POR_PAGINA_PREDETERMINADO = POR_PAGINA.first

  # REVISADO: Inicializa los objetos busqueda
  def initialize
    self.proyectos = Metamares::Proyecto.left_joins(:institucion, {especies: [:especie, :adicional]}, :dato).
        distinct(:id).select(:id, :nombre_proyecto, :autor, :campo_investigacion, :updated_at).select('nombre_institucion, descarga_datos').
        where('estatus_datos IN (1,2)').order(updated_at: :desc, created_at: :desc, id: :desc)
    self.totales = 0
    self.params = {}
  end

  # REVISADO: Hace el query con los parametros elegidos
  def consulta
    paginado_y_offset
    proyectos_propios?

    self.proyectos = proyectos.where('nombre_proyecto REGEXP ?', params[:proyecto]) if params[:proyecto].present?
    self.proyectos = proyectos.where('nombre_institucion REGEXP ?', params[:institucion]) if params[:institucion].present?
    self.proyectos = proyectos.where(tipo_monitoreo: params[:tipo_monitoreo]) if params[:tipo_monitoreo].present?
    self.proyectos = proyectos.where('autor REGEXP ?', params[:autor]) if params[:autor].present?

    if params[:especie_id].present?
      self.proyectos = proyectos.where('especies_estudiadas.especie_id=?', params[:especie_id]).left_joins({especies: [:especie, :adicional]})
    elsif params[:nombre].present?
      self.proyectos = proyectos.where('especies_estudiadas.nombre_cientifico REGEXP ?', params[:nombre]).left_joins({especies: [:especie, :adicional]})
    end

    self.totales = proyectos.count('proyectos.id')
    self.proyectos = proyectos.offset(offset).limit(por_pagina)
  end


  private

  # REVISADO: Algunos valores como el offset, pagina y por pagina
  def paginado_y_offset
    self.pagina = (params[:pagina] || 1).to_i
    self.por_pagina = params[:por_pagina].present? ? params[:por_pagina].to_i : POR_PAGINA_PREDETERMINADO
    self.offset = (pagina-1)*por_pagina
  end

  # REVISADO: Condicion para ver sus proyectos, si esta en los params
  def proyectos_propios?
    if params[:usuario_id].present?
      self.proyectos = proyectos.left_joins(:usuario).where('usuarios.id = ?', params[:usuario_id].to_i)
    end
  end

end
