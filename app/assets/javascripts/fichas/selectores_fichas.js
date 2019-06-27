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





    // Mostrar u ocultar contenido cuando se cargue la  página
    casos = ['endemicaSI', 'vegetacion-secundaria', 'especie-prioritaria'];

    for(var i = 0; i < casos.length; i++) {
        var elID = casos[i];
        var selector = "input[name='opcion-" + casos[i] + "']:checked";
        if ($(selector).val() !== undefined)
            showOrHideByName($(selector).val(), elID);
    }
});


/*
* Oculta el contenido: recibe el elemento y el div a ocultar
* */
function showOrHide(elem, iDIV) {
    if (elem.value === 'no')
        $('#' + iDIV).fadeOut();
    else
        $('#' + iDIV).fadeIn();
}

/*
* Oculta el contenido: recibe el valor y el div a ocultar
* */
function showOrHideByName(name, iDIV) {
    if (name === 'no')
        $('#' + iDIV).fadeOut();
    else
        $('#' + iDIV).fadeIn();
}



