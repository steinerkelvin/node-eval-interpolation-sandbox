chai = require 'chai'
assert = chai.assert
expect = chai.expect

{ParserAsync, ParserSync} = require('../index')

# TODO: overlaping delimiters


describe 'default', ->
  parseTemplate = require('../index')

  it 'should replace a simple variable', ->
    res = parseTemplate "`name`", name: "John"
    expect(res).to.equal "John"
  it 'should run JS code', ->
    res = parseTemplate "`name.join(' ')`", name:["John", "Stewart"]
    expect(res).to.equal "John Stewart"
  it 'should share context', ->
    res = parseTemplate "`i++` - `i++` - `i++`", i: 0
    expect(res).to.equal "0 - 1 - 2"
  it 'should share context between calls', ->
    context = i: 0
    res = parseTemplate "`i++` - `i++` - `i++`", context
    expect(res).to.equal "0 - 1 - 2"
    res = parseTemplate "`i++` - `i++` - `i++`", context
    expect(res).to.equal "3 - 4 - 5"
  it 'should sandbox context if enabled', ->
    res = parseTemplate "`i++` - `i++` - `i++`", i: 0, {sandbox: 1}
    expect(res).to.equal "0 - 0 - 0"


describe 'ParserAsync', ->
  Parser = ParserAsync

  it 'should throw error', (done) ->
    parser = new Parser(  )

    parser.parseTemplate "`notDef`/`def`", def: "Bazinga", (err,res)->
      expect(err.constructor.name).to.be.equal "ReferenceError"
      expect(res).to.equal undefined
      done()

  it 'should ignore errors if enabled (default)', (done) ->
    parser = new Parser( {ignore: 1} )

    parser.parseTemplate "{`notDef`}{`def`}{`obj.def`}{`obj.notDef.prop`}", def: "Bazinga", obj: def:42 , (err,res)->
      expect(err).to.have.length 2
      expect(err[0].constructor.name).to.be.equal "ReferenceError"
      expect(err[1].constructor.name).to.be.equal "TypeError"
      expect(res).to.equal "{}{Bazinga}{42}{}"
      done()

  it 'should ignore errors if enabled', (done) ->
    parser = new Parser()

    parser.parseTemplate "`notDef`/`def`/`obj.notDef.prop`", def: "Bazinga", {ignore: 1}, (err,res)->
      expect(err).to.have.length 2
      expect(res).to.equal "/Bazinga/"
      done()

  describe 'default', ->
    parseTemplate = new Parser().parseTemplate

    it 'should replace a simple variable', (done) ->
      parseTemplate "`name`", name: "John", (err, res)->
        expect(res).to.equal "John"
        done()
    it 'should run JS code', (done) ->
      parseTemplate "`name.join(' ')`", name:["John", "Stewart"], (err, res)->
        expect(res).to.equal "John Stewart"
        done()
    it 'should share context', (done) ->
      parseTemplate "`i++` - `i++` - `i++`", i: 0, (err, res)->
        expect(res).to.equal "0 - 1 - 2"
        done()
    it 'should share context between calls', (done) ->
      context = i: 0
      parseTemplate "`i++` - `i++` - `i++`", context, (err, res)->
        expect(res).to.equal "0 - 1 - 2"
        parseTemplate "`i++` - `i++` - `i++`", context, (err, res)->
          expect(res).to.equal "3 - 4 - 5"
          done()
    it 'should sandbox context if enabled', (done) ->
      parseTemplate "`i++` - `i++` - `i++`", i: 0, {sandbox: 1}, (err, res)->
        expect(res).to.equal "0 - 0 - 0"
        done()

  describe 'custom default delimiter', ->
    it 'should replace a simple variable', (done) ->
      parser = new Parser( {delimiter: "\'"} )

      parser.parseTemplate "\'name\'", name: "John", (err,res)->
        expect(res).to.equal "John"
        done()

    it 'should replace a simple variable (set by prop)', (done) ->
      parser = new Parser()
      parser.delimiter = "\'"

      parser.parseTemplate "\'name\'", name: "John", (err,res)->
        expect(res).to.equal "John"
        done()

    it 'should throw TypeError', (done) ->
      try
        parser = new Parser( {delimiter: 2} )
      catch err
        expect(err.constructor.name).to.be.equal "TypeError"
        done()

  describe 'custom default delimiters', ->
    it 'should replace a simple variable', (done) ->
      parser = new Parser( {delimiter: ["\#{", "}"]} )

      parser.parseTemplate "\#{name}", name: "John", (err,res)->
        expect(res).to.equal "John"
        done()

    it 'should replace a simple variable (set by prop)', (done) ->
      parser = new Parser()
      parser.leftDelimiter = "\#{"
      parser.rightDelimiter = "}"

      parser.parseTemplate "\#{name}", name: "John", (err,res)->
        expect(res).to.equal "John"
        done()

    it 'should work with regex reserved characters', (done) ->
      parser = new Parser( {delimiter: ["(", ")"]} )

      parser.parseTemplate "(name)", name: "John", (err,res)->
        expect(res).to.equal "John"
        done()

  describe 'custom delimiter', ->
    it 'should replace a simple variable', (done) ->
      parser = new Parser()

      parser.parseTemplate "\'name\'", name: "John", {delimiter: "\'"}, (err,res)->
        expect(res).to.equal "John"
        done()

    it 'should throw TypeError', (done) ->
      parser = new Parser()
      parser.parseTemplate "\'name\'", name: "John", {delimiter: 2}, (err,res)->
        expect(err.constructor.name).to.be.equal "TypeError"
        expect(res).to.equal undefined
        done()

  describe 'custom delimiters', ->
    it 'should replace a simple variable', (done) ->
      parser = new Parser()

      parser.parseTemplate "\#{name}", name: "John", {delimiter: ["\#{", "}"]}, (err,res)->
        expect(res).to.equal "John"
        done()

    it 'should work with regex reserved characters', (done) ->
      parser = new Parser()

      parser.parseTemplate "(name)", name: "John", {delimiter: ["(", ")"]}, (err,res)->
        expect(res).to.equal "John"
        done()

