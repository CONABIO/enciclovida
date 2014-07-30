require 'rubygems'
require 'trollop'
require 'rest_client'
require 'json'

OPTS = Trollop::options do
  banner <<-EOS
Importa los ID's de NaturaLista para un manejo mas rapido entre la informacion, puede ser sin
autenticacion ya que esa informacion es publica.

*** Este script practicamente se corre solo una vez ya que los ID's de las espcies no cambian, y ademas pone los
mismos record de la tabla taxon_photos

Usage:

  rails r tools/naturalista_ids.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def search
  #Especie.find_each do |taxon|
  Especie.order(:id).limit(100).each do |t|
    puts "Procesando... #{t.nombre_cientifico}" if OPTS[:debug]

    next unless !t.nombre_cientifico.include?('(')  #existen unos taxones con una estructura erronea
    response = RestClient.get "#{@site}/taxa/search.json?q=#{t.nombre_cientifico}"
    data = JSON.parse(response)

    if data.present?
      data.each do |d|
        taxon_photos(d, t)
      end
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
  return if data['name'] != taxon.nombre_cientifico     #busca que coincidan en el nombre y que no tengan una estructura distinta

  puts "  encontro el mismo nombre..."  if OPTS[:debug]
  local_proveedor = taxon.proveedor     #para guardar el ID en el Proveedor
  p = local_proveedor.present? ? local_proveedor : Proveedor.new
  p.naturalista_id = data['id']
  p.especie_id = taxon.id
  p.new_record? ? p.save : p.save if p.changed?

  photos = []
  data['taxon_photos'].each do |pho|     #Guarda todas las fotos asociadas del taxon
    local_photo =  Photo.where(:native_photo_id => pho['photo']['native_photo_id'], :type => photo_type(pho['photo']['thumb_url']))
    photo = local_photo.count == 1 ? local_photo.first : Photo.new     #Crea o actualiza la foto

    #photo.usuario_id = @user.id
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
  taxon.photos = photos
  taxon.save if photos.present?
end

def system_call(cmd)
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end


start_time = Time.now
unless @user = Usuario.where(:usuario => 'calonso').first
  puts 'No encontro el usuario'
  exit(0)
end
@site = 'http://conabio.inaturalist.org'
system_call('rake tmp:clear')
puts 'Iniciando la importacion de ID\'s...' if OPTS[:debug]
search
puts "Termino la exportación de archivos json en #{Time.now - start_time} seg" if OPTS[:debug]