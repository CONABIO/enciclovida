 /**
 * Para el paginado de los cantos de aves
 * @param paginas
 * @param pagina
 */
function paginadoXenoCanto(){


    pageSize = 3;
    incremSlide = 5;
    startPage = 0;
    numberPage = 0;

    let pageCount =  $(".audio-element").length / pageSize;
    var totalSlidepPage = Math.floor(pageCount / incremSlide);
    for(var i = 0 ; i<pageCount;i++){
        $("#pagin").append('<li><a>'+(i+1)+'</a></li> ');
        if(i>pageSize){
           $("#pagin li").eq(i).hide();
        }
    }
    var prev = $("<li/>").addClass("prev").html("←").click(function(){
        startPage-=5;
        incremSlide-=5;
        numberPage--;
        slide();
     });
     
    prev.hide();
    
    var next = $("<li/>").addClass("next").html("→").click(function(){
    startPage+=5;
    incremSlide+=5;
    numberPage++;
    slide();
    });
    $("#pagin").prepend(prev).append(next);

    $("#pagin li").first().find("a").addClass("current");
    slide = function(sens){
        $("#pagin li").hide();
        
        for(t=startPage;t<incremSlide;t++){
          $("#pagin li").eq(t+1).show();
        }
        if(startPage == 0){
          next.show();
          prev.hide();
        }else if(numberPage == totalSlidepPage ){
          next.hide();
          prev.show();
        }else{
          next.show();
          prev.show();
        }
    }
    showPage = function(page) {
        $(".audio-element").hide();
        $(".audio-element").each(function(n) {
            if (n >= pageSize * (page - 1) && n < pageSize * page)
                $(this).show();
        });        
    }
        
    showPage(1);
    $("#pagin li a").eq(0).addClass("current");

    $("#pagin li a").click(function() {
        $("#pagin li a").removeClass("current");
        $(this).addClass("current");
        showPage(parseInt($(this).text()));
    });

 };
 