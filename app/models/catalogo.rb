class Catalogo < ActiveRecord::Base

  self.table_name='catalogos'
  has_many :especies_catalogos, :class_name => 'EspecieCatalogo'
  #has_one :especie, :through => :especies_catalogos, :class_name => 'EspecieCatalogo', :foreign_key => 'catalogo_id'

  def nom_cites_iucn
    if nivel1 == 4 && nivel2 > 0 && nivel3 > 0   #se asegura que el valor pertenece a la nom, iucn o cites
      edo_conservacion = Catalogo.where(:nivel1 => nivel1, :nivel2 => nivel2, :nivel3 => 0).first   #el nombre del edo. de conservacion
      edo_conservacion ? edo_conservacion.descripcion : nil
    else
      nil
    end
  end
end
