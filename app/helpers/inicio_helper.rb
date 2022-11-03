module InicioHelper

	def insertaVideo videoCode
		"<div class='embed-responsive embed-responsive-16by9'>\n
		<iframe class='embed-responsive-item' src='https://www.youtube.com/embed/#{videoCode}' title='YouTube video player' allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture' allowfullscreen></iframe>\n
	  </div>".html_safe
	end

end
