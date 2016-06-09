
# node-eval-interpolation-sandbox
Interpolate strings with sandboxed JS code

## Example
```js
parseTemplate = require('eval-interpolation-sandbox')

parseTemplate( "`name`", {name: "John"} )
// 'John'

parseTemplate( "`name.join(' ')`", {name: ["John", "Locke"]} )
// 'John Locke'

parseTemplate( "`++i`; `++i`; `++i`", {i:0} )
// '1; 2; 3'

context = { i:0, names: ["John", "Paul"] }
parseTemplate( "`++i` - `names.shift()`", context )
parseTemplate( "`++i` - `names.shift()`", context )
// '1 - John'
// '2 - Paul'
```

## Install

    npm install eval-interpolation-sandbox

## API

  To get the synchronous parser function with default options, just import the package root:

```js
parseTemplate = require('eval-interpolation-sandbox')

result = parseTemplate( "`name.join(\" \")`", {name: ["Paul", "Jefferson"]} )  // 'Paul Jefferson'
```

  To get the asynchronous parser, or set custom defalut options

```js
ParserSync = parseTemplate.ParserSync
ParserAsync = parseTemplate.ParserAsync

parserAsync = new ParserAsync( {delimiter: ["\#{", "}"]} )
parserAsync.parseTemplate( "#{value}", {value: 42}, function(err,res){ console.log(res) } ) // '42'
```

### ParserAsync([opts])

`opts` is an object with the default values of the same options passed to `parseTemplate`

#### parseTemplate( template, context, [opts,] callback )

`template` is the string containing the tokens that will be evaluated.

`context` is the object containing the values that will be available for the tokens.

`callback(err,res)`

`opts` is an object which can receive the following options:

* `sandbox` (default: false)  

  Clones the context before parsing each token, thereby isolating the context for
  each token.

* `ignore` (default: false)

  Ignores errors while parsing the template.
  The callback will return a list of errors, and the formatted string with
  the placeholders where the errors occurred replaced by blank space.

* `delimiter` (default: ```"`"```)

  Defines the symbol that delimits both sides of the placeholders within the string.
  Accepts a string, which will define both delimiters, or an array with two strings,
  which will define the left and right delimiters, respectively.

      parseTemplate( "\'value\'", {value: 42}, { delimiter: "\'" } )
      parseTemplate( "\#{value}", {value: 42}, { delimiter: ["\#{", "}"] } )


### ParserSync([opts])

The same as `ParserAsync`, with `parseTemplate` being synchronous and not accepting
the `ignore` option.

#### parseTemplate( template, context, [opts] )

opts: {sandbox, delimiter}
