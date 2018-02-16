class GeoATopo

  # Regresa en formato topojson
  def dame_topojson(collection)
    source = open('./lib/assets/topojson.js').read
    ExecJS.runtime = ExecJS::Runtimes::Node
    context = ExecJS.compile(source)

    context.eval("topojson.topology({collection: #{collection} }, 1e4)")
  end

  # Devuelve el topojson con un comando de linux
  def dame_topojson_system(opc = {})
    res = system("geo2topo -q #{opc[:q]} #{opc[:i]} > #{opc[:tmp]}")

    if res
      res = system("toposimplify -p #{opc[:p]} #{opc[:tmp]} > #{opc[:o]}")
    end

    File.delete(opc[:tmp])
    res
  end
end