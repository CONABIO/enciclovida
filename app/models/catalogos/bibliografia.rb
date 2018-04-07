class Bibliografia < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.Bibliografia'
  self.primary_key = 'IdBibliografia'

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdBibliografia
  alias_attribute :onservaciones, :Observaciones
  alias_attribute :autor, :Autor
  alias_attribute :anio, :Anio
  alias_attribute :titulo_Publicacion, :TituloPublicacion
  alias_attribute :titulo_sub_publicacion, :TituloSubPublicacion
  alias_attribute :editorial_pais_pagina, :EditorialPaisPagina
  alias_attribute :numero_volumen_anio, :NumeroVolumenAnio
  alias_attribute :editores_compiladores, :EditoresCompiladores
  alias_attribute :isbnissn, :ISBNISSN
  alias_attribute :cita_completa, :CitaCompleta
  alias_attribute :orden_cita_completa, :OrdenCitaCompleta

  def personalizaBusqueda
    "#{self.autor} - #{self.titulo_publicacion} (#{self.anio})"
  end

end
