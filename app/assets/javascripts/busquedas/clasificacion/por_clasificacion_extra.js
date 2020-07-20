var despliegaOcontrae = function (elemento) {
    var parent = elemento.parent().parent();
    var id = parent.attr('id').split('-')[2];
    var hijos = parent.children().length
    var siguiente_hoja = parent.children('.ml-3');
    var icono_fuente = elemento.children('i');

    if (hijos > 1) {
        siguiente_hoja.remove();
        $(icono_fuente).removeClass("fa-caret-up", "fa-caret-down").addClass("fa-caret-down");
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
                parent.append(lista);
                $(icono_fuente).removeClass("fa-caret-up", "fa-caret-down").addClass("fa-caret-up");
            }
        });
};

// REVISADO: Para desplegar o contraer el arbol identado en ficha de la espcie
var despliegaOcontrae_orig = function (elemento) {
    var id = elemento.attr('taxon_id');
    var ul = $('#ul_' + id);
    var hijos = $('#ul_' + id).children().children('ul');

    if (hijos.size() > 0)  // Existe algun hijo
    {
        var minus = $('#span_' + id).hasClass("fa-caret-up");

        if (minus)
            $('#span_' + id).removeClass("fa-caret-up").addClass("fa-caret-down");

        hijos.remove();

    } else {
        $.ajax(
            {
                url: "/especies/" + id + "/arbol_identado_hojas"
            }).done(function (lista) {
                if (lista != '') {
                    var plus = $('#span_' + id).hasClass("fa-caret-down");

                    if (plus)
                        $('#span_' + id).removeClass("fa-caret-down").addClass("fa-caret-up");

                    hijos.remove();
                    $(elemento).parent().append(lista);
                }
            });
    }
};

$(document).ready(function () {
    $('#arbol-taxonomico').on('click', '.clas-plus', function () {
        despliegaOcontrae($(this));
        return false;
    });
});