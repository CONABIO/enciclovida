$(document).ready(function () {
  // Inicia el mapa
  cargaMapa("map", {
    pantalla_comp: true,
    collapsed: true,
    position: "topright",
  });

  variablesIniciales();
  opciones.filtros = {};
  cargaEjemplares(
    "/explora-por-region/ejemplares?" + "&especie_id=" + opciones.catalogo_id
  );

  // Para cargar las capas del geoserver
  if (opciones.geoserver_url !== undefined)
    cargaCapasGeoserver(opciones.geoserver_url);
});
