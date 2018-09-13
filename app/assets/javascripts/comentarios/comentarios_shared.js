/**
 * Despliega el historial de conversacion del comentario en cuestion
 * @param $(this)
 * @returns {boolean}
 */
var muestra_historial_comentario = function (elem)
{
    $('#' + elem).on('click', ".historial", function()
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
};

/**
 * Oculta el historial de conversacion del comentario en cuestion
 * @param $(this)
 * @returns {boolean}
 */
var oculta_historial_comentario = function (elem)
{
    $('#' + elem).on('click', "[id^='ocultar_']", function () {
        var comentario_id = $(this).attr('id').split("_")[1];
        var link_historial = $("a[comentario_id='" + comentario_id + "']");

        $('#historial_' + comentario_id).hide();
        $('#ocultar_' + comentario_id).hide();
        link_historial.slideDown();
        return false;
    });
};