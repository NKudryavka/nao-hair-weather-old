Jimp = require 'jimp'
fs = require 'fs'

dataPath = 'site/data/forecast.json'
scale = 1.5
imageNames = [
  'map42-2ns',

  'sunny',
  'cloudy',
  'rainy',

  'sunny-to-cloudy',
  'sunny-to-rainy',
  'cloudy-to-sunny',
  'cloudy-to-rainy',
  'rainy-to-sunny',
  'rainy-to-cloudy',

  'sunny-occ-cloudy',
  'sunny-occ-rainy',
  'cloudy-occ-sunny',
  'cloudy-occ-rainy',
  'rainy-occ-sunny',
  'rainy-occ-cloudy',

  'stormy',
  'unknown',
]

legends =
  '晴れ':
    icon: 'sunny'
    x: 30
    y: 5
  '曇り':
    icon: 'cloudy'
    x: 30
    y: 15
  '雨':
    icon: 'rainy'
    x: 30
    y: 25
  '晴のち雨':
    icon: 'sunny-to-rainy'
    x: 47
    y: 5
  '晴時々雨':
    icon: 'sunny-occ-rainy'
    x: 47
    y: 15

data = JSON.parse fs.readFileSync dataPath

backSize =
  width: 894 * scale
  height: 767 * scale

iconSize =
  width: backSize.width * 7 / 100
  height: backSize.height * 9 / 100

pos = 
  x: (percent) -> backSize.width * percent / 100
  y: (percent) -> backSize.height * percent / 100 + 10

Promise.all imageNames.map (img) -> Jimp.read "src/img/#{img}.png"
.then (images) ->
  back = images.shift().scale scale
  icons = {}
  for img, i in imageNames.slice 1
    icons[img] = images[i].scaleToFit iconSize.width, iconSize.height, Jimp.RESIZE_BICUBIC

  Promise.all ['font', 'small'].map (f) -> Jimp.loadFont "utils/font/#{f}.fnt"
  .then (fonts) ->
    forecastTime = ("#{time.slice(0, 10).replace /-/g, '/'} #{time.slice 11, 16} 時点の予報: #{cit.join ', '}" for time, cit of data.forecastTime).join ' / '
    for forecast, day in data.forecast
      image = back.clone()
      # 予報時刻
      image.print fonts[0], 75, 75, data.date[day].replace /-/g, '/'
      image.print fonts[1], 20, backSize.height - 60, forecastTime, backSize.width - 20*2

      # 凡例
      for name, val of legends
        image.composite icons[val.icon], pos.x(val.x), pos.y(val.y)
        image.print fonts[0], pos.x(val.x+8), pos.y(val.y+3), name
      for cityName, fc of forecast
        city = cities[cityName]
        image.composite (icons[fc.icon] or icons.unknown), pos.x(city.icon.x), pos.y(city.icon.y)
        image.print fonts[0], pos.x(city.text.x), pos.y(city.text.y)+8, cityName
      image.rgba false
      image.write "site/img/forecast-day-#{day}.png"

.catch (err) ->
  console.log err