describe 'ParserSync', ->
  Parser = ParserSync

  it 'should throw error', ->
    parser = new Parser(  )

    try
      res = parser.parseTemplate "`notDef`/`def`", def: "Bazinga"
      expect(res).to.equal undefined
    catch err
      expect(err.constructor.name).to.be.equal "ReferenceError"

  describe 'default', ->
    parseTemplate = new Parser().parseTemplate

    it 'should replace a simple variable', ->
      res = parseTemplate "`name`", name: "John", (err,res)->
      expect(res).to.equal "John"

    it 'should run JS code', ->
      res = parseTemplate "`name.join(' ')`", name:["John", "Stewart"], (err,res)->
      expect(res).to.equal "John Stewart"

    it 'should share context', ->
      res = parseTemplate "`i++` - `i++` - `i++`", i: 0
      expect(res).to.equal "0 - 1 - 2"

    it 'should share context between calls', ->
      context = i: 0
      res = parseTemplate "`i++` - `i++` - `i++`", context
      expect(res).to.equal "0 - 1 - 2"

      res = parseTemplate "`i++` - `i++` - `i++`", context
      expect(res).to.equal "3 - 4 - 5"

    it 'should sandbox context if enabled', ->
      res = parseTemplate "`i++` - `i++` - `i++`", i: 0, {sandbox: 1}
      expect(res).to.equal "0 - 0 - 0"

  describe 'custom default delimiter', ->
    it 'should replace a simple variable', ->
      parser = new Parser( {delimiter: "\'"} )

      res = parser.parseTemplate "\'name\'", name: "John"
      expect(res).to.equal "John"

    it 'should replace a simple variable (set by prop)', ->
      parser = new Parser()
      parser.delimiter = "\'"

      res = parser.parseTemplate "\'name\'", name: "John"
      expect(res).to.equal "John"

    it 'should throw TypeError', (done) ->
      try
        parser = new Parser( {delimiter: 2} )
      catch err
        expect(err.constructor.name).to.be.equal "TypeError"
        done()

  describe 'custom default delimiters', ->
    it 'should replace a simple variable', ->
      parser = new Parser( {delimiter: ["\#{", "}"]} )

      res = parser.parseTemplate "\#{name}", name: "John"
      expect(res).to.equal "John"

    it 'should replace a simple variable (set by prop)', ->
      parser = new Parser()
      parser.leftDelimiter = "\#{"
      parser.rightDelimiter = "}"

      res = parser.parseTemplate "\#{name}", name: "John"
      expect(res).to.equal "John"

    it 'should work with regex reserved characters', ->
      parser = new Parser( {delimiter: ["(", ")"]} )

      res = parser.parseTemplate "(name)", name: "John"
      expect(res).to.equal "John"

  describe 'custom delimiter', ->
    it 'should replace a simple variable', ->
      parser = new Parser()

      res = parser.parseTemplate "\'name\'", name: "John", {delimiter: "\'"}
      expect(res).to.equal "John"

    it 'should throw TypeError', ->
      parser = new Parser()
      try
        res = parser.parseTemplate "\'name\'", name: "John", {delimiter: 2}
      catch err
        expect(err.constructor.name).to.be.equal "TypeError"
        expect(res).to.equal undefined

    it 'should work with regex reserved characters', ->
      parser = new Parser( )

      res = parser.parseTemplate "(name)", name: "John", {delimiter: ["(", ")"]}
      expect(res).to.equal "John"
