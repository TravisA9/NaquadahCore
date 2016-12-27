



abstract Geo
#-------------------------------------------------------------------------------
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
type Square <: Geo
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
# ==============================================================================  <: Shape
type Element <: Geo
    flags::BitArray{1}
    shape::Shape
    color::Array
    opacity::Float32
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    #BoxElement(shape::Shape) = new( falses(64), shape, [], 1, Nullable{BoxOutline}(), Nullable{Point}() )
    function  Element(shape)
      return new( falses(64), shape, [], 1, Nullable{BoxOutline}(), Nullable{Point}() )
    end
end
# ==============================================================================
type Box <: Shape
    flags::BitArray{1}
    color::Array
    opacity::Float32
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    #----------------------------
    left::Float32
    top::Float32
    width::Float32
    height::Float32
    padding::Nullable{BoxOutline}
    border::Nullable{Border}
    Box() = new(
    # Generic node data
    falses(64), [], 1, Nullable{BoxOutline}(), Nullable{Point}(),
    # Shape data
    0,0,0,0, Nullable{BoxOutline}(), Nullable{Border}())
end

type Circle <: Shape
    flags::BitArray{1}
    color::Array
    opacity::Float32
    margin::Nullable{BoxOutline}
    offset::Nullable{Point}
    #----------------------------
    radius::Float32
    origin::Point
    border::Nullable{Border}
      Circle() = new(
      # Generic node data
      falses(64), [], 1, Nullable{BoxOutline}(), Nullable{Point}(),
      # Shape data
      0, Point(0,0), Nullable{Border}())
end

type Arc <: Shape
    radius::Float32
    origin::Point
    startAngle::Float32
    stopAngle::Float32
    # border::Nullable{BoxOutline}
    Arc() = new( 0, Point(0,0), 0,0)
end
type Text <: Shape
    text::String
    height::Float32
end
#==============================================================================#

#==============================================================================#
