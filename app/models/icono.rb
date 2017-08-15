class Icono < ActiveRecord::Base
  #self.primary_key='id'
  IR=%w(Animalia Plantae Fungi Prokaryotae Protoctista)
  IA=%w(Mammalia Aves Reptilia Amphibia Actinopterygii Petromyzontida Myxini Chondrichthyes Cnidaria Arachnida Myriapoda Annelida Insecta Porifera Echinodermata Mollusca Crustacea)
  IP=%w(Bryophyta Pteridophyta Cycadophyta Gnetophyta Liliopsida Coniferophyta Magnoliopsida)

  Reinos = Especie.where(:nombre_cientifico => IR)
  Animales = Especie.where(:nombre_cientifico => IA)
  Plantas = Especie.where(:nombre_cientifico => IP)

end