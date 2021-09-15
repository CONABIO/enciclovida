"use strict";

require("./config.js");
const http = require("https");

/**
 * Regresa la lista de estados
 * @returns {boolean}
 */
function dameEstados() {
  return new Promise((resolve, reject) => {
    knex
      .select(knex.raw("entid, nom_ent"))
      .from("estados")
      .orderBy("entid")
      .then((dato) => {
        resolve(dato);
      });
  });
}

/**
 * Regresa ka lista de municipios
 * @returns {boolean}
 */
function dameMunicipios() {
  return new Promise((resolve, reject) => {
    knex
      .select(knex.raw("munid, nom_mun, nom_ent"))
      .from("municipios")
      .orderBy("munid")
      .then((dato) => {
        resolve(dato);
      });
  });
}

/**
 * Regresa la lista de municipios
 * @returns {boolean}
 */
function dameANP() {
  return new Promise((resolve, reject) => {
    knex
      .select(knex.raw("anpid, nombre, cat_manejo, estados, municipios"))
      .from("anp")
      .orderBy("anpid")
      .then((dato) => {
        resolve(dato);
      });
  });
}

/**
 * Hace una petición ajax
 * @param url
 */
let ajaxRequest = function (url, reply) {
  var resultado = "";

  http
    .get(url, (res) => {
      res.on("data", (d) => {
        resultado += d;
      });
    })
    .on("error", (e) => {
      console.error(e);
    })
    .on("close", (d) => {
      reply(JSON.parse(resultado));
    });
};

module.exports = {
  dameEstados,
  dameMunicipios,
  dameANP,
  ajaxRequest,
};
