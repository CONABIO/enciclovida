module Bases
  def self.cual?(id)
    id_biotica = id/1000000 - 1                                         #para sacar el numero de base
    ActiveRecord::Base.establish_connection CONFIG.bases[id_biotica]    #se conecta a la base original
    id%1000000                                                          #regresa el id original
  end

  #para buscar en un rango de una base
  def self.limites(id)
    limite_inferior = (id/1000000)*1000000 + 1
    limite_superior = (id/1000000)*1000000 + 999999
    {:limite_inferior => limite_inferior, :limite_superior => limite_superior}
  end
end
