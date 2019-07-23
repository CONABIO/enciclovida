# Para correr en ecolibri, o donde se tenga montado mount -t cifs "//bdi/FotoWare Assets" /fotosBDI -o user=fotoweb
# sudo mount -t cifs "//bdi/FotoWare Assets" /fotosBDI -o user=fotoweb
# ó
# sudo mount -t cifs "//200.12.166.172/FotoWare Assets" /fotosBDI -o user=fotoweb
# dependiendo si el dns resuelve //bdi

# rails r tools/quitaFotos.rb

start_time = Time.now
Rails.logger.debug "Inicie en #{start_time} "


Metadato.all.each do |m|
  next if File.file?(m.path)
  print "\nMetadato.id = #{m.id.to_s} "
  print m.path.inspect
  Rails.logger.debug " <----- Este lo borro"
  p = Photo.find_by_native_photo_id(m.id.to_s)
  p.destroy if p
  m.destroy
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg"

