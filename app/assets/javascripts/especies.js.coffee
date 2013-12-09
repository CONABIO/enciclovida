# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

fnFormatDetails = (oTable, nTr) ->
  aData = oTable.fnGetData(nTr)
  sOut = "<table cellpadding=\"5\" cellspacing=\"0\" border=\"0\" style=\"padding-left:50px;\">"
  sOut += "<tr><td>Rendering engine:</td><td>" + aData[1] + " " + aData[4] + "</td></tr>"
  sOut += "<tr><td>Link to source:</td><td>Could provide a link here</td></tr>"
  sOut += "<tr><td>Extra info:</td><td>And any further details here (images etc)</td></tr>"
  sOut += "</table>"
  sOut

fnCreateSelect = (posicion, selecc) ->
  opciones = undefined
  r = undefined
  opciones = ""
  switch posicion
    when 2
      r = "Mostrar solo: <br><select id=\"filtro_" + posicion + "\"><option value=\"\">Todo</option>"
      $.ajax(url: "/categorias_taxonomica.json").done (categoria) ->
        $(jQuery.parseJSON(JSON.stringify(categoria))).each ->
          if @id is parseInt(selecc)
            if @nivel2 is 0 and @nivel1 isnt 1 and @nivel1 isnt 2
              opciones += "<option value=\"" + @id + "\" selected=\"selected\">div ✓ " + @nombre_categoria_taxonomica + "</option>"
            else if @nivel2 is 1 and @nivel1 isnt 1 and @nivel1 isnt 2
              opciones += "<option value=\"" + @id + "\" selected=\"selected\">phy ✓ " + @nombre_categoria_taxonomica + "</option>"
            else
              opciones += "<option value=\"" + @id + "\" selected=\"selected\">✓ " + @nombre_categoria_taxonomica + "</option>"
          else
            if @nivel2 is 0 and @nivel1 isnt 1 and @nivel1 isnt 2
              opciones += "<option value=\"" + @id + "\">div ✓ " + @nombre_categoria_taxonomica + "</option>"
            else if @nivel2 is 1 and @nivel1 isnt 1 and @nivel1 isnt 2
              opciones += "<option value=\"" + @id + "\">phy ✓ " + @nombre_categoria_taxonomica + "</option>"
            else
              opciones += "<option value=\"" + @id + "\">✓ " + @nombre_categoria_taxonomica + "</option>"

        $("#filtro_" + posicion).append opciones

    when 6
      r = "<select id=\"filtro_" + posicion + "\"><option value=\"\">Todas</option>"
      $.ajax(url: "/categorias_taxonomica.json").done (categoria) ->
        $(jQuery.parseJSON(JSON.stringify(categoria))).each ->
          if @id is parseInt(selecc)
            if @nivel2 is 0 and @nivel1 isnt 1 and @nivel1 isnt 2
              opciones += "<option value=\"" + @id + "\" selected=\"selected\">div ✓ " + @nombre_categoria_taxonomica + "</option>"
            else if @nivel2 is 1 and @nivel1 isnt 1 and @nivel1 isnt 2
              opciones += "<option value=\"" + @id + "\" selected=\"selected\">phy ✓ " + @nombre_categoria_taxonomica + "</option>"
            else
              opciones += "<option value=\"" + @id + "\" selected=\"selected\">✓ " + @nombre_categoria_taxonomica + "</option>"
          else
            if @nivel2 is 0 and @nivel1 isnt 1 and @nivel1 isnt 2
              opciones += "<option value=\"" + @id + "\">divi ✓ " + @nombre_categoria_taxonomica + "</option>"
            else if @nivel2 is 1 and @nivel1 isnt 1 and @nivel1 isnt 2
              opciones += "<option value=\"" + @id + "\">phy ✓ " + @nombre_categoria_taxonomica + "</option>"
            else
              opciones += "<option value=\"" + @id + "\">✓ " + @nombre_categoria_taxonomica + "</option>"

        $("#filtro_" + posicion).append opciones

    when 9
      r = "<select id=\"filtro_" + posicion + "\"><option value=\"\">Todos</option>"
      if parseInt(selecc) is 1
        r += "<option value=\"2\">válido/correcto</option><option value=\"1\" selected=\"selected\">sinónimo</option>"
      else if parseInt(selecc) is 2
        r += "<option value=\"2\" selected=\"selected\">válido/correcto</option><option value=\"1\">sinónimo</option>"
      else
        r += "<option value=\"2\">válido/correcto</option><option value=\"1\">sinónimo</option>"
  r + "</select>"

