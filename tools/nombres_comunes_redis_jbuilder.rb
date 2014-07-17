require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta todas los nombres comunes a redis:
Se almacenara el .json en db/redis/nombres_comunes.json

Usage:

  rails r tools/nombres_comunes_redis_jbuilder.rb

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def system_call(cmd)
  puts "Ejecutando ... #{cmd}" if OPTS[:debug]
  system cmd
end

def batches(file)
  limit=100
  orden='00'
  url = "http://#{CONFIG.ip}:#{CONFIG.port}/nombres_comunes.json"
  nc = NombreComun.count
  batch = nc%limit > 0 ? (nc/limit)+1 : nc/limit
  puts batch
  if batch > 0
    File.open(file,'w') do |f|
      (1..batch).each do |b|
        data = b == 1 ? open("#{url}?limit=#{limit}").read : open("#{url}?limit=#{limit}&offset=#{b-1}#{orden}").read   #lee el contenido del request
        f.puts data
      end
    end
  end
end

start_time = Time.now
file = 'db/redis/nombres_comunes.json'
File.delete(file) if File.exists?(file)
batches(file)
puts "Termino la exportación al archivo: #{file} en #{Time.now - start_time} seg"