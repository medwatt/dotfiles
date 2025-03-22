" Vim syntax file
" Language:             VHDL [VHSIC (Very High Speed Integrated Circuit) Hardware Description Language]
" Maintainer:           Daniel Kho <daniel.kho@logik.haus>
" Previous Maintainer:  Czo <Olivier.Sirol@lip6.fr>
" Credits:              Stephan Hegel <stephan.hegel@snc.siemens.com.cn>
" Last Changed:         2020 Apr 04 by Daniel Kho

" quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" case is not significant
syn case        ignore

" VHDL operators
syn keyword     vhdlOperator    and nand or nor xor xnor
syn keyword     vhdlOperator    rol ror sla sll sra srl
syn keyword     vhdlOperator    mod rem abs not

" Concatenation and math operators
syn match       vhdlOperator    "&\|+\|-\|\*\|\/"

" Equality and comparison operators
syn match       vhdlOperator    "=\|\/=\|>\|<\|>="

" Assignment operators
syn match       vhdlOperator    "<=\|:="
syn match       vhdlOperator    "=>"

" VHDL-202x concurrent signal association (spaceship) operator
syn match       vhdlOperator    "<=>"

" VHDL-2008 conversion, matching equality/non-equality operators
syn match       vhdlOperator    "??\|?=\|?\/=\|?<\|?<=\|?>\|?>="

" VHDL-2008 external names
syn match       vhdlOperator    "<<\|>>"


" VHDL 1076-2019 keywords
syn keyword     _Statement_   access after alias all
syn keyword     _Statement_   array attribute
syn keyword     _Statement_   assert assume
syn keyword     _Statement_   begin block body buffer bus
syn keyword     _Statement_   case component configuration constant
syn keyword     _Statement_   context cover
syn keyword     _Statement_   default disconnect downto
syn keyword     _Statement_   elsif exit
syn keyword     _Statement_   file for function
syn keyword     _Statement_   fairness force
syn keyword     _Statement_   generate generic group guarded
syn keyword     _Statement_   impure in inertial inout is
syn keyword     _Statement_   label linkage literal loop
syn keyword     _Statement_   map
syn keyword     _Statement_   new next null
syn keyword     _Statement_   on open others out
syn keyword     _Statement_   package port postponed procedure process pure
syn keyword     _Statement_   parameter property protected private
syn keyword     _Statement_   range record register reject report return
syn keyword     _Statement_   release restrict
syn keyword     _Statement_   select severity signal shared subtype
syn keyword     _Statement_   sequence strong
syn keyword     _Statement_   then to transport type
syn keyword     _Statement_   unaffected units until
syn keyword     _Statement_   variable view
syn keyword     _Statement_   vpkg vmode vprop vunit
syn keyword     _Statement_   wait when while with
" VHDL-AMS
syn keyword     _Statement_    quantity terminal

syn  match     _iden1_       contained '\v[a-z]\w*'
syn  match     _iden2_       contained '\v[a-z]\w*'
syn  match     _iden3_       contained '\v[a-z]\w*'
syn  keyword   _Statement_   library    nextgroup=_iden1_ skipwhite
syn  keyword   _Statement_   use        nextgroup=_iden1_ skipwhite
syn  keyword   _Statement_   entity     nextgroup=_iden2_ skipwhite
syn  keyword   _Statement_   of         nextgroup=_iden2_ skipwhite
syn  keyword   _Statement_   across     nextgroup=_iden3_ skipwhite
syn  keyword   _Statement_   through    nextgroup=_iden3_ skipwhite
syn  keyword   _Statement_   to         nextgroup=_iden3_ skipwhite
syn  match     _Statement_   'architecture' nextgroup=_iden2_ skipwhite
syn  match     _Statement_   '\vend\s+(architecture|entity)@!' nextgroup=_iden2_
syn  match     _Statement_   '\vend\ze\s+(architecture|entity)\s*;'
syn  match     _Statement_   '\vend\ze\s+(architecture|entity)\s*\w+;'




" VHDL predefined severity levels
syn keyword     vhdlAttribute   note warning error failure

" Linting of conditionals.
syn match       _Statement_   "\<\(if\|else\)\>"
syn match       vhdlError       "\<else\s\+if\>"

" Types and type qualifiers
" Predefined standard VHDL types
syn match       vhdlType        "\<bit\>\'\="
syn match       vhdlType        "\<boolean\>\'\="
syn match       vhdlType        "\<natural\>\'\="
syn match       vhdlType        "\<positive\>\'\="
syn match       vhdlType        "\<integer\>\'\="
syn match       vhdlType        "\<real\>\'\="
syn match       vhdlType        "\<time\>\'\="
" VHDL AMS
syn match       vhdlType        "\<current\>\'\="
syn match       vhdlType        "\<electrical\>\'\="

syn match       vhdlType        "\<bit_vector\>\'\="
syn match       vhdlType        "\<boolean_vector\>\'\="
syn match       vhdlType        "\<integer_vector\>\'\="
syn match       vhdlType        "\<real_vector\>\'\="
syn match       vhdlType        "\<time_vector\>\'\="

