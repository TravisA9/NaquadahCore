
# c = @Canvas()
# win = @Window("Canvas", 800, 600)
# push!(win, c)

module Naquadraw
using Graphics, Cairo, Gtk.ShortNames

  include("Flags.jl")
  include("GeomTypes.jl")
  include("GeoMethods.jl")

export
          # container for shapes:
          Element,
          # General utility:
          Point, BoxOutline
          # Shapes:
          Border, Box, Circle, Arc, Text,


          # get real data (margin, padding, border) instead of Nullables
          getReal,
          # get calculated metrics
          getBorderBox, getContentBox, getMarginBox,
          TotalShapeWidth, TotalShapeHeight
# ======================================================================================
#function clip(ctx::CairoContext, path)
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function DrawCircle(ctx::CairoContext, circle::Shape)
    border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    margin = get(circle.margin,  BoxOutline(0,0,0,0,0,0))

              radius = circle.radius + border.width
              l,t = circle.origin.x + margin.left + radius, circle.origin.y + margin.top + radius
set_antialias(ctx,6)
          set_source_rgb( ctx, circle.color...)
                  move_to(ctx, l, t)
                  arc(ctx, l, t, radius, 0, 2*pi);
                  fill(ctx);
                  # fill_preserve(ctx);
          set_source_rgb( ctx, border.color...)
                  arc(ctx, l, t, radius, 0, 2*pi);

                  set_line_width(ctx, border.top);
                  stroke(ctx);
          end

#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function DrawBox(ctx::CairoContext, box::Box)
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    margin = get(box.margin,  BoxOutline(0,0,0,0,0,0))
    l,t,w,h = getBorderBox(box, border, margin)
    r, b = l+w, t+h
    borderWidth = max(border.left,border.top,border.right,border.bottom)

    if box.flags[BordersSame] == true
        rectangle(ctx,l,t,w,h )
        set_source_rgb(ctx, box.color...)
        fill(ctx);

        set_source_rgb(ctx, border.color...)
        set_line_width(ctx, border.left);
        rectangle(ctx,l,t,w,h )
        stroke(ctx);
    else
          rectangle(ctx,l,t,w,h )
          clip(ctx)

                line = (borderWidth/2)
                t -= (line - border.top)
                l -= (line - border.left)
                r -= (border.right - line)
                b -= (border.bottom - line)
                rectangle(ctx,l,t,w,h )
                set_source_rgb(ctx, box.color...)
          		fill_preserve(ctx);

          	    # Borders...
                set_source_rgb(ctx, border.color...)
          		set_line_width(ctx, borderWidth);
          		stroke(ctx);
          		set_antialias(ctx,1)
          reset_clip(ctx)
      end
end

#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function DrawRoudedBox(ctx::CairoContext, box::Box)
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    margin = get(box.margin,  BoxOutline(0,0,0,0,0,0))
    l,t,w,h = getBorderBox(box, border, margin)
    r, b = l+w, t+h
    set_antialias(ctx,1)
    set_source_rgb(ctx, 0,0,0)
    rectangle(ctx,
             # box.left   + margin.left -1,
             # box.top    + margin.top  -1,
             # box.width  + 3,
             # box.height + 3 )

    l-1,t-1,w+3,h+3 )
    set_line_width(ctx, 1);
    stroke(ctx);

        set_antialias(ctx,6)
#getBorderBox(box::Shape, border, margin)
borderWidth = max(border.left,border.top,border.right,border.bottom)

                    # borderWidth = border.top # TODO: find the thickest and use it, then clip off any excess.
 radius = get(border.radius,[0,0,0,0])
                    TR = radius[1]
                    BR = radius[2]
                    BL = radius[3]
                    TL = radius[4]
		degrees = pi / 180.0;
        rotOne = -90 * degrees
        rotTwo = 90 * degrees
        rotThree = 180 * degrees
        rotFour = 270 * degrees




        new_sub_path(ctx);
 		arc(ctx, r - TR, t + TR, TR,     rotOne,    0);    # topRight
 		arc(ctx, r - BR, b - BR, BR, 0,         rotTwo); # bottomRight
 		arc(ctx, l + BL, b - BL, BL,     rotTwo,    rotThree);   # bottomLeft
 		arc(ctx, l + TL, t + TL, TL,         rotThree,  rotFour);      # topLeft
 		close_path(ctx);

clip(ctx)
# border.left, border.top, border.right, border.bottom
line = (borderWidth/2)
t -= (line - border.top)
l -= (line - border.left)
r -= (border.right - line)
b -= (border.bottom - line)
		new_sub_path(ctx);
		arc(ctx, r - TR, t + TR, TR,     rotOne,    0);    # topRight
		arc(ctx, r - BR, b - BR, BR, 0,         rotTwo); # bottomRight
		arc(ctx, l + BL, b - BL, BL,     rotTwo,    rotThree);   # bottomLeft
		arc(ctx, l + TL, t + TL, TL,         rotThree,  rotFour);      # topLeft
		close_path(ctx);

		# setcolor( cr, box.color...)
      #fill(ctx);
      set_source_rgb(ctx, box.color...)
		fill_preserve(ctx);

		# Borders...
    set_source_rgb(ctx, border.color...)
			set_line_width(ctx, borderWidth);
			stroke(ctx);
			set_antialias(ctx,1)
reset_clip(ctx)
end

#======================================================================================#


function DrawElement(ctx, element::Element)
     padding, border, margin = getReal(element)
     box = element.shape

    select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL);
    set_font_size(ctx, 10.0);
    set_line_width(ctx, 1);


    # Margin...............................................
        rectangle(ctx, getMarginBox(box, border, margin)... )
        set_source_rgba(ctx, .8, .5, .5, 0.5)
        fill(ctx)
        move_to(ctx, box.left,  box.top + 10);
        set_source_rgb(ctx, 0,0,0);
        show_text(ctx,"Margin");
    # Elemet....................................................
        RoudedBox(ctx, element, border, getBorderBox(box, border, margin)... )

    # Border...............................................
        #rectangle(ctx, getBorderBox(box, border, margin)...)
        #set_source_rgb(ctx, .5, .5, .5)
        #fill(ctx)
    # Padding...............................................
    move_to(ctx, box.left + border.left + margin.left,
                 box.top + border.top + margin.top + 10 );
    set_source_rgb(ctx, 0,0,0);
    show_text(ctx,"Padding");

# Content
    rectangle(ctx, getContentBox(box, padding, border, margin)...)
    set_source_rgb(ctx, .7, .7, .7)
    fill(ctx)
    move_to(ctx, box.left + border.left + padding.left + margin.left,
                 box.top + border.top + padding.top + margin.top + 10 );
    set_source_rgb(ctx, 0,0,0);
    show_text(ctx,"Content");

end

export DrawElement, RoudedBox

#end
end # module
