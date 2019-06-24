$( document ).ready(function() {

    /* PARA LA PARTE DE LEGISLACIONES */





    // Ocultar todas las opciones de las legislaciones (Se ocultará el div padre que contiene el select de la legislación)
    // $(".fichas_taxon_legislaciones_estatusLegalProteccion").hide();

    // Iterar las legislaciones existentes
    $(".tipo-legislacion").each(function(){
        var legislacion = $(this);
        console.log($(legislacion))
    });





    // Para mostrar sólo las legislaciones relacionadas: (Si es UICN, ostrar sólo sus opciones)




    /* ENDEMICA */
    // Checar el estado de endemica
    var endemicaChecker = $("#endemicaMexico");
    checkEndemica(endemicaChecker.val());
    endemicaChecker.change(function() {
        checkEndemica($(this).val());
    });

    /* ENDEMICA */
    // Checar el estado de endemica
    var vegetacionSecundariaChecker = $("#vegetacion-secundaria");
    checkVegetacionSecundaria(vegetacionSecundariaChecker.val());
    vegetacionSecundariaChecker.click(function() {
        checkVegetacionSecundaria($(this).val());
    });
});








/*
* Oculta el contenido de endemica
* */
function checkEndemica(value){
    if (value === 'no')
        $('#endemicaSI').hide();
    else
        $('#endemicaSI').show();
}


function checkVegetacionSecundaria(value){

    if (value === 'no')
        $('#si-vegetacion-secundaria').hide();
    else
        $('#si-vegetacion-secundaria').show();
}





function hideContent(idContent, value) {

    var cValue = value.val();
    switch (cValue) {
        case 'no':
            $('#' + idContent).hide();
            break;
        default:
            $('#' + idContent).show();
            break;
    }
    console.log(cValue);
}
