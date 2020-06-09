// REVISADO: Para desplegar o contraer el arbol identado en ficha de la espcie
var despliegaOcontrae = function(elemento)
{
    var id = elemento.attr('taxon_id');
    var ul = $('#ul_' + id);
    var hijos = $('#ul_' + id).children().children('ul');

    if (hijos.size() > 0)  // Existe algun hijo
    {
        var minus = $('#span_' + id).hasClass("fa-minus");

        if (minus)
            $('#span_' + id).removeClass("fa-minus").addClass("fa-plus");

        hijos.remove();

    } else {
        $.ajax(
            {
                url: "/especies/" + id + "/arbol_identado_hojas"
            }).done(function(lista)
        {
            if (lista != '')
            {
                var plus = $('#span_' + id).hasClass("fa-plus");

                if (plus)
                    $('#span_' + id).removeClass("fa-plus").addClass("fa-minus");

                hijos.remove();
                $(elemento).parent().append(lista);
            }
        });
    }
};

$(document).ready(function(){
    $('#arbol').on('click', '.sub_link_taxon', function(){
        despliegaOcontrae($(this));
        return false;
    });
});