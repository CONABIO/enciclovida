var Hapi = require('hapi');
const Joi = require('joi');
_ = require('lodash');
const query = require('./controller/query.js');


var server = new Hapi.Server({
    connections: {
        routes: {
            timeout: {
                server: 1000*60*10,
                socket: false
            },
            cors: true
        }
    }
});

server.connection({
    port: 9002,
    labels: ['api'],
});

server.register([
    require('inert'),
    require('vision'),
    {
        register: require('hapi-swaggered'),
        options: {
            tags: {
                'foobar/test': 'Example foobar description'
            },
            info: {
                title: 'Busca por region, especie o ejemplares',
                description: '',
                version: '1.0'
            }
        }
    },
    {
        register: require('hapi-swaggered-ui'),
        options: {
            title: 'Enciclovida API',
            path: '/docs',

            swaggerOptions: {
                validatorUrl: null
            }
        }
    }], {
    select: 'api'
}, function (err) {
    if (err) {
        throw err
    }

    server.route({
        path: '/',
        method: 'GET',
        handler: function (request, reply) {
            reply.redirect('/docs')
        }
    });

    server.route({
        path: '/regiones/estados',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Consulta todos los estados',
            notes: '----',
            handler: function (request, reply) {
                query
                    .dameEstados(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/regiones/municipios',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Consulta todos los estados',
            notes: '----',
            handler: function (request, reply) {
                query
                    .dameMunicipios(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/regiones/anps',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Consulta todas las ANPs',
            notes: '----',
            handler: function (request, reply) {
                query
                    .dameANP(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especies/region/estado/{entid}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa un Array de especies con más ejemplares por el estado y/o opciones seleccionadas',
            notes: 'Para mayor información acerca de "entid" consultar el servicio de regiones por estado',
            validate: {
                params: {
                    entid: Joi.string().required().valid(['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado')
                }
            },
            handler: function (request, reply) {
                query
                    .dameEspeciesPorEstado(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especies/region/municipio/{munid}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa un Array de especies con más ejemplares por el municipio y/o opciones seleccionadas',
            notes: 'Para mayor información acerca de "munid" consultar el servicio de regiones por municipio',
            validate: {
                params: {
                    munid: Joi.string().required().default('1').description('Identificador del municipio')
                }
            },
            handler: function (request, reply) {
                query
                    .dameEspeciesPorMunicipio(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especies/region/anp/{anpid}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa un Array de especies con más ejemplares por la ANP y/o opciones seleccionadas',
            notes: 'Para mayor información acerca de "anpestid" consultar el servicio de regiones por ANP',
            validate: {
                params: {
                    anpid: Joi.string().required().default('1').description('Identificador del municipio')
                }
            },
            handler: function (request, reply) {
                query
                    .dameEspeciesPorANP(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especies/region/filtros',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa todas las especies que coinciden con los filtros seleccionados en todas las regiones',
            notes: 'Posibles filtros son: NOM-059, IUCN, CITES, tipo de distribución y grupo taxonómico de la especie',
            validate: {
                query: {
                    nom: Joi.array().description('Norma Oficial Mexicana 059, valores permitidos: 14,15,16,17'),
                    iucn: Joi.array().description('Unión Internacional para la Conservación de la Naturleza, valores permitidos: 25,26,27,28,29,31,21'),
                    cites: Joi.array().description('Comercio Internacional, valores permitidos: 22,23,24'),
                    dist: Joi.array().description('Tipo de distribución, valores permitidos: 3,6,7,10'),
                    grupo: Joi.array().description('El grupo taxónomico, valores permitidos: Anfibios,Aves,Bacterias,Hongos,Invertebrados,Mamíferos,Peces,Plantas,Protoctistas,Reptiles'),
                    pagina: Joi.number().description('La pagina a consultar'),
                    por_pagina: Joi.number().description('Los resultados por pagina')
                }
            },
            handler: function (request, reply) {
                query
                    .dameEspeciesConFiltros(request.query)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especies/region/filtros/conteo',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa el total de las especies que coinciden con los filtros seleccionados en todas las regiones',
            notes: 'Posibles filtros son: NOM-059, IUCN, CITES, tipo de distribución y grupo taxonómico de la especie',
            validate: {
                query: {
                    nom: Joi.array().description('Norma Oficial Mexicana 059, valores permitidos: 14,15,16,17'),
                    iucn: Joi.array().description('Unión Internacional para la Conservación de la Naturleza, valores permitidos: 25,26,27,28,29,31,21'),
                    cites: Joi.array().description('Comercio Internacional, valores permitidos: 22,23,24'),
                    dist: Joi.array().description('Tipo de distribución, valores permitidos: 3,6,7,10'),
                    grupo: Joi.array().description('El grupo taxónomico, valores permitidos: Anfibios,Aves,Bacterias,Hongos,Invertebrados,Mamíferos,Peces,Plantas,Protoctistas,Reptiles'),
                }
            },
            handler: function (request, reply) {
                query
                    .dameEspeciesConFiltrosConteo(request.query)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especies/busqueda/basica/{q}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Busca un nombre cómun o científico, puede contener el nombre o tener un error de ortografía',
            notes: '---',
            validate: {
                params: {
                    q: Joi.string().required().description('Nombre común o científico')
                }
            },
            handler: function (request, reply) {
                var url = "http://enciclovida.mx/busquedas/resultados.json?busqueda=basica&nombre=" + request.params.q;
                query.ajaxRequest(url, reply);
            }
        }
    });

    server.route({
        path: '/especies/busqueda/avanzada',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Búsqueda avanzada de especies con diversos filtros',
            notes: '---',
            validate: {
                query: {
                    nombre: Joi.string().description('Nombre común o científico'),
                    id: Joi.number().integer().description('El identificador de la especie'),
                    cat: Joi.string().default('7100').valid(['1100','2100','3100','4100','5100','6100','7100']).description('Solo taxones con la categoria taxonómica ...'),
                    nivel: Joi.string().default('=').valid(['=','>=','>','<=','<']).description('Operador relacionado al campo cat'),
                    edo_cons: Joi.array().description('La categoría de riesgo,<br />NOM: 17,15,14,16<br />IUCN: 29,28,27,26,25<br />CITES: 22,23,24'),
                    dist: Joi.array().description('El tipo de distribución: 3,7,10,6'),
                    prior: Joi.array().description('Valor de la especie, proiritaria para la conservación: 1033,1034,1035'),
                    pagina: Joi.number().integer().default(1).description('El número de pagina'),
                    por_pagina: Joi.string().default(50).valid(['50','100','200','500','1000']).description('Los resultados por pagina')
                }
            },
            handler: function (request, reply) {
                var url = "http://enciclovida.mx/busquedas/resultados.json?busqueda=avanzada&por_pagina=50&commit=Buscar";
                var req = request.query;

                if (req.id !== undefined)
                {
                    url+= "&id=" + req.id;
                    if (req.cat !== undefined && req.nivel !== undefined) url+= "&cat=" + req.cat + "&nivel=" + req.nivel;
                } else {
                    if (req.nombre !== undefined) url+= "&nombre=" + req.nombre;
                }

                if (req.edo_cons !== undefined)
                {
                    _.forEach(req.edo_cons, function (value) {
                        url+= "&edo_cons[]=" + value;
                    });
                }

                if (req.dist !== undefined)
                {
                    _.forEach(req.dist, function (value) {
                        url+= "&dist[]=" + value;
                    });
                }

                if (req.prior !== undefined)
                {
                    _.forEach(req.prior, function (value) {
                        url+= "&prior[]=" + value;
                    });
                }

                if (req.pagina !== undefined) url+= "&pagina=" + req.pagina;
                if (req.por_pagina !== undefined) url+= "&por_pagina=" + req.por_pagina;

                query.ajaxRequest(url, reply);
            }
        }
    });

    server.route({
        path: '/especie/snib/ejemplares',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa un array con todos los ejemplares de la especie',
            notes: 'Opciones como la region y el tipo de region son opcionales (default a nivel nacional)',
            validate: {
                query: {
                    idnombrecatvalido: Joi.string().required().description('Identificador del catalogo centralizado'),
                    mapa: Joi.boolean().required().default(false).description('Si es verdadero regresa los datos compactos para consumir con geojson, de lo contrario regresa toda la respuesta de datos'),
                    region_id: Joi.number().description('Para más información, consultar la sección regiones'),
                    tipo_region: Joi.string().valid(['estado','municipio','anp']).description('De acuerdo al tipo de region se asocia el campo del region_id')
                }
            },
            handler: function (request, reply) {
                query
                    .dameEspecieEjemplares(request.query)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especie/snib/ejemplares/conteo',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa el conteo de ejemplares de la especie',
            notes: 'Opciones como la region y el tipo de region son opcionales (default a nivel nacional)',
            validate: {
                query: {
                    idnombrecatvalido: Joi.string().required().description('Identificador del catalogo centralizado'),
                    region_id: Joi.number().description('Para más información, consultar la sección regiones'),
                    tipo_region: Joi.string().valid(['estado','municipio','anp']).description('De acuerdo al tipo de region se asocia el campo del region_id')
                }
            },
            handler: function (request, reply) {
                query
                    .dameEspecieEjemplaresConteo(request.query)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especie/{id}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Consulta la información más relevante asociada de la especie',
            notes: '---',
            validate: {
                params: {
                    id: Joi.number().description('ID de la especie')
                }
            },
            handler: function (request, reply) {
                var url = "http://enciclovida.mx/especies/" + request.params.id + '.json';
                query.ajaxRequest(url, reply);
            }
        }
    });

    server.route({
        path: '/especie/{id}/ancestry',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Consulta todas las categorías ascendentes del taxon',
            notes: '---',
            validate: {
                params: {
                    id: Joi.number().description('ID de la especie')
                }
            },
            handler: function (request, reply) {
                var url = "http://enciclovida.mx/especies/" + request.params.id + '/arbol_nodo_inicial';
                query.ajaxRequest(url, reply);
            }
        }
    });

    server.route({
        path: '/autocompleta/especies/{q}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Autocompleta por el nombre común o científico',
            notes: '---',
            validate: {
                params: {
                    q: Joi.string().required().description('Nombre común o científico')
                }
            },
            handler: function (request, reply) {
                var url = "http://enciclovida.mx/sm/search?term=" + request.params.q + "&types%5B%5D=especie&types%5B%5D=subespecie&types%5B%5D=variedad&types%5B%5D=subvariedad&types%5B%5D=forma&types%5B%5D=subforma&types%5B%5D=Reino&types%5B%5D=subreino&types%5B%5D=superphylum&types%5B%5D=division&types%5B%5D=subdivision&types%5B%5D=phylum&types%5B%5D=subphylum&types%5B%5D=superclase&types%5B%5D=grado&types%5B%5D=clase&types%5B%5D=subclase&types%5B%5D=infraclase&types%5B%5D=superorden&types%5B%5D=orden&types%5B%5D=suborden&types%5B%5D=infraorden&types%5B%5D=superfamilia&types%5B%5D=familia&types%5B%5D=subfamilia&types%5B%5D=supertribu&types%5B%5D=tribu&types%5B%5D=subtribu&types%5B%5D=genero&types%5B%5D=subgenero&types%5B%5D=seccion&types%5B%5D=subseccion&types%5B%5D=serie&types%5B%5D=subserie&limit=5";
                query.ajaxRequest(url, reply);
            }
        }
    });

    server.start(function () {
        console.log('started on http://localhost:8000')
    });

});