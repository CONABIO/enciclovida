function soulmateExoticas() {

    var render = function(term, data) {

        data.nombre_cientifico = limpiar(data.nombre_cientifico);

        if (data.nombre_comun == null) {
            var nombres =
                '<a href="" class="not-active">' +
                data.nombre_cientifico +
                "</a>";
        } else {
            var nombres =
                "<b>" +
                primeraEnMayuscula(data.nombre_comun) +
                " </b><sub>" +
                data.lengua +
                '</sub><a href="" class="not-active">' +
                data.nombre_cientifico +
                "</a>";
        }

        if (data.foto == null) {
            var foto = '<i class="soulmate-img ev1-ev-icon pull-left"></i>';
        } else {
            var foto =
                "<i class='soulmate-img pull-left' style='background-image:url(\"" +
                data.foto +
                "\")'></i>";
        }

        return foto + " " + nombres;
    };

    var select = function(term, data) {

        $("#exotica_invasora_especie_id").val(data.id);

        $("#nombre_cientifico").val(data.nombre_cientifico);

        $("#soulmate-nombre_cientifico").hide();

    };

    $("#nombre_cientifico").soulmate({
        url: SITE_URL + "sm/search",
        types: TYPES,
        renderCallback: render,
        selectCallback: select,
        minQueryLength: 2,
        maxResults: 5
    });

}

$(document).on("turbolinks:load", function () {
    soulmateExoticas();
});