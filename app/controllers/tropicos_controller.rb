class TropicosController < ApplicationController

  def tropico_especie

    taxonNC = Especie.find(params['id']).nombre_cientifico
    ts_req = Tropicos_Service.new

    @name_id = ts_req.get_id_name('poa annua')

    @array = ts_req.get_media(@name_id[0]["NameId"])
  end


end


=begin

      if Proveedor.where(:especie_id => q).exists?
        id_especie = Proveedor.where(:especie_id => q)
        puts("Existe: #{id_especie}")
      else
        # Buscarla y guardarla
        # Proveedor.create(especie_id: '', tropico_id: '')
        puts("No existe")
      end


      # Para obtener el nombre cientifico de la esoecie
      # taxonNC = Especie.find(ID).nombre_cientifico



      # Supongamos que recibe el id de la especie a buscar...
      # A partir del id, buscar en la tabla proveedores si ya existe este id:


      # Supongamos que si existe, por tanto, ahora buscamos si existe el id de tropicos..
      # Si si, obtener el id
      #
      #
      # Si no existió, agregar un nuevo registro


      # Formato de fecha hora en el que se guardará
      # Time.now.strftime("%Y-%m-%d %H:%M:%S")
      #

      format = 'json'
      search_type = 'exact'
      name = q

      # Para obtener el NameId de especie
      query = "http://services.tropicos.org/Name/Search?name=#{name.gsub(' ', '+')}&type=#{search_type}&apikey=#{CONFIG.tropicos_api_key}&format=#{format}"


      begin
        pre_resu = RestClient.get query
        # Dado que el search_type es 'exact', podemos asegurar que siempre devolverá un elemento
        resu = JSON.parse(pre_resu)[0]
      rescue => e
        return {estatus: false, msg: e}
      end

      puts(query)
      puts("El nombre es: #{resu['ScientificName']} y su respectivo id: #{resu['NameId']}")


=end

