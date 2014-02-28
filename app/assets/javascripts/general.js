/**
 * Created with JetBrains RubyMine.
 * User: calonso
 * Date: 1/27/14
 * Time: 4:11 PM
 * To change this template use File | Settings | File Templates.
 */

$(document).ready(function(){
    open = function(event, ui){
        var $input = $(event.target),
            $results = $input.autocomplete("widget"),
            top = $results.position().top,
            height = $results.height(),
            inputHeight = $input.height(),
            newTop = top - height - inputHeight;

        $results.css("top", newTop + "px");
    }
});


