class Metamares::BusquedaProyecto
  attr_accessor :params, :proyectos, :proyecto, :totales, :pagina, :por_pagina, :offset

  POR_PAGINA = [50, 100, 200]
  POR_PAGINA_PREDETERMINADO = POR_PAGINA.first

  # REVISADO: Inicializa los objetos busqueda
  def initialize
    self.proyectos = Metamares::Proyecto.left_joins(:institucion, {especies: [:especie, :adicional]}, :keywords, :region).distinct
    self.totales = 0
  end

  # REVISADO: Hace el query con los parametros elegidos
  def consulta
    self.proyectos = proyectos.where('nombre_proyecto REGEXP ?', params[:proyecto]) if params[:proyecto].present?
    self.proyectos = proyectos.where('nombre_institucion REGEXP ?', params[:institucion]) if params[:institucion].present?
    self.proyectos = proyectos.where(tipo_monitoreo: params[:tipo_monitoreo]) if params[:tipo_monitoreo].present?
  end

  # REVISADO: Algunos valores como el offset, pagina y por pagina
  def paginado_y_offset
    self.pagina = (params[:pagina] || 1).to_i
    self.por_pagina = params[:por_pagina].present? ? params[:por_pagina].to_i : POR_PAGINA_PREDETERMINADO
    self.offset = (pagina-1)*por_pagina
  end

end
