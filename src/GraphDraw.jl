
# c = @Canvas()
# win = @Window("Canvas", 800, 600)
# push!(win, c)

module Naquadraw
using Cairo, Gtk.ShortNames # Graphics,

  include("GraphFlags.jl")
  include("GraphTypes.jl")
  include("GraphMethods.jl")

export
          # get real data (margin, padding, border) instead of Nullables
          getReal, DrawBox, DrawCircle, DrawRoudedBox, textToRows, DrawText,
          PushToRow, FinalizeRow,
          # get calculated metrics
          getBorderBox, getContentBox, getMarginBox, getSize
          TotalShapeWidth, TotalShapeHeight
# ======================================================================================
#function clip(ctx::CairoContext, path)
# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function DrawCircle(ctx::CairoContext, parentArea, circle::Circle)

        pl, pt, pw, ph = parentArea

    border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    margin = get(circle.margin,  BoxOutline(0,0,0,0,0,0))

              radius = circle.radius + border.left
              l = circle.left + margin.left + radius #+ pl
              t = circle.top  + margin.top  + radius #+ pt
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
#= Draw a frame around outside of box!=#
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
function DrawRoudedBox(ctx::CairoContext, parentArea, box::NBox)
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    margin = get(box.margin,  BoxOutline(0,0,0,0,0,0))
    l,t,w,h = getBorderBox(box, border, margin)
    r, b = l+w, t+h
    set_antialias(ctx,1)
#= Draw a frame around outside of box!
    set_source_rgb(ctx, 0,0,0)
    rectangle(ctx, l-1,t-1,w+3,h+3 )
    set_line_width(ctx, 1);
    stroke(ctx);
=#
        set_antialias(ctx,6)
        borderWidth = max(border.left,border.top,border.right,border.bottom)
  radius = get(border.radius,[0,0,0,0])
                    TR = radius[1]
                    BR = radius[2]
                    BL = radius[3]
                    TL = radius[4]

        rot   =   1.5707963    # 90 * degrees

    new_sub_path(ctx);
   		arc(ctx, r - TR, t + TR, TR,     -rot,   0   );    # topRight
   		arc(ctx, r - BR, b - BR, BR,     0,      rot ); # bottomRight
   		arc(ctx, l + BL, b - BL, BL,     rot,    pi  );   # bottomLeft
   		arc(ctx, l + TL, t + TL, TL,     pi,     -rot);      # topLeft
 		close_path(ctx);

clip(ctx)
# border.left, border.top, border.right, border.bottom
line = (borderWidth/2)
t -= (line - border.top)
l -= (line - border.left)
r -= (border.right - line)
b -= (border.bottom - line)
		new_sub_path(ctx);
		arc(ctx, r - TR, t + TR, TR,     -rot,   0   );    # topRight
		arc(ctx, r - BR, b - BR, BR,     0,      rot ); # bottomRight
		arc(ctx, l + BL, b - BL, BL,     rot,    pi  );   # bottomLeft
		arc(ctx, l + TL, t + TL, TL,     pi,     -rot);      # topLeft
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
function fontSlant(MyText)
    if MyText.flags[TextItalic] == true
        return Cairo.FONT_SLANT_ITALIC
    elseif MyText.flags[TextOblique] == true
        return Cairo.FONT_SLANT_OBLIQUE
    else
        return Cairo.FONT_SLANT_NORMAL
    end
end
function fontWeight(MyText)
    if MyText.flags[TextBold] == true
        return Cairo.FONT_WEIGHT_BOLD
    else
        return Cairo.FONT_WEIGHT_NORMAL
    end
end
#======================================================================================#
function textToRows(rows, parentArea, MyText)
  c = CairoRGBSurface(0,0);
  ctx = CairoContext(c);

#c = @Canvas()
#@guarded draw(c) do widget
    #ctx = getgc(c)
     h = 800 #height(c)
     w = 1000 #width(c)

      slant  = fontSlant(MyText)
      weight = fontWeight(MyText)
      select_font_face(ctx, MyText.family, slant, weight);
      set_font_size(ctx, MyText.size);

    pl, pt, width, ph = parentArea

