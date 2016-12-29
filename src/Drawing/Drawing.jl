
# c = @Canvas()
# win = @Window("Canvas", 800, 600)
# push!(win, c)

module Naquadraw
using Cairo, Gtk.ShortNames # Graphics,

  include("Flags.jl")
  include("GeomTypes.jl")
  include("GeoMethods.jl")

export
          # container for shapes:
          #  Element,
          # General utility:
          #  Point, BoxOutline
          # Shapes:
          #  Border, Box, Circle, Arc, Text,


          # get real data (margin, padding, border) instead of Nullables
          getReal, DrawBox, DrawCircle, DrawRoudedBox, textBox,
          # get calculated metrics
          getBorderBox, getContentBox, getMarginBox,
          TotalShapeWidth, TotalShapeHeight
# ======================================================================================
#function clip(ctx::CairoContext, path)
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function DrawCircle(ctx::CairoContext, traits::BitArray{1}, parentArea, circle::Shape)

        pl, pt, pw, ph = parentArea

    border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    margin = get(circle.margin,  BoxOutline(0,0,0,0,0,0))

              radius = circle.radius + border.width
              l = margin.left + radius + pl
              t = margin.top + radius + pt
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


                  select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD);
                  # set_font_size(ctx, 15.0);
                  # move_to(ctx, l, t);
                  # show_text(ctx, "Hello!");
end
#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function DrawBox(ctx::CairoContext, box::NBox)
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    margin = get(box.margin,  BoxOutline(0,0,0,0,0,0))
    l,t,w,h = getBorderBox(box, border, margin)
    r, b = l+w, t+h
    borderWidth = max(border.left,border.top,border.right,border.bottom)

    set_source_rgb(ctx, border.color...)
    set_line_width(ctx, border.left);
    rectangle(ctx,l-1,t-1,w+3,h+3 )
    stroke(ctx);

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
                w += (line - border.left)+(line - border.right)
                h += (line - border.left)+(line - border.bottom)
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
function DrawRoudedBox(ctx::CairoContext, traits::BitArray{1}, parentArea, box::NBox)
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
#======================================================================================#
function textBox(ctx, traits, parentArea, MyText)
    pl, pt, width, ph = parentArea



    if MyText.flags[TextItalic] == true
        slant = Cairo.FONT_SLANT_ITALIC
    elseif MyText.flags[TextOblique] == true
        slant = Cairo.FONT_SLANT_OBLIQUE
    else
        slant = Cairo.FONT_SLANT_NORMAL
    end

    if MyText.flags[TextBold] == true
        weight = Cairo.FONT_WEIGHT_NORMAL
    else
        weight = Cairo.FONT_WEIGHT_BOLD
    end

    select_font_face(ctx, MyText.family, slant, weight);
    set_font_size(ctx, MyText.height);

    # size::Float32, weight::String, lineHeight::Float16, align::String, family::String


    words = split(MyText.text)
    rows = []

    lines = []
    lastLine = ""
    line = words[1] * " "

     lineTop = pt

    for w in 2:length(words)
        lastLine = line
        line = lastLine * words[w] * " "
        extetents = text_extents(ctx,line )
        # long enough
        if extetents[3] >= width
            te = text_extents(ctx,lastLine )
            lineTop = AddTextRow(MyText, rows, lastLine, pl,   lineTop, (width-te[3]))
            line = ""
        end

    end
    te = text_extents(ctx,line )
    lineTop = AddTextRow(MyText, rows, lastLine, pl, lineTop, (width-te[3]))
    # push!(lines,lastLine) # Push the leftovers onto a new line



    for i in 1:length(rows)
        row = rows[i]
        for j in 1:length(row.nodes)
            node = row.nodes[j]
            # if node.flags[IsText] == true
                DrawText(ctx, MyText, row, node, pl)
            # end
        end
    end

end
# function DrawRows(ctx,row,node,left)
#======================================================================================#
function AddTextRow(MyText, rows, text, left, top, spaceLeft)

    height = MyText.size * MyText.lineHeight

    textLine = TextLine()
        textLine.flags[IsText] = true
        textLine.Reference = MyText
        textLine.text      = text
        textLine.left      = left
        textLine.top       = top + height
        println(textLine)

    row = Row()
        push!(row.nodes, textLine)
        row.height = height
        row.x = left
        row.y = top
        row.space = spaceLeft
    push!(rows,row)
    return top + height
end
#======================================================================================#
function DrawText(ctx, MyText, row, node, left)

    #MyText.flags[TextCenter] = true

    if MyText.flags[TextItalic] == true
        slant = Cairo.FONT_SLANT_ITALIC
    elseif MyText.flags[TextOblique] == true
        slant = Cairo.FONT_SLANT_OBLIQUE
    else
        slant = Cairo.FONT_SLANT_NORMAL
    end

    if MyText.flags[TextBold] == true
        weight = Cairo.FONT_WEIGHT_NORMAL
    else
        weight = Cairo.FONT_WEIGHT_BOLD
    end

    # select_font_face(ctx, MyText.family, slant, weight);
    select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD);
    set_font_size(ctx, node.height);
        here = left
        if MyText.flags[TextCenter] == true
            here = left + (row.space * .5)
        elseif  MyText.flags[TextRight] == true
            here = left + row.space
        end


    #middle = left + (row.space * .5)
    #right = left + row.space
    move_to(ctx, left, node.top);
    println(node.top)
    #set_source_rgb(ctx, MyText.color...)
    show_text(ctx, node.text);
    print("Hello!")
end

#======================================================================================#
# Draw node text
# Cairo tutorial: https://www.cairographics.org/tutorial/
# CALLED FROM: DrawNode()
#======================================================================================#






end # module
