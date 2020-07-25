var despliegaOcontrae = function (elemento) {
    //var parent = elemento.parent().parent();
    var id = $(elemento).data('taxonId');
    var siguiente_hoja = $(elemento).siblings('.arbol-taxon');
    var hijos = siguiente_hoja.length;

    var icono_fuente = $(elemento).children('i');

    if (hijos > 0) {
        console.log(siguiente_hoja);
        siguiente_hoja.remove();
        $(icono_fuente).toggleClass("fa-caret-up", "fa-caret-down");
        return;
    }

    $.ajax(
        {
            url: "/explora-por-clasificacion/hojas",
            data: {
                especie_id: id,
                ancestros: taxones
            }
        }).done(function (lista) {
            if (lista != '') {
                $(elemento).parent().append(lista);
                $(icono_fuente).toggleClass("fa-caret-up", "fa-caret-down");
            }
        });
};


$(document).ready(function () {
    $('#arbol-taxonomico').on('click', '.nodo-taxon', function () {
        despliegaOcontrae(this);
    });
});