# when we want to add text to a row that already has content
  # if length(rows) == 0 # no row!
  #   row = Row(pl, width)
  #   push!(rows, row)
  # end
    if length(rows[end].nodes) > 0 # Already has nodes!
        lineWidth = rows[end].space
        lineLeft = rows[end].x
        isPartRow = true
      else
        lineWidth = width
        lineLeft = pl
        isPartRow = false
    end



    lines = []
    lastLine = ""

     lineTop = pt + MyText.size
     words = split(MyText.text)
     line = words[1] * " "

    for w in 2:length(words)
        lastLine = line
        line = lastLine * words[w] * " "
        extetents = text_extents(ctx,line )
        # long enough
        if extetents[3] >= lineWidth
            te = text_extents(ctx, lastLine )
            # lineTop,
            textLine = TextLine(MyText, lastLine, lineLeft, 0, te[3], MyText.height)
                      #TextLine(MyText,   text,   left,     top,     width, height)
            println(textLine.left ,textLine.top ,textLine.width ,textLine.height ,textLine.text)
            PushToRow(rows, parentArea, textLine)
            #lineTop += MyText.height
            line = words[w] * " "

            if isPartRow == true
                lineWidth = width
                lineLeft = pl
                isPartRow = false
            end
        end

    end
    te = text_extents(ctx,line )
    textLine = TextLine(MyText, lastLine, lineLeft, 0, te[3], MyText.height)
    PushToRow(rows, parentArea, textLine)


end
# function DrawRows(ctx,row,node,left)
#======================================================================================#
# PushToRow(rows, parentArea, circle, circleHeight, circleWidth)
function PushToRow(rows, box, thing)
  boxleft, boxtop, boxwidth, boxheight = box
  thingWidth, thingHeight = getSize(thing)
    # if object is too wide make new row
    if length(rows) < 1
        row = Row(boxleft, boxwidth)
        row.y = boxtop
        push!(rows, row)
    end
    row = rows[end]
    # not enough space.. new row!
    if row.space < thingWidth
           FinalizeRow(box, row)
            newRow = Row(boxleft + thingWidth, boxwidth - thingWidth)
                push!(newRow.nodes, thing)
                newRow.height = thingHeight
                thing.left = boxleft
                newRow.y = row.y + row.height
                thing.top = newRow.y
            push!(rows, newRow)
            return
    end
    # if object height is greater than row reset row.height
    if row.height < thingHeight
            row.height = thingHeight
    end
    # add object to row and calculate remaining space
    if row.y == 0
      row.y = boxtop
    end
    thing.top = row.y # TODO: a bunch of stuff
    thing.left = row.x
    row.space -= thingWidth
    row.x += thingWidth
    push!(row.nodes, thing)

end
#======================================================================================#
function FinalizeRow(thing, row)
    # move objects up or down (withing row space) depending on layout options.
    # Be sure that the heights of all objects have been set.
    # Float the floats
    # The contents of a container may effect the container itself. Such as height; set that!
    # Set any node heights that are % values.
  # thing.width
  shiftAll = 0
  for i in 1:length(row.nodes)
    item = row.nodes[i]
    if isa(item, TextLine)
      MyText = item.Reference
        if MyText.flags[TextCenter] == true
            shiftAll = (row.space * .5)
            row.space = shiftAll
        elseif  MyText.flags[TextRight] == true
            shiftAll = row.space
            row.space = 0
          end

        if  MyText.flags[AlignBase] == true # AlignBase, AlignMiddle
          item.top += (row.height-MyText.height)
        end
        if MyText.flags[AlignMiddle] == true
          item.top += (row.height-MyText.height) *.5
        end

    end
    item.left += shiftAll
  end
#....................................... floats
    # LEFT
    for i in 2:length(row.nodes)
        item = row.nodes[i]
        if item.flags[FloatLeft] == true
            w, h = getSize(item)
            item.left = row.nodes[1].left
            for j in 1:(i-1)
                row.nodes[j].left += w
            end
        end
    end
    # Right
    for i in length(row.nodes):-1:1
      # row.space
        item = row.nodes[i]
        if item.flags[FloatRight] == true
            w, h = getSize(item)
            for j in (i+1):length(row.nodes)
                row.nodes[j].left -= w
            end
            wide,high = getSize(row.nodes[end])
            item.left = row.nodes[end].left + wide + row.space
        end
    end

end
#======================================================================================#
#======================================================================================#
function DrawText(ctx, row, node)
  MyText = node.Reference
  left = node.left

    slant  = fontSlant(MyText)
    weight = fontWeight(MyText)
    select_font_face(ctx, MyText.family, slant, weight);
    set_font_size(ctx, MyText.size);

    move_to(ctx, node.left, node.top + MyText.size);
    set_source_rgb(ctx, MyText.color...)
    show_text(ctx, node.text);
end

#======================================================================================#
# Draw node text
# Cairo tutorial: https://www.cairographics.org/tutorial/
# CALLED FROM: DrawNode()
#======================================================================================#






end # module
