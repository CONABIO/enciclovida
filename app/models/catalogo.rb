class Catalogo < ActiveRecord::Base

  self.table_name = 'catalogos'
  self.primary_key = 'id'

  has_many :especies_catalogos, :class_name => 'EspecieCatalogo'
  #has_one :especie, :through => :especies_catalogos, :class_name => 'EspecieCatalogo', :foreign_key => 'catalogo_id'

  def nom_cites_iucn
    if nivel1 == 4 && nivel2 > 0 && nivel3 > 0   #se asegura que el valor pertenece a la nom, iucn o cites
      limites = Bases.limites(id)
      id_inferior = limites[:limite_inferior]
      id_superior = limites[:limite_superior]
      edo_conservacion = Catalogo.where(:nivel1 => nivel1, :nivel2 => nivel2, :nivel3 => 0).where(:id => id_inferior..id_superior).first   #el nombre del edo. de conservacion
      edo_conservacion ? edo_conservacion.descripcion : nil
    else
      nil
    end
  end

  def self.nom_cites_iucn_todos
    nom = where(:nivel1 => 4, :nivel2=> 1).where('nivel3 > 0').map(&:descripcion).uniq
    nom = [nom[2],nom[0],nom[1],nom[3]]#Orden propuesto por cgalindo
    # Esta categoria de IUCN esta repetida y no tenia nada asociado
    iucn = where(:nivel1 => 4, :nivel2=> 2).where("nivel3 > 0 AND descripcion != 'Riesgo bajo (LR): Casi amenazada (nt)'").map(&:descripcion).uniq
    iucn = [iucn[7],iucn[6],iucn[9],iucn[8],iucn[4],iucn[3],iucn[2],iucn[1],iucn[0],iucn[5]]#IDEM, el iucn[5] se quita en el helper, consultar con dhernandez ASAP
    cites = where(:nivel1 => 4, :nivel2=> 3).where('nivel3 > 0').map(&:descripcion).uniq #Esta ya viene en orden (I,II,III)
    {:nom => nom, :iucn => iucn, :cites => cites}
  end
end
