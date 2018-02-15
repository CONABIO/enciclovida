var dameUrlServicioSnib = function(prop)
{
    return prop.geoportal_url + '&rd=' + prop.reino + '&id=' + prop.catalogo_id + '&clayer=' + prop.tipo_region_se + '&cvalue=' + prop.region_id_se;
};

var cargaRegistros = function(url)
{
    borraRegistrosAnteriores();
    geojsonSnib(url);
};

var borraRegistrosAnteriores = function()
{
    if (map.hasLayer(markersLayer))
    {
        map.removeLayer(markersLayer);
        markersLayer = L.markerClusterGroup({ chunkedLoading: true, spiderfyDistanceMultiplier: 2, which_layer: 'geoportal'});
    }
};

var aniadePuntosSnib = function()
{
    var geojsonFeature =  { "type": "FeatureCollection", "features": allowedPoints.values()};

    var species_layer = L.geoJson(geojsonFeature, {
        pointToLayer: function (feature, latlng) {

            if (feature.properties.d.ejemplarfosil == 'SI')  // Este campos quiere decir que es un fosil
                return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<i class="bone-ev-icon"></i>'})});
            else if (feature.properties.d.coleccion.toLowerCase().includes('averaves') || feature.properties.d.coleccion.toLowerCase().includes('ebird'))  // Este campos quiere decir que es de aves aves
                return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib', html: '<i class="feather-ev-icon"></i>'})});
            else  // de lo contrario es un registro normal
                return L.marker(latlng, {icon: L.divIcon({className: 'div-icon-snib-default', html: '<i class="circle-ev-icon"></i>'})});
        },
        onEachFeature: function (prop, layer) {
            layer.bindPopup(ejemplarSnib(prop.properties.d));
            layer.on("click", function () {
//layer.bindPopup(ejemplarSnib(prop.properties.d));
            });
        }
    });

    markersLayer.addLayer(species_layer);
    map.addLayer(markersLayer);

    /*
     var punto_rojo = '<svg height="50" width="200"><circle cx="10" cy="10" r="6" stroke="black" stroke-width="1" stroke-opacity="1" fill="#FF0000"/>';
     punto_rojo+= '<text x="20" y="13">Registros del SNIB</text>';

     var punto_naranja = punto_rojo + '<circle cx="10" cy="25" r="6" stroke="black" stroke-width="1" stroke-opacity="1" fill="#FFA500"/>';
     punto_naranja+= '<text x="20" y="28">Registros de AverAves</text>';

     var punto_gris = punto_naranja + '<circle cx="10" cy="40" r="6" stroke="black" stroke-width="1" stroke-opacity="1" fill="#888888"/>';
     punto_gris+= '<text x="20" y="43">Registros de Fósiles</text></svg>';

     legend_control.addOverlay(markersLayer,
     "<b>Registros del SNIB <sub>" + registros_conteo + "</sub><br /> (museos, colectas y proyectos)</b>" +
     "<p>"+punto_naranja+"</p>"
     );*/
};

/**
 * Hace una ajax request para la obtener la información de un taxon, esto es más rapido para muchos registros
 * */
var ejemplarSnibGeojson = function(layer, id)
{
    $.ajax({
        url: "/especies/" + TAXON.id + "/ejemplar-snib/" + id,
        dataType : "json",
        success : function (res){
            if (res.estatus == 'OK')
            {
                var ejemplar = res.ejemplar;
                var contenido = "";

                contenido += "<h4>" + nombre() + "</h4>";
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
};

/**
 * Lanza el pop up con la inforamcion del taxon, ya esta cargado; este metodo es lento con muchos registros
 * */
var ejemplarSnib = function(prop)
{
    var contenido = "";

    contenido += "<h4 class='text-center'>" + nombre() + "</h4>";
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
    contenido += "<dt>¿Tienes un comentario?: </dt><dd><a href='/especies/" + taxon.id + "/comentarios/new?proveedor_id=" + prop.idejemplar + "&tipo_proveedor=6' target='_blank'>redactar</a></dd>";

    return "<dl class='dl-horizontal'>" + contenido + "</dl>" + "<strong>ID SNIB: </strong>" + prop.idejemplar;
};

var nombre = function()
{
    if (I18n.locale == 'es')
    {
        if (taxon.nombre_comun.length > 0)
            return taxon.nombre_comun.replace(/[0-9]/g, '') + "<br /><a href='/especies/" + taxon.id + "'><i>" + taxon.nombre_cientifico + "</i></a>";
        else
            return "<a href='/especies/" + taxon.id + "' target='_blank'><i>" + taxon.nombre_cientifico + "</i></a>";
    } else
        return "<a href='/especies/" + taxon.id + "' target='_blank'><i>" + taxon.nombre_cientifico + "</i></a>";
};

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

                allowedPoints.set(item_id, {
                    "type"      : "Feature",
                    "properties": {d: d[i]}, // El ID y si es de aver aves
                    "geometry"  : JSON.parse(d[i].json_geom)
                });
            }

            aniadePuntosSnib();
        },
        error: function( jqXHR ,  textStatus,  errorThrown ){
            console.log("error: " + textStatus);
            console.log(errorThrown);
            console.log(jqXHR.responseText);
        }
    });  // termina ajax
};