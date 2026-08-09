var Hapi = require("hapi");
const Joi = require("joi");
const query = require("./controller/query.js");

var server = new Hapi.Server({
  connections: {
    routes: {
      timeout: {
        server: 1000 * 30,
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
          const url = new URL(
            `${SERVER}/busquedas/resultados.json?busqueda=basica'`
          );
          url.searchParams.set("nombre", req.params.q);

          query.ajaxRequest(url.toString(), reply);
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
            cat: Joi.number()
              .integer()
              .default(7100)
              .valid([
                1100, 2100, 3100, 4100, 5100, 6100, 7100, 1000, 2000, 3000,
                4000, 5000, 6000, 7000,
              ])
              .description("Solo taxones con la categoria taxonómica"),
            nivel: Joi.string()
              .default("=")
              .valid(["=", ">=", ">", "<=", "<"])
              .description("Operador relacionado al campo cat"),
            edo_cons: Joi.array().description(
              "La categoría de riesgo,<br />NOM: 17,15,14,16<br />IUCN: 29,28,27,26,25<br />CITES: 22,23,24"
            ),
            dist: Joi.array()
              .items(Joi.number().integer())
              .description("El tipo de distribución: 3,7,10,6"),
            prior: Joi.array().description(
              "Valor de la especie, proiritaria para la conservación: 1033,1034,1035"
            ),
            pagina: Joi.number()
              .integer()
              .default(1)
              .description("El número de pagina"),
            por_pagina: Joi.number()
              .integer()
              .default(50)
              .valid([50, 100, 200, 500, 1000])
              .description("Los resultados por pagina"),
          },
        },
        handler: function (request, reply) {
          const url = new URL(
            `${SERVER}/busquedas/resultados.json?busqueda=avanzada&commit=Buscar`
          );

          const {
            id,
            cat,
            nivel,
            nombre,
            edo_cons,
            dist,
            prior,
            pagina,
            por_pagina,
          } = request.query;

          url.searchParams.set("por_pagina", por_pagina.por_pagina ?? 50);

          if (id || (cat && nivel)) {
            if (id) url.searchParams.set("id", id);

            if (cat && nivel) {
              url.searchParams.set("cat", cat);
              url.searchParams.set("nivel", nivel);
            }
          } else if (nombre) {
            url.searchParams.set("nombre", nombre);
          }

          edo_cons?.forEach((edoItem) =>
            url.searchParams.set("edo_cons[]", edoItem)
          );
          dist?.forEach((distItem) => url.searchParams.set("dist[]", distItem));
          prior?.forEach((priorItem) =>
            url.searchParams.set("prior[]", priorItem)
          );

          if (pagina) url.searchParams.set("pagina", pagina);

          query.ajaxRequest(url.toString(), reply);
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
                "El identificador de la especie, si tambien se anota el grupo taxónomico, este id tiene precedencia"
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
            dist: Joi.array()
              .items(Joi.number().integer())
              .description("El tipo de distribución: 3,7,10,6"),
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
          const url = new URL(`${SERVER}/explora-por-region/especies.json`);

          const {
            pagina,
            especie_id,
            region_id,
            tipo_region,
            grupo,
            edo_cons,
            dist,
          } = request.query;

          url.searchParams.set("pagina", pagina ?? 1);

          if (especie_id) url.searchParams.set("especie_id", especie_id);
          if (grupo && especie_id) url.searchParams.set("grupo", grupo);
          if (region_id) url.searchParams.set("region_id", region_id);
          if (tipo_region) url.searchParams.set("tipo_region", tipo_region);

          edo_cons?.forEach((edoItem) =>
            url.searchParams.set("edo_cons[]", edoItem)
          );
          dist?.forEach((distItem) => url.searchParams.set("dist[]", distItem));

          query.ajaxRequest(url.toString(), reply);
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
          const url = new URL(`${SERVER}/explora-por-region/ejemplares`);

          const { catalogo_id, region_id, tipo_region } = request.query;

          if (catalogo_id) url.searchParams.set("catalogo_id", catalogo_id);
          if (region_id) url.searchParams.set("region_id", region_id);
          if (tipo_region) url.searchParams.set("tipo_region", tipo_region);

          query.ajaxRequest(url.toString(), reply);
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
          const url = new URL(`${SERVER}/especies/${request.params.id}.json`);

          query.ajaxRequest(url.toString(), reply);
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
          const url = new URL(
            `${SERVER}/explora-por-clasificacion.json?especie_id=${request.params.id}`
          );

          query.ajaxRequest(url.toString(), reply);
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
          const url = new URL(
            `${SERVER}/especies/${request.params.id}/resumen-wikipedia`
          );

          query.ajaxRequest(url.toString(), reply);
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
          const defaultQueryParams =
            "&types%5B%5D=especie&types%5B%5D=subespecie&types%5B%5D=variedad&types%5B%5D=subvariedad&types%5B%5D=forma&types%5B%5D=subforma&types%5B%5D=Reino&types%5B%5D=subreino&types%5B%5D=superphylum&types%5B%5D=division&types%5B%5D=subdivision&types%5B%5D=phylum&types%5B%5D=subphylum&types%5B%5D=superclase&types%5B%5D=grado&types%5B%5D=clase&types%5B%5D=subclase&types%5B%5D=infraclase&types%5B%5D=superorden&types%5B%5D=orden&types%5B%5D=suborden&types%5B%5D=infraorden&types%5B%5D=superfamilia&types%5B%5D=familia&types%5B%5D=subfamilia&types%5B%5D=supertribu&types%5B%5D=tribu&types%5B%5D=subtribu&types%5B%5D=genero&types%5B%5D=subgenero&types%5B%5D=seccion&types%5B%5D=subseccion&types%5B%5D=serie&types%5B%5D=subserie&limit=5";
          const url = new URL(`${SERVER}/sm/search?${defaultQueryParams}`);
          url.searchParams.set("term", request.params.q);

          query.ajaxRequest(url.toString(), reply);
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
          const url = new URL(
            `${SERVER}/explora-por-region/ejemplar?ejemplar_id=${request.params.id}`
          );

          query.ajaxRequest(url.toString(), reply);
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
