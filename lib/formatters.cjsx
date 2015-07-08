_ = require 'lodash'
config = require '../config/config'

{Link} = require 'react-router'


getCurrencySymbol = (currency) ->
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

  username: (schema, row, opts) ->
    user = _.get row, opts.path
    user.email or user.firstName + user.firstLast

  image: (schema, row, opts) ->
    <img src={_.get row, opts._path} />

  money: (schema, row, opts) ->
    path = opts.path or opts._path
    "#{_.get row, path} #{getCurrencySymbol opts.currency or config.currency}"

  userFullName: (schema, row, opts) ->
    path = opts.path or opts._path
    user = if path then _.get row, path else row
    user.fullName or "#{user.firstName or ''} #{user.lastName or ''}"

  username: (schema, row, opts) ->
    path = opts.path or opts._path
    user = if path then _.get row, path else row
    user.email or user.fullName or "#{user.firstName or ''} #{user.lastName or ''}"

  orderStatus: (schema, row, opts) ->
    switch row.status
      when 'paid' then <span className="success label">Paid</span>
      when 'failed' then <span className="alert label">Failed</span>
      when 'new' then <span className="warning label">New</span>

  orderTopupStatus: (schema, row, opts) ->
    unless row.topup?.status?
      return <span className="warning label">N/A</span>

    switch row.topup.status.toLowerCase()
      when 'success' then <span className="success label">Success</span>
      when 'failed' then <span className="alert label">Failed</span>

  rTopupStatus: (schema, row, opts) ->
    switch row.status
      when 'active' then <span className="success label">Active</span>
      when 'paused' then <span className="secondary label">Paused</span>
      else <span className="warning">N/A</span>
