var Hapi = require('hapi');
const Joi = require('joi');
const query = require('./controller/query.js');
const querySnib = require('./controller/querySnib.js');

var server = new Hapi.Server();

server.connection({
    port: 8001,
    labels: ['api']
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
                title: 'Servicios de búsqueda',
                description: 'Servicio de acuerdo a una región y un grupo taxonónico',
                version: '1.0'
            }
        }
    },
    {
        register: require('hapi-swaggered-ui'),
        options: {
            title: 'Example API',
            path: '/docs',
            authorization: {
                field: 'apiKey',
                scope: 'query', // header works as well 
                // valuePrefix: 'bearer '// prefix incase 
                defaultValue: 'enciclovida',
                placeholder: 'Enter your apiKey here'
            },
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
                    .getedo()
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
                    .getmun(request)
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
                    .getanp(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especies/estado/{entid}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa un Array con el top 10 de las especies con más ejemplares por el estado y/o opciones seleccionadas',
            notes: 'Para mayor información acerca de "entid" consultar el servicio de regiones por estado',
            validate: {
                params: {
                    entid: Joi.string().required().valid(['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado')
                }
            },
            handler: function (request, reply) {
                query
                    .taxonEdoTotal(request)
                    .then(dato => {

                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especies/municipio/{munid}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa un Array con el top 10 de las especies con más ejemplares por el municipio y/o opciones seleccionadas',
            notes: 'Para mayor información acerca de "munid" consultar el servicio de regiones por municipio',
            validate: {
                params: {
                    munid: Joi.string().required().default('1').description('Identificador del municipio'),
                }
            },
            handler: function (request, reply) {
                query
                    .taxonMuni(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/especies/anp/{anpestid}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa un Array con el top 10 de las especies con más ejemplares por la ANP y/o opciones seleccionadas',
            notes: 'Para mayor información acerca de "anpestid" consultar el servicio de regiones por ANP',
            validate: {
                params: {
                    anpestid: Joi.string().required().default('1').description('Identificador del municipio'),
                }
            },
            handler: function (request, reply) {
                query
                    .taxonMuni(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/taxonEdo/conteo/total/{idedo}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa un Array de los 10 grupos junto con las especies de estado seleccionado',
            notes: '----',
            validate: {
                params: {
                    idedo: Joi.string().required().valid(['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado'),
                }
            },
            handler: function (request, reply) {
                query
                    .taxonEdoTotal(request)
                    .then(dato => {

                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/taxonEdo/conteo/{idedo}/{tipo}/{grupo}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Regresa un Array de las especies junto con los ejemplares del estado y grupo seleccionado',
            notes: '----',

            validate: {
                params: {
                    idedo: Joi.string().required().valid(['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado'),
                    tipo: Joi.string().required().valid(['edomun', 'anp', 'ecoregion']).description('Tipo de region (estado, muunicipio, ANP o ecoregión)'),
                    grupo: Joi.string().required().valid(['anfibios', 'aves', 'bacterias', 'hongos', 'invertebrados', 'mamiferos', 'peces', 'plantas', 'protoctistas', 'reptiles']).description('Grupo taxonómico'),
                }
            },
            handler: function (request, reply) {
                query
                    .taxonEdo(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/taxonMuni/listado/{idedo}/{idmun}/{tipo}/{grupo}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el listado de especies con el "idnombrecatvalido"',
            notes: '----',
            validate: {
                params: {
                    idedo: Joi.string().required().valid(['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado'),
                    idmun: Joi.string().required().default('001').description('Identificador del municipio "001"'),
                    tipo: Joi.string().required().valid(['edomun', 'anp', 'ecoregion']).description('Tipo de region (estado, muunicipio, ANP o ecoregión)'),
                    grupo: Joi.string().required().valid(['anfibios', 'aves', 'bacterias', 'hongos', 'invertebrados', 'mamiferos', 'peces', 'plantas', 'protoctistas', 'reptiles']).description('Grupo taxonómico'),
                }
            },
            handler: function (request, reply) {
                query
                    .taxonMuni(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/taxonMuni/listado/total/{idedo}/{idmun}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el listado de especies con el "idnombrecatvalido"',
            notes: '----',
            validate: {
                params: {
                    idedo: Joi.string().required().valid(['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado'),
                    idmun: Joi.string().required().default('001').description('Identificador del municipio (ejemplo:"001")')
                }
            },
            handler: function (request, reply) {
                query
                    .taxonMunTotal(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/snib/{qtype}/{rd}/{id}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el listado de especies por reino y idnombrecatvalido',
            notes: 'Servicios de enclovida Ver 2018',
            validate: {
                params: {
                    qtype: Joi.string().required().valid(['getSpecies']).description('Identificador del tipo de consulta'),
                    rd: Joi.string().required().valid(['animalia','plantae','fungi','protoctista','prokaryotae']).description('Identificador del reino'),
                    id: Joi.string().required().default('13083ANFIB').description('Identificador del idnombrecatvalido  (ejemplo:"13083ANFIB")')
                }
            },
            handler: function (request, reply) {
                querySnib
                    .getSnib(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/snib/{qtype}/{rd}/{id}/{idedo}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el listado de especies por reino, nombrecatvalido y estado',
            notes: 'Servicios de enclovida Ver 2018',
            validate: {
                params: {
                    qtype: Joi.string().required().valid(['getSpecies']).description('Identificador del tipo de consulta'),
                    rd: Joi.string().required().valid(['animalia','plantae','fungi','protoctista','prokaryotae']).description('Identificador del reino'),
                    id: Joi.string().required().default('13083ANFIB').description('Identificador del idnombrecatvalido  (ejemplo:"13083ANFIB")'),
                    idedo: Joi.string().required().valid(['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado')
                }
            },
            handler: function (request, reply) {
                querySnib
                    .getSnibEdo(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });

    server.route({
        path: '/snib/{qtype}/{rd}/{id}/{idedo}/{idmun}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el listado de especies por reino, nombrecatvalido, estado y municipio',
            notes: 'Servicios de enclovida Ver 2018',
            validate: {
                params: {
                    qtype: Joi.string().required().valid(['getSpecies']).description('Identificador del tipo de consulta'),
                    rd: Joi.string().required().valid(['animalia','plantae','fungi','protoctista','prokaryotae']).description('Identificador del reino'),
                    id: Joi.string().required().default('13083ANFIB').description('Identificador del idnombrecatvalido  (ejemplo:"13083ANFIB")'),
                    idedo: Joi.string().required().valid(['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado'),
                    idmun: Joi.string().required().default('001').description('Identificador del municipio (ejemplo:"001")')
                }
            },
            handler: function (request, reply) {
                querySnib
                    .getSnibMun(request)
                    .then(dato => {
                    reply(dato)
                })
            }
        }
    });



    server.start(function () {
        console.log('started on http://localhost:8000')
    });

});