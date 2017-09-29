$ ->
  aspectRatio = 0.85794183
  dataPath = 'data/forecast.json'
  days = [0, 1, 2]

  canvas = $('#canvas')
  cover = $('#loading-cover')
  selecter = $('#day-selecter')
  icons = {}
  forecast = {}
  loadCount = 0;
  onResize = ->
    canvas.height canvas.width() * aspectRatio
    canvas.css 'font-size', canvas.width()
  $(window).on 'resize', onResize
  onResize()

  changeIcon = (hash) ->
    $('.icon').stop().fadeOut(400)
    $(".#{hash.slice(1)}").fadeIn(400)

  selecter.on 'change', (event) ->
    location.hash = $(event.target).val()

  $(window).on 'hashchange', ->
    changeIcon location.hash

  showIcons = (multiplyer) ->
    for name, pos of cities
      canvas.append $("<span class=\"area\">#{name}</span>").css left: "#{pos.text.x}%", top: "#{pos.text.y}%"
      for day in days
        icon = icons[forecast[day][name].icon].clone().hide()
        icon.css left: "#{pos.icon.x}%", top: "#{pos.icon.y}%"
        canvas.append icon.addClass("day-#{day}").addClass('icon')
        
  onLoadAll = ->
    showIcons()
    location.hash = '#day-0' unless location.hash.length == '#day-0'.length
    changeIcon location.hash
    selecter.find("[value=#{location.hash.slice(1)}]").prop('checked', true)
      .parent().addClass("active")

  failCount = 0
  startLoading = ->
    $.getJSON dataPath
    .fail (err) ->
      failCount += 1
      if failCount < 3
        startLoading()
      else
        cover.children('span').text '予報データの読み込みに失敗しました。'
        console.log err
    .done (data) ->
      cover.hide()
      forecast = data.forecast

      iconNameToImage = (name) ->
        $(new Image())
        .on('load', -> loadCount += 1)
        .addClass('icon')
        .attr('src', if name.startsWith('http') then name else "img/#{name}.png")

      for name in data.iconList
        icons[name] = iconNameToImage name

      loadLoop = ->
        if loadCount >= data.iconList.length
          onLoadAll()
        else
         setTimeout loadLoop, 10
      loadLoop()

  startLoading()
