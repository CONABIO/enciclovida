/**
 * Created with JetBrains RubyMine.
 * User: calonso
 * Date: 1/27/14
 * Time: 4:11 PM
 * To change this template use File | Settings | File Templates.
 */

$(document).ready(function()
{
    open = function(event, ui)
    {
        var $input = $(event.target),
            $results = $input.autocomplete("widget"),
            top = $results.position().top,
            height = $results.height(),
            inputHeight = $input.height(),
            newTop = top - height - inputHeight;

        $results.css("top", newTop + "px");
    }

    muestraArbol = function(id)
    {
        $.ajax(
            {
            url: "/especies/muestraTaxonomia",
            data: {
                id: id
            },
            type: 'post'
        }).done(function(arbol)
            {
                return $("#vista_arbol").html(arbol);
            });
    };

    despliegaOcontrae = function(id) {
        var sufijo;
        sufijo = id.substring(5);
        if ($("#nodo_" + sufijo + " li").length > 0)
        {
            $("#nodo_" + sufijo + " li").remove();
        } else {
            $.ajax(
                {
                url: "/especies/buscaDescendientes",
                data: {
                    id: sufijo
                }
            }).done(function(nodo)
                {
                    return $("#nodo_" + sufijo).append(nodo);
                });
        }
        return false;
    };
});


