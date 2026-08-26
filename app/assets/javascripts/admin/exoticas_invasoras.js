function soulmateExoticas() {

    var input = $("#exotica_nombre_cientifico");
    var container = $("#soulmate-exoticas");

    if (!input.length || !container.length) {
        return;
    }

    var resultadosActuales = [];

    var render = function(term, data) {

        data.nombre_cientifico = limpiar(data.nombre_cientifico);

        var nombres;

        if (data.nombre_comun == null) {

            nombres =
                '<a href="" class="not-active">' +
                data.nombre_cientifico +
                "</a>";

        } else {

            nombres =
                "<b>" +
                primeraEnMayuscula(data.nombre_comun) +
                " </b><sub>" +
                data.lengua +
                '</sub><a href="" class="not-active">' +
                data.nombre_cientifico +
                "</a>";
        }

        var foto;

        if (data.foto == null) {

            foto =
                '<i class="soulmate-img ev1-ev-icon pull-left"></i>';

        } else {

            foto =
                "<i class='soulmate-img pull-left' style='background-image:url(\"" +
                data.foto +
                "\")'></i>";
        }

        return foto + " " + nombres;
    };

    function marcarEspeciesRegistradas(data) {

      var ids = [];

      $.each(data.results, function(type, resultados) {

          if (!resultados || resultados.length === 0) {
              return;
          }

          $.each(resultados, function(i, resultado) {

              if (resultado.data && resultado.data.id) {
                  ids.push(resultado.data.id);
              }

          });

      });

      ids = [...new Set(ids)];

      if (ids.length === 0) {
          mostrarResultados(data);
          return;
      }

      $.ajax({

          url: SITE_URL + "admin/exoticas_invasoras/especies_registradas",

          dataType: "json",

          data: {
              ids: ids
          },

          success: function(registradas) {

              data.especies_registradas = {};

              $.each(registradas, function(i, id) {
                  data.especies_registradas[id] = true;
              });

              mostrarResultados(data);
              
          },

          error: function() {

              // Si falla la consulta, el autocomplete
              // continúa funcionando normalmente.
              data.especies_registradas = {};
              mostrarResultados(data);
          }

      });
    }

    function mostrarResultados(data) {

      var html = "";
      resultadosActuales = [];

      var index = 0;

      $.each(data.results, function(type, resultados) {

          if (!resultados || resultados.length === 0) {
              return;
          }

          html +=
              '<li class="soulmate-type-container">' +
                  '<ul class="soulmate-type-suggestions">';

          $.each(resultados, function(i, resultado) {

              resultadosActuales.push(resultado);

              var registrada =
                  data.especies_registradas &&
                  data.especies_registradas[resultado.data.id];

              var marca = registrada
                  ? '<span class="ml-2 text-success">✓ Registrada</span>'
                  : '';

              html +=
                  '<li id="' + index +
                  '-soulmate-exotica-suggestion" ' +
                  'class="soulmate-suggestion clearfix p-2 border-bottom" ' +
                  'data-index="' + index + '">' +
                      render(resultado.term, resultado.data) +
                      marca +
                  '</li>';

              index++;
          });

          html +=
                  "</ul>" +
                  '<div class="soulmate-type p-2 h5 font-weight-bold">' +
                      typesDiacritics(type) +
                  "</div>" +
              "</li>";
      });

      if (html.length > 0) {

          container.html(html);
          container.show();

      } else {

          resultadosActuales = [];
          container.empty().hide();
      }
    }


    function seleccionar(index) {

        var resultado = resultadosActuales[index];

        if (!resultado || !resultado.data) {
            return;
        }

        var data = resultado.data;

        $("#exotica_invasora_especie_id").val(data.id);

        input.val(data.nombre_cientifico);

        container.hide();
    }


    input.on("keyup", function(event) {

        var key = event.which || event.keyCode;

        /*
         * ESC
         */
        if (key === 27) {

            container.hide();
            return;
        }

        /*
         * ENTER
         */
        if (key === 13) {

            var focused = container.find(".soulmate-suggestion.focus");

            if (focused.length) {

                seleccionar(
                    parseInt(focused.attr("data-index"), 10)
                );

                event.preventDefault();
            }

            return;
        }

        /*
         * FLECHA ABAJO
         */
        if (key === 40) {

            var suggestions = container.find(".soulmate-suggestion");

            if (!suggestions.length) {
                return;
            }

            var current = suggestions.index(
                suggestions.filter(".focus")
            );

            suggestions.removeClass("focus");

            var next = current + 1;

            if (next >= suggestions.length) {
                next = 0;
            }

            suggestions.eq(next).addClass("focus");

            event.preventDefault();

            return;
        }

        /*
         * FLECHA ARRIBA
         */
        if (key === 38) {

            var suggestions = container.find(".soulmate-suggestion");

            if (!suggestions.length) {
                return;
            }

            var current = suggestions.index(
                suggestions.filter(".focus")
            );

            suggestions.removeClass("focus");

            var previous = current - 1;

            if (previous < 0) {
                previous = suggestions.length - 1;
            }

            suggestions.eq(previous).addClass("focus");

            event.preventDefault();

            return;
        }


        var term = input.val();

        if (term.length < 2) {

            resultadosActuales = [];
            container.empty().hide();

            return;
        }


        $.ajax({

            url: SITE_URL + "sm/search",

            dataType: "jsonp",

            data: {
                term: removeDiacritics(term),
                types: TYPES,
                limit: 5
            },

            success: function(data) {

                /*
                 * Evitar mostrar resultados de una búsqueda
                 * anterior si el usuario ya escribió algo diferente.
                 */
                if (input.val() !== term) {
                    return;
                }

              marcarEspeciesRegistradas(data);
            }
        });

    });


    /*
     * Selección con mouse
     */
    container.on(
        "mouseover",
        ".soulmate-suggestion",
        function() {

            container
                .find(".soulmate-suggestion")
                .removeClass("focus");

            $(this).addClass("focus");
        }
    );


    container.on(
        "click",
        ".soulmate-suggestion",
        function(event) {

            event.preventDefault();

            var index = parseInt(
                $(this).attr("data-index"),
                10
            );

            seleccionar(index);

            input.focus();
        }
    );


    /*
     * Cerrar al hacer click fuera
     */
    $(document)
        .off("click.soulmateExoticas")
        .on("click.soulmateExoticas", function(event) {

            if (
                !$(event.target).closest(
                    "#exotica_nombre_cientifico, #soulmate-exoticas"
                ).length
            ) {
                container.hide();
            }
        });


    /*
     * Estado inicial
     */
    container.hide();
}


$(document).on("turbolinks:load", function() {
    soulmateExoticas();
});