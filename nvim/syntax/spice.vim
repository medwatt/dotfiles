" Vim syntax file
" Language:	Spice circuit simulator input netlist
" Maintainer:	ftorres16
"
" This is based on https://github.com/1995parham/vim-spice

if exists("b:current_syntax")
	finish
endif

" spice syntax is case INsensitive
syn case ignore

" syn keyword	spiceTodo	contained TODO



" Comment
syn match spiceComment  "^ \=\*.*$" contains=@Spell,spiceTodo

" Numbers
syn match spiceNumber  "\v([+-]?\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?[fpnumkMGT]?"

" Elements
syn match spiceElement "\v^\s*[A-Z]+\d+"

" Dot
syn match spiceDot "\v^\.[a-zA-Z]+>"

" Keywords
syn keyword spiceFunc sin pulse pwl
" " Square wave source

" syn match spiceModelNames "\v^\.model\s+\w+"



" " Models
" syn match spiceModel "\.model\>"
" syn match spiceModel "\.malias\>"
" syn keyword spiceModelType nmos pmos NPN PNP D njf pjf
"
"
" " Subcircuits
" syn match spiceSubCkt "\.ends\>"
" syn match spiceSubCkt "\.eom\>"
" syn match spiceSubCkt "\.include\>"
" syn match spiceSubCkt "\.macro\>"
" syn match spiceSubCkt "\.model\>"
" syn match spiceSubCkt "\.subckt\>"
"
"
" " Analysis
" syn match spiceAnal "\.ac\>"
" syn match spiceAnal "\.dc\>"
" syn match spiceAnal "\.dcmatch\>"
" syn match spiceAnal "\.disto\>"
" syn match spiceAnal "\.fft\>"
" syn match spiceAnal "\.four\>"
" syn match spiceAnal "\.lin\>"
" syn match spiceAnal "\.net\>"
" syn match spiceAnal "\.noise\>"
" syn match spiceAnal "\.op\>"
" syn match spiceAnal "\.pat\>"
" syn match spiceAnal "\.pz\>"
" syn match spiceAnal "\.sample\>"
" syn match spiceAnal "\.sense\>"
" syn match spiceAnal "\.temp\>"
" syn match spiceAnal "\.tf\>"
" syn match spiceAnal "\.tran\>"
"
"
" " Simulation Runs
" syn match spiceAnal "\.end\>"
" syn match spiceAnal "\.temp\>"
" syn match spiceAnal "\.title\>"
"
"
" " Library Management
" syn match spiceLibManagement "\.del lib\>"
" syn match spiceLibManagement "\.endl\>"
" syn match spiceLibManagement "\.include\>"
" syn match spiceLibManagement "\.lib\>"
" syn match spiceLibManagement "\.protect\>"
" syn match spiceLibManagement "\.unprotect\>"


" " Output
" syn match spiceOutput "\.biaschk\>"
" syn match spiceOutput "\.dout\>"
" syn match spiceOutput "\.graph\>"
" syn match spiceOutput "\.measure\>"
" syn match spiceOutput "\.plot\>"
" syn match spiceOutput "\.print\>"
" syn match spiceOutput "\.probe\>"
" syn match spiceOutput "\.stim\>"
" syn match spiceOutput "\.width\>"


" " Setup
" syn match spiceSetUp "\.data\>"
" syn match spiceSetUp "\.dcvolt\>"
" syn match spiceSetUp "\.enddata\>"
" syn match spiceSetUp "\.global\>"
" syn match spiceSetUp "\.ic\>"
" syn match spiceSetUp "\.load\>"
" syn match spiceSetUp "\.nodeset\>"
" syn match spiceSetUp "\.option\>"
" syn match spiceSetUp "\.param\>"
" syn match spiceSetUp "\.save\>"
" syn match spiceSetUp "\.title\>"
"
"
" " Conditionals
" syn match spiceConditional "\.if\>"
" syn match spiceConditional "\.elseif\>"
" syn match spiceConditional "\.else\>"
" syn match spiceConditional "\.endif\>"
"

" " Functions
" " Sinusoidal source
" syn keyword spiceFunc sin
" " Square wave source
" syn keyword spiceFunc pulse
" " Piece-wise linear source
" syn keyword spiceFunc pwl


" Misc
" syn match   spiceWrapLineOperator       "\\$"
" syn match   spiceWrapLineOperator       "^+"


" Matching pairs of parentheses
" syn region  spiceParen transparent matchgroup=spiceOperator start="(" end=")" contains=ALLBUT,spiceParenError
" syn region  spiceSinglequote matchgroup=spiceOperator start=+'+ end=+'+


" Strings
" syntax region spiceString start=/\v"/ skip=/\v\\./ end=/\v"/

" Errors
" syn match spiceParenError ")"


" Syncs
syn sync minlines=50


" Highlights
highlight link spiceDot                 Keyword
highlight link spiceNumber		Number
highlight link spiceElement		Define
highlight link spiceComment		Comment
highlight link spiceFunc		Function
" highlight link spiceModelNames        Function
" highlight link spiceModelType         Type



" highlight link spiceWrapLineOperator	spiceOperator
" highlight link spiceSinglequote	spiceExpr
"
" highlight link spiceAnal		Keyword
" highlight link spiceConditional		Conditionl
" highlight link spiceExpr		Function
" highlight link spiceFunc		Function
" highlight link spiceLibManagement	Define
" highlight link spiceModel		Structure
" highlight link spiceModelType		Type
" highlight link spiceNumber		Number
" highlight link spiceOperator		Operator
" highlight link spiceOutput		Statement
" highlight link spiceSetUp		Define
" highlight link spiceSubCkt		Structure
" highlight link spiceStatement		Statement
" highlight link spiceString		String
" highlight link spiceTodo		Todo
" highlight link spiceParenError		Error


let b:current_syntax = "spice"

" insert the following to $VIM/syntax/scripts.vim
" to autodetect HSpice netlists and text listing output:
"
" " Spice netlists and text listings
" elseif getline(1) =~ 'spice\>' || getline("$") =~ '^\.end'
"   so <sfile>:p:h/spice.vim

" vim: ts=8
