(function($) {

	$.fn.scrollPagination = function(options) {
		
		var settings = { 
			per_page: 10, // The number of posts per scroll to be loaded
			page    : 1, // The page
			error   : 'No More Posts!', // When the user reaches the end this is the message that is
			                            // displayed. You can change this if you want.
			delay   : 500, // When you scroll down the posts will load after a delayed amount of time.
			               // This is mainly for usability concerns. You can alter this as you see fit
			scroll  : true // The main bit, if set to false posts will not load as the user scrolls. 
			               // but will still load if the user clicks.
		};
		
		// Extend the options so they work with the plugin
		if(options) {
			$.extend(settings, options);
		}
		
		// For each so that we keep chainability.
		return this.each(function() {		
			
			// Some variables 
			$this = $(this);
			$settings = settings;
			var page = $settings.page;
			var busy = false; // Checks if the scroll action is happening
			                  // so we don't run it multiple times

            if(settings.scroll == true) initmessage = 'Cargando... Por favor, espera <i class="spin6-ev-icon animate-spin" style="font-size: 3em; color: rgba(128, 0, 0, 0.75);"></i>';
            else initmessage = 'Click for more';

			
			function getData()
            {
                $('#loading-bar').remove();
                $this.append("<div class='loading-bar col-xs-12 col-sm-12 col-md-12 col-lg-12' id='loading-bar'>" +initmessage+'</div>');

				// Post data to ajax.php
				$.get('/comentarios/administracion', {
				    por_pagina    : $settings.per_page,
				    pagina        : page + 1
				}, function(data) {

                    // Change loading bar content (it may have been altered)
                    $('#loading-bar').html(initmessage);
						
					// If there is no data returned, there are no more posts to be shown. Show error
					if(data == "") {
                        $('#loading-bar').html(settings.error);
					}
					else {
						
						// page increases
					    page++;

						// Append the data to the content div
					   	$this.append(data);
                        $('#loading-bar').remove();
						
						// No longer busy!	
						busy = false;
					}	
						
				});
					
			}	

			// If scrolling is enabled
			if($settings.scroll == true) {
				// .. and the user is scrolling
				$(window).scroll(function() {
					
					// Check the user is at the bottom of the element
                    if($(window).scrollTop() + $(window).height() == $(document).height() && !settings.busy) {
						
						// Now we are working, so busy is true
						busy = true;

                        // Tell the user we're loading posts
                        $('#loading-bar').html('Cargando ...');

						// Run the function to fetch the data inside a delay
						// This is useful if you have content in a footer you
						// want the user to see.
						setTimeout(function() {
							
							getData();
							
						}, $settings.delay);
							
					}	
				});
			}
			
			// Also content can be loaded by clicking the loading bar/
			$this.find('#loading-bar').click(function() {
			
				if(busy == false) {
					busy = true;
					getData();
				}
			
			});
			
		});
	}

})(jQuery);
