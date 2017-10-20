rp = require 'request-promise'
fs = require 'fs'
path = require 'path'
process = require 'process'

savePath = 'site/data/forecast.json'
baseUrl = 'http://weather.livedoor.com/forecast/webservice/json/v1?city='
cityCodes = [
  '012010', # 旭川
  '014020', # 釧路
  '016010', # 札幌
  '020010', # 青森
  '050010', # 秋田
  '040010', # 仙台
  '150010', # 新潟
  '090010', # 宇都宮
  '130010', # 東京
  '200010', # 長野
  '170010', # 金沢
  '230010', # 名古屋
  '270000', # 大阪
  '320010', # 松江
  '340010', # 広島
  '370000', # 高松
  '390010', # 高知
  '340010', # 広島
  '400010', # 福岡
  '460010', # 鹿児島
  '471010', # 那覇
]

weatherReplaceTable = [
  ['暴風雨', 'stormy'],
  [/晴れ?/, 'sunny'],
  [/曇り?/, 'cloudy'],
  ['雨', 'rainy'],
  ['時々', '-occ-'],
  ['のち', '-to-'],
]

result = 
  forecast: [{}, {}]
  iconList: []
  forecastTime: {}
  date: []

saveDir = path.dirname savePath
unless fs.existsSync saveDir
  fs.mkdirSync saveDir

parseWeather = (image) ->
  title = image.title
  title = title.replace.apply title, rep for rep in weatherReplaceTable
  if /^[a-z-]+$/.test title
    icon: title
  else
    icon: image.url

Promise.all (rp(baseUrl + code) for code in cityCodes)
.then (forecasts) ->
  forecasts = forecasts.map JSON.parse

  for forecast in forecasts
    city = forecast.location.city
    if result.forecastTime[forecast.publicTime]?
      result.forecastTime[forecast.publicTime].push city
    else
      result.forecastTime[forecast.publicTime] = [city]

    for daily, day in forecast.forecasts.slice(-2)
      unless result.date[day]?
        result.date[day] = daily.date
      else if result.date[day] != daily.date
        console.log 'unmatching date'
        process.exit(1)

      weather = parseWeather daily.image
      result.forecast[day][city] = weather
      unless weather.icon in result.iconList.map((v) -> v.src)
        result.iconList.push
          src: weather.icon
          alt: daily.image.title

  fs.writeFileSync savePath, JSON.stringify result

.catch (err) ->
  console.log err
