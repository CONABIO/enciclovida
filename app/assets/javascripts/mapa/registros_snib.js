/**
 * Borra registros anteriores y carga los nuevos
 * @param url
 */
var cargaRegistrosSnib = function(url)
{
    borraRegistrosAnterioresSnib();
    geojsonSnib(url);
};

/**
 * Borra registros anteriores
 */
var borraRegistrosAnterioresSnib = function()
{
    if (map.hasLayer(markersLayer))
    {
        map.removeControl(legend_control);
        map.removeLayer(markersLayer);
        markersLayer = L.markerClusterGroup({ chunkedLoading: true, spiderfyDistanceMultiplier: 2,
            spiderLegPolylineOptions: { weight: 1.5, color: 'white', opacity: 0.5 }
        });
    }
};

/**
 * La simbologia dentro del mapa
 * @param con_conteo
 */
var leyendaSnib = function(con_conteo)
{
    legend_control = L.control.layers({}, {}, {collapsed: false, position: 'bottomleft'}).addTo(map);

    if (con_conteo == undefined)
        var conteo = "<b>Registros del SNIB</b>";
    else
        var conteo = "<b>Registros del SNIB <sub>" + registros_conteo + "</sub></b>";

    var marker_default = '&nbsp;&nbsp;<i class="circle-ev-icon div-icon-snib-default"></i>Especímenes en colecciones<br />';
    var marker_averaves = '<i class="feather-ev-icon div-icon-snib"></i>Observaciones<br />';
    var marker_fosil = '<i class="bone-ev-icon div-icon-snib"></i>Fósiles';

    legend_control.addOverlay(markersLayer,
        conteo + "<p>" + marker_default + marker_averaves + marker_fosil + "</p>"
    );
};

/**
 * Añade los puntos en forma de fuentes
 */
var aniadePuntosSnib = function()
{
    var geojsonFeature =  { "type": "FeatureCollection", "features": allowedPoints.values()};

    var species_layer = L.geoJson(geojsonFeature, {
        pointToLayer: function (feature, latlng) {
            // Para distinguir si son solo las corrdenadas
            if (opciones.solo_coordenadas)
            {
                if (feature.properties.d[1])  // Este campos quiere decir que es de aves aves
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<i class="feather-ev-icon"></i>'})});
                else if (feature.properties.d[2])  // Este campo quiere decir que es de localidad no de campo
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib-default', html: '<i class="circle-ev-icon"></i>'})});
                else  // de lo contrario es un registro rojo normal
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib-default', html: '<i class="circle-ev-icon"></i>'})});
            } else {
                if (feature.properties.d.ejemplarfosil == 'SI')  // Este campos quiere decir que es un fosil
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<i class="bone-ev-icon"></i>'})});
                else if (feature.properties.d.coleccion.toLowerCase().includes('averaves') || feature.properties.d.coleccion.toLowerCase().includes('ebird'))  // Este campos quiere decir que es de aves aves
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<i class="feather-ev-icon"></i>'})});
                else  // de lo contrario es un registro normal
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib-default', html: '<i class="circle-ev-icon"></i>'})});
            }
        },
        onEachFeature: function (feature, layer) {
            // Para distinguir si son solo las corrdenadas
            if (opciones.solo_coordenadas)
            {
                layer.on("click", function () {
                    ejemplarSnibGeojson(layer, feature.properties.d[0]);
                });
            } else
                layer.bindPopup(ejemplarSnib(feature.properties.d));
        }
    });

    markersLayer.addLayer(species_layer);
    map.addLayer(markersLayer);

    leyendaSnib(true);
};

/**
 * Hace una ajax request para la obtener la información de un taxon, esto es más rapido para muchos registros
 * */
var ejemplarSnibGeojson = function(layer, id)
{
    $.ajax({
        url: "/especies/" + opciones.taxon + "/ejemplar-snib/" + id,
        dataType : "json",
        success : function (res){
            if (res.estatus)
            {
                var contenido = ejemplarSnib(res.ejemplar);
                layer.bindPopup(contenido);
                layer.openPopup();
            }
            else
                console.log("Hubo un error al retraer el ejemplar: " + res.msg);
        },
        error: function( jqXHR ,  textStatus,  errorThrown ){
            console.log("error: " + textStatus);
            console.log(errorThrown);
            console.log(jqXHR.responseText);
        }
    });  // termina ajax
};

/**
 * Lanza el pop up con la inforamcion del taxon, ya esta cargado; este metodo es lento con muchos registros
 * */
var ejemplarSnib = function(prop)
{
    // Sustituye las etiquetas h5 por h4 y centra el texto
    var nombre_f = $('<textarea/>').html(opciones.nombre).text().replace(/<h5/g, "<h4 class='text-center'").replace(/<\/h5/g, "</h4");
    var contenido = "";

    contenido += "" + nombre_f + "";
    contenido += "<dt>Localidad: </dt><dd>" + prop.localidad + "</dd>";
    contenido += "<dt>Municipio: </dt><dd>" + prop.municipiomapa + "</dd>";
    contenido += "<dt>Estado: </dt><dd>" + prop.estadomapa + "</dd>";
    contenido += "<dt>País: </dt><dd>" + prop.paismapa + "</dd>";
    contenido += "<dt>Fecha: </dt><dd>" + prop.fechacolecta + "</dd>";
    contenido += "<dt>Colector: </dt><dd>" + prop.colector + "</dd>";
    contenido += "<dt>Colección: </dt><dd>" + prop.coleccion + "</dd>";
    contenido += "<dt>Institución: </dt><dd>" + prop.institucion + "</dd>";
    contenido += "<dt>País de la colección: </dt><dd>" + prop.paiscoleccion + "</dd>";

    if (prop.proyecto.length > 0 && prop.urlproyecto.length > 0)
        contenido += "<dt>Proyecto: </dt><dd><a href='" + prop.urlproyecto + "' target='_blank'>" + prop.proyecto + "</a></dd>";

    contenido += "<dt>Más información: </dt><dd><a href='" + prop.urlejemplar + "' target='_blank'>consultar</a></dd>";

    //Para enviar un comentario acerca de un registro en particular
    contenido += "<dt>¿Tienes un comentario?: </dt><dd><a href='/especies/" + opciones.taxon + "/comentarios/new?proveedor_id=" +
        prop.idejemplar + "&tipo_proveedor=6' target='_blank'>redactar</a></dd>";

    return "<dl class='dl-horizontal'>" + contenido + "</dl>" + "<strong>ID SNIB: </strong>" + prop.idejemplar;
};

/**
 * Carga el geojson para iterarlo
 * @param url
 */
var geojsonSnib = function(url)
{
    $.ajax({
        url: url,
        dataType : "json",
        success : function (d){
            registros_conteo = d.length;
            allowedPoints = d3.map([]);

            for(var i=0;i<d.length;i++)
            {
                var item_id = 'geo-' + i.toString();

                if (opciones.solo_coordenadas)
                {
                    allowedPoints.set(item_id, {
                        "type"      : "Feature",
                        "properties": {d: [d[i][2], d[i][3], d[i][4]]},
                        "geometry"  : {coordinates: [d[i][0], d[i][1]], type: "Point"}
                    });
                } else {
                    allowedPoints.set(item_id, {
                        "type"      : "Feature",
                        "properties": {d: d[i]},
                        "geometry"  : JSON.parse(d[i].json_geom)
                    });
                }
            }

            aniadePuntosSnib();
        },
        error: function( jqXHR ,  textStatus,  errorThrown ){
            console.log("error: " + textStatus);
            console.log(errorThrown);
            console.log(jqXHR.responseText);
        }
    });
};