class Plantid::Bibliografia < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.bibliografias"

  has_many :plantabibliografias
  has_many :plantas, through: :plantabibliografias

  before_save :validar_norebundaciaBibliografia

  def validar_norebundaciaBibliografia
      if Bibliografia.exists?(CitaCompleta: self.nombre_biblio)
      	true
      else
      	false
      end
  end

  def validar_norebundaciaprevia
  	if Plantid::Bibliografia.exists?(nombre_biblio: self.nombre_biblio)
  		true
  	else
  		false
  	end
  end
end