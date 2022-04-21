OPTS = Trollop::options do
  banner <<-EOS
Partiendo de un archivo validado en enciclovida, asocia los estados de las zonas pesqueras que tienen presencial en el SNIB.
Adicionalmente pega la zona de acuerdo al semaforo de consumo responsable.
Al final ya solo falta unir los archivos, el original de COBI, la validacion de enciclovida y la asociación con las regiones

Usage:

rails r tools/COBI/validacion_archivo.rb -d /ruta/del/archivo

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

PACIFICO_NORTE = { 31 => "Baja California Sur", 32 => "Baja California" }
GOLFO_DE_CALIFORNIA = { 5 => "Sinaloa", 6 => "Sonora", 16=> "Nayarit", 31 => "Baja California Sur" ,32 => "Baja California" }
PACIFICO_SUR = { 14 => "Michoacán", 18 => "Oaxaca", 20 => "Guerrero", 22 => "Jalisco", 27 => "Chiapas", 28 => "Colima" }
GOLFO_DE_MEXICO_NORTE = { 8 => "Tamaulipas", 10 => "Veracruz" }
GOLFO_DE_MEXICO_SUR = { 7 => "Tabasco", 11 => "Yucatán", 30 => "Campeche" }
CARIBE = { 3 => "Quintana Roo" }
ESTADOS = (PACIFICO_NORTE.keys + GOLFO_DE_CALIFORNIA.keys + PACIFICO_SUR.keys + GOLFO_DE_MEXICO_NORTE.keys + GOLFO_DE_MEXICO_SUR.keys + CARIBE.keys).uniq
ZONAS = ["Pacífico norte", "Golfo de California", "Pacífico sur", "Golfo de México norte", "Golfo de México sur", "Caribe"]

def busca_zonas_semaforo(id)
    pez = Pmc::Pez.where(especie_id: id).first
    zonas = []

    if pez
        codigo_zonas = pez.valor_zonas.split("")
        
        codigo_zonas.each_with_index do |codigo, index|
            case codigo
            when "v"
                zonas << "#{ZONAS[index]} - verde"
            when "a"
                zonas << "#{ZONAS[index]} - amarillo"
            when "r"
                zonas << "#{ZONAS[index]} - rojo"
            when "s"
                zonas << "#{ZONAS[index]} - sin información"
            when "n"
                zonas << "#{ZONAS[index]} - no está presente"
            end
        end
    else
        return zonas
    end
    
    zonas
end

def asocia_info(id)
    begin
        especie = Especie.find(id)
        catalogo_id = especie.scat.catalogo_id
    rescue
        return {}
    end

    registros = Geoportal::Snib.where(idnombrecatvalidoorig: catalogo_id, entid: ESTADOS)
    info = {}

    ZONAS.each do |zona|
        info[zona] = []
    end

    registros.each do |registro|

        if PACIFICO_NORTE.has_key?(registro.entid)
            info["Pacífico norte"] << PACIFICO_NORTE[registro.entid]
        end

        if GOLFO_DE_CALIFORNIA.has_key?(registro.entid)
            info["Golfo de California"] << GOLFO_DE_CALIFORNIA[registro.entid]
        end
        
        if PACIFICO_SUR.has_key?(registro.entid)
            info["Pacífico sur"] << PACIFICO_SUR[registro.entid]
        end
        
        if GOLFO_DE_MEXICO_NORTE.has_key?(registro.entid)
            info["Golfo de México norte"] << GOLFO_DE_MEXICO_NORTE[registro.entid]
        end
        
        if GOLFO_DE_MEXICO_SUR.has_key?(registro.entid)
            info["Golfo de México sur"] << GOLFO_DE_MEXICO_SUR[registro.entid]
        end
        
        if CARIBE.has_key?(registro.entid)
            info["Caribe"] << CARIBE[registro.entid]
        end        
    end

    # Quitamos los repetidos
    ZONAS.each do |zona|
        info[zona].uniq!
    end

    # Asocia la in formacion del semaforo
    info["Zonas en el semáforo"] = busca_zonas_semaforo(id)
    info
end

def guarda_archivo(datos_extra)
    xlsx = RubyXL::Workbook.new
    sheet = xlsx[0]
    sheet.sheet_name = 'Validacion'
    fila = 1  # Para no sobreescribir la cabecera
    columna = 0

    # Para la cabecera
    ZONAS.each do |zona|
        sheet.add_cell(0,columna,zona)
        columna+= 1
    end

    sheet.add_cell(0,columna,"Zonas en el semáforo")    

    # Itera los datos de las zonas
    datos_extra.each do |dato|
        columna = 0
        dato.each do |zona, estados|
            sheet.add_cell(fila,columna,estados.join("\n "))  
            columna+= 1 
        end

        fila+= 1
    end
    
    # Escribe el excel en cierta ruta
    ruta_dir = Rails.root.join('tools','COBI')
    nombre_archivo = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + '_validacion_enciclovida_snib.xlsx'
    FileUtils.mkpath(ruta_dir, :mode => 0755) unless File.exists?(ruta_dir)
    ruta_excel = ruta_dir.join(nombre_archivo)
    xlsx.write(ruta_excel)    
end

def leyendo_archivo
    archivo = ARGV[0]
    xlsx = Roo::Excelx.new(archivo, packed: nil, file_warning: :ignore)
    sheet = xlsx.sheet(0)  # toma la primera hoja por default
    datos_extra = []

    sheet.parse().each_with_index do |f, index|
        id = f[3]  # La pocision del Identificado unico
        
        if id.present?  # Quiere decir que si es un taxon de enciclovida
            datos_extra << asocia_info(id)
        else
            datos_extra << {}
        end
    end

    guarda_archivo(datos_extra)
end


start_time = Time.now

leyendo_archivo

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
