/*
 Cuando el usuario elige un taxon en la vists avanzada, las categorias
 taxonimicas se despliegan segun las asociadas
 */
function firstToUpperCase( str ) {
    return str.substr(0, 1).toUpperCase() + str.substr(1);
}

soulmate_asigna = function(tipo_busqueda)
{
    var render = function(term, data, type, index, id)
    {
        if (I18n.locale == 'es-cientifico')
        {
            var nombres = '<h5> ' + data.nombre_comun + '</h5>' + '<a href="" class="not-active">' + data.nombre_cientifico + ' </a><i>' + data.autoridad + '</i>';
            return nombres;

        } else {
            var nombres = '<h5>'+firstToUpperCase(data.nombre_comun)+'</h5>' + '<a href="" class="not-active">' + data.nombre_cientifico +'</a>';

            if (data.foto.length == 0)
                var foto = '<i class="soulmate-img ev1-ev-icon pull-left"></i>';
            else {
                var foto_url = data.foto;
                var foto = "<i class='soulmate-img pull-left' style='background-    image: url(\""+foto_url+"\")';></i>";
            }

            var iconos = "";
            var ev = '-ev-icon';

            $.each(data.cons_amb_dist, function(i, val){
                if (val == 'exotica' || val == 'invasora' || val == 'exotica-invasora' || val == 'no-endemica'){return true}
                iconos = iconos + "<i class='" + val + ev +"' title='"+firstToUpperCase(val)+"'></i>"
            });

            if (data.geodatos != undefined){iconos = iconos + "<i class='globe-ev-icon text-success' title='Tiene mapa'></i>"}
            if (data.fotos > 0){iconos = iconos + "<i class='picture-ev-icon text-success' title='Tiene imágenes'></i><sub>" + data.fotos + "</sub>"}

            return foto + " " + nombres + "<h5 class='soulmate-icons'>" + iconos +"</h5>";
        }
    };

    var select = function(term, data, type)
    {
        $('#nombre').val(term);
        $('#id').attr('value', data.id);
        $('ul#soulmate').hide();    // esconde el autocomplete cuando escoge uno

        if (tipo_busqueda != undefined && tipo_busqueda == 'avanzada')
            cat_tax_asociadas(data.id);  // despliega las categorias taxonomicas asociadas al taxon

        // Para no pasar por el controlador de busquedas, ir directo a la especie
        $('#basica').attr('action','/especies/'+data.id)
        $('#basica').submit();
    };

    $('#nombre').soulmate({
        url:            "http://"+ IP + ":" + PORT + "sm/search",
        types:          TYPES,
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults:     15
    });
};

$(document).ready(function()
{
    cat_tax_asociadas = function(id,nivel,cat)
    {
        $.ajax(
            {
                url: "/cat_tax_asociadas",
                type: 'GET',
                data: {
                    id: id,
                    nivel: nivel,
                    cat: cat
                }
            }).done(function(html)
            {
                $('#datos_cat').html('').html(html);
                $('#panelCategoriaTaxonomicaPt').show();
            });
    };

    scrolling_page = function(objeto, por_pagina, url)
    {
        $(objeto).scrollPagination({
            nop     : por_pagina, // The number of posts per scroll to be loaded
            offset  : 2, // Initial offset, begins at 0 in this case
            error   : '', // When the user reaches the end this is the message that is
            // displayed. You can change this if you want.
            delay   : 500, // When you scroll down the posts will load after a delayed amount of time.
                           // This is mainly for usability concerns. You can alter this as you see fit
            scroll  : true, // The main bit, if set to false posts will not load as the user scrolls.
            // but will still load if the user clicks.
            url     : url
        });
    };

    $(document).on('change', ".radio input", function()
    {
        var id = $(this).attr('value');
        cat_tax_asociadas(id,'','');
    });

//        $(document).on('change', "[id^='distribucion_nivel_']", function()
//        {
//            var valor=$(this).val();
//            $('#'+$(this).attr('id') + ' option').removeAttr('selected');  //remueve si habia algun seleccionado
//            $('#'+$(this).attr('id') + " option[value='"+valor+"']").attr('selected',true);
//            var nivel=parseInt($(this).attr('name').substring(19));
//
//            if ($(this).val() != '')
//            {
//                jQuery.ajax({
//                    success: function(html){
//                        $('#distribucion_nivel_'+(nivel)).nextAll("[id^='distribucion_nivel_']").remove();
//                        switch (nivel)
//                        {
//                            case 1:
//                                $('#distribucion_nivel').empty().html(html);       //pare el inicial
//                                break;
//                            case 2:
//                                $('#distribucion_nivel').append(html);
//                                break;
//                        }
//                    },
//                    fail: function(){
//                        $('#notice').html('Hubo un error al cargar los filtros, por favor intentalo de nuevo.');
//                    },
//                    type:'POST',
//                    url:'/regiones/regiones',
//                    cache:true,
//                    data: {region: $(this).val(), region_nivel: nivel}
//                });
//            }
//
//            if ($(this).val() == '' && nivel == 1)  //quita las sub-regiones si eligio todas
//                $('#distribucion_nivel').empty();
//
//            if ($(this).val() == '' && nivel == 2)  //quita las sub-regiones si eligio todas
//                $('#distribucion_nivel_3').remove();
//        });

    $(document).on('change', "#per_page", function(k)
    {
        var valor=$(this).val();
        $('#'+$(this).attr('id') + ' option').removeAttr('selected');
        $('#'+$(this).attr('id') + " option[value='"+valor+"']").attr('selected',true);

        $('#per_page_basica_comun, #per_page_basica_cientifico, #per_page_avanzada').val($(this).val());
        $('#per_page_basica_comun, #per_page_basica_cientifico, #per_page_avanzada').attr('value',$(this).val());
    });

    $(document).on('click', '#limpiar', function(){
        $("#id, #nombre").val("");
        $("#datos_cat").html("");
        $("#panelCategoriaTaxonomicaPt").hide();
        return false;
    });
});

