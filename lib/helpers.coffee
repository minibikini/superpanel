
module.exports =
  copyObject: (input) ->
    output = {}
    output[key] = val for key, val of input
    output
