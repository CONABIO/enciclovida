/**
 * Borra observaciones anteriores y carga las nuevas
 * @param url
 */
var cargaObservacionesNaturalista = function(url)
{
    naturalistaLayer = L.markerClusterGroup({ chunkedLoading: true, spiderfyDistanceMultiplier: 2,
        spiderLegPolylineOptions: { weight: 1.5, color: 'white', opacity: 0.5 }
    });

    borraObservacionesAnterioresNaturalista();
    geojsonNaturalista(url);
};

/**
 * Borra observaciones anteriores
 */
var borraObservacionesAnterioresNaturalista = function()
{
    if (map.hasLayer(naturalistaLayer))
    {
        map.removeControl(naturalista_control);
        map.removeLayer(naturalistaLayer);
        naturalistaLayer = L.markerClusterGroup({ chunkedLoading: true, spiderfyDistanceMultiplier: 2,
            spiderLegPolylineOptions: { weight: 1.5, color: 'white', opacity: 0.5 }
        });
    } else {
        naturalistaLayer = L.markerClusterGroup({
            chunkedLoading: true, spiderfyDistanceMultiplier: 2,
            spiderLegPolylineOptions: {weight: 1.5, color: 'white', opacity: 0.5}
        });
    }
};

/**
 * La simbologia dentro del mapa
 */
var leyendaNaturalista = function()
{
    naturalista_control = L.control.layers({}, {}, {collapsed: false, position: 'bottomleft'}).addTo(map);

    naturalista_control.addOverlay(naturalistaLayer,
        '<b>Observaciones de <span aria-hidden="true" class="naturalista-3-ev-icon"></span><span aria-hidden="true" class="naturalista-4-ev-icon"></span></b><br />(ciencia ciudadana) <sub>' + observaciones_conteo + '</sub>'
    );

    naturalista_control.addOverlay(investigacionLayer,
        '<span aria-hidden="true" class="glyphicon glyphicon-map-marker div-icon-naturalista"></span>Grado de investigación <sub>' + investigacion_conteo + '</sub>'
    );

    naturalista_control.addOverlay(casualLayer,
        '<span aria-hidden="true" class="glyphicon glyphicon-flag div-icon-naturalista"></span>Grado casual <sub>' + casual_conteo + '</sub>'
    );
};

/**
 * Añade los puntos en forma de fuentes
 */
var aniadePuntosNaturaLista = function()
{
    var geojsonFeature =  { "type": "FeatureCollection", "features": allowedPoints.values() };

    var investigacion = L.geoJson(geojsonFeature, {
        pointToLayer: function (feature, latlng) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                if (feature.properties.d[1] == 1)  // Este campos quiere decir que es de grado de investigacion
                {
                    investigacion_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-naturalista', html: '<span aria-hidden="true" class="glyphicon glyphicon-map-marker"></span>'})});
                }
            } else {
                if (feature.properties.d.quality_grade.toLowerCase() == 'investigación')
                {
                    investigacion_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-naturalista', html: '<span aria-hidden="true" class="glyphicon glyphicon-map-marker"></span>'})});
                }
            }
        },
        onEachFeature: function (feature, layer) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                layer.on("click", function () {
                    observacionNaturalistaGeojson(layer, feature.properties.d[0]);
                });
            } else
                layer.bindPopup(observacionNaturalista(feature.properties.d));
        }
    });

    var casual = L.geoJson(geojsonFeature, {
        pointToLayer: function (feature, latlng) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                if (feature.properties.d[1] == 2)  // Este campos quiere decir que es de grado casual
                {
                    casual_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-naturalista', html: '<span aria-hidden="true" class="glyphicon glyphicon-flag"></span>'})});
                }
            } else {
                if (feature.properties.d.quality_grade.toLowerCase() == 'casual')
                {
                    casual_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-naturalista', html: '<span aria-hidden="true" class="glyphicon glyphicon-flag"></span>'})});
                }
            }
        },
        onEachFeature: function (feature, layer) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                layer.on("click", function () {
                    observacionNaturalistaGeojson(layer, feature.properties.d[0]);
                });
            } else
                layer.bindPopup(observacionNaturalista(feature.properties.d));
        }
    });

    investigacionLayer = L.featureGroup.subGroup(naturalistaLayer, investigacion);
    investigacionLayer.addLayer(investigacion);
    casualLayer = L.featureGroup.subGroup(naturalistaLayer, casual);
    casualLayer.addLayer(casual);

    map.addLayer(naturalistaLayer);
    map.addLayer(investigacionLayer);
    leyendaNaturalista();
};

