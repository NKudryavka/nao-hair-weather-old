Jimp = require 'jimp'
fs = require 'fs'

dataPath = 'site/data/forecast.json'
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
]

data = JSON.parse fs.readFileSync dataPath

backSize =
  width: 894
  height: 767

iconSize =
  width: backSize.width * 7 / 100
  height: backSize.height * 9 / 100

Promise.all imageNames.map (img) -> Jimp.read "src/img/#{img}.png"
.then (images) ->
  back = images.shift()
  icons = {}
  for img, i in imageNames.slice 1
    icons[img] = images[i].scaleToFit iconSize.width, iconSize.height, Jimp.RESIZE_BICUBIC

  Promise.all ['font', 'small'].map (f) -> Jimp.loadFont "utils/font/#{f}.fnt"
  .then (fonts) ->
    forecastTime = ["#{time.slice(0, 10).replace /-/g, '/'} #{time.slice 11, 16} 時点の予報: #{cit.join ', '}" for time, cit of data.forecastTime].join '  '
    for forecast, day in data.forecast
      image = back.clone()
      image.print fonts[0], 50, 50, data.date[day].replace /-/g, '/'
      image.print fonts[1], 20, backSize.height - 60, forecastTime, backSize.width - 20*2
      for cityName, fc of forecast
        city = cities[cityName]
        image.composite icons[fc.icon], backSize.width*city.icon.x/100, backSize.height*city.icon.y/100
        image.print fonts[0], backSize.width*city.text.x/100, backSize.height*city.text.y/100 + 7, cityName
      image.rgba false
      image.write "site/img/forecast-day-#{day}.png"

.catch (err) ->
  console.log err