$ ->
  window.initialize_search_handlers = (base_url) ->
    submit_update = (data) ->
      callback = (result) ->
        $('#search_brand_id').populateFromArray(result.brands) if result.brands
        $('#search_brand_id').val(result.brand_id)
        $('#search_modell_id').populateFromArray(result.modells) if result.modells
        $('#search_modell_id').val(result.modell_id)
        $('#search_format').populateFromArray(result.formats) if result.formats
        $('#search_format').val(result.format)
        $('#search_year').populateFromArray(result.years) if result.years
        $('#search_year').val(result.year)
        $('input[name=commit]').val("Show "+result.offers_count+" offers")
      $.get base_url, {search: data}, callback

    $('form.search input.clear').click (event) ->
      $('#search_category_id').val("").trigger("change")

    $('#search_category_id').change -> submit_update
      category_id: $('#search_category_id').val()
      brand_id: ""
      modell_id: ""
      format: ""
      year: ""

    $('#search_brand_id').change -> submit_update
      brand_id: $('#search_brand_id').val()
      modell_id: ""
      format: ""
      year: ""

    $('#search_modell_id').change -> submit_update
      modell_id: $('#search_modell_id').val()
      format: ""
      year: ""

    $('#search_format').change -> submit_update
      format: $('#search_format').val()
      year: ""

    $('#search_year').change -> submit_update
      year: $('#search_year').val()

