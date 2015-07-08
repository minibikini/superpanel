watchify = require 'watchify'
browserify = require 'browserify'
gulp = require 'gulp'
gutil = require 'gulp-util'
notify = require('gulp-notify')
source = require 'vinyl-source-stream'
livereload = require 'gulp-livereload'

production = process.env.NODE_ENV is 'production'

EXTERNALS = [
  'react'
  'react-router'
  # 'alt'
  # 'iso'
  'moment'
  'numeral'
  'lodash'
  'es6-promise'
  'isomorphic-fetch'
  'classnames'
  'react-pager'
  'react-simple-table'
  'inflecto'
  'newforms'
  'react-d3'
  'qs'
]

BASES =
  src: '../client'
  build: 'public/js'

getBundler = (entry) ->
  bundler = browserify
    cache: {}
    packageCache: {}
    fullPaths: global.isWatching
    entries: ["./#{entry}"]
    extensions: ['.js', '.coffee', '.cjsx']
    # insertGlobals: yes
    debug: !production
    # transform: ['coffeeify']

  EXTERNALS.forEach (lib) ->
    bundler.external lib.expose or lib.file or lib

  bundler

getBundle = (entry) ->
  bundler = getBundler entry

  bundle = ->
    if global.isWatching
      gutil.log "Start bundling `#{entry}`..."
      timeBegin = Date.now()

    bundler.bundle()
      .on 'error', notify.onError
        title: "Browserify Error"
        emitError: yes
      .on 'error', (err) ->
        console.log err
        @emit 'end'
      .pipe source "#{entry}.js"
      .pipe gulp.dest 'public/js/'
      .on 'end', ->
        if global.isWatching
          gutil.log "Done bundle `#{entry}` in #{Date.now() - timeBegin} ms"
      .pipe livereload()

  {bundle, bundler}


gulp.task "client", ['browserify:vendor'], ->
  {bundle, bundler} = getBundle 'client'

  if global.isWatching
    watchify(bundler).on 'update', bundle

  bundle()


gulp.task 'browserify:vendor', ->
  browserify(debug: false)
    .require EXTERNALS
    .bundle()
    .on 'error', notify.onError
      title: "Browserify Error"
      emitError: yes
    .pipe source 'vendor.js'
    .pipe gulp.dest "#{BASES.build}/"