/**
 * Hace una ajax request para la obtener la información de un taxon, esto es más rapido para muchas observaciones
 * */
var observacionNaturalistaGeojson = function(layer, id)
{
    $.ajax({
        url: "/especies/" + opciones.taxon + "/observacion-naturalista/" + id,
        dataType : "json",
        success : function (res){
            if (res.estatus)
            {
                var contenido = observacionNaturalista(res.observacion);
                layer.bindPopup(contenido);
                layer.openPopup();
            }
            else
                console.log("Hubo un error al retraer la observación: " + res.msg);
        },
        error: function( jqXHR ,  textStatus,  errorThrown ){
            console.log("error: " + textStatus);
            console.log(errorThrown);
            console.log(jqXHR.responseText);
        }
    });  // termina ajax
};

/**
 * Lanza el pop up con la inforamcion del taxon, ya esta cargado; este metodo es lento con muchas observaciones
 * */
var observacionNaturalista = function(prop)
{
    // Sustituye las etiquetas h5 por h4 y centra el texto
    var nombre_f = $('<textarea/>').html(opciones.nombre).text().replace(/<h5/g, "<h4 class='text-center'").replace(/<\/h5/g, "</h4");
    var contenido = "";

    contenido += "" + nombre_f + "";

    if (prop.thumb_url != undefined)
    {
        contenido += "<div><img style='margin: 10px auto!important;' class='img-responsive' src='" + prop.thumb_url + "'/></div>";
        contenido += "<dt>Atribución: </dt><dd>" + prop.attribution + "</dd>";
    }

    contenido += "<dt>Fecha: </dt><dd>" + prop.observed_on + "</dd>";
    contenido += "<dt>¿Silvestre / Naturalizado?: </dt><dd>" + (prop.captive == true ? 'sí' : 'no') + "</dd>";
    contenido += "<dt>Grado de calidad: </dt><dd>" + prop.quality_grade + "</dd>";
    contenido += "<dt>URL NaturaLista: </dt><dd><a href='"+ prop.uri +"' target='_blank'>ver la observación</a></dd>";

    // Para enviar un comentario acerca de un registro en particular
    contenido += "<dt>¿Tienes un comentario?: </dt><dd><a href='/especies/" + opciones.taxon + "/comentarios/new?proveedor_id=" + prop.id + "&tipo_proveedor=7' target='_blank'>redactar</a></dd>";

    return "<dl class='dl-horizontal'>" + contenido + "</dl>";
};

/**
 * Carga el geojson para iterarlo
 * @param url
 */
var geojsonNaturalista = function(url)
{
    $.ajax({
        url: url,
        dataType : "json",
        success : function (d){
            observaciones_conteo = d.length;
            investigacion_conteo = 0;
            casual_conteo = 0;

            allowedPoints = d3.map([]);

            for(var i=0;i<d.length;i++)
            {
                var item_id = 'geo-' + i.toString();

                if (opciones.solo_coordenadas)
                {
                    allowedPoints.set(item_id, {
                        "type"      : "Feature",
                        "properties": {d: [d[i][2], d[i][3]]},
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

            aniadePuntosNaturaLista();
        },
        error: function( jqXHR ,  textStatus,  errorThrown ){
            console.log("error: " + textStatus);
            console.log(errorThrown);
            console.log(jqXHR.responseText);
        }
    });
};