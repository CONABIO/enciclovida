class Fichas::Legislacion < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.legislacion"
	self.primary_keys = :legislacionId,  :especieId

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

	# Legislaciones existentes
  TIPOS_LEGISLACIONES = ["NOM-059-SEMARNAT-2001", "NOM-059-SEMARNAT", "UICN", "CITES"]

  # Legislaciones
	LEGISLACIONES = [[:L_SEMARNATDES, :L_SEMARNAT], [:L_SEMARNAT2DES, :L_SEMARNAT2], [:L_UICNDES, :L_UICN], [:L_CITESDES, :L_CITES]]

  L_SEMARNAT = [:sem1, :sem2, :sem3, :sem4, :sem5]
  L_UICN = [:uicn1, :uicn2, :uicn3, :uicn4, :uicn5, :uicn6, :uicn7, :uicn8, :uicn9]
  L_CITES = [:cites1, :cites2, :cites3, :cites4]

	def existe_legislacion(lista, num)
		lista.each do |a|
			if a.nombreLegislacion == Fichas::Legislacion::TIPOS_LEGISLACIONES[num]
				return a
			end
		end
	end


end
