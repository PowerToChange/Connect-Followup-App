bootstrap_flash_class = (type) ->
  switch type
    when 'notice' then 'alert-success'
    when 'success' then 'alert-success'
    when 'error' then 'alert-error'
    when 'warning' then 'alert-warning'
    else 'alert-success'

show_ajax_message = (msg, type) ->
  $("#flash").fadeOut 'fast', ->
    $(this).html "<div class='alert fade in #{ bootstrap_flash_class(type) }'><button class='close' data-dismiss='alert'>×</button>#{ msg }</div>"
  $("#flash").slideDown()
  hide_flash_after_awhile()

hide_flash_after_awhile = ->
  setTimeout ( ->
    $("#flash").fadeOut 'slow'
  ), 5000

$ ->
  if $("#flash .alert").size() > 0
    hide_flash_after_awhile()

  $("#flash").on 'click', ->
    $("#flash").fadeOut 'fast'

  $(document).ajaxComplete (event, request) ->
    msg = request.getResponseHeader("X-Message")
    type = request.getResponseHeader("X-Message-Type")
    show_ajax_message msg, type if msg?
