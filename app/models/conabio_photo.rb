class ConabioPhoto < Photo

  Photo.descendent_classes ||= []
  Photo.descendent_classes << self

  validate :licensed_if_no_user

  def sync
    new_photo = self.class.new_from_api_response(self.class.get_api_response(native_photo_id))
    cols = Photo.column_names - %w(id user_id native_photo_id type created_at updated_at)
    cols.each do |c|
      send("#{c}=", new_photo.send(c))
    end
    save
  end

  def self.search_conabio(taxon)
    return [] unless metadatos = taxon.metadatos

    metadatos.map do |resp|
      new_from_api_response(resp)
    end.compact
  end

  def self.get_api_response(photo_id)
    begin
      Metadato.find(photo_id)
    rescue
      nil
    end
  end

  def self.new_from_api_response(api_response, guardar = false, id = nil, options = {})
    copyright = api_response.artist.present? ? "#{api_response.artist} / Banco de Imágenes CONABIO" : 'Banco de Imágenes CONABIO'
    imagen = "#{CONFIG.bdi_imagenes.to_s}/#{api_response.path.sub('/fotosBDI/Toda la Base del BI/', '')}"

    nombre = imagen.split('/').last
    i = MiniMagick::Image.open(URI.encode(imagen))
    dimensiones = i.dimensions

    # Para ver que es el mayor y no se salga del standar las fotos (copia tamanios de flickr)
    if dimensiones.any? && dimensiones.length == 2
      lado = dimensiones[0].to_i > dimensiones[1].to_i ? 'w' : 'h'
    else
      lado ='w'
    end

    # Guarda la imagen en el servidor square de 75x75 en el servidor ,
    # ya que esta imagen no se dimensiona correctamente con css, y sirve para NaturaLista
    nombre_square = "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{nombre}"
    square = "#{URI.encode(imagen)}?#{lado == 'w' ? 'h' : 'w'}=75"
    i_square = MiniMagick::Image.open(square)
    i_square.crop('75x75+0+0')

    if guardar && id.present?
      Dir.mkdir(Rails.root.join('public', 'square_images', id.to_s).to_s) unless File.exists?(Rails.root.join('public', 'square_images', id.to_s).to_s)
      i_square.write(Rails.root.join('public', 'square_images', id.to_s, nombre_square).to_s)
    end

    new(options.merge(
            :large_url => "#{imagen}?#{lado}=1024",
            :medium_url => "#{imagen}?#{lado}=500",
            :small_url => "#{imagen}?#{lado}=240",
            :thumb_url => "#{imagen}?#{lado}=100",
            :native_photo_id => api_response.id,
            :square_url => "#{CONFIG.site_url}square_images/#{id}/#{nombre_square}",
            :original_url => imagen,
            :native_page_url => "#{CONFIG.bdi_fotoweb}#{api_response.transmission_reference}",
            :native_username => copyright,
            :native_realname => copyright,
            :license => 3
        ))
  end
end
