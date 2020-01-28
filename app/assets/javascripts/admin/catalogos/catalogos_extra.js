$('form').on('focus', '.ncient-soulmate', function () {
    var events = $._data( $(this)[0], "events" );

    if (events === undefined)
        soulmateAsigna('admin/catalogos', $(this).attr('id'));
});

$('form').on('focus', '.biblio-autocomplete', function () {
    var instancia = $(this).autocomplete( "instance" );
    if (instancia !== undefined) return;

    var biblio_id = '#' + $(this).attr('id');
    var bibliografia_id = biblio_id.replace(/_biblio$/, '_bibliografia_id');

    $(this).autocomplete({
        minLength: 2,
        source: function( request, response ) {
            $.getJSON( "/admin/bibliografias/autocompleta", request, function( data, status, xhr ) {
                response( data );
            });
        },
        select: function( event, ui ) {
            $(bibliografia_id).val(ui.item.value);
            $(biblio_id).val(ui.item.label);
            return false;
        }
    });
});
