$( document ).ready(function() {

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
    // - - - -

    $('#importancia')

        .on("cocoon:before-remove", function (event) {
            var confirmation = confirm("Estás seguro?");;
            if( confirmation === false ){
                event.preventDefault();
            }
        });
    // - - - -

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

    // - - - -
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
    // - - - -

    // Botones para cargar contenido de la sección X
    $('.boton-seccion').on('click', function(event){
        var idBtn = this.id;
        var seccionACargar = idBtn.replace("boton-", "");
        cargaSeccionEnDiv(seccionACargar, event);
    });
});


$(window).load(function(){

    /* - - - - Una vez cargado el documento: - - - -*/

    // Ocultar las opciones cuando es 'NO'
    ocultaContenidoSiNo();

    // Inicializar el editor de texto TINYMCE
    tinyMCE.init({selector: 'textarea.form-control'});

    // mostrar correctamente el formulario de la sección Ambiente
    showOrHideAmbienteDesarrolloEspecie();

    //  mostrar correctamente el formulario de la sección Biologia
    showOrHideSegunTipoReproduccion();

    // Según el tipo de ficha, mostrar u ocultar el contenido que las diferencia
    muestraSoloApartadoSegunFicha();

});

// Ocultar las opciones cuando es 'NO'
function ocultaContenidoSiNo() {

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
}

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
            $('#boton-prioritaria-conservacion').fadeOut();
            $('#prioritaria-conservacion').fadeOut();

            $('#boton-invasividad').fadeIn();
            $('#invasividad').fadeIn();

        } else {
            $('#boton-prioritaria-conservacion').fadeIn();
            $('#prioritaria-conservacion').fadeIn();

            $('#boton-invasividad').fadeOut();
            $('#invasividad').fadeOut();
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

// Después de cargar una sección, cargar estilos de selectpicker y tinyMCE de toda la sección
function reloadSection(section) {

    // Ocultar las opciones cuando es 'NO'
    ocultaContenidoSiNo();

    if (section === 'biologia') {
        //  mostrar correctamente el formulario de la sección Biologia
        showOrHideSegunTipoReproduccion();
    }

    if (section === 'ambiente') {
        // mostrar correctamente el formulario de la sección Ambiente
        showOrHideAmbienteDesarrolloEspecie();
    }


    muestraSoloApartadoSegunFicha();

    setTimeout(function () {
        $('#' + section + ' .selectpicker').selectpicker('refresh');
        tinyMCE.init({ selector: '#' + section + ' textarea.form-control' });
    }, 10);
}

// Según el tipo de ficha, mostrar u ocultar el contenido que las diferencia
function muestraSoloApartadoSegunFicha() {
    $(".apartadoFicha").fadeOut();
    showOrHideInfoFicha();
}

// Recargan los imputs selectpicker y tinyMCE nuevos
function reload(classe) {
    setTimeout(function () {
        $('.' + classe).selectpicker('refresh');
        tinyMCE.init({ selector: '.tiny_' + classe });
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


// Función para cargar el contenido de una sección en un DIV
function cargaSeccionEnDiv(nombreSeccion, event) {

    // Div a verificar
    var el_div = $("#" + nombreSeccion);
    var cargando = '<p class="text-center"><i class="spin3-ev-icon animate-spin" style="font-size: 3em; color: rgba(128, 0, 0, 0.75);"></i><strong>Cargando sección... Por favor, espera<strong></p>'

    // Verificar si se cargó ya la página
    if( el_div.html() !== "")
        event.preventDefault(); // Detener la llamada si existe contenido
    else {
        // El div se encuentra vacio, pegarle el 'animate-spin' de cargando:
        el_div.html(cargando);
        // Si aún no se cargó el contenido de la sección, verificar la petición (El taxón será uno nuevo o una edición)
        var accion = window.location.pathname.replace("/fichas/taxa/", "");
        var seccionACargar = '/fichas/taxa/cargar_seccion/' +  nombreSeccion +'/';
        // Si el taxón es nuevo:
        if(accion.includes('new')) {
            el_div.load(seccionACargar +' #contenido_' + nombreSeccion, function () {
                reloadSection(nombreSeccion);
            });
        } else {
            if(accion.includes('edit')) {
                seccionACargar += accion.replace("/edit", "");
                el_div.load(seccionACargar +' #contenido_' + nombreSeccion, function () {
                    reloadSection(nombreSeccion);
                });
            }
        }
    }

}

/*
* <p class="text-center">
        <i class="spin3-ev-icon animate-spin" style="font-size: 3em; color: rgba(128, 0, 0, 0.75);"></i>
      <h4>Cargando... Por favor, espera</h4>
      </p>
* */