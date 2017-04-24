
# export windowControls, newPage
icons = Dict(     ">"       => "div", "display" => "inline-block", "height"  => 27, "width"=>100,
                  "nodes"   => [
                          Dict(">"=>"circle", "margin"=>[5,2,2,2], "radius"=>15, "color"=>"pink",	"image"=>"back-icon.png")
                  ]
)

tab = Dict(       ">"       => "div",
                  "display" => "inline-block",
                  "height"  => 27,
                  "padding" => 5,
                  "width"   => 100,
                  "color"   => [0.8,0.8,0.8],
                  "border"  => Dict( "radius"=>[11,0,0,7], "width"=>[1,1,1,0], "style"=>"solid", "color"=>[0.9,0.9,0.9] ),
                  "nodes"   => [
                          Dict(">"=>"circle","display" => "inline-block", "margin"=>2, "radius"=>10, "color"=>"pink",	"image"=>"Atlantis.png"                         ),
                          Dict(">"=>"p","display" => "inline-block",
    													 "font"=> Dict( "color"=>"black", "size"=>15, "align"=>"left", "lineHeight"=>1.4, "family"=>"Georgia" ),
    													 "text"=>"Tab!"
    															 ),
                          Dict(">"=>"circle","display" => "inline-block", "margin"=>6, "radius"=>5, "color"=>"pink",	"image"=>"close.png")
                  ]
)

windowControls = Dict(
                  ">"       => "div",
                  "display" => "block",
                  "padding" =>  [2,2,2,0],
                  "height"  => 30,
                  "color"   => [0.3,0.3,0.3],
                  "border"  => Dict( "width"=>"thin", "style"=>"solid", "color"=>[0.3,0.0,0.6] ),
                  "nodes"   => []
)

newPage = Dict(
                  ">"       => "div",
                  "display" => "block",
                  "color"   => [0.8,0.8,0.8],
                  "border"  => Dict( "width"=>"thin", "style"=>"solid",
                                     "color"=>[0.3,0.0,0.6] ),
                  "nodes"   => []
)
