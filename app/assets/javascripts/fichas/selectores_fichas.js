$( document ).ready(function() {

    // Inicializar el editor de texto TINYMCE
    tinyMCE.init({
        selector: 'textarea.form-control'
    });

    // Mostrar u ocultar contenido SEGÚN opciones SI / NO cuando se cargue la  página
    casos = ['endemicaSI', 'vegetacion-secundaria', 'especie-prioritaria', 'dimorfismoSexualAnimal', 'hibernacionSI', 'territorialidadSI'];
    for(var i = 0; i < casos.length; i++) {
        var elID = casos[i];
        var selector = "input[name='opcion-" + casos[i] + "']:checked";
        if ($(selector).val() !== undefined)
            showOrHideByName($(selector).val(), elID);
    }

    // Para mostrar correctamente el formulario de la sección Ambiente
    showOrHideAmbienteDesarrolloEspecie();
    //  Para mostrar correctamente el formulario de la sección Biologia
    showOrHideSegunTipoReproduccion();
});

$(window).load(function(){
    $(".apartadoFicha").fadeOut();
    showOrHideInfoFicha();
});


/*
* Ocultar el contenido relacionado a fichas específicas:
* */
function showOrHideInfoFicha() {
    var tipoFicha = $("input[name='selectorDeFicha']:checked").val();
    if(tipoFicha !== undefined) {
        // Ocultar todos los apartadosFicha
        $(".apartadoFicha").fadeOut();

        // Mostar el título correspondiente para la pestaña IX:
        if(tipoFicha === 'Invasora') {
            $('#pestania-IX').html('Especies invasoras');
        } else {
            $('#pestania-IX').html('Especies prioritarias');
        }

        // Construir la clase según el tipo de ficha
        var claseFicha = 'ficha-' + tipoFicha;
        // Mostrar el ID según la clase generada
        $('.' + claseFicha).fadeIn();
    }
}


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

// Función para mostrar las preguntas correspondientes al ambiente de desarrollo de la especie (sección ambiente)
function showOrHideAmbienteDesarrolloEspecie() {
    var selector = "input[name='" + 'opcion-AmbienteDesarrolloEspecie' + "']:checked";
    var theValue = $(selector).val();
    var ambienteTerrestre = '#ambiente-solo-terrestre';
    var ambienteMarino = '#ambiente-solo-marino';
    if (theValue !== undefined) {
        switch (theValue) {
            case 'terrestre':
                $(ambienteTerrestre).fadeIn();
                $(ambienteMarino).fadeOut();
                break;
            case 'acuático':
                $(ambienteTerrestre).fadeOut();
                $(ambienteMarino).fadeIn();
                break;
            default:
                $(ambienteTerrestre).fadeIn();
                $(ambienteMarino).fadeIn();
                break;
        }
    }
}

// Función para mostrar las preguntas correspondientes al tipo de reproducción de la especie (sección biologia)
function showOrHideSegunTipoReproduccion() {
    var selector = "input[name='" + 'opcion-TipoReproduccion' + "']:checked";
    var theValue = $(selector).val();
    var reprodAnimal = '#opcion-reprodAnimal';
    var reprodVegetal = '#opcion-reprodVegetal';
    if (theValue !== undefined) {
        if (theValue === 'animal') {
            $(reprodAnimal).fadeIn();
            $(reprodVegetal).fadeOut();
        } else {
            $(reprodAnimal).fadeOut();
            $(reprodVegetal).fadeIn();
        }
    }

}


function reload(div) {
    console.log(div);
    //$("#" + div).selectpicker('refresh');
    setTimeout(function () {
        $('.selectpicker').selectpicker('refresh');
    }, 10)
}

function reloadTiny() {
    console.log("div");
    tinymce.remove();
    setTimeout(function () {
        tinyMCE.init({
            selector: 'textarea.form-control'
        });
    }, 10)

}

