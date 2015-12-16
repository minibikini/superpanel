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


module.exports =
  get: (path) -> _.get @, path

  image: (schema, row, opts) ->
    <img src={_.get row, opts._path} />

  money: (schema, row, opts) ->
    path = opts.path or opts._path
    "#{_.get row, path} #{getCurrencySymbol opts.currency}"

  date: (schema, row, opts) ->
    path = opts.path or opts._path
    displayFormat = opts.displayFormat or 'lll'
    moment(_.get(row, path)).format(displayFormat)

  pre: (schema, row, opts) ->
    path = opts.path or opts._path

    value = if path
      _.get row, opts._path
    else
      row

    <pre>{value}</pre>