$(document).ready(function() {
    $('#taxon_description').on('change', '#from', function () {
        opciones.cual_ficha = $(this).val();

        $.ajax({
            url: "/especies/" + opciones.taxon + "/describe?from=" + opciones.cual_ficha,
            method: 'get',
            success: function (data, status) {
                $('.taxon_description').replaceWith(data);
            },
            error: function (request, status, error) {
                $('.taxon_description').loadingShades('close');
            }
        });
    });

    $(document).off('click').on('click', "[id^='ficha_']", function () {
        var idFicha = $(this).attr('id').replace("ficha_", "");
        var detalleEstaVacio =  $('#detalle_' + idFicha).is(':empty');

        if (detalleEstaVacio) {
            jQuery.ajax({
                success: function(html){
                    $('#detalle_' + idFicha).html(html);
                },
                fail: function(){
                    $('#detalle_' + idFicha).html('Hubo un error al cargar los datos, por favor intentalo de nuevo.');
                },
                method: 'get',
                url: '/registro_bioteca/' + idFicha
            });

            // Si el detalle está vacío, asumimos que siempre aparecerá: Ver menos detalles
            $("#ficha_" + idFicha).html("<i class='glyphicon glyphicon-minus-sign'></i> Ver menos detalles");

        } else {

            if( $('#detalle_' + idFicha).hasClass( "detalle-oculto" ) ) {
                $("#ficha_" + idFicha).html("<i class='glyphicon glyphicon-minus-sign'></i> Ver menos detalles");
            } else {
                $("#ficha_" + idFicha).html("<i class='glyphicon glyphicon-plus-sign'></i> Ver mas detalles");
            }

            $('#detalle_' + idFicha).toggleClass("detalle-oculto");
        }

        return false;
    });
});

function biotecaLoadPage(page) {

    // Primero, verificamos la página en la que se encuentra
    var paginaEstaVacia =  $('#janium_records-page-' + page).is(':empty');

    $('.page-item').removeClass("active");
    $("#button-janium_records-" + page).addClass("active");

    // Si está vacía, hayq ue invocar al servicio web para agregare la info
    if (paginaEstaVacia) {
        console.log(page)

    } else {

        $('.janium_records').addClass("janium_records-not-show");

        // Si no está vacia, sólo hay que mostrar el div
        $('#janium_records-page-' + page).removeClass("janium_records-not-show");
        console.log(page)
    }


}