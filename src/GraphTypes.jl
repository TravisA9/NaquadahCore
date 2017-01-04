

export
          # container for shapes:
          Element,
          # General utility:
          Point, BoxOutline, Square,
          # Shapes:
          Border, NBox, Circle, Arc, NText, Row, TextLine

abstract Geo


macro import_fields(t)
  tt = eval(t)
  fields = fieldnames(tt)
  ex = :()
  for i = 1:length(fields)
    ft = fieldtype(tt, fields[i])
    if i==1
      ex = :($(fields[i])::$(ft))
    else
      ex = :($ex ; $(fields[i]) :: $(ft))
    end
  end
  return ex
end









#-------------------------------------------------------------------------------
type Point <: Geo
    x::Float32
    y::Float32
    Point(x,y) = new(x,y)
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
type Square <: Geo
    left::Float32
    top::Float32
    width::Float32
    height::Float32
end

#-------------------------------------------------------------------------------
abstract Draw <: Geo
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
# ==============================================================================  <: Shape
type Row
    flags::BitArray{1} #Any
    nodes::Array{Any}
    height::Float32
    space::Float32 # Space remaining 'til full
    x::Float32
    y::Float32
    # Row() = new(falses(32),[],0,0,0,0)
    Row(x, wide) = new(falses(32),[],0,wide,x,0)
end
type BasicShape
    rows::Array{Row,1}
    flags::BitArray{1}
    color::Array
    opacity::Float32
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    left::Float32
    top::Float32
    width::Float32
    height::Float32
    BasicShape() = new([], falses(64), [0,0,0], 1, Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0)
end
# ==============================================================================
# ==============================================================================
# ==============================================================================
# ==============================================================================
type NBox <: Draw
     @import_fields(BasicShape)
    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    NBox() = new( [], falses(64), [], 1, Nullable{BoxOutline}(), Nullable{Point}(), 0,0,0,0,
                    Nullable{BoxOutline}(), Nullable{Border}())
end

type Circle <: Draw
     @import_fields(BasicShape)
    radius::Float32
    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    Circle() = new( [], falses(64), [], 1, Nullable{BoxOutline}(), Nullable{Point}(), 0,0,0,0,
                    0, Nullable{BoxOutline}(), Nullable{Border}())
end
# Box, RoundBox, Arc, Circle, Line, Curve, Text, Ellipse
# Polygon, Polyline, Path
type Arc <: Draw
     @import_fields(BasicShape)
    radius::Float32
    origin::Point
    startAngle::Float32
    stopAngle::Float32
    # border::Nullable{BoxOutline}
    Arc() = new( [], 0, Point(0,0), 0,0)
end

#=---------------------------------=#
type NText <: Draw
   @import_fields(BasicShape)
    text::String
    size::Float32
    lineHeight::Float16
    family::String
    NText() = new( [], falses(64), [0,0,0], 1, Nullable{BoxOutline}(), Nullable{Point}(),0,0,0,0,
                   "", 12, 1.4,  "Sans")
end
#=---------------------------------=#
type TextLine <: Draw
    flags::BitArray{1}
    Reference::Any
    text::String
    left::Float32
    top::Float32
    width::Float32
    height::Float32
    TextLine(MyText,   text, left, top, width, height) = new(falses(64),   MyText, text, left, top, width, height)
    TextLine(MyText, text, left, top) = new(falses(64), MyText, text, left, top,0,0)
end

#==============================================================================#

#==============================================================================#