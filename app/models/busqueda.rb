class Busqueda
  POR_PAGINA = [50, 100, 200]
  POR_PAGINA_PREDETERMINADO = POR_PAGINA.first

  NIVEL_CATEGORIAS_HASH = {
      '>' => 'inferiores a',
      '>=' => 'inferiores o iguales a',
      '=' => 'iguales a',
      '<=' => 'superiores o iguales a',
      '<' => 'superiores a'
  }

  NIVEL_CATEGORIAS = [
      ['inferior o igual a', '>='],
      ['inferior a', '>'],
      ['igual a', '='],
      ['superior o igual a', '<='],
      ['superior a', '<']
  ]

  #Especie.datos_basicos.where("ancestry_ascendente_directo LIKE '1000001/8000007/8000008/8002485%' OR especies.id IN (1000001,8000007,8000008,8002485)").where("CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4) >= '7100'").caso_rango_valores('estatus', 2)

  def self.por_categoria(busqueda, distinct = false)
    # Las condiciones y el join son los mismos pero cambia el select
    sql = "select('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4) AS nivel,"
    sql << 'nombre_categoria_taxonomica,'

    if distinct
      sql << 'count(DISTINCT especies.id) as cuantos'
    else
      sql << 'count(CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4)) as cuantos'
    end
    sql << "').categoria_taxonomica_join"

    busq = busqueda.gsub('datos_basicos', sql)
    busq << ".group('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4), nombre_categoria_taxonomica')"
    busq << ".order('nivel')"

    if distinct
      query_limpio = Bases.distinct_limpio(eval(busq).to_sql)
      query_limpio << ' ORDER BY nivel ASC'
      Especie.find_by_sql(query_limpio)
    else
      eval(busq)
    end
  end

  # Hace el conteo de los resultados por categoria en la busqueda basica
  def self.por_categoria_basica(sql)
    sql_dividido = sql.split('.')
    sql_dividido[1] = "select('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4) AS nivel,
nombre_categoria_taxonomica,count(DISTINCT especies.id) as cuantos').especies_join.categoria_taxonomica_join.adicional_join"
    sql_dividido << "group('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4), nombre_categoria_taxonomica')"
    sql_dividido << "order('nivel')"

    sql = sql_dividido.join('.')
    query_limpio = Bases.distinct_limpio(eval(sql).to_sql)
    query_limpio << ' ORDER BY nivel ASC'
  end

  def self.por_arbol(busqueda, sin_filtros=false)
    if sin_filtros #La búsqueda que realizaste no contiene filtro alguno
      busq = busqueda.gsub("datos_basicos", "datos_arbol_sin_filtros")
      busq = busq.sub(/\.where\(\"CONCAT.+/,'')
      busq << ".order('arbol')"
      eval(busq)
    else # Las condiciones y el join son los mismos pero cambia el select, para desplegar el checklist
      #sql = 'select("ancestry_ascendente_directo+\'/\'+cast(especies.id as nvarchar) as arbol")'[
      busq = busqueda.gsub("datos_basicos", "datos_arbol_con_filtros")
      eval(busq)
    end
  end

  def self.asigna_grupo_iconico
    # Itera los grupos y algunos reinos
    animalia_plantae = %w(Animalia Plantae)
    complemento_reinos = %w(Protoctista Fungi Prokaryotae)
    iconos_plantae = %w(Bryophyta Pteridophyta Cycadophyta Gnetophyta Liliopsida Coniferophyta Magnoliopsida)

    Icono.all.map{|ic| [ic.id, ic.taxon_icono]}.each do |id, grupo|
      puts grupo
      ad = Adicional.none
      taxon = Especie.where(:nombre_cientifico => grupo).first
      puts "Hubo un error al buscar el taxon: #{grupo}" unless taxon

      # solo animalia y plantae
      if animalia_plantae.include?(grupo)
        if ad = taxon.adicional
          ad.icono_id = id
        else
          ad = taxon.crea_con_grupo_iconico(id)
        end

      else  # Los grupos y reinos menos animalia y plantae
        nivel = iconos_plantae.include?(grupo) ? 3000 : 3100
        descendientes = taxon.subtree_ids

        # Itero sobre los descendientes
        descendientes.each do |descendiente|
          begin
            taxon_desc = Especie.find(descendiente)
          rescue
            next
          end

          puts "\tDescendiente de #{grupo}: #{taxon_desc.nombre_cientifico}"

          if !complemento_reinos.include?(grupo)
            # No poner icono inferiores de clase
            clase_desc = taxon_desc.categoria_taxonomica
            nivel_desc = "#{clase_desc.nivel1}#{clase_desc.nivel2}#{clase_desc.nivel3}#{clase_desc.nivel4}".to_i
            puts "\t\t#{nivel_desc > nivel ? 'Inferior a clase' : 'Superior a clase'}"
            next if nivel_desc > nivel
          end

          if ad = taxon_desc.adicional
            ad.icono_id = id
          else
            ad = taxon_desc.crea_con_grupo_iconico(id)
          end

          # Guarda el record
          ad.save if ad.changed?

        end  # Cierra el each de descendientes
      end

      # Por si no estaba definido cuando termino el loop
      next unless ad.present?

      # Guarda el record
      ad.save if ad.changed?

    end  # Cierra el iterador de grupos
  end
end
