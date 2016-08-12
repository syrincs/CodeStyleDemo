$ ->
  $.fn.populateFromArray = (array) ->
    html = ""
    option = $("<option></option").wrap("<div></div>")
    $.each array, (i, value) ->
      if value instanceof Array
        text = value[0]
        val = value[1]
      else
        val = text = value
      html += option.val(val).text(text).parent().html()
    this.html(html)

