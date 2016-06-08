try
  require("source-map-support").install()

vm = require "vm"

clone = require "clone"
asyncReplace = require "async-replace"


objTypeof = (obj) -> Object.prototype.toString.call(obj)

escapeRegExp = (str) -> str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");


class ParserAsync
  constructor: (opts={})->
    {@sandbox=0, @ignore=0, @delimiter="`"} = opts
    @makePatt()

  Object.defineProperties @prototype,
    delimiter:
      get: -> #@_delimiter
        [@leftDelimiter, @rightDelimiter]
      set: (delimiter) ->
        #@_delimiter = @leftDelimiter = @rightDelimiter = del; @makePatt()
        if objTypeof(delimiter) == "[object String]"
          @leftDelimiter = @rightDelimiter = delimiter
        else if objTypeof(delimiter) == "[object Array]" and delimiter.length == 2
          [@leftDelimiter, @rightDelimiter] = delimiter
        else
          throw new TypeError("delimiter must be an string or list with 2 items")

  #makePatt: ()-> @_patt = /`([^`]*?)`/g
  makePatt: (delimiter=@delimiter) =>
    delimiter = delimiter.map escapeRegExp
    @_patt = new RegExp "#{delimiter[0]}(.*?)#{delimiter[1]}", "g"

  evalCodeInContext: (context, code) => new vm.Script(code).runInNewContext(context)

  handleCode: (code, context, callback) =>
    try
      res = @evalCodeInContext context, code
      callback?(null, res)
    catch err
      callback? err

  parseTemplate: (strg, _context, opts..., callback) =>
    opts = opts[0] or {}
    {sandbox=@sandbox, ignore=@ignore, delimiter=@delimiter} = opts

    if objTypeof(delimiter) == "[object String]"
      delimiter = [delimiter, delimiter]
    else if not(objTypeof(delimiter) == "[object Array]" and delimiter.length == 2)
      return callback( new TypeError("delimiter must be an string or list with 2 items") )

    patt = @makePatt( delimiter )

    errors = []
    replacer = (match, p1, o, strg, cb) =>
      context = if sandbox then clone(_context) else _context
      @handleCode p1, context, (err, res) ->
        if err
          errors.push err
        if ignore
          cb(null, res)
        else
          cb(err, res)

    asyncReplace strg, patt, replacer, (err, res) ->
      err or= errors or undefined
      callback?(err, res)


class ParserSync extends ParserAsync
  handleCode: (code, context) =>
    return @evalCodeInContext context, code
  parseTemplate: (strg, _context, opts={}) =>
    {sandbox=@sandbox, delimiter=@delimiter} = opts

    if objTypeof(delimiter) == "[object String]"
      delimiter = [delimiter, delimiter]
    else if not(objTypeof(delimiter) == "[object Array]" and delimiter.length == 2)
      throw new TypeError("delimiter must be an string or list with 2 items")

    patt = @makePatt(delimiter)

    replacer = (match, p1, o, strg) =>
      context = if sandbox then clone(_context) else _context
      @handleCode p1, context

    strg.replace patt, replacer


module.exports = new ParserSync().parseTemplate
module.exports.ParserAsync = ParserAsync
module.exports.ParserSync = ParserSync
module.exports.Parser = ParserSync
