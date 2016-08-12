$ ->
  $('form.offer').submit ->
    # set type of polymorphic assocation according to selection
    $('#offer_location_type').val($('#offer_location_id option:selected').parent().attr('label'))
