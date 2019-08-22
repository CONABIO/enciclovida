var por_nombre = function()
{
    $("#id").val("");
    $("#datos_cat").html("");
    $("#panelCategoriaTaxonomicaPt").hide();

    $("[id^='id_']").each(function(){
        $(this).prop('checked', false);
    });

    $('#por_gi, #por_nombre_fuente, #por_gi_fuente, #por_nombre').toggle('easeOutBounce');
};

var por_gi = function()
{
    $("#id").val("");
    $("#nombre").val('');
    $("#datos_cat").html("");
    $("#panelCategoriaTaxonomicaPt").hide();

    $('#por_gi, #por_nombre_fuente, #por_gi_fuente, #por_nombre').toggle('easeOutBounce');
};

var cat_tax_asociadas = function(id,nivel,cat)
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

var asignaFiltros = function(SET_PARAMS)
{
    // Escogio de grupo iconico
    if (SET_PARAMS.id != undefined && SET_PARAMS.nombre == undefined)
    {
        $('#id_gi_' + SET_PARAMS.id).prop('checked', true);
        $('#id').val(SET_PARAMS.id);

    } else if (SET_PARAMS.nombre != undefined) {
        por_nombre();
        $('#nombre').val(SET_PARAMS.nombre);
    }

    if (SET_PARAMS.por_pagina != undefined) $('#por_pagina').val(SET_PARAMS.por_pagina);

    if (SET_PARAMS.edo_cons != undefined) $('#edo_cons').val(SET_PARAMS.edo_cons);
    if (SET_PARAMS.dist != undefined) $('#dist').val(SET_PARAMS.dist);
    if (SET_PARAMS.uso != undefined) $('#uso').val(SET_PARAMS.uso);
    if (SET_PARAMS.prior != undefined) $('#prior').val(SET_PARAMS.prior);
    if (SET_PARAMS.ambiente != undefined) $('#ambiente').val(SET_PARAMS.ambiente);
    if (SET_PARAMS.reg != undefined) $('#reg').val(SET_PARAMS.reg);

    if (SET_PARAMS.estatus != undefined)
    {
        SET_PARAMS.estatus.forEach(function(valor){
            $('#estatus_' + valor).prop('checked', true);
        });
    }
};

$(document).ready(function()
{
    $('#busqueda_avanzada').on('change', ".radio input", function()
    {
        // El ID del grupo iconico
        var id_gi = $(this).val();
        $('#id').val(id_gi);
        cat_tax_asociadas(id_gi,'','');
    });

    $('#busqueda_avanzada').on('click', '#limpiar', function(){
        window.location.href = "/avanzada";
    });

    $('#busqueda_avanzada').on('click', '#por_nombre_fuente', function(){
        por_nombre();
        return false;
    });

    $('#busqueda_avanzada').on('click', '#por_gi_fuente', function(){
        por_gi();
        return false;
    });

    $('#busqueda_avanzada').on('click', '#boton-enviar-checklist', function(){
        var url = $(this).attr('url');

        if (url == "") return false;
        else window.open(url, '_blank');
    });

    $("#busqueda_avanzada").on('submit', '#b_avanzada', function() {
        $("#por_gi :input").attr("disabled", true);  // Deshabilita los grupos iconicos para que los repita en la URI
    });

    $(window).load(function(){
        $("html,body").animate({scrollTop: 122}, 1000);
    });

    $('#pestañas').tabs(); // Inicia los tabs
    scrolling_page("#resultados-0", settings.nop, settings.url);  // Inicia el scrolling

    /**
     *  Carga los taxones de la categoria dada
     **/
    $("#pestañas").on('click', '.tab_por_categoria', function (){
        var id_por_categoria = parseInt($(this).attr('categoria_taxonomica_id'));
        var url = $(this).attr('url');

        if (id_por_categoria == 0)  // tab default
        {
            settings.offset = offset[0];
            settings.cat = 0;
            settings.url = settings.url_original;

            datos_descarga.url = settings.url_original;
            datos_descarga.cuantos = settings.totales;

        } else {
            $.each(POR_CATEGORIA, function (index, value) {
                if (value.categoria_taxonomica_id == id_por_categoria) {

                    if (offset[value.categoria_taxonomica_id] == undefined)
                    {
                        offset[value.categoria_taxonomica_id] = 2;
                        settings.offset = offset[value.categoria_taxonomica_id];
                    } else
                        settings.offset = offset[value.categoria_taxonomica_id];

                    settings.cat = value.categoria_taxonomica_id;
                    settings.url = value.url;

                    datos_descarga.url = value.url;
                    datos_descarga.cuantos = value.cuantos;
                }
            });
        }

        // Carga el contenido cuando le da clic en una pestaña por primera vez
        if ($("#resultados-" + settings.cat).html().length == 0)
            $("#resultados-" + settings.cat).load(url);
    });

    // Para validar en vivo el correo
    $('#modal-descargas').on('keyup', '#correo', function(){
        $('#notice-avanzada').empty().addClass('hidden');

        if( !correoValido($(this).val()) )
        {
            $(this).parent().addClass("has-error");
            $(this).parent().removeClass("has-success");

            $(this).siblings("span:first").addClass("glyphicon-remove");
            $(this).siblings("span:first").removeClass("glyphicon-ok");
            $('#boton_enviar_descarga').attr('disabled', 'disabled');
        } else {
            $(this).parent().removeClass("has-error");
            $(this).parent().addClass("has-success");
            $(this).siblings("span:first").addClass("glyphicon-ok");
            $(this).siblings("span:first").removeClass("glyphicon-remove");
            $('#boton_enviar_descarga').removeAttr('disabled')
        }
    });

    // Para validar una ultima vez cuando paso la validacion del boton
    $('#modal-descargas').on('click', '#boton_enviar_descarga', function(){
        var url_xlsx = datos_descarga.url.replace("resultados?", "resultados.xlsx?");
        var correo = $('#correo').val();

        if(correoValido(correo))
        {
            $.ajax({
                url: url_xlsx + "&correo=" + correo,
                type: 'GET',
                dataType: "json"
            }).done(function(resp) {
                $('#modal-descargas').modal('toggle');

                if (resp.estatus == 1)
                    $('#notice-avanzada').empty().html('!La petición se envió correctamente!. Se te enviará un correo con los resultados de tu búsqueda!').removeClass('hidden').slideDown(600);
                else
                    $('#notice-avanzada').empty().html('Lo sentimos no se pudo procesar tu petición, asegurate de haber anotado correctamente tu correo e inténtalo de nuevo.').removeClass('hidden').slideDown(600);

            }).fail(function(){
                $('#modal-descargas').modal('toggle');
                $('#notice-avanzada').empty().html('Lo sentimos no se pudo procesar tu petición, asegurate de haber anotado correctamente tu correo e inténtalo de nuevo.').removeClass('hidden').slideDown(600);
            });

        } else
            return false;
    });
});

