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
            console.log('aqui');
    resolve(dato);
})
})
}

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

function dameEspeciesConFiltros(req) {
    return new Promise((resolve, reject) => {
        var query = knex
            .select(knex.raw('idnombrecatvalido,nregistros,nom,iucn,cites'))
            .from('filtros')
            .orderByRaw('nregistros DESC')
            .limit(10);

    if (req.nom !== undefined)
        query.whereIn('nom', req.nom);
    if (req.iucn !== undefined)
        query.whereIn('iucn', req.iucn);
    if (req.cites !== undefined)
        query.whereIn('cites', req.cites);
    if (req.grupo !== undefined)
        query.whereIn('grupobio', req.grupo);

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

    query.then(dato => {
        resolve(dato);
})
})
}

module.exports = {
    dameEstados,
    dameMunicipios,
    dameANP,
    dameEspeciesPorEstado,
    dameEspeciesPorMunicipio,
    dameEspeciesPorANP,
    dameEspeciesConFiltros,
    conteo,
    taxonMuni,
    taxonEdo,
    taxonEdoTotal,
    taxonMunTotal
};
