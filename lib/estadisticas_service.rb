# lib/estadisticas_service.rb
class EstadisticasService
  # Método principal para actualización masiva de estadísticas de conteo
  # Ahora eliminar_ceros por defecto es false para mantener los registros con conteo 0
  def self.actualizar_masivo(eliminar_ceros: false)
    puts "=== EJECUTANDO ESTADÍSTICAS CONTEOS ==="
    puts "Base de datos: #{CONFIG.bases.cat}"
    puts "Tabla especies: #{CONFIG.bases.cat}.Nombre"
    puts "Tabla estadísticas: #{CONFIG.bases.ev}.especies_estadistica"
    puts "Eliminar ceros: #{eliminar_ceros}"
    
    stats = { actualizados: 0, eliminados: 0, insertados: 0 }
    
    # Desactivar logging temporalmente
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    
    begin
      puts "Procesando estadística 22 (especies válidas)..."
      resultado22 = procesar_estadistica_22(eliminar_ceros)
      stats[:actualizados] += resultado22[:afectadas]
      stats[:insertados] += resultado22[:insertadas]
      
      puts "Procesando estadística 2 (total especies)..."
      resultado2 = procesar_estadistica_2(eliminar_ceros)
      stats[:actualizados] += resultado2[:afectadas]
      stats[:insertados] += resultado2[:insertadas]
      
      puts "Procesando estadística 3 (especies e inferiores)..."
      resultado3 = procesar_estadistica_3(eliminar_ceros)
      stats[:actualizados] += resultado3[:afectadas]
      stats[:insertados] += resultado3[:insertadas]
      
      puts "Procesando estadística 23 (especies/inferiores válidas)..."
      resultado23 = procesar_estadistica_23(eliminar_ceros)
      stats[:actualizados] += resultado23[:afectadas]
      stats[:insertados] += resultado23[:insertadas]
      
      # Solo eliminar ceros si se solicita explícitamente
      if eliminar_ceros
        puts "Eliminando conteos 0..."
        stats[:eliminados] = EspecieEstadistica.where(conteo: 0).delete_all
      else
        puts "Manteniendo registros con conteo 0 (no se eliminan)"
      end
      
    rescue => e
      puts "ERROR: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      stats[:error] = e.message
    ensure
      ActiveRecord::Base.logger = old_logger
    end
    
    puts "=== COMPLETADO ==="
    puts "Registros actualizados: #{stats[:actualizados]}"
    puts "Registros insertados: #{stats[:insertados]}"
    puts "Registros eliminados (ceros): #{stats[:eliminados]}"
    
    stats
  end
  
  private
  
  # Estadística 22: Especies válidas
  def self.procesar_estadistica_22(eliminar_ceros)
    sql = <<-SQL
      INSERT INTO #{CONFIG.bases.ev}.especies_estadistica 
        (especie_id, estadistica_id, conteo, created_at, updated_at)
      SELECT
        t.IdNombre AS especie_id,
        22 AS estadistica_id,
        COUNT(n.IdNombre) AS conteo,
        NOW(),
        NOW()
      FROM #{CONFIG.bases.cat}.Nombre t 
      INNER JOIN #{CONFIG.bases.cat}.Nombre n
        ON FIND_IN_SET(t.IdNombre, n.AscendentesObligatorios)
        AND n.EstadoRegistro = 1
        AND n.estatus = 2
        AND n.IdCategoriaTaxonomica IN (19, 50)
        AND t.IdCategoriaTaxonomica in (1,2,4,7,9,13,27,31,35,39,44)
      GROUP BY t.IdNombre
      ON DUPLICATE KEY UPDATE
        conteo = VALUES(conteo),
        updated_at = NOW()
    SQL
    
    puts "  Ejecutando SQL para estadística 22..."
    resultado = ActiveRecord::Base.connection.execute(sql)
    filas_afectadas = resultado.to_i
    
    # Contar cuántos registros se insertaron (conteo 0 también se insertan)
    insertadas = contar_insertados(22)
    
    puts "  Filas afectadas (actualizadas+insertadas): #{filas_afectadas}"
    puts "  Nuevos registros insertados: #{insertadas}"
    
    if eliminar_ceros
      eliminados = EspecieEstadistica.where(estadistica_id: 22, conteo: 0).delete_all
      puts "  Ceros eliminados: #{eliminados}"
    end
    
    { afectadas: filas_afectadas, insertadas: insertadas }
  end
  
  # Estadística 2: Total de especies (TODAS, no solo válidas)
  def self.procesar_estadistica_2(eliminar_ceros)
    sql = <<-SQL
      INSERT INTO #{CONFIG.bases.ev}.especies_estadistica 
        (especie_id, estadistica_id, conteo, created_at, updated_at)
      SELECT
        t.IdNombre AS especie_id,
        2 AS estadistica_id,
        COUNT(DISTINCT n.IdNombre) AS conteo,
        NOW(),
        NOW()
      FROM #{CONFIG.bases.cat}.Nombre t 
      INNER JOIN #{CONFIG.bases.cat}.Nombre n
        ON FIND_IN_SET(t.IdNombre, n.AscendentesObligatorios)
        AND n.EstadoRegistro = 1
        AND n.IdCategoriaTaxonomica IN (19, 50)
        AND t.IdCategoriaTaxonomica in (1,2,4,7,9,13,27,31,35,39,44)
      GROUP BY t.IdNombre
      ON DUPLICATE KEY UPDATE
        conteo = VALUES(conteo),
        updated_at = NOW()
    SQL
    
    puts "  Ejecutando SQL para estadística 2..."
    resultado = ActiveRecord::Base.connection.execute(sql)
    filas_afectadas = resultado.to_i
    insertadas = contar_insertados(2)
    
    puts "  Filas afectadas (actualizadas+insertadas): #{filas_afectadas}"
    puts "  Nuevos registros insertados: #{insertadas}"
    
    if eliminar_ceros
      eliminados = EspecieEstadistica.where(estadistica_id: 2, conteo: 0).delete_all
      puts "  Ceros eliminados: #{eliminados}"
    end
    
    { afectadas: filas_afectadas, insertadas: insertadas }
  end
  
  # Estadística 3: Total de especies e inferiores (TODAS)
  def self.procesar_estadistica_3(eliminar_ceros)
    sql = <<-SQL
      INSERT INTO #{CONFIG.bases.ev}.especies_estadistica 
        (especie_id, estadistica_id, conteo, created_at, updated_at)
      SELECT
        t.IdNombre AS especie_id,
        3 AS estadistica_id,
        COUNT(DISTINCT n.IdNombre) AS conteo,
        NOW(),
        NOW()
      FROM #{CONFIG.bases.cat}.Nombre t 
      INNER JOIN #{CONFIG.bases.cat}.Nombre n
        ON FIND_IN_SET(t.IdNombre, n.AscendentesObligatorios)
        AND n.EstadoRegistro = 1
        AND t.IdCategoriaTaxonomica in (1,2,4,7,9,13,27,31,35,39,44)
      WHERE n.IdCategoriaTaxonomica IN (19, 50, 51, 52, 53, 54, 55, 56)
      GROUP BY t.IdNombre
      ON DUPLICATE KEY UPDATE
        conteo = VALUES(conteo),
        updated_at = NOW()
    SQL
    
    puts "  Ejecutando SQL para estadística 3..."
    resultado = ActiveRecord::Base.connection.execute(sql)
    filas_afectadas = resultado.to_i
    insertadas = contar_insertados(3)
    
    puts "  Filas afectadas (actualizadas+insertadas): #{filas_afectadas}"
    puts "  Nuevos registros insertados: #{insertadas}"
    
    if eliminar_ceros
      eliminados = EspecieEstadistica.where(estadistica_id: 3, conteo: 0).delete_all
      puts "  Ceros eliminados: #{eliminados}"
    end
    
    { afectadas: filas_afectadas, insertadas: insertadas }
  end
  
  # Estadística 23: Especies o inferiores válidas
  def self.procesar_estadistica_23(eliminar_ceros)
    sql = <<-SQL
      INSERT INTO #{CONFIG.bases.ev}.especies_estadistica 
        (especie_id, estadistica_id, conteo, created_at, updated_at)
      SELECT
        t.IdNombre AS especie_id,
        23 AS estadistica_id,
        COUNT(DISTINCT n.IdNombre) AS conteo,
        NOW(),
        NOW()
      FROM #{CONFIG.bases.cat}.Nombre t 
      INNER JOIN #{CONFIG.bases.cat}.Nombre n
        ON FIND_IN_SET(t.IdNombre, n.AscendentesObligatorios)
        AND n.EstadoRegistro = 1
        AND n.estatus = 2
        AND t.IdCategoriaTaxonomica in (1,2,4,7,9,13,27,31,35,39,44)
      WHERE n.IdCategoriaTaxonomica IN (19, 50, 51, 52, 53, 54, 55, 56)
      GROUP BY t.IdNombre
      ON DUPLICATE KEY UPDATE
        conteo = VALUES(conteo),
        updated_at = NOW()
    SQL
    
    puts "  Ejecutando SQL para estadística 23..."
    resultado = ActiveRecord::Base.connection.execute(sql)
    filas_afectadas = resultado.to_i
    insertadas = contar_insertados(23)
    
    puts "  Filas afectadas (actualizadas+insertadas): #{filas_afectadas}"
    puts "  Nuevos registros insertados: #{insertadas}"
    
    if eliminar_ceros
      eliminados = EspecieEstadistica.where(estadistica_id: 23, conteo: 0).delete_all
      puts "  Ceros eliminados: #{eliminados}"
    end
    
    { afectadas: filas_afectadas, insertadas: insertadas }
  end
  
  # Método auxiliar para contar cuántos registros nuevos se insertaron
  def self.contar_insertados(estadistica_id)
    # Cuenta registros creados en los últimos 5 segundos para esta estadística
    # Asume que la inserción fue reciente
    EspecieEstadistica.where(
      estadistica_id: estadistica_id,
      created_at: 5.seconds.ago..Time.now
    ).count
  end
end