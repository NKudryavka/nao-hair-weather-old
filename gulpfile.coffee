gulp = require 'gulp'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'
pug = require 'gulp-pug'
cson = require 'gulp-cson'
plumber = require 'gulp-plumber'

path = 
  coffee: ['src/coffee/datas/*.coffee', 'src/coffee/*.coffee']
  pug: 'src/pug/*.pug'
  cson: 'src/cson/*.cson'
  css: 'src/css/*.css'
  img: 'src/img/*.png'

gulp.task 'build:js', ->
  gulp.src path.coffee 
    .pipe plumber()
    .pipe concat('index.coffee') 
    .pipe coffee() 
    .pipe gulp.dest('site/js/')

gulp.task 'build:html', ->
  gulp.src path.pug 
    .pipe plumber() 
    .pipe pug()
    .pipe gulp.dest('site/')

gulp.task 'build:json', ->
  gulp.src path.cson
    .pipe plumber()
    .pipe cson()
    .pipe gulp.dest('site/data/')

gulp.task 'build:css', ->
  gulp.src path.css
    .pipe gulp.dest('site/css/')

gulp.task 'build:img', ->
  gulp.src path.img
    .pipe gulp.dest('site/img/')

gulp.task 'watch:js',  ->
  gulp.watch path.coffee, ['build:js']

gulp.task 'watch:html', ->
  gulp.watch path.pug, ['build:html']

gulp.task 'watch:json', ->
  gulp.watch path.cson, ['build:json']

gulp.task 'watch:css', ->
  gulp.watch path.css, ['build:css']