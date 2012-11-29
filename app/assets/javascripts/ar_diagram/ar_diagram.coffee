jQuery.fn.exists = ->
  return this.length > 0

# Utility Methods

getTargetURL = ->
  $('#ar_diagram').data('target')

remoteScript = (path, successCallback, failCallback) ->
  requestURL = getTargetURL() + "/" + path
  $.ajax requestURL,
    type: 'GET'
    dataType: 'script'
    error: (jqXHR, textStatus, errorThrown) ->
      if failCallback
        failCallback()
      else
        alert("AJAX Error in Remote Script #{path}: #{textStatus}")
    success: (data, textStatus, jqXHR) ->
      if successCallback
        successCallback()

@viewUnsaved = (v) ->
  if (typeof v == 'undefined')
    result = $('#ar_diagram').data("view-unsaved")
    return false unless result
    return true
  if(v)
    $('#ar_diagram').data("view-unsaved", true)
  else
    $('#ar_diagram').removeData("view-unsaved")

  return v

@zoom = (v) ->
  unless v
    result = $('#ar_diagram').data("zoom")
    return 1 unless result
    return result
  $('#ar_diagram').data("zoom", v)
  return v

selectedTable = (table) ->
  unless table
    return $(".diagram_table.selected").first
  else
    @selectedTable = table.attr("id")
    $(".diagram_table").removeClass("selected")
    table.addClass("selected")
    return table

tableMouseDown = (event, table) ->
  selectedTable(table)
  table.addClass("drag")
  position = table.position()
  @offsetX = parseInt(event.pageX) - position.left
  @offsetY = parseInt(event.pageY) - position.top
  event.preventDefault()

tableMouseMove = (event) ->
  return if !@selectedTable
  table = $('#' + @selectedTable)
  if table.hasClass("drag")
    gridSize = 1
    z = zoom()
    x = Math.round(parseInt(event.pageX) / gridSize) * gridSize
    y = Math.round(parseInt(event.pageY) / gridSize) * gridSize
    table.data("x", (x - @offsetX) / z)
    table.data("y", (y - @offsetY) / z)
    viewUnsaved(true)
    updateView()

@makeDraggable = (table) ->
  table.mousedown((event) ->
    tableMouseDown(event, table)
  )

setCanvasSize = ->
  canvas = $('#canvas')
  unless canvas.exists()
    canvas = $('<canvas/>', {'id': 'canvas'})
    $('#content').prepend(canvas)

  canvas_width = 0
  canvas_height = 0

  $('.diagram_table').each((index, table) ->
    t = $(table)
    width = parseInt(t.width() + t.position().left, 10)
    canvas_width = width if (width > canvas_width)
    height = parseInt(t.height() + t.position().top, 10)
    canvas_height = height if (height > canvas_height)
  )
  canvas_width += 50
  canvas_height += 50

  canvas.width(canvas_width)
  canvas.height(canvas_height)
  canvas.attr("width", canvas_width)
  canvas.attr("height", canvas_height)

drawRelationshipLine = (field, target, type) ->
  target_field = $('#' + target)
  return unless target_field.exists()

  table = field.parents("table").first()
  target_table = target_field.parents("table").first()

  canvas = $('#canvas')
  ctx = canvas[0].getContext("2d")

  field.addClass("join")
  target_field.addClass("join")

  ctx.strokeStyle = "gray"
  ctx.fillStyle = "gray"

  if field.position() && target_field.position()
    x1 = table.position().left
    y1 = table.position().top + field.position().top + (field.height() / 2)
    x2 = target_table.position().left
    y2 = target_table.position().top + target_field.position().top + (target_field.height() / 2)

    textY = y1 - 1

    if (x2 > x1)
      x1 += field.width()
      textX = x1 + 20
      textAlign = "left"
    else
      x2 += target_field.width() + 10
      textX = x1 - 10
      textAlign = "right"

    unless (type == "belongs_to")
      # Draw the main line

      ctx.beginPath()
      if (x2 > x1)
        ctx.moveTo(x1, y1)
        ctx.lineTo(x1 + 20, y1)
        ctx.lineTo(x2 - 20, y2)
      else
        ctx.moveTo(x1, y1)
        ctx.lineTo(x1 - 20, y1)
        ctx.lineTo(x2 + 20, y2)
      ctx.lineTo(x2, y2)
      ctx.stroke()

      # Draw the arrow
      ctx.textBaseline = "bottom"
      ctx.beginPath()
      if (x2 > x1)
        ctx.lineTo(x2 - 8, y2 - 8)
        ctx.lineTo(x2 - 8, y2 + 8)
      else
        ctx.lineTo(x2 + 8, y2 - 8)
        ctx.lineTo(x2 + 8, y2 + 8)

      ctx.lineTo(x2, y2)
      ctx.fill()

    # Draw the text
    ctx.fillStyle = "blue"
    ctx.textAlign = textAlign
    ctx.fillText(type, textX, textY)