fnCreateText = (posicion, selecc) ->
  opciones = undefined
  r = undefined
  switch posicion
    when 3
      r = "<input type=\"text\" value=\"\" placeholder=\"ID\" id=\"filtro_" + posicion + "\">"
    when 4
      r = "<input data-autocomplete=\"/especies/autocomplete_especie_nombre\" type=\"text\" value=\"\" placeholder=\"Nom. científico\" autocomplete=\"off\" id=\"filtro_" + posicion + "\">"
    when 5
      r = "<input type=\"text\" value=\"\" placeholder=\"Nom. autoridad\" id=\"filtro_" + posicion + "\">"
    when 11
      r = "<input data-autocomplete=\"/especies_catalogo/autocomplete_catalogo_descripcion\" type=\"text\" value=\"\" placeholder=\"Edo. conservación\" autocomplete=\"off\" id=\"filtro_" + posicion + "\">"
    when 12
      opciones = ""
      r = "<input data-autocomplete=\"/nombres_comunes/autocomplete_nombre_comun_comun\" type=\"text\" value=\"\" placeholder=\"Nombre común\" autocomplete=\"off\" id=\"filtro_" + posicion + "\">"
      r += "<br><input data-autocomplete=\"/especies_regiones/autocomplete_region_nombre\" type=\"text\" value=\"\" placeholder=\"Región\" autocomplete=\"off\" id=\"filtro_" + (posicion + 1) + "\">"
      r += "<br><select id=\"filtro_" + (posicion + 2) + "\"><option value=\"\">Todas</option>"
      $.ajax(url: "/tipos_distribuciones.json").done (distribucion) ->
        $(jQuery.parseJSON(JSON.stringify(distribucion))).each ->
          if @id is parseInt(selecc)
            opciones += "<option value=\"" + @id + "\" selected=\"selected\">" + @descripcion + "</option>"
          else
            opciones += "<option value=\"" + @id + "\">" + @descripcion + "</option>"

        $("#filtro_" + (posicion + 2)).append opciones

    when 15
      r = "<input type=\"text\" value=\"\" placeholder=\"Fuente\" id=\"filtro_" + posicion + "\">"
    when 16
      r = "<input type=\"text\" value=\"\" placeholder=\"Cita nomenclatural\" id=\"filtro_" + posicion + "\">"
    when 17
      r = "<input type=\"text\" value=\"\" placeholder=\"Sist. de clasificación\" id=\"filtro_" + posicion + "\">"
    when 18
      r = "<input type=\"text\" value=\"\" placeholder=\"Anotación\" id=\"filtro_" + posicion + "\">"
    when 19
      r = "<input type=\"date\" id=\"filtro_" + posicion + "\" value=\"" + selecc + "\">"
    when 20
      r = "<input type=\"date\" id=\"filtro_" + posicion + "\" value=\"" + selecc + "\">"
    else
      r = ""
  r

getCookie = (c_name) ->
  c_end = undefined
  c_start = undefined
  if document.cookie.length > 0
    c_start = document.cookie.indexOf(c_name + "=")
    if c_start isnt -1
      c_start = c_start + c_name.length + 1
      c_end = document.cookie.indexOf(";", c_start)
      c_end = document.cookie.length  if c_end is -1
      return unescape(document.cookie.substring(c_start, c_end))
  ""

