var Hapi = require("hapi");
const Joi = require("joi");
_ = require("lodash");
const query = require("./controller/query.js");

var server = new Hapi.Server({
  connections: {
    routes: {
      timeout: {
        server: 1000 * 60 * 10,
        socket: false,
      },
      cors: true,
    },
  },
});

server.connection({
  port: 9002,
  labels: ["api"],
});

server.register(
  [
    require("inert"),
    require("vision"),
    {
      register: require("hapi-swaggered"),
      options: {
        tags: {
          "foobar/test": "Example foobar description",
        },
        info: {
          title: "Busca por region, especie o ejemplares",
          description: "",
          version: "1.0",
        },
      },
    },
    {
      register: require("hapi-swaggered-ui"),
      options: {
        title: "Enciclovida API",
        path: "/docs",

        swaggerOptions: {
          validatorUrl: null,
        },
      },
    },
  ],
  {
    select: "api",
  },
  function (err) {
    if (err) {
      throw err;
    }

    server.route({
      path: "/",
      method: "GET",
      handler: function (request, reply) {
        reply.redirect("/docs");
      },
    });

    server.route({
      path: "/especies/busqueda/basica/{q}",
      method: "GET",
      config: {
        tags: ["api"],
        description:
          "Busca un nombre cómun o científico, puede contener el nombre o tener un error de ortografía",
        notes: "---",
        validate: {
          params: {
            q: Joi.string().required().description("Nombre común o científico"),
          },
        },
        handler: function (request, reply) {
          var url =
            SERVER +
            "/busquedas/resultados.json?busqueda=basica&nombre=" +
            request.params.q;
          query.ajaxRequest(url, reply);
        },
      },
    });

    server.route({
      path: "/especies/busqueda/avanzada",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Búsqueda avanzada de especies con diversos filtros",
        notes: "---",
        validate: {
          query: {
            nombre: Joi.string().description("Nombre común o científico"),
            id: Joi.number()
              .integer()
              .description("El identificador de la especie"),
            cat: Joi.string()
              .default("7100")
              .valid([
                "1100",
                "2100",
                "3100",
                "4100",
                "5100",
                "6100",
                "7100",
                "1000",
                "2000",
                "3000",
                "4000",
                "5000",
                "6000",
                "7000",
              ])
              .description("Solo taxones con la categoria taxonómica ..."),
            nivel: Joi.string()
              .default("=")
              .valid(["=", ">=", ">", "<=", "<"])
              .description("Operador relacionado al campo cat"),
            edo_cons: Joi.array().description(
              "La categoría de riesgo,<br />NOM: 17,15,14,16<br />IUCN: 29,28,27,26,25<br />CITES: 22,23,24"
            ),
            dist: Joi.array().description("El tipo de distribución: 3,7,10,6"),
            prior: Joi.array().description(
              "Valor de la especie, proiritaria para la conservación: 1033,1034,1035"
            ),
            pagina: Joi.number()
              .integer()
              .default(1)
              .description("El número de pagina"),
            por_pagina: Joi.string()
              .default(50)
              .valid(["50", "100", "200", "500", "1000"])
              .description("Los resultados por pagina"),
          },
        },
        handler: function (request, reply) {
          var url =
            SERVER +
            "/busquedas/resultados.json?busqueda=avanzada&por_pagina=50&commit=Buscar";
          var req = request.query;

          if (req.id !== undefined) {
            url += "&id=" + req.id;
            if (req.cat !== undefined && req.nivel !== undefined)
              url += "&cat=" + req.cat + "&nivel=" + req.nivel;
          } else {
            if (req.nombre !== undefined) url += "&nombre=" + req.nombre;
          }

          if (req.edo_cons !== undefined) {
            _.forEach(req.edo_cons, function (value) {
              url += "&edo_cons[]=" + value;
            });
          }

          if (req.dist !== undefined) {
            _.forEach(req.dist, function (value) {
              url += "&dist[]=" + value;
            });
          }

          if (req.prior !== undefined) {
            _.forEach(req.prior, function (value) {
              url += "&prior[]=" + value;
            });
          }

          if (req.pagina !== undefined) url += "&pagina=" + req.pagina;
          if (req.por_pagina !== undefined)
            url += "&por_pagina=" + req.por_pagina;

          query.ajaxRequest(url, reply);
        },
      },
    });

    server.route({
      path: "/especies/busqueda/region",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Búsqueda por región con diversos filtros",
        notes: "---",
        validate: {
          query: {
            especie_id: Joi.number()
              .integer()
              .description(
                "El identificador de la especie, si tambien se anota el grupo taxónomico, este id tiene presedencia"
              ),
            region_id: Joi.number()
              .integer()
              .description("El identificador de la región"),
            tipo_region: Joi.string().description(
              "El tipo de región: estado, municipio, anp"
            ),
            grupo: Joi.number()
              .integer()
              .description(
                "Grupo taxonómico: 22653, 22655, 22647, 22654, 213482, 22987, 22651, 22650, 66500, 16912, 40672, 56646, 40658, 66499, 129550, 40659, 40657, 135296, 135299, 135313, 135316, 135314, 135324, 135306"
              ),
            edo_cons: Joi.array().description(
              "La categoría de riesgo,<br />NOM: 17,15,14,16<br />IUCN: 29,28,27,26,25<br />CITES: 22,23,24"
            ),
            dist: Joi.array().description("El tipo de distribución: 3,7,10,6"),
            uso: Joi.array().description(
              "El uso: 11-4-0-0-0-0-0, 11-16-0-0-0-0-0, 11-5-0-0-0-0-0, 11-40-1-0-0-0-0, 11-40-2-0-0-0-0, 11-8-0-0-0-0-0, 11-9-0-0-0-0-0, 11-10-0-0-0-0-0, 11-11-0-0-0-0-0, 11-13-0-0-0-0-0, 11-15-0-0-0-0-0, 11-14-0-0-0-0-0"
            ),
            amb: Joi.array().description(
              "El ambiente: 1024, 1025, 1026, 1027, 1207, 1208, 1209, 1210"
            ),
            pagina: Joi.number()
              .integer()
              .default(1)
              .description("El número de pagina"),
          },
        },
        handler: function (request, reply) {
          var url = SERVER + "/explora-por-region/especies.json?";
          var req = request.query;

          if (req.pagina !== undefined) url += "&pagina=" + req.pagina;
          else url += "&pagina=1";

          if (req.especie_id !== undefined)
            url += "&especie_id=" + req.especie_id;

          if (req.region_id !== undefined) url += "&region_id=" + req.region_id;

          if (req.tipo_region !== undefined)
            url += "&tipo_region=" + req.tipo_region;

          if (req.grupo !== undefined && req.especie_id === undefined)
            url += "&especie_id=" + req.grupo;

          if (req.edo_cons !== undefined) {
            _.forEach(req.edo_cons, function (value) {
              url += "&edo_cons[]=" + value;
            });
          }

          if (req.dist !== undefined) {
            _.forEach(req.dist, function (value) {
              url += "&dist[]=" + value;
            });
          }

          query.ajaxRequest(url, reply);
        },
      },
    });

    server.route({
      path: "/especie/snib/ejemplares",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Regresa un array con todos los ejemplares de la especie",
        notes:
          "Opciones como la region y el tipo de region son opcionales (default a nivel nacional)",
        validate: {
          query: {
            catalogo_id: Joi.string()
              .required()
              .description("Identificador del catalogo centralizado"),
            region_id: Joi.number().description(
              "Para más información, consultar la sección regiones"
            ),
            tipo_region: Joi.string()
              .valid(["estado", "municipio", "anp"])
              .description(
                "De acuerdo al tipo de region se asocia el campo del region_id, los aceptados son: estado, municipio o anp"
              ),
          },
        },
        handler: function (request, reply) {
          var url = SERVER + "/explora-por-region/ejemplares?";
          var req = request.query;

          if (req.catalogo_id !== undefined)
            url += "catalogo_id=" + req.catalogo_id;

          if (req.region_id !== undefined) url += "&region_id=" + req.region_id;

          if (req.tipo_region !== undefined)
            url += "&tipo_region=" + req.tipo_region;

          query.ajaxRequest(url, reply);
        },
      },
    });

    server.route({
      path: "/especie/{id}",
      method: "GET",
      config: {
        tags: ["api"],
        description:
          "Consulta la información más relevante asociada de la especie",
        notes: "---",
        validate: {
          params: {
            id: Joi.number().required().description("ID de la especie"),
          },
        },
        handler: function (request, reply) {
          var url =
            SERVER + "/especies/" + request.params.id + ".json";
          query.ajaxRequest(url, reply);
        },
      },
    });

    server.route({
      path: "/especie/{id}/ancestry",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Consulta todas las categorías ascendentes del taxon",
        notes: "---",
        validate: {
          params: {
            id: Joi.number().required().description("ID de la especie"),
          },
        },
        handler: function (request, reply) {
          var url =
            SERVER + "/explora-por-clasificacion.json?especie_id=" +
            request.params.id +
            "/arbol_nodo_inicial";
          query.ajaxRequest(url, reply);
        },
      },
    });

    server.route({
      path: "/especie/descripcion/{id}/resumen-wikipedia",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Consulta el resumen de wikipedia en español o inglés",
        notes: "---",
        validate: {
          params: {
            id: Joi.number().required().description("ID de la especie"),
          },
        },
        handler: function (request, reply) {
          var url =
            SERVER + "/especies/" +
            request.params.id +
            "/resumen-wikipedia";
          console.log(url)
          query.ajaxRequest(url, reply);
        },
      },
    });

    server.route({
      path: "/autocompleta/especies/{q}",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Autocompleta por el nombre común o científico",
        notes: "---",
        validate: {
          params: {
            q: Joi.string().required().description("Nombre común o científico"),
          },
        },
        handler: function (request, reply) {
          var url =
            SERVER + "/sm/search?term=" +
            request.params.q +
            "&types%5B%5D=especie&types%5B%5D=subespecie&types%5B%5D=variedad&types%5B%5D=subvariedad&types%5B%5D=forma&types%5B%5D=subforma&types%5B%5D=Reino&types%5B%5D=subreino&types%5B%5D=superphylum&types%5B%5D=division&types%5B%5D=subdivision&types%5B%5D=phylum&types%5B%5D=subphylum&types%5B%5D=superclase&types%5B%5D=grado&types%5B%5D=clase&types%5B%5D=subclase&types%5B%5D=infraclase&types%5B%5D=superorden&types%5B%5D=orden&types%5B%5D=suborden&types%5B%5D=infraorden&types%5B%5D=superfamilia&types%5B%5D=familia&types%5B%5D=subfamilia&types%5B%5D=supertribu&types%5B%5D=tribu&types%5B%5D=subtribu&types%5B%5D=genero&types%5B%5D=subgenero&types%5B%5D=seccion&types%5B%5D=subseccion&types%5B%5D=serie&types%5B%5D=subserie&limit=5";
          query.ajaxRequest(url, reply);
        },
      },
    });

    server.route({
      path: "/snib/ejemplar/{id}",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Obtiene la información asociada al ejemplar",
        notes: "---",
        validate: {
          params: {
            id: Joi.number().required().description("ID del ejemplar"),
          },
        },
        handler: function (request, reply) {
          var url =
            SERVER + "/explora-por-region/ejemplar?ejemplar_id=" +
            request.params.id;
          query.ajaxRequest(url, reply);
        },
      },
    });

    server.route({
      path: "/snib/regiones/estados",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Consulta todos los estados",
        notes: "----",
        handler: function (request, reply) {
          query.dameEstados(request).then((dato) => {
            reply(dato);
          });
        },
      },
    });

    server.route({
      path: "/snib/regiones/municipios",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Consulta todos los estados",
        notes: "----",
        handler: function (request, reply) {
          query.dameMunicipios(request).then((dato) => {
            reply(dato);
          });
        },
      },
    });

    server.route({
      path: "/snib/regiones/anps",
      method: "GET",
      config: {
        tags: ["api"],
        description: "Consulta todas las ANPs",
        notes: "----",
        handler: function (request, reply) {
          query.dameANP(request).then((dato) => {
            reply(dato);
          });
        },
      },
    });    
    
    server.start(function () {
      console.log("started on " + SERVER);
    });
  }
);
