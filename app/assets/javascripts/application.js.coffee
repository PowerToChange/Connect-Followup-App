# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require spin.min
#= require angular
#= require angular_app
#= require_tree ./angular
#= require bootstrap
#= require connections

$ ->
  $('.survey ul.contacts > li').click ->
    window.location = $(this).data('url')

  $('a.prev-page').click ->
    parent.history.back()
    return false

  $('.carousel').carousel({
    interval: false
  })

  $('.report-progress form input[type=radio]').click ->
    $(this).closest("form").submit()

  $('a.reverse-progress').click ->
    $('.carousel').carousel('prev')

  # Submit a bootstrap modal form via a submit input element in the modal footer (instead of in the form)
  $('.modal-footer input[type="submit"]').on 'click', ->
    $('form#' + $(this).attr('form')).submit()

  # Activate Bootstrap tabs
  $('ul.nav-tabs a').click (e) ->
    e.preventDefault()
    $(this).tab('show')