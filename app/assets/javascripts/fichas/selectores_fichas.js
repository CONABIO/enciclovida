$( document ).ready(function() {
    console.log( "ready!" );
});


/*
* Oculta el contenido de endemica
* */
function hideContent(idContent, value) {

    var cValue = value.val();
    switch (cValue) {
        case 'true':
            $('#' + idContent).show();
            break;
        case 'false':
            $('#' + idContent).hide();
            break;
        default:
            $('#' + idContent).hide();
            break;
    }
    console.log(cValue);
}


$('.select-legi').css('display', 'none');
