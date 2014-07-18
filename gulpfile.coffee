path       = require 'path'
gulp       = require 'gulp'
gutil      = require 'gulp-util'
jade       = require 'gulp-jade'
stylus     = require 'gulp-stylus'
CSSmin     = require 'gulp-minify-css'
browserify = require 'gulp-browserify'
rename     = require 'gulp-rename'
ngmin      = require 'gulp-ngmin'
uglify     = require 'gulp-uglify'
coffeeify  = require 'coffeeify'
nodeStatic = require 'node-static'
lr         = require 'tiny-lr'
livereload = require 'gulp-livereload'
reloadServer = lr()

compileCoffee = (debug = true) ->

  config =
    debug: debug
    transform: ['coffeeify']
    shim:
      'jquery':
        path:    './vendor/jquery/dist/jquery.js'
        exports: '$'
      'jquery-ui-core':
        path:    './vendor/jquery-ui/ui/jquery.ui.core.js'
        exports: '$'
        depends:
          'jquery': '$'
      'jquery-ui-widget':
        path: './vendor/jquery-ui/ui/jquery.ui.widget.js'
        exports: '$'
        depends:
          'jquery': '$'
          'jquery-ui-core': '$'
      'jquery-ui-mouse':
        path: './vendor/jquery-ui/ui/jquery.ui.mouse.js'
        exports: '$'
        depends:
          'jquery': '$'
          'jquery-ui-core': '$'
          'jquery-ui-widget': '$'
      'jquery-ui-draggable':
        path: './vendor/jquery-ui/ui/jquery.ui.draggable.js'
        exports: '$'
        depends:
          'jquery': '$'
          'jquery-ui-core': '$'
          'jquery-ui-widget': '$'
          'jquery-ui-mouse': '$'
      'jquery-ui-droppable':
        path: './vendor/jquery-ui/ui/jquery.ui.droppable.js'
        exports: '$'
        depends:
          'jquery': '$'
          'jquery-ui-core': '$'
          'jquery-ui-widget': '$'
          'jquery-ui-mouse': '$'
      'jquery-ui-resizable':
        path: './vendor/jquery-ui/ui/jquery.ui.resizable.js'
        exports: '$'
        depends:
          'jquery': '$'
          'jquery-ui-core': '$'
          'jquery-ui-widget': '$'
          'jquery-ui-mouse': '$'
      'angular':
        path: './vendor/angular/angular.js'
        exports: 'angular'
      'angular-route':
        path: './vendor/angular-route/angular-route.js'
        exports: 'ngRoute'
      'leaflet':
        path: './vendor/leaflet-dist/leaflet.js'
        exports: 'L'
      'angular-leaflet-directive':
        path: './vendor/angular-leaflet-directive/dist/angular-leaflet-directive.js'
        exports: 'angular'
        depends:
          'angular': 'angular'
          'leaflet': 'L'
  bundle = gulp
    .src('./src/coffee/main.coffee', read: false)
    .pipe(browserify(config))
    .pipe(rename('bundle.js'))

  bundle.pipe(ngmin()).pipe(uglify()) unless debug

  bundle
    .pipe(gulp.dest('./public/js/'))
    .pipe(livereload(reloadServer))

compileJade = (debug = false) ->
  gulp
    .src('src/jade/*.jade')
    .pipe(jade(pretty: debug))
    .pipe(gulp.dest('public/'))
    .pipe livereload(reloadServer)

  gulp
    .src('src/coffee/**/*.jade')
    .pipe(jade(pretty: debug))
    .pipe(gulp.dest('public/partials'))
    .pipe livereload(reloadServer)

compileStylus = (debug = false) ->
  styles = gulp
    .src('src/stylus/style.styl')
    .pipe(stylus('include css': true))

  styles.pipe(CSSmin()) unless debug

  styles.pipe(gulp.dest('public/css/'))
    .pipe livereload reloadServer

# Build tasks
gulp.task "jade-production", -> compileJade()
gulp.task 'stylus-production', ->compileStylus()
gulp.task 'coffee-production', -> compileCoffee()

# Development tasks
gulp.task "jade", -> compileJade(true)
gulp.task 'stylus', -> compileStylus(true)
gulp.task 'coffee', -> compileCoffee(true)

gulp.task 'copy-files', ->
  gulp.src('src/images/*')
    .pipe(gulp.dest('public/images'))

  gulp.src('vendor/leaflet-dist/leaflet.css')
    .pipe(gulp.dest('public/vendor/leaflet'))

  gulp.src('vendor/leaflet-dist/images/*')
    .pipe(gulp.dest('public/vendor/leaflet/images'))

  gulp.src('vendor/jquery-ui/themes/smoothness/jquery-ui.min.css')
    .pipe(gulp.dest('public/css'))

  gulp.src('vendor/jquery-ui/themes/smoothness/images/*')
    .pipe(gulp.dest('public/css/images'))


gulp.task "server", ->
  require('./server').listen 9001

gulp.task "watch", ->
  reloadServer.listen 35729, (err) ->
    console.error err if err?

    gulp.watch "src/coffee/**/*.coffee", ->
      gulp.run "coffee"

    gulp.watch "src/coffee/**/*.jade", ->
      gulp.run "jade"

    gulp.watch "src/jade/*.jade", ->
      gulp.run "jade"

    gulp.watch "src/stylus/*.styl", ->
      gulp.run "stylus"

gulp.task "build", ->
  gulp.run "coffee-production", "jade-production", "stylus-production", "copy-files"

gulp.task "default", ->
  gulp.run "coffee", "jade", "stylus", "watch", "server", "copy-files"
