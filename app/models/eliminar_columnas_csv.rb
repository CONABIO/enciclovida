require 'csv'

input_file = 'exoticas_invasoras.csv'
output_file = 'exoticas_invasoras_limpio.csv'

# Función para intentar diferentes codificaciones
def read_file_with_encoding(file_path)
  encodings = ['UTF-8', 'ISO-8859-1', 'Windows-1252', 'BOM|UTF-8']
  
  encodings.each do |encoding|
    begin
      content = File.read(file_path, encoding: encoding)
      # Verificar si la lectura fue exitosa
      if content.valid_encoding?
        puts "✓ Archivo leído con codificación: #{encoding}"
        return content
      end
    rescue ArgumentError, Encoding::InvalidByteSequenceError
      next
    end
  end
  
  # Si ninguna funciona, intentar con binario y luego forzar UTF-8
  content = File.read(file_path, encoding: 'ASCII-8BIT')
  content.encode!('UTF-8', invalid: :replace, undef: :replace, replace: '?')
  puts "⚠️  Usando codificación forzada a UTF-8 con reemplazo de caracteres inválidos"
  return content
end

puts "Procesando archivo: #{input_file}"

# Leer el archivo con la codificación correcta
content = read_file_with_encoding(input_file)

# Parsear el CSV manualmente
lines = content.lines
headers = nil
data = []

lines.each_with_index do |line, index|
  # Limpiar la línea de caracteres problemáticos
  line = line.encode('UTF-8', invalid: :replace, undef: :replace)
  
  begin
    if index == 0
      headers = CSV.parse_line(line)
    else
      row = CSV.parse_line(line)
      if row && headers && row.size == headers.size
        data << row
      end
    end
  rescue CSV::MalformedCSVError
    # Si falla el parsing, intentar un enfoque más simple
    row = line.strip.split(',')
    if index == 0
      headers = row
    elsif row && headers && row.size == headers.size
      data << row
    end
  end
end

# Filtrar y guardar
filtered_data = data.select do |row|
  row_hash = headers.zip(row).to_h
  enciclovida_id = row_hash['enciclovida_id']
  !(enciclovida_id.nil? || enciclovida_id.to_s.strip.empty?)
end

# Guardar el nuevo CSV
CSV.open(output_file, 'w') do |csv|
  csv << headers
  filtered_data.each { |row| csv << row }
end

puts "\n✅ Proceso completado!"
puts "📊 Estadísticas:"
puts "   Filas originales: #{data.size}"
puts "   Filas filtradas (con enciclovida_id): #{filtered_data.size}"
puts "   Filas eliminadas: #{data.size - filtered_data.size}"
puts "   Nuevo archivo creado: #{output_file}"

# Mostrar ejemplos de filas eliminadas
if data.size > filtered_data.size
  puts "\n🔍 Ejemplos de filas eliminadas:"
  count = 0
  data.each do |row|
    row_hash = headers.zip(row).to_h
    enciclovida_id = row_hash['enciclovida_id']
    if (enciclovida_id.nil? || enciclovida_id.to_s.strip.empty?) && count < 5
      puts "   ID: #{row_hash['Id_INVAS_COMPLETO']} - #{row_hash['Nombre científico'] || row_hash['Nombre cientĂ­fico']}"
      count += 1
    end
  end
end