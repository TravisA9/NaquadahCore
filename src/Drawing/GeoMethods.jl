# include("GeomTypes.jl")


# This returns a temporary BoxElement with offset applied
# and Nullables instantiated.
function getTempBox(box::BoxElement)
    offset  = get(box.offset, Point(0,0))

    return TempElement(
                    box.left   + offset.x,
                    box.top    + offset.y,
                    box.width  + offset.x,
                    box.height + offset.y,
                    get(box.padding, BoxOutline(0,0,0,0,0,0)),
                    get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0])),
                    get(box.margin,  BoxOutline(0,0,0,0,0,0)),
                    offset
                )
end

function getBorderBox(B::TempElement)
    return ( B.left - B.border.left + B.margin.left,
             B.top - B.border.top + B.margin.top,
             B.width + B.border.right,
             B.height + B.border.bottom )
end


function getContentBox(B::TempElement)
    return ( B.left   + B.border.left   + B.padding.left + B.margin.left   ,
             B.top    + B.border.top    + B.padding.top + B.margin.top    ,
             B.width  - B.border.width  - B.padding.width,
             B.height - B.border.height - B.padding.height )
end
function getMarginBox(B::TempElement)
    return ( B.left, B.top,
             B.width  + B.border.width  + B.margin.width ,
             B.height + B.border.height + B.margin.height )
end
