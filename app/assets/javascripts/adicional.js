$(document).ready(function(){
    $(document).on('change', "#adicional_select_nom_comun", function()
    {
        if ($(this).val() == 'Otro')
        {
            $('#adicional_text_nom_comun').attr('disabled', false);
        } else {
            $('#adicional_text_nom_comun').attr('disabled', true) ;
        }
    });
});