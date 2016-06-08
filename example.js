parse = require("eval-interpolation-sandbox")
lg = console.log

lg( parse( "#{name.join(' ')}", {name: ["Claude", "Frédéric", "Bastiat"]}, {delimiter: ["\#{", "}"]} ) );

lg( parse( "`++i` - `++i` - `++i`", {i: 7} ) );

context = { i:0, names: ["John", "Paul"] }
lg( parse( "`++i` - `names.pop(0)`", context ) )
lg( parse( "`++i` - `names.pop(0)`", context ) )