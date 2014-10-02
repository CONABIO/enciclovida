module Bases
  def self.cual?(id)
    id_biotica = id/1000000 - 1                                         #para sacar el numero de base
    ActiveRecord::Base.establish_connection CONFIG.bases[id_biotica]    #se conecta a la base original
    id%1000000                                                          #id original
  end
end
