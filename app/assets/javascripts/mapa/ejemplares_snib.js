/**
 * Borra ejemplares anteriores y carga los nuevos
 * @param url
 */
var cargaEjemplaresSnib = function(url)
{
    borraEjemplaresAnterioresSnib();
    geojsonSnib(url);
};

/**
 * Borra ejemplares anteriores
 */
var borraEjemplaresAnterioresSnib = function()
{
    if (typeof snibLayer !== 'undefined')
    {
        if (map.hasLayer(snibLayer))
        {
            map.removeControl(snib_control);
            map.removeLayer(snibLayer);
        }
    }

    snibLayer = L.markerClusterGroup({ chunkedLoading: true, spiderfyDistanceMultiplier: 2,
        spiderLegPolylineOptions: { weight: 1.5, color: 'white', opacity: 0.5 }, disableClusteringAtZoom: 10,
        iconCreateFunction: function (cluster) {
            var markers = cluster.getAllChildMarkers();
            return L.divIcon({ html: '<div><span>' + markers.length + '</span></div>', className: 'div-cluster-snib',
                iconSize: L.point(40, 40) });
        }
    });
};

/**
 * La simbologia dentro del mapa
 */
var leyendaSnib = function()
{
    snib_control = L.control.layers({}, {}, {collapsed: false, position: 'bottomright'}).addTo(map);

    snib_control.addOverlay(snibLayer,
        '<b>Ejemplares del SNIB</b><br />(museos, colectas y proyectos) <sub>' + ejemplares_conteo + '</sub>'
    );

    snib_control.addOverlay(coleccionesLayer,
        '<span aria-hidden="true" class="glyphicon glyphicon-map-marker div-icon-snib"></span>Especímenes en colecciones <sub>' + colecciones_conteo + '</sub>'
    );

    snib_control.addOverlay(observacionesLayer,
        '<span aria-hidden="true" class="feather-ev-icon div-icon-snib"></span>Observaciones de aVerAves <sub>' + observaciones_conteo + '</sub>'
    );

    snib_control.addOverlay(fosilesLayer,
        '<span aria-hidden="true" class="bone-ev-icon div-icon-snib"></span>Fósiles <sub>' + fosiles_conteo + '</sub>'
    );

    snib_control.addOverlay(noCampoLayer,
        '<span aria-hidden="true" class="glyphicon glyphicon-flag div-icon-snib"></span>Localidad no de campo <sub>' + no_campo_conteo + '</sub>'
    );
};

/**
 * Añade los puntos en forma de fuentes
 */
