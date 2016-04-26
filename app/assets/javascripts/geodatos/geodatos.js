$(document).ready(function(){

    var specie_target;
    var sdata;
    var geojsonFeature = [];
    var allowedPoints = d3.map([]);

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

    // Google satellite map layer
    var GSM_layer = L.tileLayer('http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}&labels=true',{
        maxZoom: 20,
        subdomains:['mt0','mt1','mt2','mt3']
    });

    // Google terrain map layer
    var GTM_layer = L.tileLayer('http://{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',{
        maxZoom: 20,
        subdomains:['mt0','mt1','mt2','mt3']
    });

    var drawnItems = new L.FeatureGroup();

    var milliseconds = new Date().getTime();

    /*var grid_wms = L.tileLayer.betterWms(url, {
        layers: espacio_capa,
        crossDomain: true,
        transparent: true,
        format: 'image/png'
    });*/

    var species_layer;
    var markersLayer;


    /***************************************************************** map switcher */

    var map = L.map('map', {
        center: [23.5, -99],
        zoom: 5,
        layers: [
            OSM_layer,
            GSM_layer,
            GTM_layer
            //, grid_wms  // Grid de la reja
        ]
    });

    //map.scrollWheelZoom.disable();

    /***************************************************************** switch map */

    L.Control.Command = L.Control.extend({
        options: {
            position: 'bottomleft'
        },

        onAdd: function (map) {
            var controlDiv = L.DomUtil.create('div', 'leaflet-control-command ');
            L.DomEvent
                .addListener(controlDiv, 'click', L.DomEvent.stopPropagation)
                .addListener(controlDiv, 'click', L.DomEvent.preventDefault)
                .addListener(controlDiv, 'click', function () { chengeMapByDecil(); });

            var controlUI = L.DomUtil.create('div', 'leaflet-control-command-interior glyphicon glyphicon-triangle-right', controlDiv);
            controlUI.title = 'Ordena mapa por decil';
            controlUI.id = "changeMapButton"
            return controlDiv;
        }
    });

    L.control.command = function (options) {
        return new L.Control.Command(options);
    };

    function chengeMapByDecil(){

        try{
            //verifica si sdata ya tiene valores asignados
            sdata.length;

            $("#changeMapButton").toggleClass("glyphicon glyphicon-triangle-right");
            $("#changeMapButton").toggleClass("glyphicon glyphicon-triangle-left");

            if(document.getElementById("changeMapButton").classList.contains("glyphicon-triangle-right")){

                console.log("cambia mapa por decil");
                $("#changeMapButton").prop('title', 'Ordena mapa por decil');
                sdata['qtype'] = "getMapScoreCeldaDecil";
                configureStyleMap(sdata);

            }
            else {

                console.log("cambia mapa por frecuencia");
                $("#changeMapButton").prop('title', 'Ordena mapa por frecuencia');
                sdata['qtype'] = "getMapScoreCelda";
                configureStyleMap(sdata);
            }

        }catch(e){
            console.log("sdata sin asignar");
        }

    }

    var switchMap = new L.Control.Command();
    map.addControl(switchMap);

    /***************************************************************** layer switcher */

    var baseMaps = {
        "Open Street Maps": OSM_layer,
        "Vista de Satélite": GSM_layer,
        "Vista de terreno": GTM_layer
    };

    var overlayMaps = {
        //"Malla": grid_wms
    };

    var layer_control = L.control.layers(baseMaps,overlayMaps).addTo(map);

    /***************************************************************** aditional controls */

    function addPointLayerGeoportal()
    {
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
        layer_control.addOverlay(markersLayer, "Registros de museos, colectas y proyectos de CONABIO (SNIB)");
    }

    function addPointLayerNaturaLista()
    {
        geojsonFeature =  { "type": "FeatureCollection",
            "features": allowedPoints.values()};

        console.log(geojsonFeature)
        markersLayer = L.markerClusterGroup({ maxClusterRadius: 30, chunkedLoading: true, which_layer: 'naturalista'});

        species_layer = L.geoJson(geojsonFeature, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, geojsonMarkerNaturaListaInvOptions);
            },
            onEachFeature: function (feature, layer) {
                coordinates = parseFloat(feature.geometry.coordinates[1]).toFixed(2) + ", " +  parseFloat(feature.geometry.coordinates[0]).toFixed(2);
                var p_contenido = content_naturalista(feature.properties.d);
                layer.bindPopup(p_contenido);
            }
        });

        markersLayer.addLayer(species_layer);
        map.addLayer(markersLayer);
        layer_control.addOverlay(markersLayer, "Observaciones de NaturaLista");
    }

    /*var kmlLayer = new L.KML("/assets/observaciones.kml", {async: true});
    map.addLayer(kmlLayer);

    layer_control.addOverlay(kmlLayer, "Registros de NaturaLista");*/



    function content_geoportal(feature)
    {
        var contenido = "";

        contenido += "<dt>Localidad: </dt><dd>" + feature.localidad + "</dd>";
        contenido += "<dt>Municipio: </dt><dd>" + feature.municipiomapa + "</dd>";
        contenido += "<dt>Estado: </dt><dd>" + feature.estadomapa + "</dd>";
        contenido += "<dt>País: </dt><dd>" + feature.paismapa + "</dd>";
        contenido += "<dt>Fecha: </dt><dd>" + feature.fechacolecta + "</dd>";
        contenido += "<dt>Colector: </dt><dd>" + feature.colector + "</dd>";
        contenido += "<dt>Colección: </dt><dd>" + feature.coleccion + "</dd>";
        contenido += "<dt>Institución: </dt><dd>" + feature.institucion + "</dd>";
        contenido += "<dt>País de la colección: </dt><dd>" + feature.paiscoleccion + "</dd>";

        return "<dl class='dl-horizontal'>" + contenido + "</dl>";
    }

    function content_naturalista(feature)
    {
        var contenido = "";

        if (feature.photos.length > 0)
            contenido += "<dt>Atribución: </dt><dd>" + feature.photos[0].attribution + "</dd>";

        contenido += "<dt>Ubicación: </dt><dd>" + feature.place_guess + "</dd>";
        contenido += "<dt>Fecha: </dt><dd>" + feature.observed_on + "</dd>";
        contenido += "<dt>¿Es un organismo silvestre / naturalizado?: </dt><dd>" + feature.captive + "</dd>";
        contenido += "<dt>Grado de calidad: </dt><dd>" + feature.quality_grade + "</dd>";
        contenido += "<dt>URL NaturaLista: </dt><dd>" + feature.uri + "</dd>";

        return "<dl class='dl-horizontal'>" + contenido + "</dl>";
    }

    var geojson_geoportal = function()
    {
        $.ajax({
            url: "/especies/" + TAXON.id + "/geoportal",
            dataType : "json",
            beforeSend: function(xhr){
                xhr.setRequestHeader('X-Test-Header', 'test-value');
                xhr.setRequestHeader("Accept","text/json");
            },
            success : function (d){

                allowedPoints = d3.map([]);

                for(i=0;i<d.length;i++)
                {
                    item_id = JSON.parse(d[i].json_geom).coordinates.toString();

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


    var geojson_naturalista = function()
    {
        $.ajax({
            url: "/especies/" + TAXON.id + "/naturalista",
            dataType : "json",
            beforeSend: function(xhr){
                xhr.setRequestHeader('X-Test-Header', 'test-value');
                xhr.setRequestHeader("Accept","text/json");
            },
            success : function (d){
                allowedPoints = d3.map([]);

                for(i=0;i<d.length;i++)
                {
                    //var item_id_json = JSON.parse(d[i]);
                    item_id = d[i].longitude + "," + d[i].latitude;

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

    geojson_naturalista();
    geojson_geoportal();

    /*
     $("#send_email_csv").click(function(e){

     // console.log($("#email_address"));
     console.log($("#email_address")[0].validity["valid"]);

     if($("#email_address")[0].validity["valid"]){

     email = $("#email_address").val();
     console.log(email);


     tdata["download"] = true;
     tdata["mail"] = email;
     console.log(tdata);

     $.ajax({
     url : url_trabajo,
     type : 'post',
     data : tdata,
     success : function (d){

     console.log(d);
     $('#modalMail').modal('hide');
     toastr.success("Archivo enviado por correo electrónico");

     },
     error: function( jqXHR ,  textStatus,  errorThrown ){

     console.log("error: " + textStatus);
     $('#modalMail').modal('hide');
     toastr.error("Error al enviar el archivo");

     }
     });


     }
     else{
     alert("Correo invalido")
     }

     });


     $("#send_email_shp").click(function(e){

     // console.log($("#email_address"));
     console.log($("#email_address_shp")[0].validity["valid"]);

     if($("#email_address_shp")[0].validity["valid"]){

     email = $("#email_address_shp").val();
     console.log(email);


     sdata["download"] = true;
     sdata["ftype"] = "shp";
     sdata["mail"] = email;
     console.log(sdata);

     $.ajax({
     url : url_trabajo,
     type : 'post',
     data : sdata,
     success : function (d){

     console.log(d);
     $('#modalMailShape').modal('hide');
     toastr.success("Archivo enviado por correo electrónico");

     },
     error: function( jqXHR ,  textStatus,  errorThrown ){

     console.log("error: " + textStatus);
     $('#modalMailShape').modal('hide');
     toastr.error("Error al enviar el archivo");

     }
     });


     }
     else{
     alert("Correo invalido")
     }

     });

     */
});

