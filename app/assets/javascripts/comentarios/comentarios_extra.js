function es_correo(email) {
    var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(email);
}

function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }
    return vars;
}

function asigna_valores_select()
{
    var params = getUrlVars();

    if (params["comentario%5Bestatus%5D"] != undefined)
        $('#filtro_estatus').val(params["comentario%5Bestatus%5D"]);

    if (params["comentario%5Bcategorias_contenido_id%5D"] != undefined)
        $('#filtro_categorias_contenido_id').val(params["comentario%5Bcategorias_contenido_id%5D"]);

    if (params["comentario%5Bcreated_at%5D"] != undefined)
    {
        if (params["comentario%5Bcreated_at%5D"] == "ASC")
            $('#filtro_created_at > i').removeClass("glyphicon-sort").removeClass("glyphicon-down").addClass("glyphicon-chevron-up");
        if (params["comentario%5Bcreated_at%5D"] == "DESC")
            $('#filtro_created_at > i').removeClass("glyphicon-sort").removeClass("glyphicon-up").addClass("glyphicon-chevron-down");

        $('#comentario_created_at').val(params["comentario%5Bcreated_at%5D"]);
    }
}

$(document).ready(function(){

    console.log('✅ scrollPagination inicializado');
    console.log('🔍 opciones.por_pagina:', opciones.por_pagina);
    console.log('🔍 opciones.pagina:', opciones.pagina);
    
    // Interceptar todas las llamadas AJAX para ver los headers
    $(document).ajaxComplete(function(event, xhr, settings) {
        if (settings.url.includes('/comentarios/admin')) {
            console.log('🔍 AJAX Response para comentarios:');
            console.log('URL:', settings.url);
            console.log('x-total-entries:', xhr.getResponseHeader('x-total-entries'));
            console.log('Status:', xhr.status);
            console.log('Response length:', xhr.responseText.length);
            
            var totales = xhr.getResponseHeader('x-total-entries');
            if (totales) {
                // Actualizar el contenido del span
                $('#totales').text(totales);

                // Si el contenedor podría estar oculto, mostrarlo
                $('#contenedor-totales').show();
            }
        }
    });

    $('#mas_comentarios').scrollPagination({
        per_page: opciones.por_pagina,
        page    : opciones.pagina,
        error   : 'No hay mas comentarios.',
        delay   : 500,
        scroll  : true,
        
        
    });
    /* Comentado ya que no se muestra el correo extraído de xolo, en un futuro se necesitará
    $('#mas_comentarios').on('click', '.comentarios-correos', function() {
        $(this).children('div.correos, button.btn-correo').toggleClass('hidden');
        id=$(this).children('div.correos')[0].getAttribute('id');
        if ($('#'+id).html().trim().length==0) {
            $('#' + id).load('/comentarios/correoId?id=' + id);
        }
    });
    */
    
    
    muestra_historial_comentario('escucha_envio');
    oculta_historial_comentario('escucha_envio');

    $('.comentario_submit').on('click', function(){
        var errores = [];

        if ($('#comentario_correo').val() != undefined && $('#comentario_correo').val() == '')
            errores.push("El correo no puede ser vacío.");

        else if ($('#comentario_correo').val() != undefined)
        {
            if (!es_correo($('#comentario_correo').val()))
                errores.push("El correo no es válido, por favor verifica.");
        }

        if ($('#comentario_nombre').val() != undefined && $('#comentario_nombre').val() == '')
            errores.push("El nombre no puede ser vacío.");

        if ($('#comentario_comentario').val() == '')
            errores.push("El comentario no puede ser vacío.");

        if ($('#comentario_categorias_contenido_id').val() == '')
            errores.push("La clase de comentario no puede ser vacía.");

        if (errores.length > 0)
        {
            var msj_error = '<p>Algún error(es) no permitieron que tu comentario fuese enviado</p>'
            $('#error_mensaje').empty().html(msj_error + '<ul><li>' + errores.join('</li><li>') + '</li></ul>');
            return false;
        }
    });

    $('#escucha_envio').on('change', ".comentario_estatus", function()
    {
        var estatus = $(this).val();

        if (estatus == 5)
        {
            var r = confirm("¿Estás seguro de eliminar este comentario? Ya no será visible desde el panel de administración");

            if (r != true)
                return false;
        }

        var especie_id = $(this).attr('especie_id');
        var comentario_id = $(this).attr('comentario_id');
        var div_estatus = $('#comentario_estatus_div_' + comentario_id);

        $.ajax({
            url: "/especies/" + especie_id + "/comentarios/" + comentario_id,
            method: 'PUT',
            dataType: "json",
            data: {estatus: estatus}

        }).done(function(resp) {

            if (resp.estatus == 1)
            {
                if (estatus == 5)
                    $('#renglon_' + comentario_id).remove();
                else {
                    div_estatus.removeClass("alert-danger");

                    if (!div_estatus.hasClass("alert-success"))
                    {
                        $('#comentario_estatus_div_' + comentario_id).addClass('alert-success');
                        $('#comentario_estatus_div_' + comentario_id).empty().append("¡Tu cambio fue guardado exitosamente!").slideDown();
                    }
                }

            } else {
                div_estatus.removeClass("alert-success");

                if (!div_estatus.hasClass("alert-danger"))
                {
                    $('#comentario_estatus_div_' + comentario_id).addClass('alert-danger');
                    $('#comentario_estatus_div_' + comentario_id).empty().append("Hubo un problema al actualizar").slideDown();
                }
            }
        }).fail(function() {
            div_estatus.removeClass("alert-success");

            if (!div_estatus.hasClass("alert-danger"))
            {
                $('#comentario_estatus_div_' + comentario_id).addClass('alert-danger');
                $('#comentario_estatus_div_' + comentario_id).empty().append("Hubo un problema al actualizar");
            }
        });
    });

    $('#escucha_envio').on('change', ".comentario_categorias_contenido_id", function()
    {
        var especie_id = $(this).attr('especie_id');
        var comentario_id = $(this).attr('comentario_id');
        var div_estatus = $('#comentario_categorias_contenido_id_div_' + comentario_id);

        $.ajax({
            url: "/especies/" + especie_id + "/comentarios/" + comentario_id,
            method: 'PUT',
            dataType: "json",
            data: {categorias_contenido_id: $(this).val()}

        }).done(function(resp) {

            if (resp.estatus == 1)
            {
                div_estatus.removeClass("alert-danger");

                if (!div_estatus.hasClass("alert-success"))
                {
                    $('#comentario_estatus_div_' + comentario_id).addClass('alert-success');
                    $('#comentario_estatus_div_' + comentario_id).empty().append("¡Tu cambio fue guardado exitosamente!").slideDown();
                }

            } else {
                div_estatus.removeClass("alert-success");

                if (!div_estatus.hasClass("alert-danger"))
                {
                    $('#comentario_estatus_div_' + comentario_id).addClass('alert-danger');
                    $('#comentario_estatus_div_' + comentario_id).empty().append("Hubo un problema al actualizar").slideDown();
                }
            }
        }).fail(function() {
            div_estatus.removeClass("alert-success");

            if (!div_estatus.hasClass("alert-danger"))
            {
                $('#comentario_estatus_div_' + comentario_id).addClass('alert-danger');
                $('#comentario_estatus_div_' + comentario_id).empty().append("Hubo un problema al actualizar");
            }
        });
    });

    $('#escucha_envio').on('change', "[id^='filtro_']", function()
    {
        $.ajax({
            url: "/comentarios/administracion",
            method: 'GET',
            data: $('#filtro_form').serialize() + '&comentario[ajax]=1'

        }).done(function(html, textStatus, XMLHttpRequest) {
            $('#totales').html('').html(XMLHttpRequest.getResponseHeader('x-total-entries'));
            $('#mas_comentarios').empty().append(html);
        });
    });

    $('#escucha_envio').on('click', "#filtro_created_at, #filtro_nombre_cientifico", function()
    {
        if ($(this).attr("id") == "filtro_created_at")
        {
            var filtro = "#filtro_created_at";
            var obj = "#comentario_created_at";
        } else if ($(this).attr("id") == "filtro_nombre_cientifico") {
            var filtro = "#filtro_nombre_cientifico";
            var obj = "#comentario_nombre_cientifico";
        } else
            return false;

        if ($(filtro + ' > i').hasClass("glyphicon-sort"))
        {
            $(filtro + ' > i').removeClass("glyphicon-sort").addClass("glyphicon-chevron-up");
            $(obj).val('ASC');

        } else if ($(filtro + ' > i').hasClass("glyphicon-chevron-up"))
        {
            $(filtro + ' > i').removeClass("glyphicon-chevron-up").addClass("glyphicon-chevron-down");
            $(obj).val('DESC');

        } else if ($(filtro + ' > i').hasClass("glyphicon-chevron-down"))
        {
            $(filtro + ' > i').removeClass("glyphicon-chevron-down").addClass("glyphicon-chevron-up");
            $(obj).val('ASC');
        }

        $.ajax({
            url: "/comentarios/administracion",
            method: 'GET',
            data: $('#filtro_form').serialize() + '&comentario[ajax]=1'

        }).done(function(html, textStatus, XMLHttpRequest) {
            $('#totales').html('').html(XMLHttpRequest.getResponseHeader('x-total-entries'));
            $('#mas_comentarios').empty().append(html);
        });

        return false;
    });

    $('[data-toggle="tooltip"]').tooltip({html: true});
    asigna_valores_select();


    $('#escucha_envio').on('click', '.comentario_submit', function() {
        // Busco AHORA sí las etiquetas ADECUADAS (¬¬ ggonzalez)
        var commentId = $(this).attr('id').replace('submit_','');

        var label = $("#label_"+commentId);
        var comentario = $("#textArea_"+commentId);
        var historial_comentarios = $("#historial_comentarios_"+commentId);

        if (comentario.val() == ''){
            label.parent().addClass('has-error');
            $('#error_'+commentId).text('El comentario no puede estar vacío');
        }
        else {
            var form = $("#form_"+commentId);
            var ancestry = $("#comentario_ancestry_"+commentId);
            label.parent().removeClass('has-error');
            $('#error_'+commentId).text('');
            var re = new RegExp("_"+commentId,"g");

            $.ajax({
                url: form.attr('action'),
                method: 'POST',
                dataType: "json",
                data: form.serialize().replace(re,"")//se le pasa una regExp para que sustituya TODAS las apariciones y no solo la primera
            }).done(function(resp) {

                if (resp.estatus == 1)
                {
                    // Si la respuesta viene de un usuario
                    /*if (resp.comentario_id != undefined && resp.especie_id != undefined && resp.created_at != undefined)
                     window.location.replace("/especies/" + resp.especie_id + "/comentarios/" + resp.comentario_id + "/show_respuesta?created_at=" + resp.created_at);*/
                    /* else {*/
                    html_blockquote='<div class="comentario-burbuja respuesta">'+
                    comentario.val()+ '<br />'+
                    '<small>'+resp.nombre + '-' + resp.created_at +'</small>'+
                    '</div>';
                    historial_comentarios.append(html_blockquote);
                    ancestry.val(resp.ancestry);
                    comentario.val('');
                    //}

                } else
                    console.log('Hubo un error al guardar la respuesta');

            }).fail(function() {
                console.log('Hubo un error al guardar la respuesta');
            });
        }
    });

});