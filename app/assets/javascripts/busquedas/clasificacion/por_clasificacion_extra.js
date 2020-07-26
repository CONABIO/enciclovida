var despliegaOcontrae = function(button){
    var button = $(button);
    var sub_arbol = button.siblings('.arbol-taxon');

    button.children('i').toggleClass(["fa-caret-up", "fa-caret-down"]);

    if(sub_arbol.length == 0 && !button.data('hoja')){
        $.get("/explora-por-clasificacion/hojas?especie_id="+button.data('taxonId'), function (data) {
            button.after(data);
        });
    }else{
        sub_arbol.remove();
    }
};
