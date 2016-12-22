using Colors

abstract Geo
# abstract Plane <: Geo

type Point <: Geo
    x::Float32
    y::Float32
end
#-------------------------------------------------------------------------------
type BoxOutline <: Geo
    left::Float32
    top::Float32
    right::Float32
    bottom::Float32
    width::Float32
    height::Float32
end

type Box <: Geo
    left::Float32
    top::Float32
    width::Float32
    height::Float32
end

#-------------------------------------------------------------------------------
abstract Shape <: Geo
type Border <: Geo
    left::Float32
    top::Float32
    right::Float32
    bottom::Float32
    width::Float32
    height::Float32

    style::Any
    color::Array # this may be an array of arrays in the case that each side has a different color
    radius::Nullable{Array}
    Border(left,top, right,bottom, width,height, style,color,radius) = new(left,top, right,bottom, width,height, style,color,radius)
end
type BoxElement <: Shape
    flags::BitArray{1}
    left::Float32
    top::Float32
    width::Float32
    height::Float32

    color::Array
    opacity::Float32

    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}

    BoxElement() = new( falses(64),  0,0,0,0, [], Nullable{BoxOutline}(),
                        Nullable{Border}(),
                        Nullable{BoxOutline}(), Nullable{Point}()
                       )
    BoxElement(flags,left,top,width,height,color,opacity,padding,border,margin,offset) =
              new(flags,left,top,width,height,color,opacity,padding,border,margin,offset)
end

type TempElement <: Shape
    left::Float32
    top::Float32
    width::Float32
    height::Float32
    padding::BoxOutline
    border::Border
    margin::BoxOutline
    offset::Point
    TempElement() = new(0,0,0,0, BoxOutline(), Border(), BoxOutline(), Point())
    TempElement(left,top,width,height,padding,border,margin,offset) =  new(left,top,width,height,padding,border,margin,offset)
end

function topLeft(box::BoxElement)
    offset = get(box.offset,Point(0,0))
     return Point(box.left + offset.x, box.top + offset.y)
 end
function bottomRight(box::BoxElement)
    offset = get(box.offset,Point(0,0))
     return Point(box.right + offset.x, box.bottom + offset.y)
 end
 function Border(box::BoxElement,padding,border,margin)
     return box.width + padding.left + padding.right + border.left + border.right + margin.left + margin.right
 end
function TotalShapeWidth(box::BoxElement,padding,border,margin)
    return box.width + margin.width + border.width
end
function TotalShapeHeight(box::BoxElement,padding,border,margin)
    return box.height + border.height + margin.height
end
type Circle <: Shape
    origin::Point
    radius::Float32
end
type CircleElement <: Shape
    radius::Float32
    origin::Point
    padding::Nullable{BoxOutline}
    border::Nullable{BoxOutline}
    margin::Nullable{BoxOutline}
    offset::Point
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

type Arc <: Shape
    origin::Point
    radius::Float32
    startAngle::Float32
    stopAngle::Float32
end
type ArcElement <: Shape
    radius::Float32
    origin::Point
    startAngle::Float32
    stopAngle::Float32
    padding::Nullable{BoxOutline}
    border::Nullable{BoxOutline}
    borderColor::Nullable{Array{Float32}}
    margin::Nullable{BoxOutline}
    offset::Point
end
