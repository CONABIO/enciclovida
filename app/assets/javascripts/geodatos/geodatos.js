$(document).ready(function(){

    var geojsonFeature = [];
    var allowedPoints = d3.map([]);

    var geoportal_count = 0;
    var naturalista_count = 0;

    var geojsonMarkerGeoportalOptions = {
        radius: 5,
        fillColor: "#ff0000",
        color: "white",
        weight: 2,
        opacity: 1,
        fillOpacity: 0.6
    };

    var geojsonMarkerGeoportalFosilOptions = {
        radius: 5,
        fillColor: "#2a2a2a",
        color: "white",
        weight: 2,
        opacity: 1,
        fillOpacity: 0.6
    };

    var geojsonMarkerGeoportalAveravesOptions = {
        radius: 5,
        fillColor: "#FFA500",
        color: "black",
        weight: 2,
        opacity: 1,
        fillOpacity: 0.6
    };

    var geojsonMarkerNaturaListaInvOptions = {
        radius: 5,
        fillColor: "#0b9c31",
        color: "white",
        weight: 2,
        opacity: 1,
        fillOpacity: 0.6
    };

    var geojsonMarkerNaturaListaCasualOptions = {
        radius: 5,
        fillColor: "#FFFF00",
        color: "white",
        weight: 2,
        opacity: 1,
        fillOpacity: 0.6
    };

    var customOptions ={
        'maxWidth': '500',
        'className' : 'custom'
    };

    /***************************************************************** Layer creation */
    var OSM_layer = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png');


    // Google terrain map layer
    var GTM_layer = L.tileLayer('http://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',{
        maxZoom: 20,
        subdomains:['mt0','mt1','mt2','mt3']
    });
    // Google Hybrid
    var GHM_layer = L.tileLayer('http://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',{
        maxZoom: 20,
        subdomains:['mt0','mt1','mt2','mt3']
    });
    var drawnItems = new L.FeatureGroup();

    var milliseconds = new Date().getTime();

    var species_layer;
    var markersLayer;

    /***************************************************************** map switcher */
    /* Quite var, para poder tener acceso a la variable fuera del scope*/
    map = L.map('map', {
        center: [23.79162789, -102.04376221],
        fullscreenControl: true,
        zoom: 5,
        //maxBounds: L.latLngBounds(L.latLng(14.3227,-86.4236),L.latLng(32.4306,-118.2727)),
        layers: [
            OSM_layer,
            GTM_layer,
            GHM_layer
        ]
    });

    /***************************************************************** layer switcher */
    var baseMaps = {
        "Open Street Maps": OSM_layer,
        "Vista de terreno": GTM_layer,
        "Vista Híbrida": GHM_layer
    };

    var layer_control = L.control.layers(baseMaps).addTo(map);
    var legend_control = L.control.layers({}, {}, {collapsed: false, position: 'bottomleft'}).addTo(map);

    /***************************************************************** aditional controls */
    function addPointLayerGeoportal(){
        geojsonFeature =  { "type": "FeatureCollection",
            "features": allowedPoints.values()};

        markersLayer = L.markerClusterGroup({ maxClusterRadius: 30, chunkedLoading: true, which_layer: 'geoportal', chunkInterval: '2000', chunkDelay: 1});

        species_layer = L.geoJson(geojsonFeature, {
            pointToLayer: function (feature, latlng) {
                // Este campos quiere decir que es de aves aves
                if (feature.properties.d[1])
                    return L.circleMarker(latlng, geojsonMarkerGeoportalAveravesOptions);
                //else if (fosil != undefined && fosil != "")
                  //  return L.circleMarker(latlng, geojsonMarkerGeoportalFosilOptions);
                else  // de lo contrario es un registro rojo normal
                    return L.circleMarker(latlng, geojsonMarkerGeoportalOptions);
            },
            onEachFeature: function (feature, layer) {
                layer.on("click", function (e) {
                    ejemplar_snib(layer, feature.properties.d[0]);
                });
            }
        });

        markersLayer.addLayer(species_layer);
        map.addLayer(markersLayer);

        var punto_rojo = '<svg height="50" width="200"><circle cx="10" cy="10" r="6" stroke="black" stroke-width="1" stroke-opacity="1" fill="#FF0000"/>';
        punto_rojo+= '<text x="20" y="13">Registros del SNIB</text>';

        var punto_naranja = punto_rojo + '<circle cx="10" cy="25" r="6" stroke="black" stroke-width="1" stroke-opacity="1" fill="#FFA500"/>';
        punto_naranja+= '<text x="20" y="28">Registros de AverAves</text>';

        /*var punto_gris = punto_naranja + '<circle cx="10" cy="40" r="6" stroke="black" stroke-width="1" stroke-opacity="1" fill="#888888"/>';
        punto_gris+= '<text x="20" y="43">Registros de Fósiles</text></svg>';*/

        legend_control.addOverlay(markersLayer,
            "<b>Registros del SNIB <sub>" + geoportal_count + "</sub><br /> (museos, colectas y proyectos)</b>" +
            "<p>"+punto_naranja+"</p>"
        );
    }

    function addPointLayerNaturaLista(){
        geojsonFeature =  { "type": "FeatureCollection",
            "features": allowedPoints.values()};

        markersLayer = L.markerClusterGroup({ maxClusterRadius: 30, chunkedLoading: true, which_layer: 'naturalista', chunkInterval: '2000', chunkDelay: 1});

        species_layer = L.geoJson(geojsonFeature, {
            pointToLayer: function (feature, latlng) {
                // Para cuando es una observacion casual o de investigacion
                if (feature.properties.d[1])
                    return L.circleMarker(latlng, geojsonMarkerNaturaListaInvOptions);
                else
                    return L.circleMarker(latlng, geojsonMarkerNaturaListaCasualOptions);
                //return L.marker(latlng, {icon: L.divIcon({className: "glyphicon glyphicon-map-marker"})});
            },
            onEachFeature: function (feature, layer) {
                layer.on("click", function (e) {
                    observacion_naturalista(layer, feature.properties.d[0]);
                    });
            }
        });

        markersLayer.addLayer(species_layer);
        map.addLayer(markersLayer);

        // Para la legenda de la simbologia
        var punto_verde = '<svg height="35" width="200"><circle cx="10" cy="10" r="6" stroke="black" stroke-width="1" stroke-opacity="1" fill="#0b9c31" />';
        punto_verde+= '<text x="20" y="13" >Grado de investigación</text>';

        var punto_amarillo = punto_verde + '<circle cx="10" cy="25" r="6" stroke="black" stroke-width="1" stroke-opacity="1" fill="#FFFF00" />';
        punto_amarillo+= '<text x="20" y="28">Grado casual</text></svg>';

        legend_control.addOverlay(markersLayer,
            "<b>Obs. de  <i class='naturalista-3-ev-icon'></i><i class='naturalista-4-ev-icon'></i><sub>" + naturalista_count + "</sub></b>" +
            "<p>"+punto_amarillo+"</p>"
        );
    }

    function wms_distribucion_potencial() {
        var distribucion_potencial = L.tileLayer.wms(GEO.geoserver_url, {
            layers: GEO.geoserver_layer,
            format: 'image/png',
            transparent: true,
            opacity:.5,
            maxZoom: 20
        });

        map.addLayer(distribucion_potencial);
        legend_control.addOverlay(distribucion_potencial, "<b>Distribución potencial (CONABIO)</b>");
    }

    function ejemplar_snib(layer, id){
        $.ajax({
            url: "/especies/" + TAXON.id + "/ejemplar-snib/" + id,
            dataType : "json",
            success : function (res){
                if (res.estatus == 'OK')
                {
                    var ejemplar = res.ejemplar;
                    var contenido = "";

                    contenido += "<h4>" + name() + "</h4>";
                    contenido += "<dt>Localidad: </dt><dd>" + ejemplar.localidad + "</dd>";
                    contenido += "<dt>Municipio: </dt><dd>" + ejemplar.municipiomapa + "</dd>";
                    contenido += "<dt>Estado: </dt><dd>" + ejemplar.estadomapa + "</dd>";
                    contenido += "<dt>País: </dt><dd>" + ejemplar.paismapa + "</dd>";
                    contenido += "<dt>Fecha: </dt><dd>" + ejemplar.fechacolecta + "</dd>";
                    contenido += "<dt>Colector: </dt><dd>" + ejemplar.colector + "</dd>";
                    contenido += "<dt>Colección: </dt><dd>" + ejemplar.coleccion + "</dd>";
                    contenido += "<dt>Institución: </dt><dd>" + ejemplar.institucion + "</dd>";
                    contenido += "<dt>País de la colección: </dt><dd>" + ejemplar.paiscoleccion + "</dd>";

                    if (ejemplar.proyecto.length > 0 && ejemplar.urlproyecto.length > 0)
                        contenido += "<dt>Proyecto: </dt><dd><a href='" + ejemplar.urlproyecto + "' target='_blank'>" + ejemplar.proyecto + "</a></dd>";

                    contenido += "<dt>Más información: </dt><dd><a href='http://" + ejemplar.urlejemplar + "' target='_blank'>consultar</a></dd>";

                    // Para enviar un comentario acerca de un registro en particular
                    contenido += "<dt>¿Tienes un comentario?: </dt><dd><a href='/especies/" + TAXON.id + "/comentarios/new?proveedor_id=" + ejemplar.idejemplar + "&tipo_proveedor=6' target='_blank'>redactar</a></dd>";

                    contenido = "<dl class='dl-horizontal'>" + contenido + "</dl>" + "<strong>ID: </strong>" + ejemplar.idejemplar;
                } else {
                    var contenido = "Hubo un error al retraer el ejemplar: " + res.msg;
                }

                // Pone el popup arriba del punto
                var popup = new L.Popup();
                var bounds = layer.getBounds();

                popup.setLatLng(bounds.getCenter());
                popup.setContent(contenido);
                map.openPopup(popup);
            },
            error: function( jqXHR ,  textStatus,  errorThrown ){
                console.log("error: " + textStatus);
                console.log(errorThrown);
                console.log(jqXHR.responseText);
            }
        });  // termina ajax
    }

    function observacion_naturalista(layer, id)
    {
        $.ajax({
            url: "/especies/" + TAXON.id + "/observacion-naturalista/" + id,
            dataType : "json",
            success : function (res){
                if (res.estatus == 'OK')
                {
                    var observacion = res.observacion;
                    var contenido = "";

                    contenido += "<h4>" + name() + "</h4>";

                    if (observacion.thumb_url != undefined)
                    {
                        contenido += "<div><img style='margin: 10px auto!important;' class='img-responsive' src='" + observacion.thumb_url + "'/></div>";
                        contenido += "<dt>Atribución: </dt><dd>" + observacion.attribution + "</dd>";
                    }

                    /*contenido += "<dt>Ubicación: </dt><dd>" + feature.place_guess + "</dd>";*/
                    contenido += "<dt>Fecha: </dt><dd>" + observacion.observed_on + "</dd>";
                    contenido += "<dt>¿Silvestre / Naturalizado?: </dt><dd>" + (observacion.captive == true ? 'sí' : 'no') + "</dd>";
                    contenido += "<dt>Grado de calidad: </dt><dd>" + observacion.quality_grade + "</dd>";
                    contenido += "<dt>URL NaturaLista: </dt><dd><a href='"+ observacion.uri +"' target='_blank'>ver la observación</a></dd>";

                    // Para enviar un comentario acerca de un registro en particular
                    contenido += "<dt>¿Tienes un comentario?: </dt><dd><a href='/especies/" + TAXON.id + "/comentarios/new?proveedor_id=" + observacion.id + "&tipo_proveedor=7' target='_blank'>redactar</a></dd>";

                    contenido = "<dl class='dl-horizontal'>" + contenido + "</dl>";
                } else {
                    var contenido = "Hubo un error al retraer la observación: " + res.msg;
                }

                // Pone el popup arriba del punto
                var popup = new L.Popup();
                var bounds = layer.getBounds();

                popup.setLatLng(bounds.getCenter());
                popup.setContent(contenido);
                map.openPopup(popup);
            },
            error: function( jqXHR ,  textStatus,  errorThrown ){
                console.log("error: " + textStatus);
                console.log(errorThrown);
                console.log(jqXHR.responseText);
            }
        });  // termina ajax
    }

    function name()
    {
        if (I18n.locale == 'es')
        {
            if (NOMBRE_COMUN_PRINCIPAL.length > 0)
                return NOMBRE_COMUN_PRINCIPAL + " <a href='/especies/" + TAXON.id + "'><i>(" + TAXON.nombre_cientifico + ")</i></a>";
            else
                return "<i>(" + TAXON.nombre_cientifico + ")</i>";
        } else {
            return "<i>(" + TAXON.nombre_cientifico + ")</i>";
        }
    }

    var geojson_geoportal = function()
    {
        $.ajax({
            url: GEO.snib_mapa_json,
            dataType : "json",
            success : function (d){
                geoportal_count = d.length;
                allowedPoints = d3.map([]);

                for(i=0;i<d.length;i++)
                {
                    var item_id = d[i];

                    allowedPoints.set(item_id, {
                        "type"      : "Feature",
                        "properties": {d: [d[i][2], d[i][3]]}, // El ID y si es de aver aves
                        "geometry"  : {coordinates: [d[i][0], d[i][1]], type: "Point"}
                    });
                }

                addPointLayerGeoportal();
            },
            error: function( jqXHR ,  textStatus,  errorThrown ){
                console.log("error: " + textStatus);
                console.log(errorThrown);
                console.log(jqXHR.responseText);
            }
        });  // termina ajax
    };


    var geojson_naturalista = function()
    {
        $.ajax({
            url: GEO.naturalista_mapa_json,
            dataType : "json",
            success : function (d){
                naturalista_count = d.length;
                allowedPoints = d3.map([]);

                for(i=0;i<d.length;i++)
                {
                    var item_id = d[i][2];

                    allowedPoints.set(item_id, {
                        "type"      : "Feature",
                        "properties": {d: [d[i][2], d[i][3]]},  // El ID y si es de grado de investigacion
                        "geometry"  : {coordinates: [d[i][0], d[i][1]], type: "Point"}
                    });
                }
                addPointLayerNaturaLista();
            },
            error: function( jqXHR ,  textStatus,  errorThrown ){
                console.log("error: " + textStatus);
                console.log(errorThrown);
                console.log(jqXHR.responseText);
            }
        });  // termina ajax
    };

    if (GEO.cuales.indexOf("naturalista") >= 0) geojson_naturalista();
    if (GEO.cuales.indexOf("snib") >= 0) geojson_geoportal();
    if (GEO.cuales.indexOf("geoserver") >= 0) wms_distribucion_potencial();
});

