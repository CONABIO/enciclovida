"use strict";

require('./config.js');
const http = require('http');

/**
 * Regresa la lista de estados
 * @returns {boolean}
 */
function dameEstados() {
    return new Promise((resolve, reject) => {
        knex
        .select(knex.raw('entid, nom_ent'))
            .from('estados')
            .orderBy('entid')
            .then(dato => {
            resolve(dato);
})
})
}

/**
 * Regresa ka lista de municipios
 * @returns {boolean}
 */
function dameMunicipios() {
    return new Promise((resolve, reject) => {
        knex
        .select(knex.raw('munid, nom_mun, nom_ent'))
            .from('municipios')
            .orderBy('munid')
            .then(dato => {
            resolve(dato)
        })
})
}

/**
 * Regresa la lista de municipios
 * @returns {boolean}
 */
function dameANP() {
    return new Promise((resolve, reject) => {
        knex
        .select(knex.raw('anpid, nombre, cat_manejo, estados, municipios'))
            .from('anp')
            .orderBy('anpid')
            .then(dato => {
            resolve(dato)
        })
})
}

/**
 * Regresa la lista de especies por estado
 * @param req
 * @returns {boolean}
 */
var dameEspeciesPorRegion = function (region_id, nombre_id)
{
    return new Promise((resolve, reject) => {
        knex
        .select(knex.raw('idnombrecatvalido, COUNT(*) AS nregistros'))
            .from('snib')
            .whereRaw(nombre_id + "=" + region_id)
            .whereRaw("idnombrecatvalido <> ''")
            .whereRaw("especievalidabusqueda <> ''")
            .whereRaw("comentarioscatvalido LIKE '%Validado completamente con CAT.%'")
            .groupBy('idnombrecatvalido')
            .orderByRaw('nregistros DESC')
            .then(dato => {
            resolve(formatoEjemplares(dato))
        })
    })
};

/**
 * Regresa la lista de especies con filtros
 * @param req
 * @returns {boolean}
 */
let dameEspeciesConFiltros = function(req)
{
    return new Promise((resolve, reject) => {
        var query = knex
            .select(knex.raw('idnombrecatvalido,nregistros'))
            .from('filtros')
            .orderByRaw('nregistros DESC');

    query = armaQueryFiltros(req, query);

    // paginado
    let pagina = 1;
    let por_pagina = 10;

    if (req.pagina !== undefined) pagina = req.pagina;
    if (req.por_pagina !== undefined) por_pagina = req.por_pagina;

    query.offset((pagina-1)*por_pagina);
    query.limit(por_pagina);

    query.then(dato => {
        resolve(formatoEjemplares(dato));
})
})
};

/**
 * Regresa el conteo de especies con filtros
 * @param req
 * @returns {boolean}
 */
let dameEspeciesConFiltrosConteo = function(req)
{
    return new Promise((resolve, reject) => {
        var query = knex
            .count('* AS nespecies')
            .from('filtros');

    query = armaQueryFiltros(req, query);

    query.then(dato => {
        resolve({nespecies: parseInt(dato[0].nespecies)});
})
})
};

let formatoEjemplaresMapa = function (dato)
{
    var res = [];

    _.forEach(dato, function(row) {
        res.push(_.toArray(row));
    });

    return res;
};

let formatoEjemplares = function (dato)
{
    var res = {};

    _.forEach(dato, function(row) {
        res[row.idnombrecatvalido] = parseInt(row.nregistros);
    });

    return res;
};

let dameEspecieEjemplares = function(req)
{
    if (req.mapa)
        var camposEnciclovida = ["longitud","latitud","idejemplar","tipocoleccion"];
    else
        var camposEnciclovida = ["idejemplar","longitud","latitud","especievalidabusqueda","ejemplarfosil","region","localidad","paismapa","estadomapa","municipiomapa","coleccion","institucion","paiscoleccion","determinador","colector","fechacolecta","proyecto","urlproyecto","urlejemplar","probablelocnodecampo"];

    return new Promise((resolve, reject) => {
        var query = knex
            .select(camposEnciclovida);

    query = armaQueryEjemplares(req, query);

    query.then(dato => {
        resolve(formatoEjemplaresMapa(dato));
})
})
};

let dameEspecieEjemplaresConteo = function(req)
{
    return new Promise((resolve, reject) => {
        var query = knex
            .count('idnombrecatvalido AS nregistros');

    query = armaQueryEjemplares(req, query);

    query.then(dato => {
        resolve(dato);
})
})
};

/**
 * Regresa el query armado con filtros
 * @param req
 * @param query
 * @returns {*}
 */
let armaQueryFiltros = function(req, query)
{
    if (req.nom !== undefined) query.whereIn('nom', req.nom);
    if (req.iucn !== undefined) query.whereIn('iucn', req.iucn);
    if (req.cites !== undefined) query.whereIn('cites', req.cites);
    if (req.grupo !== undefined) query.whereIn('grupobio', req.grupo);

    // Para las distribuciones
    if (req.dist !== undefined)
    {
        let dist = [];
        if (req.dist.includes(3)) dist.push('endemica=true');
        if (req.dist.includes(7)) dist.push('nativa=true');
        if (req.dist.includes(10)) dist.push('exotica=true');
        if (req.dist.includes(6)) dist.push('exoticainvasora=true');
        query.whereRaw(dist.join(' OR '));
    }

    return query;
};

/**
 * Regresa el query armado de los ejempalres por especie
 * @param req
 * @param query
 * @returns {*}
 */
let armaQueryEjemplares = function(req, query)
{
    query.from('snib');

    if (req.idnombrecatvalido !== undefined) query.where({idnombrecatvalido: req.idnombrecatvalido});

    if (req.region_id !== undefined && req.tipo_region !== undefined)
    {
        switch (req.tipo_region) {
            case "anp":
                query.where({anpid: req.region_id});
                break;
            case "estado":
                query.where({entid: req.region_id});
                break;
            case "municipio":
                query.where({munid: req.region_id});
                break;
        }
    }

    return query;
};

/**
 * Hace una petición ajax
 * @param url
 */
let ajaxRequest = function(url, reply)
{
    var resultado = '';

    http.get(url, (res) => {

        res.on('data', (d) => {
            resultado+= d;
});

}).on('error', (e) => {
    console.error(e);
}).on('close', (d) =>{
    reply(JSON.parse(resultado))
});
};

module.exports = {
    dameEstados,
    dameMunicipios,
    dameANP,
    dameEspeciesPorRegion,
    dameEspeciesConFiltros,
    dameEspeciesConFiltrosConteo,
    dameEspecieEjemplares,
    dameEspecieEjemplaresConteo,
    ajaxRequest
};
