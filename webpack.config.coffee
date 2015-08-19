path = require('path')
webpack = require('webpack')
_ = require 'lodash'
ExtractTextPlugin = require("extract-text-webpack-plugin")

isProd = process.env.NODE_ENV is 'production'

publicJsPath = path.join(__dirname, "public/build")
{projectRoot} = require './lib/cli.js'
customViewsPath = path.resolve projectRoot, './client'
customResourcesPath = path.resolve projectRoot, './resources'

definePlugin = new webpack.DefinePlugin
  __DEV__: JSON.stringify(JSON.parse(process.env.BUILD_DEV || 'true')),
  __PRERELEASE__: JSON.stringify(JSON.parse(process.env.BUILD_PRERELEASE || 'false'))
  __CUSTOM_VIEWS_PATH__: JSON.stringify customViewsPath
  __CUSTOM_RESOURCES_PATH__: JSON.stringify customResourcesPath

sassOpts = ""
for dir in ["foundation-apps/scss/", "font-awesome/scss/"]
  sassOpts += "includePaths[]=#{__dirname}/public/bower_components/#{dir}&"

commonConfig =
  output:
    path: publicJsPath
    filename: 'bundle.js'
    publicPath: '/build/'

  resolveLoader:
    modulesDirectories: [__dirname + '/node_modules', 'node_modules']

  resolve:
    extensions: ['', '.jsx', '.js', '.cjsx', '.coffee']

  module:
    loaders: [
      # { test: /\.css$/, loaders: ['style', 'css']},
      { test: /\.scss$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader!sass-loader?#{sassOpts}")},
      { test: /\.cjsx$/, loaders: ['react-hot', 'coffee', 'cjsx']},
      { test: /\.jsx$/, loaders: ['react-hot', 'babel']},
      { test: /\.json$/, loader: 'json'}
      { test: /\.coffee$/, loaders: ['react-hot', 'coffee'] }
      # { test: /\.cjsx$/, loaders: ['coffee', 'cjsx']},
      # { test: /\.jsx$/, loaders: ['babel']},
      # { test: /\.coffee$/, loaders: ['coffee'] },
      {
        test: /\.woff(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=application/font-woff"
      }, {
        test: /\.woff2(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=application/font-woff"
      }, {
        test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=application/octet-stream"
      }, {
        test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
        loader: "file"
      }, {
        test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url?limit=10000&mimetype=image/svg+xml"
      }
    ]


devConfig =
  entry: [
    "#{__dirname}/node_modules/webpack-dev-server/client?http://localhost:8181",
    "#{__dirname}/node_modules/webpack/hot/only-dev-server",
    "#{__dirname}/client/index"
  ]
  devtool: "eval"
  debug: true
  preprocessors:
    "#{publicJsPath}/bundle.js": ['webpack', 'sourcemap']

  plugins: [
    new webpack.HotModuleReplacementPlugin()
    new webpack.NoErrorsPlugin()
    new webpack.IgnorePlugin(/vertx/)
    new ExtractTextPlugin("bundle.css")
    definePlugin
  ]

prodConfig =
  entry: [
    "#{__dirname}/client/index"
  ]
  debug: no

  plugins: [
    new ExtractTextPlugin("bundle.css")
    new webpack.NoErrorsPlugin()
    new webpack.IgnorePlugin(/vertx/)
    definePlugin
    new webpack.optimize.DedupePlugin()
    new webpack.optimize.UglifyJsPlugin(sourceMap: no)
  ]

module.exports = if isProd
  _.defaults prodConfig, commonConfig
else
  _.defaults devConfig, commonConfig