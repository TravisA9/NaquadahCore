include("GeomTypes.jl")

# ==============================================================================
# This returns a temporary BoxElement with offset applied
# and Nullables instantiated.
function getReal(box::Element)
    return (  get(box.shape.padding, BoxOutline(0,0,0,0,0,0)),
              get(box.shape.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0])),
              get(box.margin,  BoxOutline(0,0,0,0,0,0))    )
end # padding, border, margin

function getBorderBox(box::Shape, border, margin)
    return ( box.left   - border.left + margin.left,
             box.top    - border.top  + margin.top,
             box.width  + border.right,
             box.height + border.bottom )
end
function getContentBox(box::Shape, padding, border, margin)
    return ( box.left   + border.left   + padding.left + margin.left   ,
             box.top    + border.top    + padding.top  + margin.top    ,
             box.width  - border.width  - padding.width,
             box.height - border.height - padding.height )
end
function getMarginBox(box::Shape, border, margin)
    return ( box.left, box.top,
             box.width  + border.width  + margin.width ,
             box.height + border.height + margin.height )
end
# ==============================================================================
function topLeft(box::Element)
    offset = get(box.offset,Point(0,0))
     return Point(box.left + offset.x, box.top + offset.y)
 end
function bottomRight(box::Element)
    offset = get(box.offset,Point(0,0))
     return Point(box.right + offset.x, box.bottom + offset.y)
 end
# function Border(box::BoxElement,padding,border,margin)
#     return box.width + padding.left + padding.right + border.left + border.right + margin.left + margin.right
# end

function TotalShapeWidth(box::Element,border,margin)
    return box.width + margin.width + border.width
end
function TotalShapeHeight(box::Element,border,margin)
    return box.height + border.height + margin.height
end
function topLeft(circle::Circle)
     return Point(origin.x - radius, origin.y - radius)
end
function bottomRight(circle::Circle)
    return Point(origin.x + radius, origin.y + radius)
end
function TotalShapeWidth(circle::Circle,padding,border,margin)
    width = radius*2
    return width + padding.left + padding.right + border.left + border.right + margin.left + margin.right
end
function TotalShapeHeight(circle::Circle,padding,border,margin)
    height = radius*2
    return height + padding.top + padding.bottom + border.top + border.bottom + margin.top + margin.bottom
end
