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
});