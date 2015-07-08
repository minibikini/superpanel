requireDirectory = require('require-directory')
gulp = require('gulp')
minifyCss = require 'gulp-minify-css'
gulps = ['sass', 'concat', 'uglify', 'livereload', 'notify']
global[name] = require "gulp-#{name}" for name in gulps

global.isWatching = no

requireDirectory module, './gulp/'

gulp.task 'sass', ->
  scssPath = ['./client/scss/**/*.scss']

  gulp.src scssPath
  .pipe sass
    includePaths: ['./public/bower_components/foundation-apps/scss/', './public/bower_components/font-awesome/scss/']
  .on 'error', notify.onError
    title: "Browserify Error"
    emitError: yes
  .on 'error', (err) ->
    @emit 'end'

  .pipe gulp.dest './public/css'
  .pipe(livereload())

gulp.task 'setWatch', ->
  livereload.listen()
  global.isWatching = yes

gulp.task 'watch', ['setWatch', 'default'],  ->
  gulp.watch './client/scss/**/*.scss', ['sass']
  # gulp.watch ['./views/**/*.jade', './public/js/**/*.js'], (file) ->
  #   livereload.reload file.path

# gulp.task 'default', ['sass', 'client', 'minify']
gulp.task 'default', ['sass', 'client']

gulp.task 'minify-css', ['sass'],  ->
  gulp.src './public/css/client.css'
  .pipe concat 'bundle.min.css'
  .pipe minifyCss()
  .pipe gulp.dest './public/css'

gulp.task "minify:app", ['client'], ->
  gulp.src ['./public/js/vendor.js', "./public/js/app.js"]
  .pipe concat "#{bundle}.min.js"
  .pipe uglify outSourceMap: no
  .pipe gulp.dest './public/js'

gulp.task 'minify', ['minify-css','minify:app']
