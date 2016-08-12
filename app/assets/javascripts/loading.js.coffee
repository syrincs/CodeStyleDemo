$(document).ajaxStart ->
  $('#loading').fadeIn 'fast', ->
 
$(document).ajaxStop ->
  $('#loading').fadeOut 'fast', ->

$(document).ajaxComplete ->
  $('#loading').stop(true,false).fadeOut 'fast', ->
