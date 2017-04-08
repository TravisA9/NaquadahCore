# module NaquadahCore
#   package code goes here
# end # module

include("GraphDraw.jl")
include("DomUtilities.jl")
include("DomTree.jl")
include("GraphFlags.jl")

using Gtk, Gtk.ShortNames, Cairo   # Colors
using NaquadahDOM, Naquadraw


defaultPage = "file:///src/SamplePages/test.json"
global PATH = pwd() * "/data/"



function CreateLayoutTree(document, node)
    isa(node.shape, NText) && return

    node.rows  = []
    l,t,w,h = getContentBox(node.shape, getReal(node.shape)...)
    children = node.children

    for child in children
                # Create rows in child if it has children (I wonder if this could be done while setting DOM? )
                length(child.children) > 0   &&   Row(child.rows, l,t,w)
                # Create Child's DOM
                AtributesToLayout(child)

                # Put child into row
                if isa(child.shape, NText) #node.shape.flags[] == true row =
                    textToRows(node, child, l,t,w)
                else
                    PushToRow(node, child, l,t,w)
                end
                # Create child's children
                CreateLayoutTree(document, child)
    end
    # Clean-up! Generally the last row of each child is not yet finalized.
    if length(node.rows) > 0    lastRow = node.rows[end]
        FinalizeRow(lastRow)
        # Set content height and width for scroller
        node.scroll.contentHeight = lastRow.y + lastRow.height - node.shape.top
        node.scroll.contentWidth  = lastRow.x + lastRow.width  - node.shape.left

        if node.shape.flags[FixedHeight] == false
            node.shape.height = node.scroll.contentHeight
        end
    end

    # Make sure the final size is set

end
# ======================================================================================
function DrawANode(document)
    c = document.canvas
    node = document.children[1]

   @guarded draw(c) do widget
        ctx = getgc(c)
        h   = height(c)
        w   = width(c)
       set_antialias(ctx,1)
       setWindowSize(w,h, node)
       AttatchEvents(document)
       CreateLayoutTree(document, node)
       MoveAll(node,node.scroll.x,node.scroll.y)
       DrawContent(ctx, node)
   end
show(c)
end
# ======================================================================================
c = @Canvas()
win = @Window("Canvas", 1000, 800)
push!(win, c)
document = FetchPage(defaultPage, c)
DrawANode(document)
