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

$('form').on('focus', '.reg-autocomplete', function () {
    var instancia = $(this).autocomplete( "instance" );
    if (instancia !== undefined) return;

    var reg_id = '#' + $(this).attr('id');
    var region_id = reg_id.replace(/_reg$/, '_region_id');

    $(this).autocomplete({
        minLength: 2,
        source: function( request, response ) {
            $.getJSON( "/admin/regiones/autocompleta", request, function( data, status, xhr ) {
                response( data );
            });
        },
        select: function( event, ui ) {
            $(region_id).val(ui.item.value);
            $(reg_id).val(ui.item.label);
            return false;
        }
    });
});

$('form').on('change', '.select-nivel', function () {
    var nivel_id = '#' + $(this).attr('id');
    var nivel = parseInt(nivel_id.slice(-1));

    var i;
    for(i=nivel+1; i < 6; i++)
    {
        var nivel_siguiente_id = nivel_id.replace(nivel, i);
        console.log(nivel_siguiente_id);
        $(nivel_siguiente_id).find('option').not(':first').remove();

        if(i == nivel+1)
        {
            $.ajax({
                url: "/admin/catalogos/" + especie_id + "/comentarios/" + comentario_id,
                method: 'GET',
                data: {ficha: ficha}

            }).done(function(html) {
                $('#historial_' + comentario_id).empty().append(html).slideDown();
                var link_historial = $( "a[comentario_id='"+ comentario_id +"']");
                link_historial.hide();
                $('#ocultar_' + comentario_id).slideDown();
            });
        }  // end if
    }  // end for
});