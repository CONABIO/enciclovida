/*
 Cuando el usuario elige un taxon en la vists avanzada, las categorias
 taxonimicas se despliegan segun las asociadas
 */

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
        $("#id_basica_comun, #id_avanzada_comun, #id_basica_cientifico, #id_avanzada_cientifico, #nombre_comun_1, #nombre_cientifico_1").attr("value", "");
        $("#datos_cat").html("");
        $("#panelCategoriaTaxonomicaPt").hide();
    });

    // autocomplete para la busqueda basica
    $(document).on('focus', '#nombre_comun', {num: "1"}, soulmate_asigna);
    $(document).on('focus', '#nombre_cientifico', {num: "2"}, soulmate_asigna);
    // autocomplete para la busqueda avanzada
    $(document).on('focus', '#nombre_comun_1', {num: "3"}, soulmate_asigna);
    $(document).on('focus', '#nombre_cientifico_1', {num: "4"}, soulmate_asigna);
});

