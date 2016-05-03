#Para correr en ecolibri, o donde se tenga montado mount -t cifs "//bdi/FotoWare Assets" /fotosBDI -o user=fotoweb
start_time = Time.now
puts "Inicie en #{start_time} " 


Metadato.all.each do |m|
  print "\nMetadato.id = #{m.id.to_s} "
  print m.path.inspect
  next if File.file?(f.path.inspect)
puts " <----- Este lo borro (#{m_url})"
  p = Photo.find_by_native_photo_id(m.id.to_s)
  p.destroy if p
  m.destroy
end

puts "Termino en #{Time.now - start_time} seg"
