module EstadisticasHelper

  # Función uqe devolverá una lista de estadísticas para seleccionar
  def selectEstadisticas
    el_select = '<select class="selectpicker form-control" id="showEstadisticas" data-live-search="true" title="Selecciona las estadísticas a mostrar (ninguno para mostrar todas)" multiple data-selected-text-format="count > 0" name="showEstadisticas[]" multiple>'
    Estadistica::SECCIONES_ESTADISTICAS.each do |seccion|
      el_select += "<optgroup label='#{seccion}'>"
      Estadistica.all.each do |estadistica|
        # Saltar estadísticas que no se usarán
        next if Estadistica::ESTADISTICAS_QUE_NO.index(estadistica.id)
        if estadistica.descripcion_estadistica.include?(seccion)
          nombre = estadistica.descripcion_estadistica.gsub("#{seccion} "," * ")
          el_select << "<option value='#{estadistica.id}'>#{nombre}</option>"
        end
      end
      el_select += "</optgroup>"
    end
    el_select << '</select>'
    el_select
  end
end