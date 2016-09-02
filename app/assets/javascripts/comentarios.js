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

    if (params["comentario%5Bcategoria_comentario_id%5D"] != undefined)
        $('#filtro_categoria_comentario_id').val(params["comentario%5Bcategoria_comentario_id%5D"]);

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

        if ($('#comentario_categoria_comentario_id').val() == '')
            errores.push("La clase de comentario no puede ser vacía.");

        if (errores.length > 0)
        {
            var msj_error = '<p>Algún error(es) no permitieron que tu comentario fuese enviado</p>'
            $('#error_mensaje').empty().html(msj_error + '<ul><li>' + errores.join('</li><li>') + '</li></ul>');
            return false;
        }
    });

    $(document).on('change', ".comentario_estatus", function()
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

    $(document).on('change', ".comentario_categoria_comentario_id", function()
    {
        var especie_id = $(this).attr('especie_id');
        var comentario_id = $(this).attr('comentario_id');
        var div_estatus = $('#comentario_categoria_comentario_id_div_' + comentario_id);

        $.ajax({
            url: "/especies/" + especie_id + "/comentarios/" + comentario_id,
            method: 'PUT',
            dataType: "json",
            data: {categoria_comentario_id: $(this).val()}

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

    $(document).on('click', ".historial", function()
    {
        var especie_id = $(this).attr('especie_id');
        var comentario_id = $(this).attr('comentario_id');
        var ficha = $(this).attr('ficha');

        if (especie_id == undefined || comentario_id == undefined)
            return false;

        $.ajax({
            url: "/especies/" + especie_id + "/comentarios/" + comentario_id,
            method: 'GET',
            data: {ficha: ficha}

        }).done(function(html) {
            $('#historial_' + comentario_id).empty().append(html).slideDown();
            var link_historial = $( "a[comentario_id='"+ comentario_id +"']");
            link_historial.hide();
            $('#ocultar_' + comentario_id).slideDown();
        });

        return false;
    });

    $(document).on('click', "[id^='ocultar_']", function()
    {
        var comentario_id = $(this).attr('id').split("_")[1];
        var link_historial = $( "a[comentario_id='"+ comentario_id +"']");

        $('#historial_' + comentario_id).hide();
        $('#ocultar_' + comentario_id).hide();
        link_historial.slideDown();
        console.log('aqui');
        return false;
    });

    $(document).on('change', "[id^='filtro_']", function()
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

    $(document).on('click', "#filtro_created_at, #filtro_nombre_cientifico", function()
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
});
