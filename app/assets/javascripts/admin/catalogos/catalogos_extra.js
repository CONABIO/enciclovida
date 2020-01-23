$('form').on('focus', '.ncient-soulmate', function () {
    var events = $._data( $(this)[0], "events" );

    if (events === undefined)
        soulmateAsigna('admin/catalogos', $(this).attr('id'));
});

$('form').on('focus', '.biblio-autocomplete', function () {
    $(this).autocomplete({
        source: [ "c++", "java", "php", "coldfusion", "javascript", "asp", "ruby" ]
    });
});
