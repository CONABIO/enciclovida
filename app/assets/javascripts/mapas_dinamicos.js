$(document).ready(function() {

    map = new GMaps({
        div: '#map',
        zoom: 5,
        lat: 19.29478848,
        lng: -99.65630269,
        mapTypeId:google.maps.MapTypeId.HYBRID,
        height: "500px",
        width:	"100%"
    });


    //console.log('Ya cree el Mapa donde se dibujaran las capas KML(Z)');

    MAPAS = new Array (	["http://www.conabio.gob.mx/informacion/gis/maps/api/kml?nc=Panthera%20onca","Colonias de Mariposas"]);

    for (var i = 0; i<MAPAS.length;i++){
        infoWindow =	new google.maps.InfoWindow({});
        MAPAS[i][2]	=	function(direccion){
            return	map.loadFromKML({
                url: direccion,
                preserveViewport: true,
                suppressInfoWindows: true,
                events:{
                    click: function(point){
                        anchoInfo = function(){
                            return parseInt($("#map").width()/5)*4;
                        };
                        altoInfo = function(){
                            return parseInt($("#map").height()/10)*9;
                        };
                        if(point.featureData.infoWindowHtml.indexOf('$[description]')>-1){
                            infoWindow.setContent("<div id='balloon' style='max-height: "+altoInfo()+"px; max-width: "+anchoInfo()+"px;'>"+point.featureData.name+"</div>");
                            infoWindow.maxWidth = 2;
                        }else{
                            infoWindow.setContent("<div id='balloon' style='max-height: "+altoInfo()+"px; max-width: "+anchoInfo()+"px;'>"+point.featureData.infoWindowHtml+"</div>");
                        };
                        infoWindow.setPosition(point.latLng);
                        infoWindow.open(map.map);
                        $(function(){
                            $("#balloon div").removeAttr("style");
                        });
                    }
                }
            });
        }
    }

    //console.log('Ya cargue los KML(Z) como Funciones en MAPAS en el indice [2]()');

    /*****************************************************************************************************************/

    cambiaEstado = function(input,indice){
        if(input.checked){
            MAPAS[indice][2](MAPAS[indice][0]).setMap(map.map);
        }else{
            for(var i = 0 ; i<map.layers.length;i++){
                //console.log('Encontre Coincidencia: '+MAPAS[indice][0]+' == '+map.layers[i].url+' Procedo a borrar');
                if(MAPAS[indice][0]==map.layers[i].url){
                    layer = map.layers[i];
                    map.removeLayer(layer);
                }else{
                    //console.log('No encontre la capa a borrar');
                }
            }
        }
    }


    function anadeLista(){
        //console.log('Añadire los elementos de la lista');
        var x = '';
        for (var i=0; i<MAPAS.length; i++) {
            //console.log(MAPAS[i][1]);
            if (i == 0){   //para el default
                x= x+'<li style="list-style: none;"><input type="checkbox" onChange="cambiaEstado(this,'+i+')" checked></input><label>'+MAPAS[i][1]+'</label></li>';
                MAPAS[i][2](MAPAS[i][0]).setMap(map.map);
            } else
                x= x+'<li style="list-style: none;"><input type="checkbox" onChange="cambiaEstado(this,'+i+')"></input><label>'+MAPAS[i][1]+'</label></li>';
        }
        return x;
    }

    function anadeControlCapas(){
        //console.log('Inserto el control de cambio de capa');
        map.addControl({
            position: 'right_bottom',
            content: 	'<div class="gmapv3control overlaycontrol" id="capas" style="padding: 5px;">'+
                '<span class="ui-icon ui-icon-grip-diagonal-se">HOLA</span>'+
                '<ul id="lista_capas" style="display: none; margin-left: 20px; margin-right: 10px; padding: 0px;">.:Mapas Mariposa Monarca:.'+
                anadeLista()+
                '</ul>'+
                '</div>',
            style: {
                margin: '5px',
                padding: '0 0 0 0',
                border: 'solid 1px #717B87',
                background: '#fff'
            },
            events: {
                mouseover: function(){
                    var controlUI = $('#capas');
                    controlUI.addClass('open');
                    $('#lista_capas').show();
                },
                mouseout: function(){
                    var controlUI = $('#capas');
                    controlUI.removeClass('open')
                    $('#lista_capas').hide()
                }
//						click: function(){
//							$('#capas').toggleClass("open");
//							$('#lista_capas').toggle();
//						}
            }
        });
    }

    function anadeControlFullScreen(){
        //console.log('Inserto el control de cambio de capa');
        map.addControl({
            position: 'top_right',
            content: 	'<div class="gmapv3control overlaycontrol" id="capas" style="padding: 1px;">'+
                '<span class="ui-icon ui-icon-arrow-4-diag">HOLA</span>'+
                '</div>',
            style: {
                margin: '3px',
                padding: '0 0 0 0',
                border: 'solid 1px #717B87',
                background: '#fff'
            },
            events: {
                click: function(){
                    $("#map").toggleClass("fullscreen");
                    if(document.getElementById("map").style.position=="relative"){
                        document.getElementById("map").style.position="fixed";
                        document.getElementById("map").style.height="100%";
                    }	else{
                        document.getElementById("map").style.position="relative"
                        document.getElementById("map").style.height="500px";
                    }
                    google.maps.event.trigger(map.map, 'resize');
                }
            }
        });
    }

    anadeControlFullScreen();
    anadeControlCapas();
    //document.getElementById("map").style.position="absolute";
});