drawRelationships = (table) ->
  t = $(table)
  t.find('tr').each((index, row) ->
    r = $(row)
    hasMany = r.data("has-many")
    hasOne = r.data("has-one")
    belongsTo = r.data("belongs-to")
    if hasMany
      relationships = hasMany.split(",")
      $.each(relationships, (index, relationship) ->
        drawRelationshipLine(r, relationship, "has_many")
      )
    if hasOne
      relationships = hasOne.split(",")
      $.each(relationships, (index, relationship) ->
        drawRelationshipLine(r, relationship, "has_one")
      )
    if belongsTo
      relationships = belongsTo.split(",")
      $.each(relationships, (index, relationship) ->
        drawRelationshipLine(r, relationship, "belongs_to")
      )
  )

@saveView = ->
  p = new Object()
  p["tables"] = new Object()

  $(".diagram_table").each((index, table) ->
    t = $(table)
    table_id = t.attr("id")
    pTable = new Object()
    pTable["name"] = table_id
    pTable["x"] = t.data("x")
    pTable["y"] = t.data("y")
    pTable["fields"] = new Object()
    t.find('tr').each((index, field) ->
      f = $(field)
      field_id = f.attr("id")
      pField = new Object()
      pField["name"] = field_id
      pTable["fields"][field_id] = pField
    )
    p["tables"][table_id] = pTable
    p["zoom"] = zoom()
  )
  requestURL = getTargetURL()
  $.ajax requestURL,
    type: 'PUT'
    data: p
    dataType: 'script'
    error: (jqXHR, textStatus, errorThrown) ->
      alert("AJAX Error while saving view: #{textStatus}")
    success: (data, textStatus, jqXHR) ->

updateTableMenu = ->
  $('.table-select').each((index, item) ->
    t = $(item)
    tableName = t.data("table-name")
    table = $("##{tableName}")
    t.off("click")
    if table.exists()
      t.find("i").attr("class", "icon-ok").attr("style", "color:green;")
      t.click(->
        table.remove()
        viewUnsaved(true)
        updateView()
      )
    else
      t.find("i").attr("class", "icon-plus").attr("style", "color:white;")
      t.click(->
        requestURL = getTargetURL() + "/add_table"
        $.ajax requestURL,
          type: 'POST'
          dataType: 'script'
          data:
            {
            model: tableName
            }
        error: (jqXHR, textStatus, errorThrown) ->
          if failCallback
            failCallback()
          else
            alert("AJAX Error in Remote Script #{path}: #{textStatus}")
        success: (data, textStatus, jqXHR) ->
          if successCallback
            successCallback()
      )
  )

@updateView = ->
  z = zoom()
  $('#content').css("font-size", (12 * z) + "px")
  $(".diagram_table").each((index, table) ->
    t = $(table)
    t.css("left", (t.data("x") * z) + "px")
    t.css("top", (t.data("y") * z) + "px")
  )
  setCanvasSize()
  $(".diagram_table").each((index, table) ->
    drawRelationships(table)
  )

  if viewUnsaved()
    $('#saveViewButton').show()
  else
    $('#saveViewButton').hide()

  updateTableMenu()

$(document).ready ->
  $('html').mousemove((event) ->
    tableMouseMove(event)
  )

  $('html').mouseup((event) =>
    $(".diagram_table").removeClass("drag")
  )
  $('.diagram_table').each(->
    makeDraggable($(this))
  )
  $('#zoom-in-button').click(=>
    zoom(zoom() + 0.1)
    updateView()
  )

  $('#zoom-out-button').click(=>
    zoom(zoom() - 0.1)
    updateView()
  )

  updateView()
