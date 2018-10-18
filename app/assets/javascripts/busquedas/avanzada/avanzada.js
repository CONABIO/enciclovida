var por_nombre = function()
{
    $("#id").val("");
    $("#datos_cat").html("");
    $("#panelCategoriaTaxonomicaPt").hide();

    $("[id^='id_']").each(function(){
        $(this).prop('checked', false);
    });

    $('#por_gi, #por_nombre_fuente, #por_gi_fuente, #por_nombre').toggle('easeOutBounce');
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
        $('#id').val(id_gi);
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

    $('#busqueda_avanzada').on('click', '#boton_checklist', function(){
        var url = $(this).attr('url');

        if (url == "") return false;
        else window.open(url, '_blank');
    });

    $("#busqueda_avanzada").on('submit', '#b_avanzada', function() {
        $("#por_gi :input").attr("disabled", true);  // Deshabilita los grupos iconicos para que los repita en la URI
    });

    $(window).load(function(){
        $("html,body").animate({scrollTop: 122}, 1000);
    });
});

