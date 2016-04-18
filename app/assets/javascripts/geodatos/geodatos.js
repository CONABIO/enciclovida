$(document).ready(function(){

//set this value to 0 when youre working local and 1 in production
    var AMBIENTE = 1;
    var TEST = false;

    var NEG_DECIL = true;
    var ADD_TOTAL = false;
    var tbl = false;
    var tbl_decil = false;

    if (AMBIENTE == 1){
        var url_trabajo = "http://geoportal.conabio.gob.mx/niche2?"
        var url_geoserver = "http://geoportal.conabio.gob.mx:80/geoserver/cnb/wms?"
        var workspace = "cnb"
        var url_nicho = "http://geoportal.conabio.gob.mx/charlie/geoportal_v0.1.html";
        var url_comunidad = "http://geoportal.conabio.gob.mx/charlie/comunidad_v0.1.html";

    }
    else{

        var url_trabajo = "http://localhost:3000/"
        var url_geoserver = "http://localhost:8080/geoserver/conabio/wms?"
        var workspace = "conabio"
        var url_nicho = "http://localhost:3000/geoportal_v0.1.html";
        var url_comunidad = "http://localhost:3000/comunidad_v0.1.html";

    }

    var species_selected;
    var specie_target;

    var arrayLayerStates = [];
    var arrayLayerEco = [];
    var var_tree = [];
    var nodes_selected = [];
    var loadVars = false;
    var varfilter_selected = [];
    var arrayVarSelected = [];
    var groupvar_dataset = [];
    var arrayBioclimSelected = [];
    var groupbioclimvar_dataset = [];

    var value_vartree;
    var field_vartree;
    var parent_field_vartree;
    var level_vartree;
    var var_sel_array = [];
    var REQUESTS = 0;
    var GROUP_REQUEST = 0;

// diccionario de parametros que son utilizados por metodos externos
    var cdata;
    var sdata;
    var tdata;
    var validationData;

    var time_selected;
    var TOTALS_NAME = "Total"

    var fathers = [];
    var sons = [];
    var geojsonFeature = [];
    var allowedPoints = d3.map([]);
    var discardedPoints = d3.map([]);
    var validationPoints = d3.map([]);
    var DELETE_STATE_POINTS = false;

    var geojsonMarkerOptions = {
        radius: 5,
        fillColor: "#4F9F37",
        color: "#488336",
        weight: 2,
        opacity: 1,
        fillOpacity: 0.6
    };
    var geojsonMarkerOptionsDelete = {
        radius: 5,
        fillColor: "#E10C2C",
        color: "#833643",
        weight: 2,
        opacity: 1,
        fillOpacity: 0.6
    };
    var customOptions ={
        'maxWidth': '500',
        'className' : 'custom'
    }



// default tree to fill the bioclim jstree
    var data_bio = [{
        "text": "Bioclim",
        "id": "rootbio",
        attr: { "bid": "Bioclim", "parent": "Bioclim", "level": 0 },
        'state' : {'opened' : true},
        "icon": "assets/images/dna.png",
        "children": [
            {
                "text": "Temperatura media anual",
                "id": "bio01",
                attr: { "bid": "bio01", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Rango medio diurno",
                "id": "bio02",
                attr: { "bid": "bio02", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Forma Isotérmica",
                "id": "bio03",
                attr: { "bid": "bio03", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Temperatura estacional",
                "id": "bio04",
                attr: { "bid": "bio04", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Temperatura máxima del mes mas caliente",
                "id": "bio05",
                attr: { "bid": "bio05", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Temperatura mínima de mes mas frio",
                "id": "bio06",
                attr: { "bid": "bio06", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Rango anual de temperatura",
                "id": "bio07",
                attr: { "bid": "bio07", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Temperatura media del trimestre mas húmedo",
                "id": "bio08",
                attr: { "bid": "bio08", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Temperatura media del trimestre mas seco",
                "id": "bio09",
                attr: { "bid": "bio09", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Temperatura media del trimestre mas caliente",
                "id": "bio10",
                attr: { "bid": "bio10", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Temperatura media del trimestre mas frio",
                "id": "bio11",
                attr: { "bid": "bio11", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Precipitación anual",
                "id": "bio12",
                attr: { "bid": "bio12", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Precipitación del mes mas húmedo",
                "id": "bio13",
                attr: { "bid": "bio13", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Precipitación del mes mas seco",
                "id": "bio14",
                attr: { "bid": "bio14", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Precipitación estacional",
                "id": "bio15",
                attr: { "bid": "bio15", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Precipitación del trimestre mas húmedo",
                "id": "bio16",
                attr: { "bid": "bio16", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Precipitación del trimestre mas seco",
                "id": "bio17",
                attr: { "bid": "bio17", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Precipitación del trimestre mas caliente",
                "id": "bio18",
                attr: { "bid": "bio18", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            },
            {
                "text": "Precipitación del trimestre mas frio",
                "id": "bio19",
                attr: { "bid": "bio19", "parent": "Bioclim", "level": 1 },
                'state' : {'opened' : true},
                "icon": "assets/images/dna.png"
            }
        ]
    }
    ];

// initializaing bioclim-jstree
    $("#jstree-variables-bioclim").jstree({
        'plugins': ["wholerow", "checkbox"],
        'core': {
            'data': data_bio,
            'themes': {
                'name': 'proton',
                'responsive': true
            },
            'check_callback': true
        }
    });

    $("#jstree-variables-bioclim").on('loaded.jstree',function(){
        $("#jstree-variables-bioclim").on('changed.jstree',getChangeTreeVarBioclim);
    });

    var reino_campos = {
        "phylum": "phylumdivisionvalido",
        "clase": "clasevalida",
        "orden": "ordenvalido",
        "familia": "familiavalida",
        "genero": "generovalido",
        "especie": "epitetovalido"
    };

    var ID_STYLE_GENERATED = 0;


    /*
     window.onbeforeunload = function() {

     deleteStyle();
     console.log("bye");
     return "Bye now!";

     };
     */


    /***************************************************************** map styles */
    var geojsonStyleDefault = {
        radius: 7,
        fillColor: "#E2E613",
        color: "#ACAE36",
        weight: 1,
        opacity: 1,
        fillOpacity: 0.6
    };

    var geojsonHighlightStyle = {
        radius: 7,
        fillColor: "#16EEDC",
        color: "#36AEA4",
        weight: 1,
        opacity: 1,
        fillOpacity: 0.6
    };

    var geojsonMouseOverStyle = {
        radius: 7,
        fillColor: "#CED122",
        color: "#8C8E3A",
        weight: 1,
        opacity: 1,
        fillOpacity: 0.6
    };

    /***************************************************************** Layer creation */

    mapquestLink = '<a href="http://www.mapquest.com//">MapQuest</a>';
    mapquestPic = '<img src="http://developer.mapquest.com/content/osm/mq_logo.png">';


    var OSM_layer = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png');

    var drawnItems = new L.FeatureGroup();

    var milliseconds = new Date().getTime();

// capa raster, comentado para probar de manera local
    var url = url_geoserver + "t=" + milliseconds;
    var espacio_capa = workspace + ":sp_grid_terrestre";
    var grid_wms = L.tileLayer.betterWms(url, {
        layers: espacio_capa,
        crossDomain: true,
        // dataType: "jsonp",
        transparent: true,
        format: 'image/png'
    });

    var species_layer;
    var states_layer;
    var eco_layer;
    var markersLayer;


    /***************************************************************** map switcher */

    var map = L.map('map', {
        center: [23.5, -99],
        zoom: 5,
        layers: [
            OSM_layer
            , grid_wms
            // , sp_grid_wms
            // , sp_grid_mex_wms
            // , grid_sp_wms
        ]
    });

    map.scrollWheelZoom.disable();
    document.getElementById("tbl_hist").style.display = "none";
    document.getElementById("dShape").style.display = "none";


    toastr.options = {
        "debug": false,
        "positionClass": "toast-bottom-left",
        "onclick": null,
        "fadeIn": 300,
        "fadeOut": 1000,
        "timeOut": 3000,
        "extendedTimeOut": 1000
    }


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
            else{

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

    /***************************************************************** add map points */


    function addPointLayer(){

        console.log("geojsonFeature: " + allowedPoints.values().length);

        geojsonFeature =  { "type": "FeatureCollection",
            "features": allowedPoints.values()};

        markersLayer = L.markerClusterGroup({ maxClusterRadius: 30, chunkedLoading: true });

        species_layer = L.geoJson(geojsonFeature, {
            pointToLayer: function (feature, latlng) {
                return L.circleMarker(latlng, geojsonMarkerOptions);
            },
            onEachFeature: function (feature, layer) {
                coordinates = parseFloat(feature.geometry.coordinates[1]).toFixed(2) + ", " +  parseFloat(feature.geometry.coordinates[0]).toFixed(2)
                layer.bindPopup(feature.properties.specie+"<br/>"+coordinates,customOptions);
            }

        });


        markersLayer.addLayer(species_layer);
        map.addLayer(markersLayer);
        // there is an error with great amount of points ex: zea mays
        // map.fitBounds(markersLayer.getBounds());
        layer_control.addOverlay(markersLayer, specie_target.label);
    }


    /***************************************************************** sidebar */

// var sidebar = L.control.sidebar('sidebar').addTo(map);

    /***************************************************************** layer switcher */

    var baseMaps = {
        "Open Street Maps": OSM_layer
    };

    var overlayMaps = {
        "Malla": grid_wms
        // ,"Malla sp_grid": sp_grid_wms
        // ,"Malla Mex": sp_grid_mex_wms
        // ,"grid_sp": grid_sp_wms
    };

    var layer_control = L.control.layers(baseMaps,overlayMaps).addTo(map);

    /***************************************************************** aditional controls */
// comentados para no saturar la carga del mapa
//L.control.scale().addTo(map);
//L.control.fullscreen().addTo(map);

// var OSM_mini_layer = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png');
//
// var miniMap = new L.Control.MiniMap(OSM_mini_layer, {
// 	toggleDisplay: true
// 	//position: 'bottomleft'
// }).addTo(map);



    L.drawLocal.draw.toolbar.buttons.polygon = 'Selecciona región';
    L.drawLocal.draw.toolbar.buttons.circle = 'Selecciona región';
    L.drawLocal.draw.toolbar.buttons.rectangle = 'Selecciona región';
    L.drawLocal.draw.toolbar.buttons.edit = 'Edita región';

    var drawControl = new L.Control.Draw({
        position: 'topleft',
        draw: {
            polyline: false,
            polygon: {
                allowIntersection: false,
                showArea: true,
                drawError: {
                    color: '#5B7CF4',
                    timeout: 1000
                },
                shapeOptions: {
                    color: '#5B7CF4'
                }
            },
            circle: {
                shapeOptions: {
                    color: '#5B7CF4'
                }
            },
            marker: false,
            rectangle: {
                shapeOptions: {
                    color: '#5B7CF4'
                }
            }
        },
        edit: {
            featureGroup: drawnItems,
            remove: true
        }
    });

    map.on('draw:created', function (e) {
        var type = e.layerType,
            layer = e.layer;

        if (type === 'marker') {
            layer.bindPopup('A popup!');
        }

        drawnItems.addLayer(layer);
    });

    map.on('draw:edited', function (e) {
        var layers = e.layers;
        var countOfEditedLayers = 0;
        layers.eachLayer(function(layer) {
            countOfEditedLayers++;
        });
        console.log("Edited " + countOfEditedLayers + " layers");
    });

    /*
     //  generation of random colors
     var randomColor = (function(){

     var golden_ratio_conjugate = 0.618033988749895;
     var h = Math.random();

     var hslToRgb = function (h, s, l){
     var r, g, b;

     if(s == 0){
     r = g = b = l; // achromatic
     }else{
     function hue2rgb(p, q, t){
     if(t < 0) t += 1;
     if(t > 1) t -= 1;
     if(t < 1/6) return p + (q - p) * 6 * t;
     if(t < 1/2) return q;
     if(t < 2/3) return p + (q - p) * (2/3 - t) * 6;
     return p;
     }

     var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
     var p = 2 * l - q;
     r = hue2rgb(p, q, h + 1/3);
     g = hue2rgb(p, q, h);
     b = hue2rgb(p, q, h - 1/3);
     }

     return '#'+Math.round(r * 255).toString(16)+Math.round(g * 255).toString(16)+Math.round(b * 255).toString(16);
     };

     return function(){
     h += golden_ratio_conjugate;
     h %= 1;
     return hslToRgb(h, 0.5, 0.60);
     };
     })();
     */


    /* functionality of search button  ******************/

    var busca_especie = function(){

        // species_selected = {id: 47930, label:'Lynx rufus'};

//  console.log(specie_target.spid);
//  console.log(specie_target.label);

        /*  $.ajax({
         url: url_trabajo,
         type : 'post',
         dataType : "json",
         data : {
         "qtype" : "getSpecies",
         "id" : specie_target.spid
         },
         // accepts: {text: "application/json"},
         beforeSend: function(xhr){
         xhr.setRequestHeader('X-Test-Header', 'test-value');
         xhr.setRequestHeader("Accept","text/json");
         },
         success : function (d){*/

        // console.log("DATA: ");
        d = [{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.52466,28.89341]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.5381,28.98174]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.16265,29.20975]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.296371,29.8628]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8038056,23.7997222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.905556,32.048889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.1070023,23.8059998]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.8720016,27.2220001]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-92.0916667,16.425]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.3166667,19.05]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5860889,30.8024944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.94833,30.37528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.69,29.88]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.76,23.96]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5533333,30.7916667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.37,19.5]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.3619444,28.3469444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1166667,19.1041667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.1002778,30.4505556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.25,26.83]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.2872222,19.0283333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.0666667,30.6]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.4502778,31.0336111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.978227,19.114619]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2083333,23.3222222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.8958333,27.2819444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.0083333,22.8277778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.068224,24.864101]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.9086111,29.485]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.9247,17.56501]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.05996,17.91188]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.475,23.18111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.1716667,26.5033333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.75,21.83]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.6043623,29.8050333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0597222,18.1683333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5938889,30.7925]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.055833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.6977778,24.4408333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.17,26.79]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.4041672,30.2549992]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-111.8125,26.0625]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.2916667,27.2380556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.89484,17.55577]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1406833,29.2086667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.083333,30.6]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.2527778,19.0411111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.0005556,26.7858333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.1036,18.8497]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.0808869,30.4569092]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5925,30.7879167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1469667,29.2123889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7906,26.6751306]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.1475,25.3597222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-116.5145339,31.5760728]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1166667,25.7333333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.9247,17.56501]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.05984,17.91794]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-114.8336111,31.033889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1688889,19.0902778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6080556,19.5288889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2680556,19.4008333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5836111,30.7891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.3269444,19.4122222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4341667,24.1494444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7863361,26.769325]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.5421974,29.06028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1688889,19.0905556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8525,23.7658333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3333333,29.9666667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.89484,17.55577]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.4502778,31.0336111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2405556,19.5163889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.852461,23.563993]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.9166667,27.2166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2480556,23.3875]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1669444,19.09]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.631944,17.181139]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3297222,24.123056]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.7077789,30.0561103]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.8241667,24.1011111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.0097222,22.8269444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.649333,17.177639]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.17,30.04]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.631167,17.183361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.6997222,23.1783333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.74385,26.67635]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.182165,19.112271]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.925,19.325]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5830556,30.8008333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.5672222,28.9522222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.055833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1688889,19.0905556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.8209992,28.1200008]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8311111,23.7558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5952778,30.81]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.8275,19.6897222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.4327778,21.4347222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0509972,18.1607111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.992013,19.118416]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.6777778,27.5727778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.8488889,19.3186111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5680556,30.7858333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8318333,23.7463333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.33,24.12]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4672222,24.1375]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0509972,18.1607111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.55,28.19]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.84,23.7547222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.76583,29.33667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1688889,19.0905556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7911667,23.78525]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7444028,26.6929472]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.406808,19.65616]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1611111,19.1030556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0572222,18.1766667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.10933,19.100941]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0572222,18.1766667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5844306,30.7981111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3919444,24.060833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1825,25.9255556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1669444,19.0891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0611111,18.1697222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.51,30.8366667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.4538889,22.8080556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8361111,23.76]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.81667,29.44306]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5888889,30.7858333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.94833,30.37528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.209209,19.146042]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0719444,18.1591667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.576204,23.191487]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.300383,19.291237]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9566667,19.3011111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5480556,30.7801944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1461111,22.8202778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0625,18.1575]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.55,28.19]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8472222,23.7694444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4341667,24.1494444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1688889,19.0902778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.27,23.96]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7429611,26.6776972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.2672222,19.0283333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0611111,18.1697222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.1036111,18.8497222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.5517556,28.9779644]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0663889,18.1652778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2083333,23.3222222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5930556,30.795]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7902944,26.6747028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.32583,26.70861]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4670029,24.1380005]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0586111,18.1597222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.525,28.1661111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8547222,23.7683333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.070278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6044444,30.5413889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7435528,26.6768083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.2588889,27.225]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.81667,29.44306]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.6141667,22.5641667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5901111,30.7953889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0625,18.1508333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.2178117,26.1368961]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8511111,23.7772222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5847222,30.7927778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.9263889,26.0516667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8505056,23.7768361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.790575,26.7651556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-114.3886947,28.8139592]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5875,30.8094444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1911111,19.0963889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.84,23.7547222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1891667,19.0877778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.0097222,22.8269444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3716667,24.081111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7443667,26.6832889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.2822222,19.0188889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.81667,29.44306]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.3166667,19.05]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0586111,18.1561111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5333333,30.7883333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7895111,26.764025]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.4,16.9166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8987178,29.3920969]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.9936111,31.2947222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7901556,26.6746028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.33,24.12]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8497222,23.7741667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.9113889,16.6547222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5999444,30.7859028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5861111,30.775]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.94833,30.37528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.7491667,23.7297222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8466667,23.7691667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7913611,23.7842778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0572222,18.1766667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.0666667,30.6]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5394444,30.7966667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7901861,26.7647722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.58775,30.7817111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.18,19.0888889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7439333,26.6760611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8525,23.7658333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5238889,30.5202778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.0108333,31.2605556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.93,23.70278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.7871167,20.8610333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8525,23.7658333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7910833,23.7832778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0611111,18.1697222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.9183333,22.8836111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5915667,30.8007833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894306,26.7658028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5728833,30.7895833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7452778,26.6716667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8283333,23.7622222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5419167,30.775]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5958333,30.7955556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7911667,23.78525]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.070278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5693389,30.7915833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8413889,23.7627778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7439528,26.6760444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0663889,18.1652778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5955556,30.8008333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.8958333,27.281944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.2872222,19.0283333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7998611,23.7914167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7850083,26.75885]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5938889,30.7925]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.299285,31.677386]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8438889,23.7611111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8076111,23.8006111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.42,27.99]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8447222,23.7741667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6016667,30.8166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1588889,19.0897222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.4041672,30.2549992]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6010361,30.7970528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8497222,23.7736111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.9263889,26.0516667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0625,18.1594444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3,30.1]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1711111,19.0891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.2916667,30.794167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7900472,26.7644917]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.787325,26.7614722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.84,23.7547222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8463889,23.7608333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1838889,19.0844444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5914167,30.77335]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.887172,29.308336]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1669444,19.0891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7439306,26.6762139]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8475,23.7683333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6022222,30.5352778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0622222,18.1691667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.070278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5836111,30.7891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5856667,30.8029833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.28818,24.1149378]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8525,23.7658333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5880833,30.79105]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.4744594,23.99333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8512806,23.765225]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1800667,19.0889278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5954722,30.8033056]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3208333,26.7075]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8380556,23.7638889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0652778,18.1591667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.6280556,25.8408333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.16,19.0883333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5385556,30.7741667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7687708,26.6345306]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.925,27.125]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8577778,23.7727778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5888889,30.7858333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.84,23.7547222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.2761553,24.61472]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1838889,19.0844444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-111.90611,26.71944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7427861,26.6752389]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8375,23.7544444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5836111,30.7891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0611111,18.1697222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1688889,19.0902778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5385833,30.7741389]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7572528,26.6894417]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7901861,26.7647722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8363194,23.7597083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.2258333,26.8944444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5919444,30.7933056]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.29,24.1133333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1052778,24.7880556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1641667,19.0875]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6913889,31.3236111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.3230556,19.435]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4341667,24.1494444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8497222,23.7741667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0622222,18.1691667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7848306,26.7587333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.2527778,19.0411111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.75111,31.6389675]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7907611,26.6752944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8511111,23.765]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2416667,21.875]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-111.55583,28.62944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8430556,23.7727778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.1416667,21.775]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7891694,26.7658278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1688889,19.0902778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.4502778,30.8836111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2894444,19.4177778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8463889,23.7608333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0594444,18.1575]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8430556,23.7611111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.0991667,19.375]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2083333,23.3222222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7464333,26.6938222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8466667,23.7691667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.3,21.8]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.5722222,22.0916667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7888639,26.7633167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.3375,23.8216667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.2291667,23.0452778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.299424,19.286991]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2794444,19.4738889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.63,26.43]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-92.175,17.175]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.1102778,25.3758333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.45,28.45]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0622222,18.1691667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7854306,26.772125]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5803028,30.7856028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.110756,19.101708]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2083333,23.3222222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7439306,26.6762139]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.2958333,24.3083333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8413889,23.7627778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7879611,26.7621611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.3375,23.8216667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.3133333,19.4269444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.096309,19.106597]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.5379944,28.9122275]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.37,25.22]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0625,18.1666667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7856306,26.7712694]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.0669,21.50289]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2480556,23.3875]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894306,26.7658028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.2754261,26.2876461]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.91,27.21]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8463889,23.7608333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.0951333,29.40194]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.17,30.04]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2816667,19.4927778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1166667,19.1041667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.82,28.1]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0625,18.1666667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7889361,26.7632806]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5888889,30.7858333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2083333,23.3222222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.3916667,26.3966667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1677778,19.1011111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.070278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.7697222,23.9719444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8425,23.7697222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.4083333,16.925]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7893306,26.7638083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.648361,29.888923]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-116.03105,30.71968]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2936111,19.4622222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.094108,19.082287]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0625,18.16]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7896611,26.7639917]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.10762,21.48419]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2669444,19.4686111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3380556,29.9741667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5066667,30.53]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7900167,26.7645444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.6348,23.596653]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3380556,29.9741667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2919444,19.4761111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5836111,30.7897222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0509972,18.1607111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.775,26.7758333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7871556,26.7613333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5851667,30.7941944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.9130556,27.1419444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2866667,19.4661111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.9333333,30.7166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.0077778,31.265]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.9125,23.9558333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.9138889,27.2113889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7887361,26.7630444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.24639,23.38639]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.95,30.3833333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7443667,26.6832889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7439306,26.6762139]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5481389,30.7806667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5859389,30.7965833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0586111,18.1561111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4341667,24.1494444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.07576,21.49083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5888889,30.7858333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7439306,26.6762139]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8043611,23.7984167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5547222,30.7883333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0586111,18.1561111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.8,27]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.4083333,16.925]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5853611,30.7935833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.3097222,29.8916667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.3283333,19.4241667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-114.3719444,27.575]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0622222,18.1691667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.2761553,24.61472]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.0669,21.50289]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1469667,29.2123889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.04732,17.86313]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5932167,30.7879833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8038056,23.7997222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7895333,26.7655444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4341667,24.1494444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7438083,26.6763944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.94833,30.37528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.6047222,26.6697222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0622222,18.1691667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7427861,26.6752389]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1461111,22.8202778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7957444,26.7888778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0572222,18.1766667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7404944,26.6789556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.0669,21.50289]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.0065744,28.5529644]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8046667,23.7995278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.3952212,23.4691835]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7706194,26.7568861]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7901639,26.6745861]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.585,30.7896111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.0133333,16.8147222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2222222,19.4588889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5936111,30.795]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.65,28.55]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.81,23.99]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.9866667,29.2591667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8365708,24.73761]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6002778,30.78]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.0889,28.6353]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.138231,19.434503]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.2997222,19.1197222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0583333,18.1761111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2336111,19.4394444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5925,30.7934722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108,31.15]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1401167,29.2196111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2861111,19.4408333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.7576369,25.8685244]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0586111,18.1561111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8365708,24.73761]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5875556,30.7944722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.791675,26.6733972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3208333,26.7075]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-116.0175019,30.7197228]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2341667,19.4763889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.3166667,19.05]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.0833333,26.2166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.7738889,25.8944444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0583333,18.1761111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5692778,30.7911944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7502667,26.6878083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5693389,30.7915833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2594444,19.4216667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.3952212,23.4691835]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0683333,18.1627778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.83611,24.73722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5908333,30.7955556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.741925,26.6749528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3891667,29.4280556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5958333,30.8125]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.1127778,19.42875]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.8166667,25.85]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0625,18.1594444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2486111,19.4752778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.2916667,30.794167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0586111,18.1561111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-114.16,28.9252778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0625,18.1666667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5888889,30.7858333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3208333,26.7075]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.55333,17.53444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.3166667,19.05]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5992778,30.7859028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5925,30.7601111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.7,28.68]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.9505556,24.8927778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.4691444,30.8185222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.45,30.88333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.1833333,29.8833333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5690194,30.7695833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6025,30.5347222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6102778,19.5216667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.4641667,30.4116667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.3166667,19.05]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.1083333,18.8583333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5897222,30.7919444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.9505556,24.8927778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5888889,30.7897222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.12,27.84833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.2769444,28.0769444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.3,19.1363889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1677778,19.0891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5686444,30.7689556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.25,26.83]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.9505556,24.8927778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5630556,30.7883333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.4425,27.6477778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.2769444,28.0769444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5692806,30.7913611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5880833,30.79105]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5925,30.7934722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.316164,19.281631]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4341667,24.1494444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5803028,30.7856028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5694278,30.7912222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.2338889,19.4441667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5947222,30.7905556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.3225,19.0705556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2833333,25.1333333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5836111,30.7891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5860889,30.8024944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5283333,30.9083333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.3916667,26.3966667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5066472,30.5999167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.3225,19.0705556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5803028,30.7856028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.5127778,23.7361111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5868333,30.7915833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6002778,30.7886111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5836111,30.7891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.3916667,26.3966667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5886111,30.7855556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.21873,19.154617]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.54825,30.7816111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3208333,26.7075]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6088889,30.7936111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5692,30.78975]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5728833,30.7895833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.3952212,23.4691835]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.4692833,30.8190083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5066667,30.5311111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.3952212,23.4691835]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.4692833,30.8190083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.7402778,31.1375]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5880833,30.79105]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2083333,23.3222222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7854556,26.759425]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.5127778,23.7361111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1406833,29.2086667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4672222,24.1375]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5803028,30.7856028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.61889,22.56028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.9430556,24.5819444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5888889,30.7897222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6072056,30.5626056]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.7625,31.1472222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.271142,19.220068]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5687583,30.7739167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.7069444,31.3272222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.5505556,30.4952778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.3139,19.0495]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894306,26.7658028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.0669,21.50289]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.1902778,30.8883333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.5,22.4166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5728833,30.7895833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.055833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.098889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894444,26.7656056]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5886111,30.7855556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8401667,23.6833333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.3291667,23.6543333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5836111,30.8055556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.60333,16.39917]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.84,27.94]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-111.5555556,28.6291667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7863361,26.769325]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.7591667,17.0022222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.0669,21.50289]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.3952212,23.4691835]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.625,16.5916667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.6094722,19.5134167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8505056,23.7768361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.0886111,18.3030556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7863361,26.7693528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6966667,24.6416667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.4502778,30.8836111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1461111,22.8202778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8525,23.7658333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1166667,19.1041667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.5333333,28.45]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.787175,26.7613333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7470017,24.7383956]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.07576,21.49083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.24,19.49]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.8830556,23.7869444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6933333,24.87]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.8680556,23.1747222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894306,26.7658028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.5871162,24.7612862]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.2916667,30.794167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.9830556,16.4333333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6966667,24.6416667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.2947778,19.0511111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.375,19.5083333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.2202758,23.1588897]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894444,26.7656056]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6,24.6416667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.07576,21.49083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.11556,21.84111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.7766667,22.8352778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.6367918,25.6752162]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7856306,26.7712694]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3819444,24.070833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.192681,19.161966]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8447222,23.7741667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1553694,19.0930889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6173089,19.5127808]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.785,26.7588694]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.1416667,21.775]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.514022,29.705951]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1576361,29.2193611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.6882556,23.1793278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1461111,23.7361111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8327778,23.7572222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7482972,26.6904889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7905806,26.6751028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6016667,19.5211111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7866861,26.7684806]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7431722,26.6776083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.256768,19.153302]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.9736111,16.4291667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.83565,23.7687306]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.925,27.2083333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7856306,26.7712778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894833,26.6744611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8547222,23.7683333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.2616038,24.61472]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8505056,23.7768361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.6416667,25.6744444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7434083,26.6772833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.7628,19.1278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.3197222,27.8197222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8511111,23.7652778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894417,26.6744889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5927778,30.7934722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.5379944,28.9122275]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7904528,26.6749222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.7806503,25.9291067]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.33083,25.35972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8377778,23.7572222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7464333,26.6938222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.5671919,29.0238725]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.0675,18.1630556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.091667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.791675,26.6733972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-91.9916667,17.525]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1680556,19.0938889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.66,28.48]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8361111,23.76]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-116.3016586,31.9132994]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-111.7197222,25.1358333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.9430556,26.8372222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.5379944,28.9122275]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.0833333,26.2166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7431722,26.6776083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1541667,19.0911111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.4625,21.3916667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8566833,23.7732944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1461111,22.8202778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.9905,23.9521667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.7766667,22.8352778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.1333333,26.1666667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1800667,19.0889278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7585056,26.6629278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8463889,23.7608333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7439306,26.6762139]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7439333,26.6760611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.7738889,25.8944444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7443667,26.6832889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.854299,23.948972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.8046667,23.7995278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7437833,26.6751472]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.3952212,23.4691835]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.972642,29.596919]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7443667,26.6832889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.61889,22.56028]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7962417,26.7789972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.791675,26.6733972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.79068,23.78894]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7437778,26.6764944]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7429111,26.67765]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1802167,19.0943583]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7913611,23.7805556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7414028,26.6777556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.971478,19.106394]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1597222,19.0977778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7911667,23.78525]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.1583333,23.8641667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.2031325,28.1922017]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.65,29.68]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.36609,24.67956]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894833,26.6744611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.3333333,23.8166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1825,19.1133333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7900528,26.6689056]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7899278,26.6742222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7911667,23.78525]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.165,19.1036111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.143867,19.132097]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7894833,26.6744611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7906917,26.6752222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.2761553,24.61472]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7849694,26.7588417]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.61,27.52]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7902139,26.6746222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7913611,23.7842778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.3952212,23.4691835]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.004306,19.090306]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.2658333,19.0280556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.4216667,24.6147222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7871861,26.7689361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1677778,19.0891667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.791,23.7813611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.0916667,25.6455556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3716667,24.081111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.94694,27.53361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7890944,26.7634722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.1416667,21.775]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.61575,17.201972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.5188889,17.5388889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.791675,26.6733972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.0494444,25.7863889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3833333,29.6166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1401167,29.2196111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7906306,26.6751583]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7889556,26.7632556]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3297222,24.123056]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.3208333,26.7075]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-114.640801,30.350598]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7502667,26.6878083]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.4376667,23.798]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7907806,26.6752583]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.817302,27.20097]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7906583,26.6753194]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7888417,26.7664222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.6166667,16.4166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.94833,30.37528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.27,23.91]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.78625,26.76035]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95,16.4166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7889333,26.7633444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.6094444,19.5158333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.45,30.88333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1594444,19.0883333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-114.7011111,30.8166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1888889,19.0883333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.055833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-98.8577778,19.3177778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1647222,19.0872222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5354472,30.7688667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.925,27.125]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1838889,19.0844444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.04732,17.86313]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.785,26.7588694]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.1688889,19.0902778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6966667,24.5083333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7893028,26.7656306]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.9825,23.7297222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7856306,26.7712694]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7893611,26.7656333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.4672222,24.1375]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.5925,22.4102778]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.913002,27.1420002]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-109.6882556,23.1793278]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.2833333,29.8666667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.94833,30.37528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.5594444,28.7658333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5941667,30.7933333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.2769444,28.0769444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.1416667,21.775]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-99.250731,19.249017]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.5888889,30.7858333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.0855556,17.0538889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.5916667,16.4083333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.475,23.18111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.6173089,19.5127808]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.9666667,23.7166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.3466667,22.6422222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.475,23.18111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-95.683294,16.449324]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3005556,30.9813889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.9488889,30.3786111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.9666667,23.7166667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-107.94833,30.37528]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-116.35,32.6]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-116.35,32.6]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.785,26.7588694]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7853389,26.7591972]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7879611,26.7621611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7879611,26.7621611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7879611,26.7621611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7897806,26.7642361]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7895028,26.7656333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7917,26.7888611]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7956833,26.7889583]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.905556,32.048889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3108333,24.084444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1636667,29.2056389]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.978641,29.472158]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.5500031,28.2332992]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.9905556,23.9522222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7439306,26.6762139]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.7906611,26.6741917]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.7555915,25.8686095]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-97.7922222,22.9658333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.9398919,23.3503295]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.6094722,19.5134167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.16275,29.2014722]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.33,24.12]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.6436111,23.4622222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8347222,23.7672222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-116.6166686,31.8666667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-113.5672222,28.9522222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-96.3625,16.92222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.4327778,21.4347222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-103.987838,19.564373]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-111.6526407,29.09889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-114.8336106,31.0338897]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.46,21.15]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.9333344,30.7166672]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-111.782872,28.830644]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.142126,19.717071]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.32583,26.70861]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.6147222,27.9519444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-106.8305556,23.7683333]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.32583,26.70861]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2083333,23.3222222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.1313739,26.1435939]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.66,21.37]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.328739,19.655922]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-112.1469667,29.2123889]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.25,26.83]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-115.2916667,30.794167]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.2877778,24.1175]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-110.3919444,24.060833]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.0991667,19.375]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-100.5791667,25.2722222]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-116.1904756,31.2786444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-102.1416667,21.775]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-101.1155556,21.8411111]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-104.3763889,29.2669444]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-108.9263889,26.0516667]}"},{"json_geom":"{\"type\":\"Point\",\"coordinates\":[-105.1416633,26.1538833]}"}]
        // d = JSON.parse(json_file)
        // console.log(d);

        try {
            // map.removeLayer(species_layer);
            // map.removeLayer(markersLayer);

            markersLayer.clearLayers();
            layer_control.removeLayer(markersLayer);

            // species_layer.clearLayers();
            // layer_control.removeLayer(species_layer);

        } catch (e) {

            console.log("primera vez");

        }

        specie_target = {"genero":"genero", "especie":"especie", "spid":99999, "label":"Nombre especie"};

        // var species_points = [];
        allowedPoints = d3.map([]);
        discardedPoints = d3.map([]);
        validationPoints = d3.map([]);


        for(i=0;i<d.length;i++){

            // json_item = JSON.parse(d[i].json_geom)
            item_id = JSON.parse(d[i].json_geom).coordinates.toString()
            // console.log(json_item);

            // this map is fill with the records in the database from an specie, so it discards repetive elemnts.
            allowedPoints.set(item_id, {
                "type"      : "Feature",
                "properties": {"specie" : specie_target.label, "gridid": d[i].gridid},
                //"properties": {"specie" : "Nombre_especie", "gridid": d[i].gridid},
                "geometry"  : JSON.parse(d[i].json_geom)
            });


            // validationPoints.set(item_id, {
            //             "type"      : "Feature",
            //             "properties": {"specie" : species_selected.label, "gridid": d[i].gridid},
            //             "geometry"  : JSON.parse(d[i].json_geom)
            //           });

            // species_points.push( { "type": "Feature",
            // 					  "properties": {"specie" : species_selected.label},
            //                       "geometry": JSON.parse(d[i].json_geom)
            //                     } );

        }

        console.log(allowedPoints.size());

        addPointLayer();

        /*    },
         error: function( jqXHR ,  textStatus,  errorThrown ){
         console.log("error: " + textStatus);
         console.log(errorThrown);
         console.log(jqXHR.responseText);
         }

         });*/



    };



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

    busca_especie();
});

