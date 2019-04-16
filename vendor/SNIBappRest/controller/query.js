"use strict";

require('./config.js');

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
            .select(knex.raw('entid, entidad'))
            .from('estados')
            /*.groupByRaw('entid,estado')*/
            .orderBy('entid')
            .then(dato => {
                resolve(dato)
            })
    })
}
function getmun(req) {
    let idedo = req.params['idedo']
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
    let idedo = req.params['idedo']
    let idmun = req.params['idmun']
    let grupo = req.params['grupo']
    let tabla = tablas[grupo];
    //console.log(`taxonMuni-> seleccion del grupo: ${grupo} y la tabla ${tablas[grupo]} -----${tabla}`)
    return new Promise((resolve, reject) => {
        knex
            .with('cuenta', knex.raw(`SELECT spid,idnombrecatvalido, COUNT (*) AS COUNT FROM ${tabla} WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${idedo}' AND cve_mun = '${idmun}' AND munid = ${tabla}.munid /*and ${tabla}.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid,idnombrecatvalido,especievalidabusqueda`))
            .select(knex.raw(`sp_${tabla}.especievalidabusqueda,cuenta.idnombrecatvalido,cuenta.count AS nregistros`))
            .from(`sp_${tabla}`)
            .innerJoin('cuenta', `sp_${tabla}.spid`, 'cuenta.spid')
            .then(dato => {
                resolve(dato)
            })
    })
}
function taxonEdo(req) {
    let idedo = req.params['idedo']
    let grupo = req.params['grupo']
    let tabla = tablas[grupo];
    // console.log(`taxonEdo-> seleccion del grupo: ${grupo} y la tabla ${tablas[grupo]}`)
    return new Promise((resolve, reject) => {
        knex
            .with('cuenta', knex.raw(`SELECT spid,idnombrecatvalido, COUNT (*) AS COUNT FROM ${tabla} WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${idedo}' and munid = ${tabla}.munid /*and ${tabla}.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid,idnombrecatvalido,especievalidabusqueda`))
            .select(knex.raw(`sp_${tabla}.especievalidabusqueda,cuenta.idnombrecatvalido,cuenta.count AS nregistros`))
            .from(`sp_${tabla}`)
            .innerJoin('cuenta', `sp_${tabla}.spid`, 'cuenta.spid')
            .then(dato => {
                resolve(dato);
            })
    })
}
//funcion para db0.conabio.gob.mx con el cluster
function taxonEdoTotal2(req) {
    let ent = req.params['idedo']
    //console.log(`idedo:${ent}`);
    return new Promise((resolve, reject) => {
        knex
            .with('anfibios', knex.raw(`select count(*) from ( SELECT COUNT (*) AS COUNT FROM snibanfigw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibanfigw.munid /*and snibanfigw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('aves', knex.raw(`select count(*) from (SELECT COUNT (*) AS COUNT FROM snibavesgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibavesgw.munid /*and snibavesgw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('bacterias', knex.raw(`select count(*) from (SELECT COUNT (*) AS COUNT FROM snibbactgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibbactgw.munid /*and snibbactgw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('hongos', knex.raw(`select count(*) from (SELECT COUNT (*) AS COUNT FROM snibhonggw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibhonggw.munid /*and snibhonggw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('invertebrados', knex.raw(`select count(*) from (SELECT COUNT (*) AS COUNT FROM snibinvegw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibinvegw.munid /*and snibinvegw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('mamiferos', knex.raw(`select count(*) from (SELECT COUNT (*) AS COUNT FROM snibmamigw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibmamigw.munid /*and snibmamigw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('peces', knex.raw(`select count(*) from (SELECT COUNT (*) AS COUNT FROM snibpecegw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibpecegw.munid /*and snibpecegw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('plantas', knex.raw(`select count(*) from (SELECT COUNT (*) AS COUNT FROM snibplangw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibplangw.munid /*and snibplangw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('protoctistas', knex.raw(`select count(*) from (SELECT COUNT (*) AS COUNT FROM snibprotgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibprotgw.munid /*and snibprotgw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('reptiles', knex.raw(`select count(*) from (SELECT COUNT (*) AS COUNT FROM snibreptgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and munid = snibreptgw.munid /*and snibreptgw.comentarioscat=''*/) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid) a`))
            .with('total', knex.raw(
                `
        select 'Anfibios'::VARCHAR as grupo,COUNT as total from anfibios
        union select 'Aves'::VARCHAR as grupo, COUNT as total from aves
        union select 'Bacterias'::VARCHAR as grupo, COUNT as total from bacterias
        union select 'Hongos'::VARCHAR as grupo, COUNT as total from hongos
        union select 'Invertebrados'::VARCHAR as grupo, COUNT as total from invertebrados
        union select 'Mamíferos'::VARCHAR as grupo, COUNT as total from mamiferos
        union select 'Peces'::VARCHAR as grupo, COUNT as total from peces
        union select 'Plantas'::VARCHAR as grupo, COUNT as total from plantas
        union select 'Protoctistas'::VARCHAR as grupo, COUNT as total from protoctistas
        union select 'Reptiles'::VARCHAR as grupo, COUNT as total from reptiles
        `))
            .select(knex.raw('*'))
            .from('total')
            .orderByRaw('grupo')
            .then(dato => {
                //console.log(JSON.parse(JSON.stringify(dato)));
                resolve(dato);
            })
    })
}

function taxonEdoTotal(req) {
    let ent = req.params['idedo']
    console.log(`idedo:${ent}`);
    return new Promise((resolve, reject) => {
        let query=knex
            .select(knex.raw('grupo,total'))
            .from('conteos.estados')
            .whereRaw(`idedo='${ent}'`)
            .orderByRaw('grupo')
            console.log(query.toSQL()['sql'])
            query.then(dato => {
                console.log(JSON.parse(JSON.stringify(dato)));
                resolve(dato);
            })
    })
}
function taxonMunTotal(req) {
    let ent = req.params['idedo']
    let mun = req.params['idmun']
    /*console.log(`
    Resultado de entidad:${ent}, 
    Resultado de Municipio:${mun}
    `)*/
    return new Promise((resolve, reject) => {
        knex
            .with('anfibios', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibanfigw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibanfigw.munid /*and snibanfigw.comentarioscat=''*/ ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
            .with('aves', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibavesgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibavesgw.munid /*and snibavesgw.comentarioscat=''*/  ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
            .with('bacterias', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibbactgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibbactgw.munid /*and snibbactgw.comentarioscat=''*/  ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
            .with('hongos', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibhonggw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibhonggw.munid /*and snibhonggw.comentarioscat=''*/  ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
            .with('invertebrados', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibinvegw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibinvegw.munid /*and snibinvegw.comentarioscat=''*/  ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
            .with('mamiferos', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibmamigw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibmamigw.munid /*and snibmamigw.comentarioscat=''*/  ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
            .with('peces', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibpecegw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibpecegw.munid /*and snibpecegw.comentarioscat=''*/  ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
            .with('plantas', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibplangw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibplangw.munid /*and snibplangw.comentarioscat=''*/  ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
            .with('protoctistas', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibprotgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibprotgw.munid /*and snibprotgw.comentarioscat=''*/  ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
            .with('reptiles', knex.raw(`SELECT COUNT (*) AS COUNT FROM snibreptgw WHERE EXISTS ( SELECT 1 FROM municipios WHERE cve_ent = '${ent}' and cve_mun = '${mun}' and munid = snibreptgw.munid /*and snibreptgw.comentarioscat=''*/  ) AND especievalidabusqueda <> '' AND munid IS NOT NULL GROUP BY spid`))
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
                //console.log(JSON.parse(JSON.stringify(dato)));
                resolve(dato);
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
    taxonMunTotal
}
