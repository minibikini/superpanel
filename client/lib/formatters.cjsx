_ = require 'lodash'
moment = require 'moment'
# config = require '../config/config'
# {Link} = require 'react-router'

getCurrencySymbol = (currency = "THB") ->
  switch currency
    when 'USD','ARS', 'BSD', 'BBD', 'BZD', 'BRL', 'BND', 'CAD', 'KYD', 'CLP', 'COP', 'DOP', 'SVC', 'FJD', 'GYD','HKD', 'JMD', 'LRD', 'MXN', 'NAD', 'NZD', 'NIO', 'SGD', 'SBD', 'SRD','TWD', 'TTD', 'ZWD'
      '$'
    when 'EGP', 'FKP', 'GIP', 'GGP','IMP','JEP','LBP', 'SHP', 'SYP', 'GBP' then '£'
    when 'CNY', 'JPY' then '¥'
    when 'CRC' then '₡'
    when 'CUP', 'PHP' then '₱'
    when 'EUR' then '€'
    when 'GHC' then '¢'
    when 'ILS' then '₪'
    when 'KPW', 'KRW' then '₩'
    when 'LAK' then '₭'
    when 'MNT' then '₮'
    when 'NGN' then '₦'
    when 'INR', 'SCR', 'LKR' then '₹'
    when 'THB' then '฿'
    when 'TRL' then '₤'
    when 'UAH' then '₴'
    else currency


formatters =
  get: (path) -> _.get @, path

  image: (schema, row, opts) ->
    src = _.get row, opts.path
    if _.isEmpty(src)
      <span style={color:'#666'}>N/A</span>
    else
      <img src={_.get row, opts.path} />

  money: (schema, row, opts) ->
    "#{_.get row, opts.path}#{getCurrencySymbol opts.currency}"

  boolean: (schema, row, opts) ->
    if _.get(row, opts.path)
      <span className="boolean-value-true">&#10004;</span>
    else
      <span>&#10060;</span>

  string: (schema, row, opts) ->
    value = _.get(row, opts.path)
    if _.isEmpty(value) then <span style={color:'#666'}>N/A</span> else value

  null: (schema, row, opts) ->
    <span style={color:'#666'}>null</span>

  date: (schema, row, opts) ->
    displayFormat = opts.displayFormat or 'lll'
    moment(_.get(row, opts.path)).format(displayFormat)

  datetime: (schema, row, opts) ->
    formatters.date schema, row, opts

  pre: (schema, row, opts) ->
    value = if opts.path
      _.get row, opts.path
    else
      row

    <pre>{value}</pre>


module.exports = formatters