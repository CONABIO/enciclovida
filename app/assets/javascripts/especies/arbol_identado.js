var despliegaOcontrae = function(elemento)
{
    var id = elemento.attr('taxon_id');
    var ul = $('ul_' + id);

    if (ul.length > 0)
    {
        var minus = $('#span_' + id).hasClass("glyphicon-minus");

        if (minus)
            $('#span_' + sufijo).removeClass("glyphicon-minus").addClass("glyphicon-plus");

        $("#nodo_" + id + " li").remove();

    } else {
        $.ajax(
            {
                url: "/especies/" + id + "/arbol_identado_hojas"
            }).done(function(lista)
            {
                if (lista != '')
                {
                    console.log('aqui')
                    var plus = $('#span_' + id).hasClass("glyphicon-plus");

                    if (plus)
                        $('#span_' + id).removeClass("glyphicon-plus").addClass("glyphicon-minus");

                    $("#ul_" + id).parent().append(lista);
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