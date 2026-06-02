# app/models/transforma_nombre.rb
class TransformaNombre < ActiveRecord::Base
  self.table_name = "#{CONFIG.bases.cat}._TransformaTablaNombre"
  self.primary_key = 'IdNombre'

  # Relaciones
  has_many :rel_nombre_catalogos,
           foreign_key: 'IdNombre',
           class_name: 'RelNombreCatalogo'

  has_many :catalogos,
           through: :rel_nombre_catalogos,
           source: :catalogo

  # ==========================================
  # CONSULTAS PARA POLINIZADORES
  # ==========================================

  # Catálogos 1298 y 2485
  def self.especies_todos_interaccion
    ids = joins(:catalogos)
          .where("#{Catalogo.table_name}.IdCatNombre IN (?)", [1298, 2485])
          .distinct
          .pluck(:IdNombre)

    Especie.left_joins(:adicional)
           .select(
             'catalogocentralizado.Nombre.*,
              adicionales.foto_principal,
              adicionales.nombre_comun_principal'
           )
           .where(IdNombre: ids)
  end

  # Catálogo 1298
  # Visitantes Florales (VF) y Polinizadores (P)
  def self.especies_visitantes_florales_y_polinizadores
    ids = joins(:rel_nombre_catalogos)
          .where(
            "#{RelNombreCatalogo.table_name}.IdCatNombre = ?",
            1298
          )
          .where(
            "#{RelNombreCatalogo.table_name}.Observaciones IN (?)",
            ['P', 'VF', 'P, VF', 'VF, P']
          )
          .distinct
          .pluck(:IdNombre)

    Especie.left_joins(:adicional)
           .select(
             'catalogocentralizado.Nombre.*,
              adicionales.foto_principal,
              adicionales.nombre_comun_principal'
           )
           .where(IdNombre: ids)
  end

  # Catálogo 2485
  # Plantas Melíferas
  def self.especies_plantas_meliferas
    ids = joins(:rel_nombre_catalogos)
          .where(
            "#{RelNombreCatalogo.table_name}.IdCatNombre = ?",
            2485
          )
          .where(
            "#{RelNombreCatalogo.table_name}.Observaciones = ?",
            'Melífera'
          )
          .distinct
          .pluck(:IdNombre)

    Especie.left_joins(:adicional)
           .select(
             'catalogocentralizado.Nombre.*,
              adicionales.foto_principal,
              adicionales.nombre_comun_principal'
           )
           .where(IdNombre: ids)
  end

  # ==========================================
  # PAGINACIÓN
  # ==========================================

  def self.buscar_polinizadores_por_tipo(tipo, pagina = 1, por_pagina = 20)
    resultados = case tipo
                 when 'todos_interaccion'
                   especies_todos_interaccion
                 when 'visitantes_polinizadores'
                   especies_visitantes_florales_y_polinizadores
                 when 'plantas_meliferas'
                   especies_plantas_meliferas
                 else
                   Especie.none
                 end

    resultados.offset((pagina - 1) * por_pagina)
              .limit(por_pagina)
  end

  # ==========================================
  # CONTEOS
  # ==========================================

  def self.contar_polinizadores_por_tipo(tipo)
    case tipo

    when 'todos_interaccion'
      joins(:catalogos)
        .where("#{Catalogo.table_name}.IdCatNombre IN (?)", [1298, 2485])
        .distinct
        .count(:IdNombre)

    when 'visitantes_polinizadores'
      joins(:rel_nombre_catalogos)
        .where(
          "#{RelNombreCatalogo.table_name}.IdCatNombre = ?",
          1298
        )
        .where(
          "#{RelNombreCatalogo.table_name}.Observaciones IN (?)",
          ['P', 'VF', 'P, VF', 'VF, P']
        )
        .distinct
        .count(:IdNombre)

    when 'plantas_meliferas'
      joins(:rel_nombre_catalogos)
        .where(
          "#{RelNombreCatalogo.table_name}.IdCatNombre = ?",
          2485
        )
        .where(
          "#{RelNombreCatalogo.table_name}.Observaciones = ?",
          'Melífera'
        )
        .distinct
        .count(:IdNombre)

    else
      0
    end
  end
end