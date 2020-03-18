/**
 * Despliega las fotos de naturalista
 */
var fotosNaturalista = function(){
    $.ajax({
        url: opciones.naturalista_api,
        type: 'GET',
        dataType: 'json'
    }).done(function (json) {
        if(jQuery.isEmptyObject(json)){
            fotosBDI();
        }else{

            if(json.total_results == 0){
                fotosBDI();
            }else if(json.results[0].taxon_photos.length == 0){
                fotosBDI();//TODO PONER CAJAS FIJAS, EN EL EVENTO DONE RELLENAR LOS BACKGROUND
            }else{
                $.ajax({
                    url: '/especies/' + opciones.taxon + '/fotos-referencia',
                    type: 'POST',
                    data: {
                        fotos: JSON.stringify(json.results[0].taxon_photos.slice(0, 5))
                    }
                }).done(function (fotos){
                    if(jQuery.isEmptyObject(opciones.geodatos)){}
                    else{}

                    $('#contenedor_fotos').html(fotos);
                    $('#especies-destacadas .col').hover(function(){$(this).toggleClass('col-9')});
                    $('#especies-destacadas').hover(function(){$('#especies-destacadas div.col:first-of-type').toggleClass('col-8')});
                }).fail(function(error){
                    fotosBDI();
                });
            }
        }
    }).fail(function(error){
        fotosBDI();
    });
};

/**
 * Despliega las fotos de BDI
 */
var fotosBDI = function(){
    $.ajax({
        url: opciones.bdi_api,
        type: 'GET',
        dataType: 'json'
    }).done(function (json){
        if(jQuery.isEmptyObject(json)){
            $('#contenedor_fotos').remove();
            if(jQuery.isEmptyObject(opciones.geodatos)){$('#sin_datos').html('Lo sentimos, pero no contamos con una imagen o geodato');}
        }else{
            if(json.estatus == 'error'){
                $('#contenedor_fotos').remove();
                if (jQuery.isEmptyObject(opciones.geodatos)) $('#sin_datos').html('Lo sentimos, pero no contamos con una imagen o geodato');
            }else if(json.estatus == 'OK' && json.fotos.length == 0){
                $('#contenedor_fotos').remove();
                if(jQuery.isEmptyObject(opciones.geodatos)){$('#sin_datos').html('Lo sentimos, pero no contamos con una imagen o geodato');}
            }else{
                $.ajax({
                    url: '/especies/' + opciones.taxon + '/fotos-referencia',
                    type: 'POST',
                    data: {fotos: JSON.stringify(json.fotos.slice(0, 5))}
                }).done(function (fotos) {
                    if (jQuery.isEmptyObject(opciones.geodatos)){}
                    else {}

                    $('#contenedor_fotos').html(fotos);
                    $('#especies-destacadas .col').hover(function(){$(this).toggleClass('col-5')});
                    $('#especies-destacadas').hover(function(){$('#especies-destacadas div.col:first-of-type').toggleClass('col-4')});
                }).fail(function (error) {
                    $('#contenedor_fotos').remove();
                    if (jQuery.isEmptyObject(opciones.geodatos)){
                        $('#sin_datos').html('Lo sentimos, pero aún no contamos con una imagen o geodato');
                    }
                });
            }
        }
    }).fail(function (error){
        //$('#contenedor_fotos').remove();
        if (jQuery.isEmptyObject(opciones.geodatos)){
            $('#sin_datos').html('Lo sentimos, pero hubo un error al cargar las fotos');
        }
    });
};
