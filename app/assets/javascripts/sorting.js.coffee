$ ->
  $(".sortable").sortable(
    update: ->
      $this = $(this)
      url = $this.data('url')
      if url
        data = {}
        $this.children().each((order, subject) ->
          data[$(subject).data('id')] = order
        )

        $.ajax
          type: 'PUT'
          url: url
          data: {order: data}
      else
        $this.children().each((order, subject) ->
          $(subject).find('.order').val(order)
        )
  ).disableSelection()

