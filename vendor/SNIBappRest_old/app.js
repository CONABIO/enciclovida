var Hapi = require('hapi');
const Joi = require('joi');
const query = require('./controller/query.js');

var server = new Hapi.Server({
    connections: {
        routes: {
            timeout: {
                server: 1000*60*10,
                socket: false,
            }
        }
    }
});

server.connection({
    port: 8000,
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
        path: '/estados',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el nombre de los estados',
            notes: '----',
            handler: function (request, reply) {
                query
                    .getedo()
                    .then(dato => {
                        reply(dato)
                    })
            }
        }
    })
    server.route({
        path: '/municipios/{idedo}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el nombre de los municipio',
            notes: '----',
            validate: {
                params: {
                    idedo: Joi.string().required().valid(['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado'),
                }
            },
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
        path: '/taxonEdo/conteo/{idedo}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el conteo (especies) por los 10 grupos taxonomicos del SNIB',
            notes: 'Contiene el conteo (especies) por los 10 grupos taxonomicos del SNIB',
            validate: {
                params: {
                    idedo: Joi.string().required().valid(['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado'),
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
        path: '/taxonEdo/listado/{idedo}/{grupo}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el conteo (especies) por los 10 grupos taxonomicos del SNIB',
            notes: '----',

            validate: {
                params: {
                    idedo: Joi.string().required().valid(['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado'),
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
        path: '/taxonMuni/conteo/{idmun}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el conteo (especies) por municipio y por los 10 grupos taxonomicos del SNIB',
            notes: '----',
            validate: {
                params: {
                    idmun: Joi.string().required().default('250').description('Identificador del municipio (ejemplo:"250")')
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
        path: '/taxonMuni/listado/{idmun}/{grupo}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el listado de especies con el municipio y grupo correspndiente',
            notes: '----',
            validate: {
                params: {
                    idmun: Joi.string().required().default('001').description('Identificador del municipio "001"'),
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
        path: '/snib/{idcat}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el listado de especies por idCAT',
            notes: 'Servicios de enclovida ver. 2020',
            validate: {
                params: {
                    idcat: Joi.string().required().default('13083ANFIB').description('Identificador del idnombrecatvalido  (ejemplo:"13083ANFIB")'),
                }
            },
            handler: function (request, reply) {
                query
                    .getSnib(request)
                    .then(dato => {
                        reply(dato)
                    })
            }
        }
    });

    server.route({
        path: '/snib/estado/{idcat}/{entid}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el listado de especies por idCAT y estado',
            notes: 'Servicios de enclovida ver. 2020',
            validate: {
                params: {
                    idcat: Joi.string().required().default('13083ANFIB').description('Identificador del idnombrecatvalido  (ejemplo:"13083ANFIB")'),
                    entid: Joi.string().required().valid(['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32']).description('Identificador del estado')
                }
            },
            handler: function (request, reply) {
                query
                    .getSnibEdo(request)
                    .then(dato => {
                        reply(dato)
                    })
            }
        }
    });

    server.route({
        path: '/snib/municipio/{idcat}/{munid}',
        method: 'GET',
        config: {
            tags: ['api'],
            description: 'Contiene el listado de especies por idCAT y municipio',
            notes: 'Servicios de enclovida ver. 2020',
            validate: {
                params: {
                    idcat: Joi.string().required().default('13083ANFIB').description('Identificador del idnombrecatvalido  (ejemplo:"13083ANFIB")'),
                    munid: Joi.string().required().default('320').description('Identificador del municipio')
                }
            },
            handler: function (request, reply) {
                query
                    .getSnibMun(request)
                    .then(dato => {
                        reply(dato)
                    })
            }
        }
    });

    server.start(function () {
        console.log('started on http://localhost:8000')
    })
})
