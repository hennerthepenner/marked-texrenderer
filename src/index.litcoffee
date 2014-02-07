Tex Renderer for marked
=======================

marked needs a hash with some functions to be able to use the renderer. There 
are inline renderer methods and block renderer methods.

    module.exports = class TexRenderer

      constructor: (options) ->
        @options = options or {}


Inline renderer methods
-----------------------

### strong

Print normal emphasis (markdown: `*`, `_`) as italic.

      em: (text) -> "\\textit{#{text}}"

Print strong emphasis (markdown: `**`, `__`) as bold.

      strong: (text) -> "\\textbf{#{text}}"

Print inline code (markdown backticks) as mono typed.

      codespan: (text) -> "\\texttt{#{text}}"

Print linebreak as text with a line break.

      br: (text) -> "#{text}\n"

Strikethrough (markdown: `~~`) isn't supported, because it requires special 
packages to be loaded (ulem or soul) and can cause problems with non-ASCII 
characters.

      del: (text) -> text

Print links as `urls`. Is there a good way to present the title and a text 
alongside the href? Ignore them for now

      link: (href, title, text) -> "\\url{#{href}}"

Images aren't supported, yet.

      image: (href, title, text) -> ""


Block renderer methods
----------------------

### paragraph

Uses some package like listing (can be specified in the constructor) to create 
an environment.

      code: (code, language) -> 
        @options.packageName ?= "listing"
        @options.packageOptions ?= ""
        @options.resetLineNumbers ?= true
        @options.minted ?= {}
        @options.minted.linenos ?= true
        @options.minted.bgcolor ?= "codebg"

        if @options.resetLineNumbers is true
          @options.minted.firstnumber = 1
        else
          @options.minted.firstnumber ?= 1

        if "highlight" of @options and typeof @options.highlight is "function"
          highlighted = @options.highlight.call(@, code, language)
        else
          highlighted = @defaultHighlighting(code, language)

        # If highlighting fails, at least include the code
        highlighted ?= code

        if @options.resetLineNumbers is false
          lines = code.split(/\r\n|\r|\n/)
          @options.minted.firstnumber += lines.length

        """
        \\begin{#{@options.packageName}}#{#{@options.packageOptions}}
        #{highlighted}
        \\end{#{@options.packageName}}\n\n"""

Create a nice default tex syntax highlighting. The minted package does a great 
job using pygments. Users can options, but there are some defaults. In some 
cases the programming language is given in github flavored markdown using the 
three ticks syntax for code blocks. As a fallback let's check the options for 
a "defaultLanguage". If that doesn't work, we have to use "text".

      defaultHighlighting: (code, language) ->
        # Prepare options for the minted package
        mintedOpts = []
        for optName, optValue of @options.minted
          if optValue is true
            mintedOpts.push(optName)
          else
            mintedOpts.push(optName + "=" + optValue)
        mintedOptsStr = "[" + mintedOpts.join(",") + "]"

        # Determine the programming language
        language ?= @options.defaultLanguage or "text"

        # Return the string
        "\\begin{minted}#{mintedOptsStr}{#{language}}\n#{code}\n\\end{minted}"

Print paragraph as a paragraph with a blank line.

      paragraph: (text) -> "#{text}\n\n"

HTML can't be displayed in tex. So just pass it unchanged.

      html: (html) -> html

Maps the different levels of headings to tex sections and paragraphs. There is 
only support for 5 levels of headings.

      heading: (text, level) ->
        return "#{text}\n\n" if level < 1 or level > 5

        headingMap = [
          "\\section{#{text}}",        # Level 1
          "\\subsection{#{text}}",     # Level 2
          "\\subsubsection{#{text}}",  # Level 3
          "\\paragraph{#{text}}",      # Level 4
          "\\subparagraph{#{text}}",   # Level 5
        ]
        headingMap[level - 1] + "\n\n"

Horizontal rulers are difficult to do in tex. Let's use this to enforce a page 
break.
      
      hr: () -> "\\pagebreak\n\n"

Print lists as itemized and enumerated environment. Print list items as item.

      list: (body, ordered) ->
        if ordered
          "\\begin{enumerate}\n#{body}\\end{enumerate}\n\n"
        else
          "\\begin{itemize}\n#{body}\\end{itemize}\n\n"

      listitem: (text) -> "\\item #{text}\n"

Print tables are difficult. Let's take care of that later.

      table: (header, body) -> "#{header}#{body}\n\n"

      tablerow: (content) -> content

      tablecell: (content, flags) -> content
