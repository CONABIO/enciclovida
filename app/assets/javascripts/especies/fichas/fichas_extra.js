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

    $(document).on('click', "[id^='ficha_']", function () {
        var idFicha = $(this).attr('id').replace("ficha_", "");
        var detalleEstaVacio =  $('#detalle_' + idFicha).is(':empty');
        console.log("La ficha a buscar será: " + idFicha);

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
        } else {

        }

        return false;
    });

});