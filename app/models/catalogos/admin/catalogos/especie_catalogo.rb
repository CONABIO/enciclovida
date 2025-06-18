class Admin::EspecieCatalogo < EspecieCatalogo

  has_many :bibliografias, class_name: Admin::EspecieCatalogoBibliografia, primary_key: [attribute_alias(:especie_id),attribute_alias(:catalogo_id)], foreign_key: [attribute_alias(:especie_id),attribute_alias(:catalogo_id)]
  has_many :regiones, class_name: Admin::EspecieCatalogoRegion, primary_key: [attribute_alias(:especie_id),attribute_alias(:catalogo_id)], foreign_key: [attribute_alias(:especie_id),attribute_alias(:catalogo_id)]

  attr_accessor :nombre_cientifico
  accepts_nested_attributes_for :bibliografias, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :regiones, reject_if: :all_blank, allow_destroy: true

  before_update :asigna_usuario

  def asigna_usuario
    cambios = changes.keys

    # Regresa el valor original del usuario si no se edito nada
    if cambios.length == 1 && cambios.include?('usuario')
      self.usuario = usuario_was
    end
  end

end