var aniadePuntosSnib = function()
{
    var geojsonFeature =  { "type": "FeatureCollection", "features": allowedPoints.values() };

    var colecciones = L.geoJson(geojsonFeature, {
        pointToLayer: function (feature, latlng) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                if (feature.properties.d[1] == 1)  // Este campos quiere decir que es el deafult de la coleccion
                {
                    colecciones_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<span aria-hidden="true" class="glyphicon glyphicon-map-marker"></span>'})});
                }
            } else {
                if (!feature.properties.d.coleccion.toLowerCase().includes('averaves') && !feature.properties.d.coleccion.toLowerCase().includes('ebird')
                && feature.properties.d.ejemplarfosil.toLowerCase() != 'si' && feature.properties.d.probablelocnodecampo.toLowerCase() != 'si')
                {
                    colecciones_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<span aria-hidden="true" class="glyphicon glyphicon-map-marker"></span>'})});
                }
            }
        },
        onEachFeature: function (feature, layer) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                layer.on("click", function () {
                    ejemplarSnibGeojson(layer, feature.properties.d[0]);
                });
            } else
                layer.bindPopup(ejemplarSnib(feature.properties.d));
        }
    });

    var observaciones = L.geoJson(geojsonFeature, {
        pointToLayer: function (feature, latlng) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                if (feature.properties.d[1] == 2)  // Este campos quiere decir que es de aves aves
                {
                    observaciones_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<span aria-hidden="true" class="feather-ev-icon"></span>'})});
                }
            } else {
                if (feature.properties.d.coleccion.toLowerCase().includes('averaves') || feature.properties.d.coleccion.toLowerCase().includes('ebird'))
                {
                    observaciones_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<span aria-hidden="true" class="feather-ev-icon"></span>'})});
                }
            }
        },
        onEachFeature: function (feature, layer) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                layer.on("click", function () {
                    ejemplarSnibGeojson(layer, feature.properties.d[0]);
                });
            } else
                layer.bindPopup(ejemplarSnib(feature.properties.d));
        }
    });

    var fosiles = L.geoJson(geojsonFeature, {
        pointToLayer: function (feature, latlng) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                if (feature.properties.d[1] == 3)  // Este campos quiere decir que es de fosiles
                {
                    fosiles_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<span aria-hidden="true" class="bone-ev-icon"></span>'})});
                }
            } else {
                if (feature.properties.d.ejemplarfosil.toLowerCase() == 'si')
                {
                    fosiles_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<span aria-hidden="true" class="bone-ev-icon"></span>'})});
                }
            }
        },
        onEachFeature: function (feature, layer) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                layer.on("click", function () {
                    ejemplarSnibGeojson(layer, feature.properties.d[0]);
                });
            } else
                layer.bindPopup(ejemplarSnib(feature.properties.d));
        }
    });

    var noCampo = L.geoJson(geojsonFeature, {
        pointToLayer: function (feature, latlng) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                if (feature.properties.d[1] == 4)  // Este campos quiere decir que es de locacion no de campo
                {
                    no_campo_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<span aria-hidden="true" class="glyphicon glyphicon-flag"></span>'})});
                }
            } else {
                if (feature.properties.d.probablelocnodecampo.toLowerCase() == 'si')
                {
                    no_campo_conteo++;
                    return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<span aria-hidden="true" class="glyphicon glyphicon-flag"></span>'})});
                }
            }
        },
        onEachFeature: function (feature, layer) {
            // Para distinguir si son solo las coordenadas
            if (opciones.solo_coordenadas)
            {
                layer.on("click", function () {
                    ejemplarSnibGeojson(layer, feature.properties.d[0]);
                });
            } else
                layer.bindPopup(ejemplarSnib(feature.properties.d));
        }
    });

    coleccionesLayer = L.featureGroup.subGroup(snibLayer, colecciones);
    coleccionesLayer.addLayer(colecciones);
    observacionesLayer = L.featureGroup.subGroup(snibLayer, observaciones);
    observacionesLayer.addLayer(observaciones);
    fosilesLayer = L.featureGroup.subGroup(snibLayer, fosiles);
    fosilesLayer.addLayer(fosiles);
    noCampoLayer = L.featureGroup.subGroup(snibLayer, noCampo);
    noCampoLayer.addLayer(noCampo);

    map.addLayer(snibLayer);
    map.addLayer(coleccionesLayer);
    map.addLayer(observacionesLayer);
    map.addLayer(fosilesLayer);
    leyendaSnib();
};

/**
 * Hace una ajax request para la obtener la información de un taxon, esto es más rapido para muchos ejemplares
 * */
var ejemplarSnibGeojson = function(layer, id)
{
    $.ajax({
        url: "/especies/" + opciones.especie_id + "/ejemplar-snib/" + id,
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
 * Lanza el pop up con la inforamcion del taxon, ya esta cargado; este metodo es lento con muchos ejemplares
 * */
var ejemplarSnib = function(prop)
{
    console.log(opciones);
    var datos = opciones.datos.taxones[opciones.especie_id];

    if (datos !== undefined)
    {
        var nombre_comun = '';
        if (datos.nombre_comun !== undefined) var nombre_comun = '<h4 class="text-center">' + datos.nombre_comun + '</h4>';
        var nombre = nombre_comun + '</h4><h4 class="text-center"><a href="/especies/' + datos.id + '"><i>' + datos.nombre_cientifico + '</i></a></h4>';
    }

    var contenido = "";
    contenido += "" + nombre + "";
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

    //Para enviar un comentario acerca de un ejemplar en particular
    contenido += "<dt>¿Tienes un comentario?: </dt><dd><a href='/especies/" + opciones.especie_id + "/comentarios/new?proveedor_id=" +
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
            if (d.estatus != undefined) d = d.resultados;

            ejemplares_conteo = d.length;
            colecciones_conteo = 0;
            observaciones_conteo = 0;
            fosiles_conteo = 0;
            no_campo_conteo = 0;

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

            aniadePuntosSnib();
        },
        error: function( jqXHR ,  textStatus,  errorThrown ){
            console.log("error: " + textStatus);
            console.log(errorThrown);
            console.log(jqXHR.responseText);
        }
    });
};