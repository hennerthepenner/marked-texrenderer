marked-texrenderer
==================

TeX renderer for marked.

[marked](https://github.com/chjj/marked) is a full-featured markdown parser 
and compiler, written in JavaScript. Built for speed.


Usage
-----

Please refer to the [documentation of marked](https://github.com/chjj/marked) 
for more information about the usage and options.

    var marked = require("marked");
    var TexRenderer = require("marked-texrenderer");

    var options = {renderer: new TexRenderer()};
    console.log(marked("I am using __markdown__.", options));
    // Outputs: I am using \textbf{markdown}.


Options
-------

You can use all the options available in marked. In addition to that there are 
a few more for:

__`packageName`__ (`String`): Name of the package to be used for the 
environment for code blocks. Examples are `verbatim` (this is what pandoc 
uses), `lstlisting`, `listing`. Defaults to `listing`.

__`packageOptions`__ (`String`): Options to be passed to the environment for 
code blocks, e.g. `H` for positioning on the page. Defaults to none.

__`resetLineNumbers`__ (`true`|`false`): Whether or not to reset the line 
number on the next block of code. When a document contains several blocks of 
code, usually the line numbers start over beginning with 1. Defaults to `true`.

__`minted`__ (`Object`): Hash of options to be passed to minted. Defaults to 
`{linenos: true, bgcolor: "codebg", firstnumber: 1}`.


How is my stuff rendered?
-------------------------

marked    | markdown                  | marked-texrenderer
----------|---------------------------|--------------------
em        | `*`, `_`                  | `\\textit{}`
strong    | `**`, `__`                | `\\textbf{}`
codespan  | ````                      | `\\texttt{}`
br        | line break                | line break
del       | `~~`                      | *unsupported*
link      | `(linkname)[href]`        | *unsupported*
image     | `![Alt](href)`            | *unsupported*
code      | intent 4 spaces or `````  | **to be described**
paragraph | blank line                | blank line
html      | HTML code                 | *unsupported*
heading   | `#`, `##`, etc.           | `\\section{}`, `\\subsection{}`, `\\subsubsection{}`, `\\paragraph{}`, `\\subparagraph{}`
hr        | `...`                     | page break
list      | `-`, `*`, `+`             | `\\begin{enumerate}` or `\\begin{itemize}`
table     | github flavor             | *unsupported*
