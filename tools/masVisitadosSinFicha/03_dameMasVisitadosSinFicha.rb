conFicha = File.readlines('taxonesConFicha.csv', chomp: true)
masVisitadas =File.readlines('taxonesMasVisitados.csv', chomp: true)

idsConFicha = conFicha.map do |cf|
	cf.gsub("%2F","/").split("/")[-2]
end
idsConFicha.uniq!
File.open('taxonesMasVisitadosSinFicha.csv', 'w'){ |f|
masVisitadas.each do |mv|
	unless	idsConFicha.include? mv
		f.write mv+"\n"
	end
end
}
