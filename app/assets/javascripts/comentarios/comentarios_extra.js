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

$(document).ready(function() {
    var paginaActual = opciones.pagina || 1;
    var cargando = false;
    var finComentarios = false;

    $('#mas_comentarios').scrollPagination({
        per_page: opciones.por_pagina,
        page: paginaActual,
        error: 'No hay más comentarios.',
        delay: 100,
        scroll: true,
        beforeLoad: function() {
            if (cargando || finComentarios) return false;
            cargando = true;
            return true;
        },
        afterLoad: function(elementsLoaded, data) {
            cargando = false;
            if (!elementsLoaded || elementsLoaded.length === 0 ||
                paginaActual * opciones.por_pagina >= data.totalComentarios) {
                finComentarios = true;
                $('#mas_comentarios').append('<p>No hay más comentarios.</p>');
                $('#mas_comentarios').stopScrollPagination();
            } else {
                paginaActual++;
            }
        }
    });
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

    //enviando respuestas a comentarios
    $(document).on('click', '.historial', function (e) {
        e.preventDefault();

        const comentarioId = $(this).attr('comentario_id');
        const especieId = $(this).attr('especie_id');
        const ficha = $(this).attr('ficha');
        const accion = $(this).data('accion');

        switch (accion) {
            case 'responder':
            muestraFormularioRespuesta(comentarioId, especieId, this); // <-- pasa el botón clicado
            break;
            case 'ver_respuestas':
            muestraRespuestas(comentarioId, especieId);
            break;
            case 'ocultar':
            ocultarRespuestas(comentarioId);
            break;
        }
    });


   function muestraFormularioRespuesta(comentarioId, especieId, elemento) {
    // Verifica si ya existe un formulario
        if ($(`#formulario_respuesta_${comentarioId}`).length > 0) {
            return;
        }

        const formulario = `
            <div id="formulario_respuesta_${comentarioId}" class="formulario-respuesta" style="margin-top: 10px;">
                <form action="/especies/${especieId}/comentarios/${comentarioId}/respuestas" method="POST">
                    <div class="form-group">
                        <label for="respuesta_${comentarioId}">Tu respuesta</label>
                        <textarea id="respuesta_${comentarioId}" name="comentario[comentario]" class="form-control" rows="3"></textarea>
                    </div>
                    <input type="hidden" name="es_respuesta" value="1">
                    <button type="submit" class="btn btn-primary btn-sm">Enviar</button>
                    <button type="button" class="btn btn-secondary btn-sm cancelar-formulario" data-comentario-id="${comentarioId}">Cancelar</button>
                </form>
            </div>
        `;

        // Insertar el formulario justo debajo del botón "Responder"
        $(elemento).after(formulario);
    }

    $(document).on('click', '.cancelar-formulario', function () {
        const comentarioId = $(this).data('comentario-id');
        $(`#formulario_respuesta_${comentarioId}`).remove();
    });

    $(document).on('submit', '.formulario-respuesta form', function (e) {
        e.preventDefault();

        const form = $(this);
        const action = form.attr('action');
        const data = form.serialize();
        const comentarioId = form.closest('.formulario-respuesta').attr('id').split('_').pop();
        const textarea = form.find('textarea');

        if (textarea.val().trim() === '') {
            alert('La respuesta no puede ir vacía.');
            return;
        }

        $.ajax({
            url: action,
            method: 'POST',
            data: data,
            dataType: 'json',
            success: function (resp) {
            if (resp.estatus === 1) {
                const nuevoComentario = `
                <div class="comentario-burbuja respuesta">
                    ${resp.comentario_html}
                </div>
                `;
                $(`#formulario_respuesta_${comentarioId}`).after(nuevoComentario);
                $(`#formulario_respuesta_${comentarioId}`).remove();
            } else {
                alert('Ocurrió un error al guardar tu respuesta.');
            }
            },
            error: function () {
            alert('Error al enviar la respuesta. Inténtalo de nuevo.');
            }
        });
    });
    //ver respuestas
    function muestraRespuestas(comentarioId, especieId) {
        $.ajax({
            url: `/especies/${especieId}/comentarios/${comentarioId}/ver_respuestas`,
            type: 'GET',
            dataType: 'script'  // Esto ejecuta el archivo .js.erb que retorna Rails
        });
    }
    //ocultar respuestas 
    function ocultarRespuestas(comentarioId) {
    // Elimina el contenedor que tiene las respuestas
        $(`#respuestas_${comentarioId}`).remove();
        // Oculta el botón ocultar
        $(`#ocultar_${comentarioId}`).hide();
    }

    $(document).on('click', "[id^='ocultar_']", function(e) {
        e.preventDefault();

        // Obtener el comentarioId del id del botón
        const comentarioId = this.id.split('_')[1];
        ocultarRespuestas(comentarioId);
    });

    //codigo anterior para enviar los cmentarios 
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

    $(document).on('change', "[id^='filtro_']", function() {
    console.log('Filtro detectado en cambio');

    $.ajax({
        url: "/comentarios/administracion",
        method: 'GET',
        data: $('#filtro_form').serialize() + '&comentario[ajax]=1'
    }).done(function(html, textStatus, jqXHR) {
        const total = jqXHR.getResponseHeader('x-total-entries');
        $('#totales').text(total);
        $('#mas_comentarios').html(html);
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

