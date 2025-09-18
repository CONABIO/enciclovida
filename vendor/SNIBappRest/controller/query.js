"use strict";

require("./config.js");
const http = require("https");

const TABLES = {
  estados: "estados",
  municipios: "municipios",
  anp: "anp",
};

/**
 * Regresa la lista de estados
 */
function dameEstados() {
  return knex
    .select(knex.raw("entid, nom_ent"))
    .from(TABLES.estados)
    .orderBy("entid");
}

/**
 * Regresa la lista de municipios
 */
function dameMunicipios() {
  return knex
    .select(knex.raw("munid, nom_mun, nom_ent"))
    .from(TABLES.municipios)
    .orderBy("munid");
}

/**
 * Regresa la lista de areas naturales protegidas
 */
function dameANP() {
  return knex
    .select(knex.raw("anpid, nombre, cat_manejo, estados, municipios"))
    .from(TABLES.anp)
    .orderBy("anpid");
}

/**
 * Hace una petición ajax
 * @param {string} url
 * @param callback: receives an object
 */
let ajaxRequest = function (url, callback) {
  let resultado = "";

  return http
    .get(url, (res) => {
      res.on("data", (chunk) => {
        resultado += chunk;
      });
    })
    .on("error", (error) => {
      console.error(`ajaxRequest: http.get, url: ${url}`, error);
    })
    .on("close", () => {
      try {
        const obj = JSON.parse(resultado)
        callback(obj);
      }catch(error) {
        console.error(`ajaxRequest: No fue posible parsear string (JSON.parse)`,error)
      }
    });
};

module.exports = {
  dameEstados,
  dameMunicipios,
  dameANP,
  ajaxRequest,
};
