settings = {
    nop     : 100, // The number of posts per scroll to be loaded
    offset  : 2, // Initial offset, begins at 2 in this case
    error   : '¡Has llegado al final de los resultados!', // When the user reaches the end this is the message that is
                                // displayed. You can change this if you want.
    delay   : 500, // When you scroll down the posts will load after a delayed amount of time.
                   // This is mainly for usability concerns. You can alter this as you see fit
    scroll  : true, // The main bit, if set to false posts will not load as the user scrolls.
    // but will still load if the user clicks.
    url     : '',   //URL del request
    busy    : false
};

(function($) {

    $.fn.scrollPagination = function(options) {

        // Extend the options so they work with the plugin
        if(options) {
            $.extend(settings, options);
        }

        // For each so that we keep chainability.
        return this.each(function() {

            if(settings.scroll == true) initmessage = 'Cargando... Por favor, espera <i class="spin3-ev-icon animate-spin" style="font-size: 3em; color: rgba(128, 0, 0, 0.75);"></i>';
            else initmessage = 'Clic para cargar más';

            function getData() {
                $this = $("#resultados-" + settings.cat);
                $('#loading-bar-' + settings.cat).remove();
                $this.append("<div class='loading-bar col-xs-12 col-sm-12 col-md-12 col-lg-12' id='loading-bar-" + settings.cat + "'>" + initmessage+'</div>');

                $.get(settings.url, {
                    pagina: settings.offset
                }, function(data) {
                    // Change loading bar content (it may have been altered)
                    $('#loading-bar-' + settings.cat).html(initmessage);

                    // If there is no data returned, there are no more posts to be shown. Show error
                    if(data == "") {
                        $('#loading-bar-' + settings.cat).html(settings.error);
                        settings.busy = false;  // Parche para que cuando acabe un scrolling de un TAB, siga cargando otros
                    }
                    else {
                        // Offset increases
                        settings.offset++;// = settings.offset + 1;
                        offset[settings.cat] = settings.offset;
                        //eval("offset."+settings.cat + "=" + settings.offset);
                        $this.append(data);
                        $('#loading-bar-' + settings.cat).remove();

                        // No longer busy!
                        settings.busy = false;
                    }
                });
            }

            $this = $("#resultados-" + settings.cat);

            // If scrolling is enabled
            if(settings.scroll == true) {
                // .. and the user is scrolling
                $(window).scroll(function() {
                    var $this = $("#resultados-" + settings.cat);

                    // Check the user is at the bottom of the element
                    if($(window).scrollTop() + $(window).height() + 400  > $(document).height() && !settings.busy) {

                        // Now we are working, so busy is true
                        settings.busy = true;

                        // Tell the user we're loading posts
                        $('#loading-bar-' + settings.cat).html('Cargando... Por favor, espera <i class="spin3-ev-icon animate-spin" style="font-size: 3em; color: rgba(128, 0, 0, 0.75);"></i>');

                        // Run the function to fetch the data inside a delay
                        // This is useful if you have content in a footer you
                        // want the user to see.
                        setTimeout(function() {
                            getData();
                        }, settings.delay);

                    }
                });
            }

            // Also content can be loaded by clicking the loading bar/
            $this.find("#resultados-" + settings.cat + '.loading-bar').click(function() {
                if(settings.busy == false) {
                    settings.busy = true;
                    getData();
                }
            });
        });
    }

})(jQuery);
