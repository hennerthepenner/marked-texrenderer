Renderer = require("../index")
marked = require("marked")
should = require("should")


# Helper function to make marked use the tex renderer
render = (inputText) -> marked(inputText, renderer: new Renderer())

describe "Basic rendering", () ->
  ###
  # Inline rendering
  ###

  it "renders strong text to bold face", (done) ->
    render("**bla**").should.eql("\\textbf{bla}\n\n")
    render("__bla__").should.eql("\\textbf{bla}\n\n")
    done()

  it "renders emphasized text to italic", (done) ->
    render("*bla*").should.eql("\\textit{bla}\n\n")
    render("_bla_").should.eql("\\textit{bla}\n\n")
    done()

  it "renders codespan text to monotype", (done) ->
    render("`bla`").should.eql("\\texttt{bla}\n\n")
    done()

  it "renders linebreaks to linebreaks", (done) ->
    render("bla\nblub").should.eql("bla\nblub\n\n")
    done()

  it "doesn't render strikethroughs", (done) ->
    render("~~bla~~").should.eql("bla\n\n")
    done()

  it "renders links to urls", (done) ->
    # From the daring fireball markdown documentation:
    markdown = 'This is [an example](http://example.com/ "Title") inline link.'
    tex = "This is \\url{http://example.com/} inline link.\n\n"
    render(markdown).should.eql(tex)
    done()

  it "doesn't render images", (done) ->
    render("![bla](/path/to/img.jpg)").should.eql("\n\n")
    done()

  ###
  # Block rendering
  ###

  it "renders paragraphs by adding a blank line", (done) ->
    render("bla").should.eql("bla\n\n")
    done()

  it "doesn't change html", (done) ->
    render("<p>bla</p>").should.eql("<p>bla</p>")
    done()

  it "renders headings as sections and paragraphs", (done) ->
    # Setext versions
    render("bla\n===").should.eql("\\section{bla}\n\n")
    render("bla\n---").should.eql("\\subsection{bla}\n\n")
    # atx versions (but no more than 5 levels)
    render("# bla").should.eql("\\section{bla}\n\n")
    render("## bla").should.eql("\\subsection{bla}\n\n")
    render("### bla").should.eql("\\subsubsection{bla}\n\n")
    render("#### bla").should.eql("\\paragraph{bla}\n\n")
    render("##### bla").should.eql("\\subparagraph{bla}\n\n")
    render("###### bla").should.eql("bla\n\n")
    done()

  it "renders horizontal lines as page breaks", (done) ->
    render("***").should.eql("\\pagebreak\n\n")
    done()

  it "renders lists as itemized or enumerated thingy", (done) ->
    itemized = "\\begin{itemize}\n\\item bla\n\\end{itemize}\n\n"
    render("* bla").should.eql(itemized)
    render("- bla").should.eql(itemized)
    render("+ bla").should.eql(itemized)
    enumerated = "\\begin{enumerate}\n\\item bla\n\\end{enumerate}\n\n"
    render("1. bla").should.eql(enumerated)
    render("8. bla").should.eql(enumerated)
    done()

  it "doesn't render tables", (done) ->
    markdown = """
               First Header  | Second Header
               ------------- | -------------
               Content Cell  | Content Cell
               Content Cell  | Content Cell
               """
    tex = "First HeaderSecond HeaderContent CellContent CellContent CellContent Cell\n\n"
    render(markdown).should.eql(tex)
    done()


describe "Code rendering", () ->
  describe "when using normal markdown code blocks", () ->
    # Use this pseudo coffeescript tutorial written in literate coffeescript to 
    # feed into the rendering process
    markdown = """
               This is coffeescript:

                   console.log(bla)
               """

    it "renders using listing and minted by default", (done) ->
      tex = """
            This is coffeescript:

            \\begin{listing}
            \\begin{minted}[linenos,bgcolor=codebg,firstnumber=1]{text}
            console.log(bla)
            \\end{minted}
            \\end{listing}\n\n"""
      render(markdown).should.eql(tex)
      done()

    it "can be supplied with a custom highlighting function", (done) ->
      tex = """
            This is coffeescript:

            \\begin{listing}
            \\begin{ernie}
            console.log(bla)
            \\end{ernie}
            \\end{listing}\n\n"""

      # Let's ask ernie from the sesame street to highlight some code for us
      ernieHighlighting = (code, language) ->
        "\\begin{ernie}\n#{code}\n\\end{ernie}"

      opts = {renderer: new Renderer(), highlight: ernieHighlighting}
      marked(markdown, opts).should.eql(tex)
      done()

    it "unfortunately doesn't know the programming language", (done) ->
      opts = 
        renderer: new Renderer()
        highlight: (code, language) -> 
          if not language then done()
      
      marked(markdown, opts)

    it "renders the correct programming language if in options", (done) ->
      tex = """
            This is coffeescript:

            \\begin{listing}
            \\begin{minted}[linenos,bgcolor=codebg,firstnumber=1]{coffeescript}
            console.log(bla)
            \\end{minted}
            \\end{listing}\n\n"""
      opts = 
        renderer: new Renderer()
        defaultLanguage: "coffeescript"

      marked(markdown, opts).should.eql(tex)
      done()


  describe "when using github flavored three ticks block", () ->  
    # Also give it a shot for the github flavored coding style to be able to 
    # specify the programming language used.
    githubMarkdown = """
                  This is git flavored coffeescript:

                  ```coffeescript
                  console.log(bla)
                  ```
                  """

    it "renders it with the correct programming language", (done) ->
      opts = 
        renderer: new Renderer()
        highlight: (code, language) ->
          language.should.eql("coffeescript")
          done()

      marked(githubMarkdown, opts)


describe "Line numbers", () ->
  markdown = """
             Block 1:

                 console.log("bla 1")

             Block 2:

                 console.log("bla 2")

             Done."""

  it "are resetted for every block", (done) ->
    tex = """
          Block 1:

          \\begin{listing}
          \\begin{minted}[linenos,bgcolor=codebg,firstnumber=1]{text}
          console.log("bla 1")
          \\end{minted}
          \\end{listing}

          Block 2:

          \\begin{listing}
          \\begin{minted}[linenos,bgcolor=codebg,firstnumber=1]{text}
          console.log("bla 2")
          \\end{minted}
          \\end{listing}

          Done.\n\n"""
    render(markdown).should.eql(tex)
    done()

  it "can be spanning over multiple blocks", (done) ->
    tex = """
          Block 1:

          \\begin{listing}
          \\begin{minted}[linenos,bgcolor=codebg,firstnumber=1]{text}
          console.log("bla 1")
          \\end{minted}
          \\end{listing}

          Block 2:

          \\begin{listing}
          \\begin{minted}[linenos,bgcolor=codebg,firstnumber=2]{text}
          console.log("bla 2")
          \\end{minted}
          \\end{listing}

          Done.\n\n"""
    opts = 
      renderer: new Renderer()
      resetLineNumbers: false
    marked(markdown, opts).should.eql(tex)
    done()
