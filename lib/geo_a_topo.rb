class GeoATopo

  # Regresa en formato topojson
  def dame_topojson(collection)
    source = open('./lib/assets/topojson.js').read
    ExecJS.runtime = ExecJS::Runtimes::Node
    context = ExecJS.compile(source)

    context.eval("topojson.topology({collection: #{collection} }, 1e4)")
  end
end