syn match       vhdlType        "\<character\>\'\="
syn match       vhdlType        "\<string\>\'\="
syn keyword     vhdlType        line text side width

" Predefined standard IEEE VHDL types
syn match       vhdlType        "\<std_ulogic\>\'\="
syn match       vhdlType        "\<std_logic\>\'\="
syn match       vhdlType        "\<std_ulogic_vector\>\'\="
syn match       vhdlType        "\<std_logic_vector\>\'\="
syn match       vhdlType        "\<unresolved_signed\>\'\="
syn match       vhdlType        "\<unresolved_unsigned\>\'\="
syn match       vhdlType        "\<u_signed\>\'\="
syn match       vhdlType        "\<u_unsigned\>\'\="
syn match       vhdlType        "\<signed\>\'\="
syn match       vhdlType        "\<unsigned\>\'\="

" array attributes
syn match       vhdlAttribute   "\'high"
syn match       vhdlAttribute   "\'left"
syn match       vhdlAttribute   "\'length"
syn match       vhdlAttribute   "\'low"
syn match       vhdlAttribute   "\'range"
syn match       vhdlAttribute   "\'reverse_range"
syn match       vhdlAttribute   "\'right"
syn match       vhdlAttribute   "\'ascending"
" block attributes
syn match       vhdlAttribute   "\'simple_name"
syn match       vhdlAttribute   "\'instance_name"
syn match       vhdlAttribute   "\'path_name"
syn match       vhdlAttribute   "\'foreign"         " VHPI
" signal attribute
syn match       vhdlAttribute   "\'active"
syn match       vhdlAttribute   "\'delayed"
syn match       vhdlAttribute   "\'event"
syn match       vhdlAttribute   "\'last_active"
syn match       vhdlAttribute   "\'last_event"
syn match       vhdlAttribute   "\'last_value"
syn match       vhdlAttribute   "\'quiet"
syn match       vhdlAttribute   "\'stable"
syn match       vhdlAttribute   "\'transaction"
syn match       vhdlAttribute   "\'driving"
syn match       vhdlAttribute   "\'driving_value"
" type attributes
syn match       vhdlAttribute   "\'base"
syn match       vhdlAttribute   "\'subtype"
syn match       vhdlAttribute   "\'element"
syn match       vhdlAttribute   "\'leftof"
syn match       vhdlAttribute   "\'pos"
syn match       vhdlAttribute   "\'pred"
syn match       vhdlAttribute   "\'rightof"
syn match       vhdlAttribute   "\'succ"
syn match       vhdlAttribute   "\'val"
syn match       vhdlAttribute   "\'image"
syn match       vhdlAttribute   "\'value"
" VHDL-2019 interface attribute
syn match       vhdlAttribute   "\'converse"

" VHDL-AMS
syn match   vhdlAttribute    "\'dot"
syn match   vhdlAttribute    "\'integ"
syn match   vhdlAttribute    "\'ramp"
syn match   vhdlAttribute    "\'slew"
syn match   vhdlAttribute    "\'ltf"
syn match   vhdlAttribute    "\'above"


syn keyword     vhdlBoolean     true false

" for this vector values case is significant
syn case        match
" Values for standard VHDL types
syn match       vhdlVector      "\'[0L1HXWZU\-\?]\'"
syn case        ignore

syn match       vhdlVector      "B\"[01_]\+\""
syn match       vhdlVector      "O\"[0-7_]\+\""
syn match       vhdlVector      "X\"[0-9a-f_]\+\""
syn match       vhdlCharacter   "'.'"
syn region      vhdlString      start=+"+  end=+"+

" floating numbers
syn match       vhdlNumber      "-\=\<\d\+\.\d\+\(E[+\-]\=\d\+\)\>"
syn match       vhdlNumber      "-\=\<\d\+\.\d\+\>"
syn match       vhdlNumber      "0*2#[01_]\+\.[01_]\+#\(E[+\-]\=\d\+\)\="
syn match       vhdlNumber      "0*16#[0-9a-f_]\+\.[0-9a-f_]\+#\(E[+\-]\=\d\+\)\="
" integer numbers
syn match       vhdlNumber      "-\=\<\d\+\(E[+\-]\=\d\+\)\>"
syn match       vhdlNumber      "-\=\<\d\+\>"
syn match       vhdlNumber      "0*2#[01_]\+#\(E[+\-]\=\d\+\)\="
syn match       vhdlNumber      "0*16#[0-9a-f_]\+#\(E[+\-]\=\d\+\)\="


