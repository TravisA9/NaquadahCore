
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
              l = circle.origin.x + margin.left + radius + pl
              t = circle.origin.y + margin.top + radius + pt
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
function textBox(ctx, traits, parentArea, text)
    pl, pt, pw, ph = parentArea

    select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD);
    set_font_size(ctx, 15.0);

    words = split(text.text)
    lines = []
    lastLine = ""
    line = words[1]
    for w in 2:length(words)
        lastLine = line
        line = lastLine * words[w] * " "
        extetents = text_extents(ctx,line )
        # long enough
        if extetents[3] >= pw
            push!(lines,lastLine)
            line = ""
        end

    end
    # Push the leftovers onto a new line
    push!(lines,lastLine)
    for i in 1:length(lines)
        move_to(ctx, 0+pl, (i*15) +pt);
        show_text(ctx, lines[i]);
    end
#text_extents(ctx,w );


end
#======================================================================================#
# Draw node text
# Cairo tutorial: https://www.cairographics.org/tutorial/
# CALLED FROM: DrawNode()
#======================================================================================#
function drawText(cr::CairoContext, traits::BitArray{1}, parentArea, text::Text)
    # document::Page, node
      #=---------------------------------=#
      # Text=  lines, top, left, color, size, style, weight
      #        lineHeight, align, family
      #=---------------------------------=#
      # TODO: perhaps these should be changes from strings to flags and values!


        text = get(node.text)
      if text.style == "italic"
      slant = Cairo.FONT_SLANT_ITALIC
      elseif text.style == "oblique"
      slant = Cairo.FONT_SLANT_OBLIQUE
      else
      slant = Cairo.FONT_SLANT_NORMAL
      end

      if text.weight == "normal"
              weight = Cairo.FONT_WEIGHT_NORMAL
          elseif text.weight == "bold"
              weight = Cairo.FONT_WEIGHT_BOLD
          end
      select_font_face(cr, text.family, slant, weight);
        set_font_size(cr, text.size);
        # set text color to draw
        textcolor = text.color
        setcolor( cr, textcolor...)


                set_antialias(cr,0)
               # extents = text_extents(cr,E["text"]);
				x = node.content.left
				y = node.content.top + text.size #extents[4]
				move_to(cr, x, y);

#text.align = "center"
			    # select_font_face(cr, "Sans", Cairo.FONT_SLANT_OBLIQUE, Cairo.FONT_WEIGHT_BOLD);
	            # set_font_size(cr, 16.0);
		for line in text.lines # lines
                # justify Still not working very well
				if text.align == "justify"
				            	# we'll need spacers to insert between words
				            	#      We should also make a spacer-length to line-length
				            	# contingency to keep the last line pretty!
				            	# spacers = line.space/line.words
				            words = split(line.text)
				            left = x
				            if line.words > 2
				            	spacer = (line.space/(line.words-1))
				            elseif line.words == 2
				            	spacer = line.space
				            elseif line.words == 1
				            	spacer = line.space/2
				            end
				        #for word in words
				        for i in eachindex(words) #

				        	#TODO: put a condition on the last word here
				        	if i == length(words)
				        		w = words[i]
				        	else
				        		w = words[i] * " "
				        		# print(w)
				        	end

				        	#width = textwidth(cr,w) + spacer
				        	width = text_extents(cr,w );
				            # print(width[3], ", ")
				        	# text_extents(cr,E["text"]);
						    move_to(cr, left, y);
							show_text(cr,w);
				            left = left + width[3] + spacer
						end

							y = y + ( text.size * text.lineHeight) # WAS: extents[4]
							if y >=  node.box.top + node.area.height
                                # print("drop out")
								break
							end

				else
						    #extents = text_extents(cr,line.text );
			            	# print(extents)
			            	if text.align == "left"
				            	left = x
				            elseif text.align == "right"
				            	left = x + line.space
				            elseif text.align == "center"
				            	left = x + (line.space/2)
			            	end




Highlight(cr::CairoContext,document::Page,text,line,left,y)







			            	# print(extents,": ")
						    move_to(cr, left, y);
							show_text(cr,line.text);
              stroke(cr);

              # let's see if we can underline the text
              if node.flags[IsUnderlined] == true
                set_antialias(cr,0)
                set_line_width(cr, 1);
                extents = text_extents(cr, line.text );
                move_to(cr, left, y+2);
                rel_line_to(cr, extents[3], 0);
                stroke(cr);
              end



							y = y + ( text.size * text.lineHeight) # WAS: extents[4]
							if y >= node.box.top + node.area.height - 3
								break
							end
				end #end of not-justify
		end
set_antialias(cr,1)
stroke(cr);
end






end # module
