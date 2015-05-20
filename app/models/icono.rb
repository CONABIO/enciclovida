class Icono < ActiveRecord::Base
  self.primary_key='id'
  IR=%w(Animalia Plantae Fungi Prokaryotae Protoctista bar_reino)
  IA=%w(Mammalia Aves Reptilia Amphibia Actinopterygii Petromyzontida Myxini Chondrichthyes Cnidaria Arachnida Myriapoda Annelida Insecta Porifera Echinodermata Mollusca Crustacea bar_animalia)
  IP=%w(Bryophyta Pteridophyta Cycadophyta Gnetophyta Liliopsida Coniferophyta Magnoliopsida bar_plantae)
end