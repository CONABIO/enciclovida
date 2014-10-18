# Maximo 5 argumentos (tiempos tomados para todas las bases)

# 1.3 seg
rails r tools/atributos_adicionales.rb -d create $1 $2 $3 $4 $5


# 6359.2 seg
rails r tools/ancestry_ascendente_directo_sql.rb -d $1 $2 $3 $4 $5


# 6303.9 seg
rails r tools/ancestry_ascendente_obligatorio_sql.rb -d $1 $2 $3 $4 $5


# 1804.4 seg
rails r tools/nombre_comun_principal_sql.rb -d $1 $2 $3 $4 $5


# 4971.3 seg
rails r tools/nombre_cientifico_sql.rb -d $1 $2 $3 $4 $5

#
rails r tools/ancestry_regiones_sql.rb -d $1 $2 $3 $4 $5

