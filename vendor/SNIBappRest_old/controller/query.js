"use strict";

require('./config.js');
const http = require('http');

var tablas = {
    'anfibios': 'snibanfigw',
    'aves': 'snibavesgw',
    'bacterias': 'snibbactgw',
    'hongos': 'snibhonggw',
    'invertebrados': 'snibinvegw',
    'mamiferos': 'snibmamigw',
    'peces': 'snibpecegw',
    'plantas': 'snibplangw',
    'protoctistas': 'snibprotgw',
    'reptiles': 'snibreptgw'
};

function getedo() {
    return new Promise((resolve, reject) => {
        knex
            .select(knex.raw('cve_ent, estado'))
            .from('municipios')
            .groupByRaw('cve_ent,estado')
            .orderBy('cve_ent')
            .then(dato => {
                resolve(dato)
            })
    })
}

function getmun(req) {
    let idedo = req.params['idedo'];
    return new Promise((resolve, reject) => {
        knex
            .select(knex.raw('cve_ent,cve_mun, municipio'))
            .from('municipios')
            .whereRaw(`cve_ent='${idedo}'`)
            .orderBy('cve_mun')
            .then(dato => {
                resolve(dato)
            })
    })
}

function conteo() {
    return new Promise((resolve, reject) => {
        knex
            .with('cuenta', knex.raw("SELECT spid, COUNT (*) AS COUNT FROM snibavesgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '07' AND cve_mun = '059' AND munid = snibavesgw.munid ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid"))
            .select(knex.raw('sp_snibavesgw.*,cuenta.count AS nregistros'))
            .from('sp_snibavesgw')
            .innerJoin('cuenta', 'sp_snibavesgw.spid', 'cuenta.spid')
            .then(dato => {
                resolve(dato)
            })
    })
}
function taxonMuni(req) {
    let idmun = req.params['idmun'];
    let grupo = req.params['grupo'];
    let tabla = tablas[grupo];

    return new Promise((resolve, reject) => {
        let query = knex
            .with('cuenta', knex.raw(`SELECT spid,idnombrecatvalido, COUNT (*) AS COUNT FROM ${tabla} WHERE munid=${idmun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY spid,idnombrecatvalido`))
            .select(knex.raw(`cuenta.spid,cuenta.idnombrecatvalido,cuenta.count AS nregistros`))
            .from(`sp_${tabla}`)
            .innerJoin('cuenta', `sp_${tabla}.spid`, 'cuenta.spid')
            .orderBy('cuenta.count', 'desc');

            query.then(dato => {
                resolve(dato)
            })
    })
}
function taxonEdo(req) {
    let idedo = req.params['idedo'];
    let grupo = req.params['grupo'];
    let tabla = tablas[grupo];

    return new Promise((resolve, reject) => {
        let query=knex
            .with('cuenta', knex.raw(`SELECT spid,idnombrecatvalido, COUNT (*) AS COUNT FROM ${tabla} WHERE entid=${idedo} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY spid,idnombrecatvalido`))
            .select(knex.raw(`cuenta.spid,cuenta.idnombrecatvalido,cuenta.count AS nregistros`))
            .from(`sp_${tabla}`)
            .innerJoin('cuenta', `sp_${tabla}.spid`, 'cuenta.spid')
            .orderBy('cuenta.count', 'desc');

        query.then(dato => {
            resolve(dato);
        })
    })
}

function taxonEdoTotal(req) {
    let ent = req.params['idedo'];

    return new Promise((resolve, reject) => {
        let query=knex
            .select(knex.raw('grupobio AS grupo,total'))
            .from('conteos.estados')
            .whereRaw(`entid='${ent}'`)
            .orderByRaw('grupo');

        query.then(dato => {
            resolve(dato);
        })
    })
}

