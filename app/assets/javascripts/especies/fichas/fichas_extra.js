$(document).ready(function() {
    cual_ficha = '';

    $('#taxon_description').on('change', '#from', function () {
        cual_ficha = $(this).val();

        $.ajax({
            url: "/especies/" + TAXON.id + "/describe?from=" + cual_ficha,
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