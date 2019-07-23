require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
*** Este script crea los triggers necesarios para cada base y cada tabla

Usage:

  rails r tools/triggers.rb -d create    #para crear los triggers en todas las bases
  rails r tools/triggers.rb -d drop      #para borrar los triggers en todas las bases

  rails r tools/triggers.rb -d create 03-Hongos-Sept14    #para correr solo un conjunto de bases
  rails r tools/triggers.rb -d drop 03-Hongos-Sept14      #para correr solo un conjunto de bases
where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def argumento_a_trigger(arg, base)
  Rails.logger.debug "Argumento con: #{arg}" if OPTS[:debug]

  Bases::EQUIVALENCIA.each do |tabla,tabla_bio|
    trigger = ''
    if arg == 'create'
      modelo = I18n.t("nombres_modelos.#{tabla}") + 'Bio'
      primary_key = modelo.constantize.primary_key
      primary_key = primary_key.split if primary_key.is_a? String
      primary_key_sql = primary_key.map{|campo| "CAST(#{campo} AS VARCHAR)"}.join("+'-'+")

      trigger+= "CREATE TRIGGER [dbo].[validaciones_#{tabla}]\n"
      trigger+= "ON #{tabla_bio}\n"
      trigger+= "AFTER INSERT, UPDATE, DELETE\n"
      trigger+= "AS\n"

      #Evita un loop en SQL Server cuando se modifica de la maquina directa de Rails
      #Agregar posibles IP de desarrollo
      trigger+= "DECLARE @ip NVARCHAR(255);\n"
      trigger+= "DECLARE @sql VARCHAR(255);\n"
      trigger+= "SELECT @ip=[#{Bases.base_del_ambiente}].dbo.GetCurrentIP();\n"
      trigger+= "--SET @sql = 'INSERT INTO [#{Bases.base_del_ambiente}].dbo.ips (ip) VALUES ('''+@ip+''')';\n"
      trigger+= "--EXEC (@sql);\n"
      trigger+= "IF (@ip = '#{CONFIG.ip}') RETURN;\n"

      #Checa cual accion es
      trigger+= "DECLARE @accion as char(6);\n"
      trigger+= "SET @accion = (CASE WHEN EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED)\n"
      trigger+= "THEN 'update'\n"
      trigger+= "WHEN EXISTS(SELECT * FROM INSERTED)\n"
      trigger+= "THEN 'insert'\n"
      trigger+= "WHEN EXISTS(SELECT * FROM DELETED)\n"
      trigger+= "THEN 'delete'\n"
      trigger+= "ELSE NULL\n"
      trigger+= "END);\n"
      #Si no es ninguna de las accione anteriores, acaba
      trigger+= "IF (@accion IS NULL) RETURN;\n"

      #Es necesario hacer este loop asi de repetitivo ya que la clusula SELECT no se puede poner otro FROM (INSERTED, DELETED)
      trigger+= "IF @accion = 'delete'\n"
      trigger+= "BEGIN\n"
      trigger+= "DECLARE @ids VARCHAR(255);\n"

      #Parte de cursores para poder iterar
      trigger+= "DECLARE end_point_cursor CURSOR FOR\n"
      trigger+= "SELECT #{primary_key_sql} FROM DELETED;\n"
      trigger+= "OPEN end_point_cursor\n"
      trigger+= "FETCH NEXT FROM end_point_cursor INTO @ids\n"
      trigger+= "WHILE @@FETCH_STATUS = 0\n"
      trigger+= "BEGIN\n"
      trigger+= "EXEC [#{Bases.base_del_ambiente}].dbo.webservice 'a-las-plantas-las-endereza-el-cultivo-a-los-hombres-la-educacion-rosseau', @ids, '#{base}', @accion, '#{tabla}';\n"
      trigger+= "FETCH NEXT FROM end_point_cursor INTO @ids\n"
      trigger+= "END\n"

      #Cierra coenxiones del cursor
      trigger+= "CLOSE end_point_cursor;\n"
      trigger+= "DEALLOCATE end_point_cursor;\n"
      trigger+= "END\n"
      trigger+= "ELSE\n"
      trigger+= "BEGIN\n"

      #Segundo cursor
      trigger+= "DECLARE end_point_cursor CURSOR FOR\n"
      trigger+= "SELECT #{primary_key_sql} FROM INSERTED;\n"
      trigger+= "OPEN end_point_cursor\n"
      trigger+= "FETCH NEXT FROM end_point_cursor INTO @ids\n"
      trigger+= "WHILE @@FETCH_STATUS = 0\n"
      trigger+= "BEGIN\n"
      trigger+= "EXEC [#{Bases.base_del_ambiente}].dbo.webservice 'a-las-plantas-las-endereza-el-cultivo-a-los-hombres-la-educacion-rosseau', @ids, '#{base}', @accion, '#{tabla}';\n"
      trigger+= "FETCH NEXT FROM end_point_cursor INTO @ids\n"
      trigger+= "END\n"

      #Cierra conexiones del segundo cursor
      trigger+= "CLOSE end_point_cursor;\n"
      trigger+= "DEALLOCATE end_point_cursor;\n"
      trigger+= "END\n"

      Bases.ejecuta trigger
      Rails.logger.debug "Creo para: #{tabla}" if OPTS[:debug]
    else
      trigger+= "DROP TRIGGER [dbo].[validaciones_#{tabla}]"
      Bases.ejecuta trigger
      Rails.logger.debug "Borro para: #{tabla}" if OPTS[:debug]
    end
  end
end


start_time = Time.now

acciones = %w(create drop)                #posibles acciones
if ARGV.any? && acciones.include?(ARGV[0].downcase)
  if ARGV.count > 1
    ARGV.each_with_index do |base, index|
      next if index == 0
      if CONFIG.bases.include?(base)
        Bases.conecta_a base
        Rails.logger.debug "Con base: #{base}" if OPTS[:debug]
        argumento_a_trigger(ARGV[0].downcase, base)
      end
    end
  elsif ARGV.count == 1
    CONFIG.bases.each do |base|
      Bases.conecta_a base
      Rails.logger.debug "Con base: #{base}" if OPTS[:debug]
      argumento_a_trigger(ARGV[0].downcase, base)
    end
  end
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]