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

$(document).ready(function(){
    $('#comentario_submit').click(function(){
        if ($('#comentario_correo').val() != undefined && $('#comentario_correo').val() == '')
        {
            $('#error_mensaje').empty().html('El correo no puede ser vacio.');
            return false;
        } else if ($('#comentario_correo').val() != undefined){
            if (!es_correo($('#comentario_correo').val()))
            {
                $('#error_mensaje').empty().html('El correo no es válido, por favor verifica.');
                return false;
            }
        }
        if ($('#comentario_nombre').val() != undefined && $('#comentario_nombre').val() == '')
        {
            $('#error_mensaje').empty().html('El nombre no puede ser vacio.');
            return false;
        }
        if ($('#comentario_comentario').val() == '')
        {
            $('#error_mensaje').empty().html('El comentario no puede ser vacio.');
            return false;
        }
    });

    $(document).on('change', "[id^='estatus_']", function()
    {
        var especie_id = $(this).attr('especie_id');
        var comentario_id = $(this).attr('id').split("_")[1];

        // Cambiamos el valor del checkbox de acuerdo a lo que escogio
        $(this).val($(this).val() == "1" ? "0" : "1");

        $.ajax({
            url: "/especies/" + especie_id + "/comentarios/" + comentario_id,
            method: 'PUT',
            dataType: "json",
            data: {estatus: $(this).val()}

        }).done(function(resp) {

            if (resp.estatus == 1)
            {
                // Quiere decir que cambio a estatus=1
                if ($('#estatus_'+comentario_id).val() == '1')
                {
                    $('#span_estatus_' + comentario_id).removeClass('glyphicon-alert').addClass('glyphicon-ok');
                    $('#span_estatus_' + comentario_id).css('color','#889b45');
                } else {
                    $('#span_estatus_' + comentario_id).removeClass('glyphicon-ok').addClass('glyphicon-alert');
                    $('#span_estatus_' + comentario_id).css('color','#ea9028');
                }
            }
        });
    });

    $(document).on('click', ".historial", function()
    {
        var especie_id = $(this).attr('especie_id');
        var comentario_id = $(this).attr('comentario_id');

        $.ajax({
            url: "/especies/" + especie_id + "/comentarios/" + comentario_id,
            method: 'GET'

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

        return false;
    });

    $(document).on('change', "#filtro_categoria_comentario_id", function()
    {
        window.location = $('#filtro_form').attr('action') + "?" + $('#filtro_form').serialize();
    });

    $(document).on('click', "[class^='eliminar_']", function(){
        console.log('aqui');
        return false;
    });

    $('[data-toggle="popover"]').popover();
});
