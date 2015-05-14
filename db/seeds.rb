iconos =
[
  %w(Animalia Animales icon-animales #6c3630),
  %w(Mammalia Mamíferos icon-mamifero #9d4c47),
  %w(Aves Aves icon-aves #9b7845),
  %w(Reptilia Reptiles icon-reptil #999744),
  %w(Amphibia Anfibios icon-anfibio #7a9944),
  ['Actinopterygii', 'Peces óseos', 'icon-peces', '#44997d'],
  %w(Petromyzontida Lampreas icon-lampreas #449999),
  %w(Myxini Mixines icon-mixines #437395),
  ['Chondrichthyes', 'Tiburones, rayas y quimeras', 'icon-tiburon_raya', '#284559'],
  ['Cnidaria', 'Medusas, corales y anémonas', 'icon-medusasc', '#56686f'],
  %w(Arachnida Arácnidos icon-arana #6c4e30),
  ['Myriapoda', 'Ciempiés y milpies', 'icon-ciempies', '#7b5637'],
  ['Annelida', 'Lombrices y gusanos marinos', 'icon-lombrices', '#956e43'],
  %w(Insecta Insectos icon-insectos #aa774d),
  %w(Porifera Esponjas icon-porifera #a8734c),
  ['Echinodermata', 'Estrellas y erizos de mar', 'icon-estrellamar', '#865a3c'],
  ['Mollusca', 'Caracoles, almejas y pulpos', ' icon-caracol', '#aa7961'],
  %w(Crustacea Crustáceos icon-crustaceo #a0837c),

  %w(Plantae Plantas icon-plantas #3f7e54),
  ['Bryophyta', 'Musgos, hepáticas y antoceros', 'icon-musgo', '#7a7544'],
  %w(Pteridophyta Helechos icon-helecho #adb280),
  %w(Cycadophyta Cícadas icon-cicada #545a35),
  %w(Gnetophyta Canutillos icon-canutillos #394822),
  ['Liliopsida', 'Pastos y palmeras', 'icon-pastos_palmeras', '#114722'],
  ['Coniferophyta', 'Pinos y cedros', 'icon-pino', '#788c4a'],
  ['Magnoliopsida', 'Margaritas y magnolias', 'icon-magnolias', '#495925'],

  %w(Protoctista Arquea icon-arquea #0c4354),

  %w(Fungi Hongos icon-hongos #af7f45),

  %w(Prokaryotae Bacterias icon-bacterias #0e5f59)
]

iconos.each do |taxon_icono, nombre_icono, icono, color_icono|
  Icono.create(taxon_icono: taxon_icono, nombre_icono: nombre_icono, icono: icono, color_icono: color_icono)
end