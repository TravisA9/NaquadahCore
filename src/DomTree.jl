include("GraphDraw.jl")
include("Events.jl")

module NaquadahDOM
import Base
using Gtk, JSON, Cairo, Requests   # Colors
using Gtk.ShortNames
using Naquadraw, NaquadahEvents

include("DomUtilities.jl")

defaultPage = "file:///src/SamplePages/test.json"
global PATH = pwd() * "/data/"

c = @Canvas()
win = @Window("Canvas", 1000, 800)
push!(win, c)

# ======================================================================================
# ======================================================================================
type Point
    x::Float32
    y::Float32
end
# ======================================================================================

# ======================================================================================
type Element
    DOM::Dict       # Reference to dictionary counterpart of this node
    parent::Any               # This node's parent
    children::Array{Element,1} # Children in order they appear in DOM
    rows::Array{Row,1} # A layout property
    shape::Any # link to layout representation of node
        function Element(DOM=Dict())
            parent = nothing
            children::Array{Element,1} = []
            new(DOM, parent, children, [], nothing)
        end
end
# ======================================================================================
# ======================================================================================
type Page
         parent::Any  # First node needs a Psudo-parent too ..maybe!
         children::Array{Element,1} # First node in a tree-like data structure representing all elements on page
         styles::Dict
         head::Dict

         url::Any         # URL of page
         # events::EventTypes  # All registered events
         flags::BitArray{1}        #  buttonPressed
         mousedown::Point       # These may be better than trying to copy the nodes
         mouseup::Point
         focusNode::Any
         hoverNode::Any
         # ui::PageUI   # Window
             function Page(url::String)
                     children::Array{Element,1} = [Element()]
                     parent = children[1]
                     children[1].parent = parent
                 new(parent, children, Dict(), Dict(), url, falses(8), Point(0, 0), Point(0, 0), 0, 0)
             end
end
include("DomToLayout.jl")

# ======================================================================================
# Print out Dict but not children
# CALLED FROM: Below, third button event line 100+
# ======================================================================================
function printDict(DOM)

    dict = copy(DOM)
    dict["nodes"] = "[...]"
    #contents = []

       keyList = sort(collect(keys(dict)))
       str, key, value = "","",""
           for k in 1:length(keyList)
             key = keyList[k]
               if isa(dict[key], Dict)
                 value = "{ $(printDict(dict[key])) } "
               else
                 value = dict[keyList[k]]
               end
               if k != 1; key = ", $(key)"; end
            str =   "$(str)$(key):$(value)"
           end
    #println(str)
    # return str
end
# ======================================================================================
#
# ======================================================================================
function CreateDomTree(document::Page, parent::Element)
    DOM = parent.DOM
        if isa(DOM["nodes"], Array)
            DOM_nodes = DOM["nodes"]

            for i in eachindex(DOM_nodes)
                push!(parent.children, Element(DOM_nodes[i]))
                    node = parent.children[end]
                    # printDict(node.DOM)

                    if haskey(DOM_nodes[i], "nodes") # Instantiate Children
                        CreateDomTree(document, node)
                    end
            end
        end
end
# ======================================================================================
function CreateLayoutTree(document, node)
  children = node.children
  #l,t,w,h = getContentBox(node, getReal(node)... )

    for i in 1:length(children)
        child = children[i]
        AtributesToLayout(child)
        if isa(child.shape, NText) #node.shape.flags[] == true row =
            textToRows(node, child)
        else
            PushToRow(node, child)
        end

        CreateLayoutTree(document, child)

    end
end
# ======================================================================================
function setWindowSize(w,h, n)
  n.shape = NBox()
    n.shape.color = [.5,.8,.8]
    n.shape.padding = BoxOutline(10,10,10,10,20,20)
    # we need to make sure we set VP based on padding!
    padding = get(n.shape.padding, BoxOutline(0,0,0,0,0,0))
    n.shape.left    = padding.left
    n.shape.top     = padding.top
    n.shape.width   = w - padding.width
    n.shape.height  = h - padding.height
    #n.shape.padding = BoxOutline(3,3,3,3,6,6)
end
# ======================================================================================
function DrawANode(document, n)
   @guarded draw(c) do widget
       ctx = getgc(c)
        h = height(c)
        w = width(c)
       set_antialias(ctx,1)
       setWindowSize(w,h, n)

       node = n.children[1]
       CreateLayoutTree(document, n)
       DrawContent(ctx, n)

end
show(c)
end
# ======================================================================================
function DrawContent(ctx, n)
  rows = n.rows
  parentArea = getContentBox(n.shape, getReal(n.shape)... )
  for i in 1:length(rows)
      row = rows[i]
      for j in 1:length(row.nodes)
          node = row.nodes[j]
          shape = getShape(node)


           if isa(shape, TextLine)
               DrawText(ctx, row, shape)
           end
           if isa(shape, Circle) #getContentBox(box::NBox, padding, border, margin)
               DrawCircle(ctx, parentArea, shape)
           end
           if isa(shape, NBox)
             if node.shape.flags[IsRoundBox] == true
               DrawRoundedBox(ctx, 1, shape)
             else
               DrawBox(ctx, shape)
             end
           end

           if !isa(node, TextLine)
             DrawContent(ctx, node)
           end
      end
  end
end
# ======================================================================================
#
# ======================================================================================
function FetchPage(URL::String)
       # .......................................................................
       # get the file...
       uri = URI(URL)
              if uri.scheme == "file"
                 File = pwd() * uri.path
                       Page_text = readstring(open(File))
              elseif uri.scheme == "http" || uri.scheme == "https"
                  got = get(URL; timeout = 10.0)
                  Page_text = readall(got)
              end

        pageContent = JSON.parse(Page_text)
        # ......................................................................
        document = Page(URL)
        node = document.children[1]
        parent = document.parent

        if haskey(pageContent, "head")
            document.head = pageContent["head"]
        end
        if haskey(pageContent, "style")
            document.styles = pageContent["style"]
        end
        if haskey(pageContent, "body")
            node.DOM = Dict( ">" => "window", "display" => "inline-block", "padding" => [10,10,10,10],
                  "font" => Dict( "size" => 13, "family" => "Sans", "weight" => "bold", "color" => "black" )	)
                #  , "nodes" => []
            #push!(node.DOM["nodes"], Dict("nodes" => pageContent["body"]))
            node.DOM["nodes"] = pageContent["body"]
        end
        # ......................................................................
        # ParseDictionary(document, node)  # maybe some extra preproccessing.
        # SetDOMdefaults(document, node) # Set tag, class and style attributes.
        CreateDomTree(document, node)
        # SetConstantAtributes(document, node) # this is to set layout attributes that will not change
        DrawANode(document, node)
end
# ======================================================================================
#.......>: display, position, float, padding, margin, overflow, color, opacity, background,
#          width, height, bottom, top, left, right, x1, x2, y1, y2, center, radius, angle,
#          text, href, nodes,
#          onmouseout, mousedown, hover, click, drag,
#..border: width, style, radius, color,
#....font: color, style, align, weight, lineHeight, family,
# ======================================================================================


   FetchPage(defaultPage)

# ==============================================================================

# ======================================================================================
#
# ======================================================================================
end # module



#=
d = Dict("test" => 1)

         @m(d,"test")

macro m(DOM, t)
  quote
      if haskey($(DOM), $(t))
       return true
     end
     return false
 end
end
=#
