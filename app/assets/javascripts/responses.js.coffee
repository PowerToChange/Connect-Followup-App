$ ->
  # Update the lead status on load
  $("form.edit-lead input[type='radio'][value='#{ $('form.edit-lead').data('status-id') }']").prop('checked', true)