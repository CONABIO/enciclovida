start_time = Time.now
puts "Inicie en #{start_time} " 


Metadato.all.each do |f|
  print "\nMetadato.id = #{f.id.to_s} "
  f_url =  URI.encode("http://bdi.conabio.gob.mx:5050"+f.path[29..-1])
  print f_url
next if (Net::HTTP.get_response(URI(f_url)).class != "Net::HTTPNotFound")
puts " <----- Este lo borro (#{f_url})"
Photo.find_by_native_photo_id(f.id.to_s).destroy
f.destroy
end

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
