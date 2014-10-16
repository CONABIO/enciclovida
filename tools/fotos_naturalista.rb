require 'rubygems'
require 'trollop'
require 'rest_client'
require 'json'

OPTS = Trollop::options do
  banner <<-EOS
Importa las fotos de NaturaLista desde el archivo .json para un manejo mas rapido entre la informacion.

*** En caso de estar en SQL Server, el volcado es necesario para esta accion
*** tools/bitacoras/info_naturalista     <-------- path por default
Usage:

  rails r tools/fotos_naturalista.rb -d nombre_archivo

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def search
  json = ''
  file = File.read("#{@path}/#{ARGV[0]}")
  data = JSON.parse(file)

  data.keys.uniq.each do |id|
    begin
      taxon = Especie.find(id)
      taxon_photos(data[id], taxon)
    rescue
      next
    end
  end
end

def photo_type(url)
  return 'FlickrPhoto' if url.include?("staticflickr\.com") || url.include?("static\.flickr\.com")
  return 'EolPhoto' if url.include? "media\.eol\.org"
  return 'NaturalistaPhoto' if url.include? "static\.inaturalist\.org"
  return 'WikimediaCommonsPhoto' if url.include? "upload\.wikimedia\.org"
end

def taxon_photos(data, taxon)
  photos = []
  data['taxon_photos'].each do |pho|     #Guarda todas las fotos asociadas del taxon
    local_photo =  Photo.where(:native_photo_id => pho['photo']['native_photo_id'], :type => photo_type(pho['photo']['thumb_url']))
    photo = local_photo.count == 1 ? local_photo.first : Photo.new     #Crea o actualiza la foto

    photo.usuario_id = @user.id
    photo.native_photo_id = pho['photo']['native_photo_id']
    photo.square_url = pho['photo']['square_url']
    photo.thumb_url = pho['photo']['thumb_url']
    photo.small_url = pho['photo']['small_url']
    photo.medium_url = pho['photo']['medium_url']
    photo.large_url = pho['photo']['large_url']
                                                                       #photo.original_url = pho['photo']['original_url']
    photo.created_at = pho['photo']['created_at']
    photo.updated_at = pho['photo']['updated_at']
    photo.native_page_url = pho['photo']['native_page_url']
    photo.native_username = pho['photo']['native_username']
    photo.native_realname = pho['photo']['native_realname']
    photo.license = pho['photo']['license']
    photo.type = photo_type(pho['photo']['thumb_url'])
    photos << photo
  end

  puts "    tiene #{photos.count} fotos asociadas..."  if OPTS[:debug] && photos.present?
  taxon.photos.destroy_all   #es necesario para asignar las nuevas fotos
  taxon.photos = photos
  taxon.save if photos.length > 0
end

def system_call(cmd)
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end


start_time = Time.now

exit(0) if ARGV.count != 1    # por si no puso argumento de carpeta o puso de mas
@path = 'tools/bitacoras/info_naturalista'
exit(0) if !File.exists?("#{@path}/#{ARGV[0]}")

unless @user = Usuario.where(:usuario => 'calonso').first
  puts 'No encontro el usuario' if OPTS[:debug]
  exit(0)
end

@site = 'http://conabio.inaturalist.org'
system_call('rake tmp:clear')
search

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]