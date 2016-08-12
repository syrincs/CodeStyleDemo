# Full row clickable in tables, implements click of first button in actions column
@fullTableRowClickable = ->
  $('.table tbody tr td:not(:last-child)').click ->
    $(this).parent().find(':last-child a:first')[0].click()
    return

$ ->
  #catch global ajax error and show as flash alert
  $(document).on "ajax:error", "form", (evt, xhr, status, error) ->
    $("#alert-div").html('<div class="alert alert-danger fade in"><a class="close" data-dismiss="alert" href="#">  &times;</a>' + error + '</div>')
    $("#alert-div").hide().fadeIn(600).delay(3000).fadeOut(600)
    return

  #activate autofocus for bootstrap modal dialogues
  $(document).on 'shown.bs.modal', (e) ->
    $('[autofocus]', e.target).focus()
    return

  fullTableRowClickable()

  # all bootstrap modals draggable by their header
  $('#modal').draggable handle: '.modal-header'

  #manually clear form on .clear button click (also works after form submit)
  $("form input[name*='clear']").click (e) ->
    e.preventDefault()
    $(this).closest('form').find('input:text, input:password, input:file, select, textarea').val('')
    $(this).closest('form').find('input:radio, input:checkbox').removeAttr('checked').removeAttr('selected')
    return

  #Dropdown Menus
  $('.dropdown-toggle').dropdown()

  $('.dropdown').hover (->
        $(this).addClass('open')
        return
      ), ->
        $(this).removeClass('open')
        return
      $('.dropdown-menu li').hover (->
        $(this).find('.sub-menu').css('visibility', 'visible').stop(true, true).slideDown()
        return
      ), ->
        $(this).find('.sub-menu').css('visibility', 'hidden').stop(true, true).slideUp()
        return    

  # selectbox inside dropdown menus fixes
  $('.dropdown-menu').click (e) ->
    e.stopPropagation()
    return
  $('.dropdown-menu').hover (e) ->
    e.stopPropagation()
    return

  #Hide dropdown menu on outside click of menu
  $(document).on 'click touchend', ->
    $('.dropdown').removeClass('open')
    return

  $('.custom-tooltip').tooltip({
      delay: { show: 100, hide: 100 }
    })

  $('a.hide-tooltip').click ->
    $(this).parent().tooltip("hide")

  $('.list-listnav').listnav()
  
  #scroll to top arrow
  $block = $('<div/>', 'class': 'top-scroll').append('<a href="#"/>').hide().appendTo('body').click(->
    $('body,html').animate { scrollTop: 0 }, 800
    false
  )

  # static navigation bar
  hideElem = ->
    $('.main-nav-wrap').removeClass 'fixed-pos'
    $block.fadeOut()
    return

  showElem = ->
    $('.main-nav-wrap').addClass 'fixed-pos'
    $block.fadeIn()
    return

  $window = $(window)

  if $window.scrollTop() > 35
    showElem()
  else
    hideElem()

  $window.scroll ->
    if $(this).scrollTop() > 35
      showElem()
    else
      hideElem()
    return

  #loose focus on action button in table rows
  $('.table .btn-group a').click ->
    $(this).blur()
    return


  # Checkbox in tables should still be clickable
  $('.table tr td input[type="checkbox"]').click (event) ->
    event.stopPropagation()
    return

  #Revo slider
  $('.fullwidthbanner').revolution
    delay: 5000
    startheight: 400
    startwidth: 1350
    hideThumbs: 0
    thumbWidth: 170
    thumbHeight: 106
    thumbAmount: 3
    navigationType: 'none'
    navigationArrows: 'solo'
    navigationStyle: 'round'
    navigationHAlign: 'center'
    navigationVAlign: 'bottom'
    navigationHOffset: 0
    navigationVOffset: 0
    soloArrowLeftHalign: 'left'
    soloArrowLeftValign: 'center'
    soloArrowLeftHOffset: 0
    soloArrowLeftVOffset: 0
    soloArrowRightHalign: 'right'
    soloArrowRightValign: 'center'
    soloArrowRightHOffset: 0
    soloArrowRightVOffset: 0
    touchenabled: 'off'
    onHoverStop: 'off'
    stopAtSlide: -1
    stopAfterLoops: -1
    hideCaptionAtLimit: 0
    hideAllCaptionAtLilmit: 0
    hideSliderAtLimit: 0
    shadow: 1
    fullWidth: 'off'
    tpBannertimer: 'off'

  #3D-hover for iPhone, iPad, iPod
  $('.ch-item').on 'mouseenter mouseleave', (e) ->
    e.preventDefault()
    $(this).toggleClass 'hover'
    return
  $('.ch-second-item').on 'click mouseenter mouseleave', (e) ->
    e.preventDefault()
    $(this).toggleClass 'hover'
    return

  #Roundabout Slider
  $('#carousel').roundabout
    tilt: 0.4
    minScale: 0.5
    minOpacity: 1
    duration: 400
    easing: 'easeOutQuad'
    enableDrag: true
    dropEasing: 'easeOutBack'
    dragFactor: 2
    responsive: true

  #Bxslider Slider
  $('.appic-team').bxSlider
    pager: false
    minSlides: 1
    maxSlides: 4
    slideWidth: 270
    slideMargin: 30
    auto: true
    autoControls: false
    autoHover: true

  $('.bxslider').bxSlider
    pager: false
    minSlides: 2
    maxSlides: 4
    slideWidth: 270
    slideMargin: 30
  $('.bxslider').children().on 'mouseenter', (e) ->
    $('.bxslider').children().removeClass 'bxslider-active'
    $('.bxslider-description').children().removeClass 'description-active'
    number = parseInt($(this).addClass('bxslider-active').data('order'))
    $('.bxslider-description').children().eq(--number).addClass 'description-active'
    return

  $('.client-say-slider').bxSlider
    pager: false
    minSlides: 1
    maxSlides: 1
    slideWidth: 1200

  #Timeline
  $( ".timeline" ).timeLineG
    maxdis:280
    mindis:100
    wraperClass:'timeline-wrap'

  #Accordion Bootstrap
  $('.accordion').on 'show hide', (n) ->
    $(n.target).siblings('.accordion-heading').find('.accordion-toggle').toggleClass 'accordion-minus accordion-plus'
    return

  return

###### TURBOKLINKS EXPERIMENTS ######

# if typeof Turbolinks != 'undefined'
#   $(document).on("page:change", ->
#     ready());
# else
#   $(document).ready ->
#     ready();

# $(".btn-group a").each ->
#   $(this).attr 'data-no-turbolink', true
#   return

# $(document).on 'page:fetch', ->
#   $('.loading-indicator').show()
#   return
# $(document).on 'page:change', ->
#   $('.loading-indicator').hide()
#   return

###### TURBOKLINKS EXPERIMENTS ######
