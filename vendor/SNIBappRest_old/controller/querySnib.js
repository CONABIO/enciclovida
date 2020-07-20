"use strict"

require('./config.js');
const http = require('http');

function getSnib(req) {
    let qtype = req.params['qtype']
    let rd = req.params['rd']
    let id = req.params['id']
    let enciclofields = "idejemplar,longitud,latitud,especievalidabusqueda,ejemplarfosil,region,localidad,paismapa,estadomapa,municipiomapa,coleccion,institucion,paiscoleccion,determinador,colector,fechacolecta,proyecto,urlproyecto,urlejemplar,probablelocnodecampo"
    return new Promise((resolve, reject) => {
        knex
            .select(knex.raw(`st_asgeojson(the_geom) AS json_geom,${enciclofields}`))
            .from(`public.${rd}`)
            .whereRaw(`idnombrecatvalido = '${id}' AND coleccion != 'Naturalista Naturalista'/*AND comentarioscat=''*/`)
            .then(dato => {
                resolve(dato)
            })
    })
}
function getSnibEdo(req) {
    let qtype = req.params['qtype']
    let rd = req.params['rd']
    let id = req.params['id']
    let idedo = req.params['idedo']
    let enciclofields = `
        idejemplar,longitud,latitud,especievalidabusqueda,ejemplarfosil,
        region,localidad,paismapa,estadomapa,municipiomapa,coleccion,institucion,paiscoleccion,determinador,
        colector,fechacolecta,proyecto,urlproyecto,urlejemplar,probablelocnodecampo 
    `
    return new Promise((resolve, reject) => {
        knex
            .select(knex.raw(`st_asgeojson(the_geom) AS json_geom,${enciclofields}`))
            .from(`public.${rd}`)
            .whereRaw(`idnombrecatvalido = '${id}' /*and comentarioscat=''*/ and exists(select 1 from municipios where cve_ent = '${idedo}' and munid = ${rd}.munid)`)
            .then(dato => {
                resolve(dato)
            })
    })
}
function getSnibMun(req) {
    let qtype = req.params['qtype']
    let rd = req.params['rd']
    let id = req.params['id']
    let idedo = req.params['idedo']
    let idmun = req.params['idmun']
    let enciclofields = `
        idejemplar,longitud,latitud,especievalidabusqueda,ejemplarfosil,
        region,localidad,paismapa,estadomapa,municipiomapa,coleccion,institucion,paiscoleccion,determinador,
        colector,fechacolecta,proyecto,urlproyecto,urlejemplar,probablelocnodecampo 
    `
    return new Promise((resolve, reject) => {
        knex
            .select(knex.raw(`st_asgeojson(the_geom) AS json_geom,${enciclofields}`))
            .from(`public.${rd}`)
            .whereRaw(`idnombrecatvalido = '${id}' /*AND comentarioscat=''*/ and exists(select 1 from municipios where cve_ent = '${idedo}' and cve_mun = '${idmun}' and munid = ${rd}.munid)`)
            .then(dato => {
                resolve(dato)
            })
    })
}
module.exports = {
    getSnib,
    getSnibEdo,
    getSnibMun
}
