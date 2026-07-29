# REVISADO: Guarda los nombres comunes y científico en Redis
def guarda_redis(opc = {})
  # Determina el loader a utilizar
  loader =
    if opc[:loader].present?
      Soulmate::Loader.new(opc[:loader])
    else
      categoria = I18n.transliterate(
        categoria_taxonomica.nombre_categoria_taxonomica
      ).gsub(' ', '_')

      Soulmate::Loader.new(categoria)
    end

  # Los taxones eliminados no deben aparecer en el autocomplete
  unless EstadoRegistro == 1
    borra_redis(loader)
    borra_fuzzy_match
    return
  end

  # Suma la visita solamente cuando corresponda
  suma_visita unless opc[:sin_visita]

  # Limpia variables temporales
  self.x_foto_principal = nil
  self.x_nombre_comun_principal = nil
  self.x_lengua = nil
  self.x_fotos_totales = 0
  self.x_nombres_comunes = nil
  self.x_nombres_comunes_todos = []

  # Actualiza fuzzy match para nombres científicos
  if opc[:loader].nil?
    borra_fuzzy_match
    FUZZY_NOM_CIEN.put(nombre_cientifico.strip, id)
  end

  # Borra los registros actuales de Redis
  borra_redis(loader)

  # Guarda el nombre científico
  loader.add(
    asigna_redis(
      opc.merge(consumir_servicios: true)
    )
  )

  # Obtiene explícitamente los nombres comunes de los catálogos.
  # No dependemos de que x_nombres_comunes_todos haya sido llenado
  # previamente por una visita a la especie.
  nombres_comunes = dame_nombres_comunes_catalogos || []

  # Guarda los nombres comunes
  num_nombre = 0

  nombres_comunes.each do |nombres|
    lengua = nombres.keys.first

    nombres.values.flatten.each do |nombre|
      next if nombre.blank?

      num_nombre += 1
      id_referencia = nombre_comun_a_id_referencia(num_nombre)

      nombre_obj = NombreComun.new(
        id: id_referencia,
        nombre_comun: nombre,
        lengua: lengua
      )

      loader.add(
        asigna_redis(
          opc.merge(nombre_comun: nombre_obj)
        )
      )

      FUZZY_NOM_COM.put(nombre, id_referencia) if opc[:loader].nil?
    end
  end
end