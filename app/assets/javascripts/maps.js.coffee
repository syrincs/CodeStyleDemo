$ ->
  window.show_map = (map, address) ->
    lat = address.split(" ")[0]
    lng = address.split(" ")[1]
    position = new google.maps.LatLng(lat, lng)
    map = new google.maps.Map map,
      zoom: 15
      center: position
      mapTypeId: google.maps.MapTypeId.ROADMAP
    marker = new google.maps.Marker
      map: map
      position: position
    map

  $.fn.address_selector = ->
    this.each ->
      container = $(this)

      address = container.find('.storage').val().split(" ")
      address[0] = parseFloat(address[0])
      address[1] = parseFloat(address[1])
      if isNaN(address[0]) || isNaN(address[1])
        address[0] = 49
        address[1] = 8
      center = new google.maps.LatLng(address[0], address[1])

      map = new google.maps.Map container.find(".map")[0],
        zoom: 10
        center: center
        mapTypeId: google.maps.MapTypeId.ROADMAP

      marker = new google.maps.Marker
        map: map
        position: center
        draggable: true

      update_position = (point) ->
        marker.setPosition(point)
        map.panTo(point)
        container.find('.storage').val(point.lat().toFixed(5)+" "+point.lng().toFixed(5))

      google.maps.event.addListener marker, "dragend",
        ->
          update_position marker.getPosition()

      query_address = ->
        geocoder = new google.maps.Geocoder()
        address = container.find('.query').val()
        geocoder.geocode({'address': address}, (results, status) ->
          if (status == google.maps.GeocoderStatus.OK)
            update_position(results[0].geometry.location)
          else
            alert("Adresse unbekannt: "+address)
        )

      container.find("input[type=submit]").click (event) ->
        event.preventDefault()
        query_address()
        false

      container.find('.query').keyup (event) ->
        return unless event.keyCode == 13
        event.preventDefault()
        query_address()
        false

