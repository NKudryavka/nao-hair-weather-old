$ ->
  aspectRatio = 0.85794183
  dataPath = 'data/forecast.json'

  days = []
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
    hash = '#day-0' unless hash
    $('.icon').stop().fadeOut(400)
    $(".#{hash.slice(1)}").fadeIn(400).tooltip html: true

  selecter.on 'change', (event) ->
    location.hash = $(event.target).val()

  $(window).on 'hashchange', ->
    changeIcon location.hash

  showIcons = ->
    for name, pos of cities
      canvas.append $("<span class=\"area\">#{name}</span>").css left: "#{pos.text.x}%", top: "#{pos.text.y}%"
      for day in days
        icon = icons[forecast[day][name].weather.icon].clone().hide()
        temp = forecast[day][name].temperature
        icon.attr 'title', "#{icon.attr('title')}<br>最高気温 #{if temp.max? then temp.max else '-'}度<br>最低気温 #{if temp.min then temp.min else '-'}度"
        icon.css left: "#{pos.icon.x}%", top: "#{pos.icon.y}%"
        canvas.append icon.addClass("day-#{day}").addClass('icon')
        
  onLoadAll = ->
    showIcons()
    changeIcon location.hash
    selecter.find("[value=#{if location.hash then location.hash.slice(1) else 'day-0'}]").prop('checked', true)
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
      days = [0...data.date.length]
      for date, d in data.date
        selecter.children().eq(d).append date.replace /-/g, '/'
      selecter.css 'opacity', 1
      cover.hide()
      forecast = data.forecast

      iconNameToImage = (img) ->
        $(new Image())
        .on 'load', -> loadCount += 1
        .addClass 'icon'
        .attr 'src', if img.src.startsWith('http') then img.src else "img/#{img.src}.png"
        .attr 'alt', img.alt
        .data 'toggle', 'tooltip'
        .data 'placement', 'top'
        .attr 'title', img.alt

      for img in data.iconList
        icons[img.src] = iconNameToImage img

      loadLoop = ->
        if loadCount >= data.iconList.length
          onLoadAll()
        else
         setTimeout loadLoop, 10
      loadLoop()

  startLoading()