textos=[3, 4, 5, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
conBusqueda=[4, 11, 12, 13]
opciones=[2, 6, 9]
textoAtrasado=[13, 14, 15, 16, 17, 18]

jQuery ->
  oTable = $("#especies").dataTable(
    oLanguage:
      sSearch: "Buca en todos los campos de nombre (comunes o cientificos):"
      sInfo: "Mostrando rango: _START_ a _END_ de _TOTAL_ resulatdos"
      sInfoEmpty: "La búsqueda no dio ningún resultado."
      sEmptyTable: "No se encontro ningún resultado."
      sInfoFiltered: "(_MAX_ registros totales)."
      sZeroRecords: "No se encontro ningún resultado."
      sProcessing: "<h2><b>Procesando...</b></h2>"
      oPaginate:
        sFirst: "Primera"
        sNext: "Sig."
        sPrevious: "Ant."
        sLast : "Última"
      sLengthMenu: 'Muestra <select>'+
      '<option value="10">10</option>'+
      '<option value="20">20</option>'+
      '<option value="30">30</option>'+
      '<option value="40">40</option>'+
      '<option value="50">50</option>'+
      '<option value="100">100</option>'+
      '<option value="200">200</option>'+
      '</select> resultados por página'

    bStateSave: "true"
    #sCookiePrefix: "datatable_"

    aoColumns: [
      mDataProp: "0"
    ,
      mDataProp: "1"
    ,
      mDataProp: "2"
    ,
      mDataProp: "3"
    ,
      mDataProp: "4"
    ,
      mDataProp: "5"
    ,
      mDataProp: "6"
    ,
      mDataProp: "7"
    ,
      mDataProp: "8"
    ,
      mDataProp: "9"
    ,
      mDataProp: "10"
    ,
      mDataProp: "11"
    ,
      mDataProp: "12"
    ,
      bVisible: false
    ,
      bVisible: false
    ,
      mDataProp: "15"
    ,
      mDataProp: "16"
    ,
      mDataProp: "17"
    ,
      mDataProp: "18"
    ,
      mDataProp: "19"
    ,
      mDataProp: "20"
    ]

    sScrollX: "500px"
    sScrollY: "500px"
    sPaginationType: "full_numbers"
    bJQueryUI: "true"
    bProcessing: "true"
    bServerSide: "true"
    sAjaxSource: $("#especies").data("source")
    aoColumnDefs: [
      bSortable: false
      aTargets: [ 0, 1, 2, 6, 7, 8, 9, 10, 11, 12, 13, 14 ]
    ]

    #fnServerData: (sSource, aoData, fnCallback) ->
      #aoData.push
        #name: "sSearch_1"
        #value: $("#filtro_1").val()
      #$.getJSON sSource, aoData, (json) ->
        #fnCallback json
  )

  #$('#consultar').click ->
    #oTable.fnFilter $(this).val(), 0

  $(".dataTables_filter input").unbind("keypress keyup").bind "change", ->
    oTable.fnFilter $(this).val()
  $(".dataTables_filter input").bind "keypress keyup", (e) ->
    if e.keyCode is 13
      oTable.fnFilter $(this).val()
      false

  $("tfoot th").each (i) ->
    cookie=getCookie('SpryMedia_DataTables_especies_')
    if cookie is ""
      cookie=getCookie('SpryMedia_DataTables_especies_especies')

    if textos.indexOf(i) > -1
      if cookie != ""
        if i is 12
          @innerHTML = fnCreateText(i, JSON.parse(cookie).aoSearchCols[i+2].sSearch)
        else if textoAtrasado.indexOf(i) > -1
          @innerHTML = fnCreateText(i+2, JSON.parse(cookie).aoSearchCols[i+2].sSearch)
        else
          @innerHTML = fnCreateText(i)
        $("#filtro_"+i).val(decodeURIComponent(escape(JSON.parse(cookie).aoSearchCols[i].sSearch)))
      else
        @innerHTML = fnCreateText(i)

      if conBusqueda.indexOf(i) > -1
        $("#filtro_"+i).bind "railsAutocomplete.select", (event, data) ->
          if i is 4
            $(this).val(data.item.nombre_cientifico)
            oTable.fnFilter ($(this).val() +  '|' + data.item.id), i
          if i is 11
            $(this).val data.item.descripcion
          if i is 12
            $(this).val data.item.nombre_comun
          if i is 13
            $(this).val data.item.nombre_region
          if i != 4
            oTable.fnFilter $(this).val(), i

        $("#filtro_"+i).change ->
          if $(this).val() is ""
            oTable.fnFilter $(this).val(), i

    if opciones.indexOf(i) > -1
      if cookie != ""
        @innerHTML = fnCreateSelect(i, JSON.parse(cookie).aoSearchCols[i].sSearch)
      else
        @innerHTML = fnCreateSelect(i, "")
      $("#filtro_"+i).change ->
        oTable.fnFilter $(this).val(), i

  $("#box_especie").click ->
    checaCaja = (if $(this).is(":checked") then true else false)
    if checaCaja
      $(":input[id^='box_especie_']").prop "checked", true
    else
      $(":input[id^='box_especie_']").prop "checked", false

  $("#limpiar").click ->
    document.cookie = "SpryMedia_DataTables_especies_=;expires=Thu, 01 Jan 1990 00:00:01 GMT;"
    document.cookie = "SpryMedia_DataTables_especies_especies=;expires=Thu, 01 Jan 1990 00:00:01 GMT;"
    location.reload false

  $(":input[id^='filtro_']").keypress (e) ->
    if e.keyCode is 13
      $("#limpiar").focus()
      $(this).focus()
      false

  $(":input[id^='filtro_']").change ->
    oTable.fnFilter $(this).val(), $(this).attr('id').substring(7)

  #oTable.fnSetColumnVis( 13, false );
  #oTable.fnSetColumnVis( 14, false );

