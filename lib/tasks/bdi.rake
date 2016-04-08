namespace :bdi do

  #@rutaBDI = Dir.new('/fotosBDI/Toda la Base del BI/')
  @rutaBDI = Dir.new('/')
  @url = "#{CONFIG.site_url}:4000/metadatos" # Bastante probable q no la deba ocupar, en caso de q así fuese, llama al dummy ws de ca
  @rutaFotos = 'metadato' # IDEM as above, accion a la cual ir en el mini ws dummy
  @workingDir = "/home/ggonzalez/" # IDEM as above, dir donde se leían los archivos de fotos
  @animales = 'Animales' # IDEM Nombre de archivos a leer
  @bacterias = 'Bacterias' # IDEM Nombre de archivos a leer
  @hongos = 'Hongos' # IDEM Nombre de archivos a leer
  @plantas = 'Plantas' # IDEM Nombre de archivos a leer
  @protozoarios = 'Protozoarios' # IDEM Nombre de archivos a leer

  @renombre = 	{	'Iptc.Application2.ObjectName'=>'object_name',
                  'Exif.Image.Artist' =>'artist',
                  'Exif.Image.Copyright' =>'copyright',
                  'Iptc.Application2.CountryName' =>'country_name',
                  'Iptc.Application2.ProvinceState' =>'province_state',
                  'Iptc.Application2.CountryCode' =>'country_code',
                  'Iptc.Application2.TransmissionReference' =>'transmission_reference',
                  'Iptc.Application2.Category' =>'category',
                  'Iptc.Application2.SuppCategory' =>'supp_category',
                  'Iptc.Application2.Keywords' =>'keywords',
                  'Xmp.fwc.CustomField6' =>'custom_field6',
                  'Xmp.fwc.CustomField7' =>'custom_field7',
                  'Xmp.fwc.CustomField12' =>'custom_field12',
                  'Xmp.fwc.CustomField13' =>'custom_field13'
  }

  @exiv2 = "exiv2 -pa" # Opcion para el exiv2 a llamar como system call
  @renombre.each do |k,v| @exiv2 << " -g #{k}" end # Bloque para llenar las opciones del exiv2

  desc "TODO"
  task deleteNotFound: :environment do
    a=Time.now
    m = Metadato.all.find_each do |x|
      next if File.exist?(x.path)
      x.object_name = 'PATOOOo'
      x.save
    end
    #m.each { |x|
    #}
    puts (Time.now-a).to_s

  end

  desc "TODO"
  task actualizaTabla_delayed: [:environment, :actualizaTabla] do
  end

  desc "TODO"
  task pruebita: :environment do
    #Metadato.delete()
  end
end
