$( document ).ready(function() {

    // Inicializar el editor de texto TINYMCE
    tinyMCE.init({
        selector: 'textarea.form-control'
    });

    // Mostrar u ocultar contenido SEGÚN opciones SI / NO cuando se cargue la  página
    casos = [
        'fichas_taxon[endemicas_attributes][0][endemicaMexico]',
        'endemicaSI',
        'fichas_taxon[habitats_attributes][VegetacionSecundaria]',
        'vegetacion-secundaria',
        'fichas_taxon[prioritaria]',
        'especie-prioritaria',
        'fichas_taxon[historiaNatural_attributes][reproduccionAnimal_attributes][dimorfismoSexual]',
        'dimorfismoSexualAnimal',
        'fichas_taxon[historiaNatural_attributes][hibernacion]',
        'hibernacionSI',
        'fichas_taxon[historiaNatural_attributes][territorialidad]',
        'territorialidadSI',
        'fichas_taxon[historiaNatural_attributes][reproduccionAnimal_attributes][cuidadoParental]',
        'cuidadoParentalAnimal'
    ];

    for(var i = 0; i < casos.length; i+=2) {
        var elID = casos[i+1];
        var selector = "input[name='" + casos[i] + "']:checked";
        if ($(selector).val() !== undefined)
            showOrHideByName($(selector).val(), elID);
    }
    // - - - - - - - - - - - - - - - - - - -  --  - - - - - - - - -  - - -

    // Para mostrar correctamente el formulario de la sección Ambiente
    showOrHideAmbienteDesarrolloEspecie();

    //  Para mostrar correctamente el formulario de la sección Biologia
    showOrHideSegunTipoReproduccion();

    // - - - - - - - - - - - - - - - - - - -  --  - - - - - - - - -  - - -

    // LISTENERS PARA COOCON
    $('#clasificacion-descripcion')
        .on('cocoon:before-insert', function (event) {
            // Antes de insertar una legislación, verificar el total (máximo 4)
            var legislaciones = document.getElementsByClassName("nueva_legislacion").length;
            if (legislaciones > 3){
                confirm("No pueden haber más de 4 legislaciones");
                event.preventDefault();
            }
        })

        .on("cocoon:before-remove", function (event) {
            var confirmation = confirm("Estás seguro?");
            if( confirmation === false ){
                event.preventDefault();
            }
        });

    $('#importancia')

        .on("cocoon:before-remove", function (event) {
            var confirmation = confirm("Estás seguro?");;
            if( confirmation === false ){
                event.preventDefault();
            }
        });

    $('#opcion-reprodAnimal')
        .on('cocoon:before-insert', function (event) {
            // Antes de agregar información animal, verificr que no exista antes
            var hay_rep = document.getElementsByClassName("reproduccionAnimal_add").length;
            if (hay_rep > 0){
                confirm("Ya puedes seguir completando el formulario!");
                event.preventDefault();
            }
        })

        .on("cocoon:before-remove", function (event) {
            var confirmation = confirm("Estás seguro?");
            if( confirmation === false ){
                event.preventDefault();
            }
        });

    $('#opcion-reprodVegetal')
        .on('cocoon:before-insert', function (event) {
            // Antes de agregar información animal, verificr que no exista antes
            var hay_rep = document.getElementsByClassName("reproduccionVegetal_add").length;
            if (hay_rep > 0){
                confirm("Ya puedes seguir completando el formulario!");
                event.preventDefault();
            }
        })

        .on("cocoon:before-remove", function (event) {
            var confirmation = confirm("Estás seguro?");
            if( confirmation === false ){
                event.preventDefault();
            }
        });
});

$(window).load(function(){
    //$(".apartadoFicha").fadeOut();
    //showOrHideInfoFicha();
});


/*
* Ocultar el contenido relacionado a fichas específicas:
* */
function showOrHideInfoFicha() {
    var tipoFicha = $("input[name='fichas_taxon[tipoficha]']:checked").val();
    //console.log("La ficha actual es: " + tipoFicha);
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
    var selector = "input[name='" + 'fichas_taxon[habitats_attributes][tipoAmbiente]' + "']:checked";
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
    var selector = "input[name='" + 'fichas_taxon[historiaNatural_attributes][tipoReproduccion]' + "']:checked";
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

// Recargan los imputs selectpicker y tinyMCE nuevos
function reload(classe) {
    setTimeout(function () {
        $('.' + classe).selectpicker('refresh');
        reloadTiny(classe);
    }, 10)
}

function reloadTiny(classe) {
    setTimeout(function () {
        tinyMCE.init({
            selector: '.tiny_' + classe
        });
    }, 10)
}

// Para que los valores min y max sean correctos
function checkValues(e) {

    var nombreFinal = e.name;
    var nombreInicial = nombreFinal.replace("final", "inicial");

    var vmax = Number(document.getElementsByName(nombreFinal)[0].value);
    var vmin = Number(document.getElementsByName(nombreInicial)[0].value);

    if (vmax != 0) {
        if (vmax < vmin){
            document.getElementsByName(nombreFinal)[0].value = '';
            alert('El campo M\xe1ximo debe ser mayor que el campo M\xednimo');
            document.getElementsByName(nombreFinal)[0].focus();
            return false;
        }
    }
}

// Para asegurar las clasificaciones correctas
function cambiaLegislaciones(e) {

    var idSelect = $(e).attr('id');
    var selectedOption = $(e).val();
    var idOptionsSelect = idSelect.replace("nombreLegislacion", "estatusLegalProteccion");

    $('#' + idOptionsSelect).find('option').removeAttr("selected");

    if ( selectedOption.includes("SEMARNAT")) {
        $('#' + idOptionsSelect +  ' optgroup[label="SEMARNAT"]').prop('hidden', false);
        $('#' + idOptionsSelect +  ' optgroup[label="UICN"]').prop('hidden', true);
        $('#' + idOptionsSelect +  ' optgroup[label="CITES"]').prop('hidden', true);
    }

    if ( selectedOption.includes("UICN")) {
        $('#' + idOptionsSelect +  ' optgroup[label="SEMARNAT"]').prop('hidden', true);
        $('#' + idOptionsSelect +  ' optgroup[label="UICN"]').prop('hidden', false);
        $('#' + idOptionsSelect +  ' optgroup[label="CITES"]').prop('hidden', true);
    }

    if ( selectedOption.includes("CITES")) {
        $('#' + idOptionsSelect +  ' optgroup[label="SEMARNAT"]').prop('hidden', true);
        $('#' + idOptionsSelect +  ' optgroup[label="UICN"]').prop('hidden', true);
        $('#' + idOptionsSelect +  ' optgroup[label="CITES"]').prop('hidden', false);
    }

    reload('seccion_clasificacion');
}
