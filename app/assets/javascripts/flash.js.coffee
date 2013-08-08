bootstrap_flash_class = (type) ->
  switch type
    when 'notice' then 'alert-success'
    when 'success' then 'alert-success'
    when 'error' then 'alert-error'
    when 'warning' then 'alert-warning'
    else 'alert-success'

show_ajax_message = (msg, type) ->
  $("#flash").hide().html "<div class='alert fade in #{ bootstrap_flash_class(type) }'><button class='close' data-dismiss='alert'>×</button>#{ msg }</div>"
  $("#flash").slideDown('slow')
  $("#flash").delay(10000).slideUp('slow')

$(document).ajaxComplete (event, request) ->
  msg = request.getResponseHeader("X-Message")
  type = request.getResponseHeader("X-Message-Type")
  show_ajax_message msg, type if msg?
