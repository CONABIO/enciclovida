var despliegaOcontrae = function (elemento){
    var elemento = $(elemento)
    var siguiente_hoja = $(elemento).siblings('.arbol-taxon');
    var hijos = siguiente_hoja.length;

    var caret = elemento.children('i');

    if (hijos > 0){
        siguiente_hoja.remove();
        caret.toggleClass(["fa-caret-up", "fa-caret-down"]);
        return;
    }

    $.ajax({
        url: "/explora-por-clasificacion/hojas",
        data: {
            especie_id: elemento.data('taxonId'),
            ancestros: taxones
        }
    }).done(function (lista){
        if (lista != ''){
            elemento.after(lista);
            caret.toggleClass(["fa-caret-up", "fa-caret-down"]);
        }
    });
};


/*
$(document).ready(function (){
    $('#arbol-taxonomico').on('click', '.nodo-taxon', function (){
        despliegaOcontrae(this);
    });
});*/
