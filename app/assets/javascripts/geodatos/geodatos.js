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

    /***************************************************************** aditional controls */
    function addPointLayerGeoportal(){
        geojsonFeature =  { "type": "FeatureCollection",
            "features": allowedPoints.values()};

        markersLayer = L.markerClusterGroup({ maxClusterRadius: 30, chunkedLoading: true, which_layer: 'geoportal'});

        species_layer = L.geoJson(geojsonFeature, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, geojsonMarkerGeoportalOptions);
            },
            onEachFeature: function (feature, layer) {
                coordinates = parseFloat(feature.geometry.coordinates[1]).toFixed(2) + ", " +  parseFloat(feature.geometry.coordinates[0]).toFixed(2);
                var p_contenido = content_geoportal(feature.properties.d);
                layer.bindPopup(p_contenido);
            }
        });

        markersLayer.addLayer(species_layer);
        map.addLayer(markersLayer);
        layer_control.addOverlay(markersLayer, "<i>" + geoportal_count + "</i> registros del SNIB <br /> (museos, colectas y proyectos de CONABIO)");
    }

    function addPointLayerNaturaLista(){
        geojsonFeature =  { "type": "FeatureCollection",
            "features": allowedPoints.values()};

        markersLayer = L.markerClusterGroup({ maxClusterRadius: 30, chunkedLoading: true, which_layer: 'naturalista'});

        species_layer = L.geoJson(geojsonFeature, {
            pointToLayer: function (feature, latlng) {
                // Para cuando es una observacion casual o de investigacion
                if (feature.properties.d.quality_grade == 'research')
                    return L.circleMarker(latlng, geojsonMarkerNaturaListaInvOptions);
                else
                    return L.circleMarker(latlng, geojsonMarkerNaturaListaCasualOptions);
                //para cuando tenga tiempo, poner el ícono como DEBE de ser!!!
                //return L.marker(latlng, {icon: L.divIcon({className: "glyphicon glyphicon-map-marker"})});
            },
            onEachFeature: function (feature, layer) {
                coordinates = parseFloat(feature.geometry.coordinates[1]).toFixed(2) + ", " +  parseFloat(feature.geometry.coordinates[0]).toFixed(2);
                var p_contenido = content_naturalista(feature.properties.d);
                layer.bindPopup(p_contenido);
            }
        });

        markersLayer.addLayer(species_layer);
        map.addLayer(markersLayer);
        layer_control.addOverlay(markersLayer, "<i>" + naturalista_count + "</i> observaciones de <i class='naturalista-ev-icon'></i><i class='naturalista-2-ev-icon'></i><i class='naturalista-3-ev-icon'></i><i class='naturalista-4-ev-icon'></i>");
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
        layer_control.addOverlay(distribucion_potencial, "Distribución potencial (CONABIO)");
    }

    function content_geoportal(feature){
        var contenido = "";

        contenido += "<h4>" + name() + "</h4>";
        contenido += "<dt>Localidad: </dt><dd>" + feature.localidad + "</dd>";
        contenido += "<dt>Municipio: </dt><dd>" + feature.municipiomapa + "</dd>";
        contenido += "<dt>Estado: </dt><dd>" + feature.estadomapa + "</dd>";
        contenido += "<dt>País: </dt><dd>" + feature.paismapa + "</dd>";
        contenido += "<dt>Fecha: </dt><dd>" + feature.fechacolecta + "</dd>";
        contenido += "<dt>Colector: </dt><dd>" + feature.colector + "</dd>";
        contenido += "<dt>Colección: </dt><dd>" + feature.coleccion + "</dd>";
        contenido += "<dt>Institución: </dt><dd>" + feature.institucion + "</dd>";
        contenido += "<dt>País de la colección: </dt><dd>" + feature.paiscoleccion + "</dd>";

        if (feature.proyecto.length > 0 && feature.urlproyecto.length > 0)
            contenido += "<dt>Proyecto: </dt><dd><a href='" + feature.urlproyecto + "' target='_blank'>" + feature.proyecto + "</a></dd>";

        contenido += "<dt>Más información: </dt><dd><a href='http://" + feature.urlejemplar + "' target='_blank'>consultar</a></dd>";

        return "<dl class='dl-horizontal'>" + contenido + "</dl>";
    }

    function content_naturalista(feature){
        var contenido = "";

        contenido += "<h4>" + name() + "</h4>";

        if (feature.photos.length > 0)
        {
            contenido += "<div><img style='margin: 10px auto!important;' class='img-responsive' src='" + feature.photos[0].thumb_url + "'/></div>"
            contenido += "<dt>Atribución: </dt><dd>" + feature.photos[0].attribution + "</dd>";
        }

        /*contenido += "<dt>Ubicación: </dt><dd>" + feature.place_guess + "</dd>";*/
        contenido += "<dt>Fecha: </dt><dd>" + feature.observed_on + "</dd>";
        contenido += "<dt>¿silvestre / naturalizado?: </dt><dd>" + (feature.captive == true ? 'sí' : 'no') + "</dd>";
        contenido += "<dt>Grado de calidad: </dt><dd>" + I18n.t('quality_grade.' + feature.quality_grade) + "</dd>";
        contenido += "<dt>URL NaturaLista: </dt><dd><a href='"+ feature.uri +"' target='_blank'>ver la observación</a></dd>";

        return "<dl class='dl-horizontal'>" + contenido + "</dl>";
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
            url: GEO.geoportal_url,
            //url: "http://colibri.conabio.gob.mx:9000/snib?qtype=getSpecies&rd=plantae&taxlevel=genero&taxvalue=zea",
            dataType : "json",
            success : function (d){
                geoportal_count = d.length;
                allowedPoints = d3.map([]);

                for(i=0;i<d.length;i++)
                {
                    item_id = 'geoportal-' + i.toString();

                    // this map is fill with the records in the database from an specie, so it discards repetive elemnts.
                    allowedPoints.set(item_id, {
                        "type"      : "Feature",
                        "properties": {d: d[i]},
                        "geometry"  : JSON.parse(d[i].json_geom)
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


    var geojson_naturalista = function(){
        $.ajax({
            url: "/especies/" + TAXON.id + "/naturalista",
            dataType : "json",
            beforeSend: function(xhr){
                xhr.setRequestHeader('X-Test-Header', 'test-value');
                xhr.setRequestHeader("Accept","text/json");
            },
            success : function (d){
                naturalista_count = d.length;
                allowedPoints = d3.map([]);

                for(i=0;i<d.length;i++)
                {
                    item_id = '-' + i.toString();

                    // this map is fill with the records in the database from an specie, so it discards repetive elemnts.
                    allowedPoints.set(item_id, {
                        "type"      : "Feature",
                        "properties": {d: d[i]},
                        "geometry"  : {coordinates: [parseFloat(d[i].longitude), parseFloat(d[i].latitude)], type: "Point"}
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
    if (GEO.cuales.indexOf("geoportal") >= 0) geojson_geoportal();
    if (GEO.cuales.indexOf("geoserver") >= 0) wms_distribucion_potencial();
});

