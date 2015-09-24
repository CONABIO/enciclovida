/*
 Cuando el usuario elige un taxon en la vists avanzada, las categorias
 taxonimicas se despliegan segun las asociadas
 */

$(document).ready(function()
{
    cat_tax_asociadas = function(id)
    {
        $.ajax(
            {
                url: "/cat_tax_asociadas",
                type: 'GET',
                data: {
                    id: id
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

    $(document).on('click', ".busqueda_atributo_radio", function()
    {
        var id = $(this).attr('id_icono');

        // Quito las opciones seleccionadas para que despues no haya problema
        $(".busqueda_atributo_radio").each(function(index) {
            var id_radio = $(this).attr('id_icono');
            if (id != id_radio)
            {
                $('#id_nom_cientifico_' + id_radio).attr('checked', false);
                $(this).removeClass("busqueda_atributo_radio_seleccionado");
            }
        });

        $('#id_nom_cientifico_' + id).prop('checked', true);
        $('#id_nom_cientifico').attr('value',id);

        $(this).toggleClass("busqueda_atributo_radio_seleccionado");
        cat_tax_asociadas(id);
    });
    //
    //$(document).on('click', ".busqueda_atributo_imagen", function(){
    //    if ($('#' + $(this).attr('name')).prop('checked'))
    //    {
    //        $('#' + $(this).attr('name')).prop('checked',false);
    //        $('#' + $(this).attr('name')).attr('checked', false);//Esto es para que genere el HTML y sea guardado en la bd !>.>
    //    } else {
    //        /* Se ponen los dos tipos de id ya que en este punto no se a cual de los dos tipos de select NO fue el que entre
    //         * Se puede mejorar la funcion añadiendo una clase fantasma tanto a la imágenes como a los input
    //         * pero dicho cambio no se realizara a las 22:00 en viernes
    //         * se redujo las ejecuciones dummie en 20% aprox
    //         * */
    //        $('#' + $(this).attr('name')).prop('checked', true);
    //        $('#' + $(this).attr('name')).attr('checked', true);//IDEM
    //    }
    //    $(this).toggleClass("busqueda_atributo_imagen_seleccionado");
    //});

    $(document).on('change', "#nivel, #cat", function()
    {
        var valor=$(this).val();
        $('#'+$(this).attr('id') + ' option').removeAttr('selected');  //remueve si habia algun seleccionado
        $('#'+$(this).attr('id') + " option[value='"+valor+"']").attr('selected',true);
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

    $(document).on('change', "#nombre_comun, #nombre_cientifico, #nombre_comun_1, #nombre_cientifico_1", function()
    {
        var id=$(this).attr('id');
        $(this).attr('value',$(this).val());

        // La funcionalidad de las categorias taxonomicas solo la tiene el nombre cientifico de la vista avanzada
        if ($(this).attr('id') == 'nombre_cientifico_1')
            $('#panelCategoriaTaxonomicaPt').hide();
    });


/*Sección comentada ya que ya no se guarda el html en la BD :D*/
    //$(document).on('click', '#limpiar', function()
    //{
    //    jQuery.ajax({
    //        success: function(html)
    //        {
    //            if (html!='true')
    //            {
    //                $('#notice').html('Hubo un error al limpiar los filtros, por favor intentalo de nuevo.');
    //                return false
    //            }
    //            window.location.replace(window.location.origin);
    //        },
    //        fail: function() {
    //            $('#notice').html('Hubo un error al limpiar los filtros, por favor intentalo de nuevo.');
    //        },
    //        type:'POST',
    //        url:'/usuarios/limpia_filtro',
    //        cache:true
    //    });
    //});

    $(document).on('change', "#per_page", function(k)
    {
        var valor=$(this).val();
        $('#'+$(this).attr('id') + ' option').removeAttr('selected');
        $('#'+$(this).attr('id') + " option[value='"+valor+"']").attr('selected',true);

        $('#per_page_basica_comun, #per_page_basica_cientifico, #per_page_avanzada').val($(this).val());
        $('#per_page_basica_comun, #per_page_basica_cientifico, #per_page_avanzada').attr('value',$(this).val());
    });

    // autocomplete para la busqueda basica
    $(document).on('focus', '#nombre_comun', {num: "1"}, soulmate_asigna);
    $(document).on('focus', '#nombre_cientifico', {num: "2"}, soulmate_asigna);
    // autocomplete para la busqueda avanzada
    $(document).on('focus', '#nombre_comun_1', {num: "3"}, soulmate_asigna);
    $(document).on('focus', '#nombre_cientifico_1', {num: "4"}, soulmate_asigna);
});

