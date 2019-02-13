/**
 * Autocompleta el tipo de propiedad
 */
var dameTipoPropiedad = function () {
    $("#pmc_propiedad_tipo_propiedad").autocomplete({
        source: function( request, response ) {
            $.ajax( {
                url: "/pmc/propiedades/dame-tipo-propiedades/" + request.term,
                dataType: "json",
                success: function( data ) {
                    response( data );
                }
            } );
        },
        minLength: 2,
        select: function( event, ui ) {
            $('#pmc_propiedad_tipo_propiedad').val(ui.item.id);
        }
    });
};

$('#content').ready(function(){
    dameTipoPropiedad();
});