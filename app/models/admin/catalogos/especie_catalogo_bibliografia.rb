class Admin::EspecieCatalogoBibliografia < EspecieCatalogoBibliografia

  attr_accessor :biblio

  before_update :asigna_usuario

  def asigna_usuario
    cambios = changes.keys

    # Regresa el valor original del usuario si no se edito nada
    if cambios.length == 1 && cambios.include?('usuario')
      self.usuario = usuario_was
    end
  end
  
end