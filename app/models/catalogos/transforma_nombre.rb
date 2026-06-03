# app/models/transforma_nombre.rb
class TransformaNombre < ActiveRecord::Base
  self.table_name = "#{CONFIG.bases.cat}._TransformaTablaNombre"
  self.primary_key = 'IdNombre'

  # Relaciones
  has_many :rel_nombre_catalogos, foreign_key: 'IdNombre', class_name: 'RelNombreCatalogo'
  has_many :catalogos, through: :rel_nombre_catalogos, source: :catalogo

  # ==========================================
  # CONSULTAS PARA POLINIZADORES
  # ==========================================

  # Obtener IDs de visitantes y polinizadores (Catálogo 1298) con filtro de clase
  def self.obtener_ids_visitantes_polinizadores(clase = nil)
    query = joins(:rel_nombre_catalogos)
            .where("#{RelNombreCatalogo.table_name}.IdCatNombre = ?", 1298)
            .distinct
    
    if clase.present?
      query = query.where(Clase: clase)
    end
    
    query.pluck(:IdNombre)
  end

  # Obtener IDs de plantas melíferas (Catálogo 2485)
  def self.obtener_ids_meliferas
    joins(:rel_nombre_catalogos)
      .where("#{RelNombreCatalogo.table_name}.IdCatNombre = ?", 2485)
      .distinct
      .pluck(:IdNombre)
  end

  # Catálogo 1298 - Visitantes Florales (VF) y Polinizadores (P)
  def self.especies_visitantes_florales_y_polinizadores(clase = nil)
    ids = obtener_ids_visitantes_polinizadores(clase)
    
    Especie.left_joins(:adicional)
           .select('catalogocentralizado.Nombre.*, adicionales.foto_principal, adicionales.nombre_comun_principal')
           .where(IdNombre: ids)
  end

  # Catálogo 2485 - Plantas Melíferas
  def self.especies_plantas_meliferas
    ids = obtener_ids_meliferas
    
    Especie.left_joins(:adicional)
           .select('catalogocentralizado.Nombre.*, adicionales.foto_principal, adicionales.nombre_comun_principal')
           .where(IdNombre: ids)
  end

  # Catálogos 1298 y 2485 - Todos
  def self.especies_todos_interaccion(clase = nil)
    ids_1298 = obtener_ids_visitantes_polinizadores(clase)
    ids_2485 = obtener_ids_meliferas
    ids = (ids_1298 + ids_2485).uniq
    
    Especie.left_joins(:adicional)
           .select('catalogocentralizado.Nombre.*, adicionales.foto_principal, adicionales.nombre_comun_principal')
           .where(IdNombre: ids)
  end

  # ==========================================
  # PAGINACIÓN
  # ==========================================

  def self.buscar_polinizadores_por_tipo(tipo, pagina = 1, por_pagina = 20, clase = nil)
    resultados = case tipo
                 when 'todos_interaccion'
                   especies_todos_interaccion(clase)
                 when 'visitantes_polinizadores'
                   especies_visitantes_florales_y_polinizadores(clase)
                 when 'plantas_meliferas'
                   especies_plantas_meliferas
                 else
                   Especie.none
                 end

    resultados.offset((pagina - 1) * por_pagina).limit(por_pagina)
  end

  # ==========================================
  # CONTEOS
  # ==========================================

  def self.contar_polinizadores_por_tipo(tipo, clase = nil)
    case tipo
    when 'todos_interaccion'
      ids_1298 = obtener_ids_visitantes_polinizadores(clase)
      ids_2485 = obtener_ids_meliferas
      (ids_1298 + ids_2485).uniq.count
      
    when 'visitantes_polinizadores'
      obtener_ids_visitantes_polinizadores(clase).count
      
    when 'plantas_meliferas'
      obtener_ids_meliferas.count
      
    else
      0
    end
  end
end