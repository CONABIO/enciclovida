var por_nombre = function()
{
    $("#panelCategoriaTaxonomicaPt").hide();

    if (I18n.locale == 'es'){
        $('#por_gi, #por_nombre_fuente, #por_gi_fuente, #por_nombre').toggle('easeOutBounce');

        $("[id^='id_']").each(function(){
            $(this).prop('checked', false);
        });
    }
};

var por_gi = function()
{
    $("#id").val("");
    $("#nombre").val('');
    $("#datos_cat").html("");
    $("#panelCategoriaTaxonomicaPt").hide();

    $('#por_gi, #por_nombre_fuente, #por_gi_fuente, #por_nombre').toggle('easeOutBounce');
};

var cat_tax_asociadas = function(id,nivel,cat)
{
    $.ajax(
        {
            url: "/cat_tax_asociadas",
            type: 'GET',
            data: {
                id: id,
                nivel: nivel,
                cat: cat
            }
        }).done(function(html)
    {
        $('#datos_cat').html('').html(html);
        $('#panelCategoriaTaxonomicaPt').show();
    });
};

$(document).ready(function()
{
    $('#busqueda_avanzada').on('change', ".radio input", function()
    {
        // El ID del grupo iconico
        var id_gi = $(this).val();
        cat_tax_asociadas(id_gi,'','');
    });

    $('#busqueda_avanzada').on('click', '#limpiar', function(){
        window.location.href = "/avanzada";
    });

    $('#busqueda_avanzada').on('click', '#por_nombre_fuente', function(){
        por_nombre();
        return false;
    });

    $('#busqueda_avanzada').on('click', '#por_gi_fuente', function(){
        por_gi();
        return false;
    });

    $('#busqueda_avanzada').on('click', '#boton-enviar-checklist', function(){
        var url = $(this).attr('url');

        if (url == "") return false;
        else window.open(url, '_blank');
    });

    if ($('#id').val() != '') por_nombre();
});