" Linting for illegal operators
" '='
syn match       vhdlError       "\(=\)[<=&+\-\*\/\\]\+"
syn match       vhdlError       "[=&+\-\*\\]\+\(=\)"
" '>', '<'
" Allow external names: '<< ... >>'
syn match       vhdlError       "\(>\)[<&+\-\/\\]\+"
syn match       vhdlError       "[&+\-\/\\]\+\(>\)"
syn match       vhdlError       "\(<\)[&+\-\/\\]\+"
syn match       vhdlError       "[>=&+\-\/\\]\+\(<\)"
" Covers most operators
" support negative sign after operators. E.g. q<=-b;
" Supports VHDL-202x spaceship (concurrent simple signal association).
syn match       vhdlError       "\(<=\)[<=&+\*\\?:]\+"
syn match       vhdlError       "[>=&+\-\*\\:]\+\(=>\)"
syn match       vhdlError       "\(&\|+\|\-\|\*\*\|\/=\|??\|?=\|?\/=\|?<=\|?>=\|>=\|:=\|=>\)[<>=&+\*\\?:]\+"
syn match       vhdlError       "[<>=&+\-\*\\:]\+\(&\|+\|\*\*\|\/=\|??\|?=\|?\/=\|?<\|?<=\|?>\|?>=\|>=\|<=\|:=\)"
syn match       vhdlError       "\(?<\|?>\)[<>&+\*\/\\?:]\+"
syn match       vhdlError       "\(<<\|>>\)[<>&+\*\/\\?:]\+"

"syn match      vhdlError       "[?]\+\(&\|+\|\-\|\*\*\|??\|?=\|?\/=\|?<\|?<=\|?>\|?>=\|:=\|=>\)"
" '/'
syn match       vhdlError       "\(\/\)[<>&+\-\*\/\\?:]\+"
syn match       vhdlError       "[<>=&+\-\*\/\\:]\+\(\/\)"

syn match       vhdlSpecial     "<>"
syn match       vhdlSpecial     "[().,;]"


" time
syn match       vhdlTime        "\<\d\+\s\+\(\([fpnum]s\)\|\(sec\)\|\(min\)\|\(hr\)\)\>"
syn match       vhdlTime        "\<\d\+\.\d\+\s\+\(\([fpnum]s\)\|\(sec\)\|\(min\)\|\(hr\)\)\>"

syn case        match
syn keyword     vhdlTodo        contained TODO NOTE
syn keyword     vhdlFixme       contained FIXME
syn case        ignore

syn region      vhdlComment     start="/\*" end="\*/"   contains=vhdlTodo,vhdlFixme,@Spell
syn match       vhdlComment     "\(^\|\s\)--.*"         contains=vhdlTodo,vhdlFixme,@Spell

" Standard IEEE P1076.6 preprocessor directives (metacomments).
syn match       vhdlPreProc     "/\*\s*rtl_synthesis\s\+\(on\|off\)\s*\*/"
syn match       vhdlPreProc     "\(^\|\s\)--\s*rtl_synthesis\s\+\(on\|off\)\s*"
syn match       vhdlPreProc     "/\*\s*rtl_syn\s\+\(on\|off\)\s*\*/"
syn match       vhdlPreProc     "\(^\|\s\)--\s*rtl_syn\s\+\(on\|off\)\s*"

" Industry-standard directives. These are not standard VHDL, but are commonly
" used in the industry.
syn match       vhdlPreProc     "/\*\s*synthesis\s\+translate_\(on\|off\)\s*\*/"
"syn match      vhdlPreProc     "/\*\s*simulation\s\+translate_\(on\|off\)\s*\*/"
syn match       vhdlPreProc     "/\*\s*pragma\s\+translate_\(on\|off\)\s*\*/"
syn match       vhdlPreProc     "/\*\s*pragma\s\+synthesis_\(on\|off\)\s*\*/"
syn match       vhdlPreProc     "/\*\s*synopsys\s\+translate_\(on\|off\)\s*\*/"

syn match       vhdlPreProc     "\(^\|\s\)--\s*synthesis\s\+translate_\(on\|off\)\s*"
"syn match      vhdlPreProc     "\(^\|\s\)--\s*simulation\s\+translate_\(on\|off\)\s*"
syn match       vhdlPreProc     "\(^\|\s\)--\s*pragma\s\+translate_\(on\|off\)\s*"
syn match       vhdlPreProc     "\(^\|\s\)--\s*pragma\s\+synthesis_\(on\|off\)\s*"
syn match       vhdlPreProc     "\(^\|\s\)--\s*synopsys\s\+translate_\(on\|off\)\s*"

"Modify the following as needed.  The trade-off is performance versus functionality.
syn sync        minlines=600

" Define the default highlighting.
" Only when an item doesn't have highlighting yet


hi def link _Statement_     Statement
hi def link vhdlSpecial     Special
hi def link vhdlCharacter   Character
hi def link vhdlString      String
hi def link vhdlVector      Number
hi def link vhdlBoolean     Number
hi def link vhdlTodo        Todo
hi def link vhdlFixme       Fixme
hi def link vhdlComment     Comment
hi def link vhdlNumber      Number
hi def link vhdlTime        Number
hi def link vhdlType        Type
hi def link vhdlOperator    Operator
hi def link vhdlError       Error
hi def link vhdlAttribute   Special
hi def link vhdlPreProc     Error
hi def link _iden1_         Argument
hi def link _iden2_         Predefined
hi def link _iden3_         DoomOneTSParameter

let b:current_syntax = "vhdl"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ts=8