function taxonMunTotal(req) {
    let mun = req.params['idmun'];

    return new Promise((resolve, reject) => {
        knex
            .with('anfibios', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibanfigw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('aves', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibavesgw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('bacterias', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibbactgw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('hongos', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibhonggw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('invertebrados', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibinvegw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('mamiferos', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibmamigw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('peces', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibpecegw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('plantas', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibplangw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('protoctistas', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibprotgw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('reptiles', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibreptgw WHERE munid=${mun} AND idnombrecatvalido <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND especievalidabusqueda <> '' GROUP BY idnombrecatvalido`))
            .with('total', knex.raw(
                    `
        select 'Anfibios'::VARCHAR as grupo, count(*) as total from anfibios
        union select 'Aves'::VARCHAR as grupo, count(*) as total from aves
        union select 'Bacterias'::VARCHAR as grupo, count(*) as total from bacterias
        union select 'Hongos'::VARCHAR as grupo, count(*) as total from hongos
        union select 'Invertebrados'::VARCHAR as grupo, count(*) as total from invertebrados
        union select 'Mamíferos'::VARCHAR as grupo, count(*) as total from mamiferos
        union select 'Peces'::VARCHAR as grupo, count(*) as total from peces
        union select 'Plantas'::VARCHAR as grupo, count(*) as total from plantas
        union select 'Protoctistas'::VARCHAR as grupo, count(*) as total from protoctistas
        union select 'Reptiles'::VARCHAR as grupo, count(*) as total from reptiles
        `))
            .select(knex.raw('*'))
            .from('total')
            .orderByRaw('grupo')
            .then(dato => {
                resolve(dato);
            })
    })
}

function getSnib(req) {
    let idcat = req.params['idcat'];
    let enciclofields = `
        idejemplar,longitud,latitud,especievalidabusqueda,ejemplarfosil,
        region,localidad,paismapa,estadomapa,municipiomapa,coleccion,institucion,paiscoleccion,determinador,
        colector,fechacolecta,proyecto,urlproyecto,urlejemplar,probablelocnodecampo 
    `;
    return new Promise((resolve, reject) => {
        let query=knex
            .select(knex.raw(`${enciclofields}`))
            .from('snib')
            .whereRaw(`idnombrecatvalido = '${idcat}' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%'`);

        query.then(dato => {
            resolve(dato)
        })
    })
}

function getSnibEdo(req) {
    let idcat = req.params['idcat'];
    let entid = req.params['entid'];
    let enciclofields = `
        idejemplar,longitud,latitud,especievalidabusqueda,ejemplarfosil,
        region,localidad,paismapa,estadomapa,municipiomapa,coleccion,institucion,paiscoleccion,determinador,
        colector,fechacolecta,proyecto,urlproyecto,urlejemplar,probablelocnodecampo 
    `;
    return new Promise((resolve, reject) => {
        let query=knex
            .select(knex.raw(`${enciclofields}`))
            .from('snib')
            .whereRaw(`idnombrecatvalido = '${idcat}' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND entid='${entid}'`);

        query.then(dato => {
            resolve(dato)
        })
    })
}

function getSnibMun(req) {
    let idcat = req.params['idcat'];
    let munid = req.params['munid'];
    let enciclofields = `
        idejemplar,longitud,latitud,especievalidabusqueda,ejemplarfosil,
        region,localidad,paismapa,estadomapa,municipiomapa,coleccion,institucion,paiscoleccion,determinador,
        colector,fechacolecta,proyecto,urlproyecto,urlejemplar,probablelocnodecampo 
    `;
    return new Promise((resolve, reject) => {
        let query=knex
            .select(knex.raw(`${enciclofields}`))
            .from('snib')
            .whereRaw(`idnombrecatvalido = '${idcat}' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND munid='${munid}'`);

        query.then(dato => {
            resolve(dato)
        })
    })
}

module.exports = {
    getedo,
    getmun,
    conteo,
    taxonMuni,
    taxonEdo,
    taxonEdoTotal,
    taxonMunTotal,
    getSnib,
    getSnibEdo,
    getSnibMun
};
