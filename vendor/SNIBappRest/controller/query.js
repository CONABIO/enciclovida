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
function dameEspeciesPorEstado(req) {
    let entid = req.params['entid'];

    return new Promise((resolve, reject) => {
        knex
        .with('anfibios', knex.raw(`SELECT spid, idnombrecatvalido, COUNT(*) AS COUNT FROM snibanfigw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibanfigw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('aves', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibavesgw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibavesgw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('bacterias', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibbactgw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibbactgw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('hongos', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibhonggw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibhonggw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('invertebrados', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibinvegw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibinvegw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('mamiferos', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibmamigw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibmamigw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('peces', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibpecegw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibpecegw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('plantas', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibplangw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibplangw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('protoctistas', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibprotgw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibprotgw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('reptiles', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibreptgw WHERE EXISTS ( SELECT 1 FROM estados WHERE entid = '${entid}' AND entid = snibreptgw.entid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('total', knex.raw(
                    `
        SELECT anfibios.idnombrecatvalido, anfibios.count AS nregistros FROM sp_snibanfigw INNER JOIN anfibios ON sp_snibanfigw.spid=anfibios.spid
        UNION SELECT aves.idnombrecatvalido, aves.count AS nregistros FROM sp_snibavesgw INNER JOIN aves ON sp_snibavesgw.spid=aves.spid
        UNION SELECT bacterias.idnombrecatvalido, bacterias.count AS nregistros FROM sp_snibbactgw INNER JOIN bacterias ON sp_snibbactgw.spid=bacterias.spid
        UNION SELECT hongos.idnombrecatvalido, hongos.count AS nregistros FROM sp_snibhonggw INNER JOIN hongos ON sp_snibhonggw.spid=hongos.spid
        UNION SELECT invertebrados.idnombrecatvalido, invertebrados.count AS nregistros FROM sp_snibinvegw INNER JOIN invertebrados ON sp_snibinvegw.spid=invertebrados.spid
        UNION SELECT mamiferos.idnombrecatvalido, mamiferos.count AS nregistros FROM sp_snibmamigw INNER JOIN mamiferos ON sp_snibmamigw.spid=mamiferos.spid
        UNION SELECT peces.idnombrecatvalido, peces.count AS nregistros FROM sp_snibpecegw INNER JOIN peces ON sp_snibpecegw.spid=peces.spid
        UNION SELECT plantas.idnombrecatvalido, plantas.count AS nregistros FROM sp_snibplangw INNER JOIN plantas ON sp_snibplangw.spid=plantas.spid
        UNION SELECT protoctistas.idnombrecatvalido, protoctistas.count AS nregistros FROM sp_snibprotgw INNER JOIN protoctistas ON sp_snibprotgw.spid=protoctistas.spid
        UNION SELECT reptiles.idnombrecatvalido, reptiles.count AS nregistros FROM sp_snibreptgw INNER JOIN reptiles ON sp_snibreptgw.spid=reptiles.spid
        `))
            .select(knex.raw('*'))
            .from('total')
            .orderByRaw('nregistros DESC')
            .then(dato => {
            resolve(dato);
})
})
}

/**
 * Regresa la lista de especies por municipio
 * @param req
 * @returns {boolean}
 */
function dameEspeciesPorMunicipio(req) {
    let munid = req.params['munid'];

    return new Promise((resolve, reject) => {
        knex
        .with('anfibios', knex.raw(`SELECT spid, idnombrecatvalido, COUNT(*) AS COUNT FROM snibanfigw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibanfigw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('aves', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibavesgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibavesgw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('bacterias', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibbactgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibbactgw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('hongos', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibhonggw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibhonggw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('invertebrados', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibinvegw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibinvegw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('mamiferos', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibmamigw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibmamigw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('peces', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibpecegw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibpecegw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('plantas', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibplangw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibplangw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('protoctistas', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibprotgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibprotgw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('reptiles', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibreptgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE munid = '${munid}' AND munid = snibreptgw.munid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('total', knex.raw(
                    `
        SELECT anfibios.idnombrecatvalido, anfibios.count AS nregistros FROM sp_snibanfigw INNER JOIN anfibios ON sp_snibanfigw.spid=anfibios.spid
        UNION SELECT aves.idnombrecatvalido, aves.count AS nregistros FROM sp_snibavesgw INNER JOIN aves ON sp_snibavesgw.spid=aves.spid
        UNION SELECT bacterias.idnombrecatvalido, bacterias.count AS nregistros FROM sp_snibbactgw INNER JOIN bacterias ON sp_snibbactgw.spid=bacterias.spid
        UNION SELECT hongos.idnombrecatvalido, hongos.count AS nregistros FROM sp_snibhonggw INNER JOIN hongos ON sp_snibhonggw.spid=hongos.spid
        UNION SELECT invertebrados.idnombrecatvalido, invertebrados.count AS nregistros FROM sp_snibinvegw INNER JOIN invertebrados ON sp_snibinvegw.spid=invertebrados.spid
        UNION SELECT mamiferos.idnombrecatvalido, mamiferos.count AS nregistros FROM sp_snibmamigw INNER JOIN mamiferos ON sp_snibmamigw.spid=mamiferos.spid
        UNION SELECT peces.idnombrecatvalido, peces.count AS nregistros FROM sp_snibpecegw INNER JOIN peces ON sp_snibpecegw.spid=peces.spid
        UNION SELECT plantas.idnombrecatvalido, plantas.count AS nregistros FROM sp_snibplangw INNER JOIN plantas ON sp_snibplangw.spid=plantas.spid
        UNION SELECT protoctistas.idnombrecatvalido, protoctistas.count AS nregistros FROM sp_snibprotgw INNER JOIN protoctistas ON sp_snibprotgw.spid=protoctistas.spid
        UNION SELECT reptiles.idnombrecatvalido, reptiles.count AS nregistros FROM sp_snibreptgw INNER JOIN reptiles ON sp_snibreptgw.spid=reptiles.spid
        `))
            .select(knex.raw('*'))
            .from('total')
            .orderByRaw('nregistros DESC')
            .then(dato => {
            resolve(dato);
})
})
}

/**
 * Regresa la lista de especies por ANP
 * @param req
 * @returns {boolean}
 */
function dameEspeciesPorANP(req) {
    let anpid = req.params['anpid'];

    return new Promise((resolve, reject) => {
        knex
        .with('anfibios', knex.raw(`SELECT spid, idnombrecatvalido, COUNT(*) AS COUNT FROM snibanfigw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibanfigw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('aves', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibavesgw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibavesgw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('bacterias', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibbactgw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibbactgw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('hongos', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibhonggw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibhonggw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('invertebrados', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibinvegw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibinvegw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('mamiferos', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibmamigw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibmamigw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('peces', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibpecegw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibpecegw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('plantas', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibplangw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibplangw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('protoctistas', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibprotgw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibprotgw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('reptiles', knex.raw(`SELECT spid, idnombrecatvalido, COUNT (*) AS COUNT FROM snibreptgw WHERE EXISTS ( SELECT 1 FROM anp WHERE anpid = '${anpid}' AND anpid = snibreptgw.anpid ) AND idnombrecatvalido <> '' GROUP BY spid, idnombrecatvalido`))
            .with('total', knex.raw(
                    `
        SELECT anfibios.idnombrecatvalido, anfibios.count AS nregistros FROM sp_snibanfigw INNER JOIN anfibios ON sp_snibanfigw.spid=anfibios.spid
        UNION SELECT aves.idnombrecatvalido, aves.count AS nregistros FROM sp_snibavesgw INNER JOIN aves ON sp_snibavesgw.spid=aves.spid
        UNION SELECT bacterias.idnombrecatvalido, bacterias.count AS nregistros FROM sp_snibbactgw INNER JOIN bacterias ON sp_snibbactgw.spid=bacterias.spid
        UNION SELECT hongos.idnombrecatvalido, hongos.count AS nregistros FROM sp_snibhonggw INNER JOIN hongos ON sp_snibhonggw.spid=hongos.spid
        UNION SELECT invertebrados.idnombrecatvalido, invertebrados.count AS nregistros FROM sp_snibinvegw INNER JOIN invertebrados ON sp_snibinvegw.spid=invertebrados.spid
        UNION SELECT mamiferos.idnombrecatvalido, mamiferos.count AS nregistros FROM sp_snibmamigw INNER JOIN mamiferos ON sp_snibmamigw.spid=mamiferos.spid
        UNION SELECT peces.idnombrecatvalido, peces.count AS nregistros FROM sp_snibpecegw INNER JOIN peces ON sp_snibpecegw.spid=peces.spid
        UNION SELECT plantas.idnombrecatvalido, plantas.count AS nregistros FROM sp_snibplangw INNER JOIN plantas ON sp_snibplangw.spid=plantas.spid
        UNION SELECT protoctistas.idnombrecatvalido, protoctistas.count AS nregistros FROM sp_snibprotgw INNER JOIN protoctistas ON sp_snibprotgw.spid=protoctistas.spid
        UNION SELECT reptiles.idnombrecatvalido, reptiles.count AS nregistros FROM sp_snibreptgw INNER JOIN reptiles ON sp_snibreptgw.spid=reptiles.spid
        `))
            .select(knex.raw('*'))
            .from('total')
            .orderByRaw('nregistros DESC')
            .then(dato => {
            resolve(dato);
})
})
}

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
        resolve(dato);
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
        resolve(dato);
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
    dameEspeciesPorEstado,
    dameEspeciesPorMunicipio,
    dameEspeciesPorANP,
    dameEspeciesConFiltros,
    dameEspeciesConFiltrosConteo,
    dameEspecieEjemplares,
    dameEspecieEjemplaresConteo,
    ajaxRequest
};
