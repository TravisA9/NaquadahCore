using Gtk.ShortNames, Graphics, Cairo
include("GeomTypes.jl")
include("GeoMethods.jl")
c = @Canvas()
win = @Window("Canvas", 800, 600)
push!(win, c)


#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function RoudedBox(ctx::CairoContext,B::TempElement)
    # B = getTempBox(box)
    border = getBorderBox(B)

     # rectangle(ctx, border...)
     # set_source_rgb(ctx, .7, .3, .7)
     # stroke(ctx);


    set_antialias(ctx,6)
      l, t, w, h = border
                    # l = border.left   # minus 1 while the sides are being
                    # t = border.top     # expanded by antialias-ing
                    # h = border.height
                    # w = border.width

                    borderWidth = B.border.top # [1]
 radius = get(B.border.radius,[0,0,0,0])
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
		arc(ctx, l + w - TR, t + TR, TR,     rotOne,    0);    # topRight
		arc(ctx, l + w - BR, t + h - BR, BR, 0,         rotTwo); # bottomRight
		arc(ctx, l + BL, t + h - BL, BL,     rotTwo,    rotThree);   # bottomLeft
		arc(ctx, l + TL, t + TL, TL,         rotThree,  rotFour);      # topLeft
		close_path(ctx);

        set_source_rgb(ctx, B.border.color...)
		# setcolor( cr, box.color...)
      # fill(cr);
		#fill_preserve(cr);

		# Borders...

			set_line_width(ctx, borderWidth);
			stroke(ctx);
			set_antialias(ctx,1)

end
#======================================================================================#


function DrawElement(ctx, box::BoxElement)
    B = getTempBox(box)

    select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL);
    set_font_size(ctx, 10.0);
    set_line_width(ctx, 1);
# Offset
    rectangle(ctx, box.left,
                   box.top,
                   box.width + B.border.width + B.margin.width,
                   box.height + B.border.height + B.margin.height  )
    set_source_rgb(ctx, 1, 0, 0)
    stroke(ctx);
    move_to(ctx,box.left+1 ,box.top+11);
    set_source_rgb(ctx, 0,0,0);
    show_text(ctx,"Offset from here.");

    # Margin
    if !isnull(box.margin)
        rectangle(ctx, getMarginBox(B)... )
        set_source_rgba(ctx, .8, .5, .5, 0.5)
        fill(ctx)
        move_to(ctx, B.left,  B.top + 10);
        set_source_rgb(ctx, 0,0,0);
        show_text(ctx,"Margin");
    end

    # Border
    if !isnull(box.border)
        rectangle(ctx, getBorderBox(B)...)
        set_source_rgb(ctx, .5, .5, .5)
        fill(ctx)
    end
if !isnull(box.padding)
    move_to(ctx, B.left + B.border.left + B.margin.left,
                 B.top + B.border.top + B.margin.top + 10 );
    set_source_rgb(ctx, 0,0,0);
    show_text(ctx,"Padding");
end
# Content
    rectangle(ctx, getContentBox(B)...)
    set_source_rgb(ctx, .3, .3, .3)
    fill(ctx)
    move_to(ctx, B.left + B.border.left + B.padding.left + B.margin.left,
                 B.top + B.border.top + B.padding.top + B.margin.top + 10 );
    set_source_rgb(ctx, 0,0,0);
    show_text(ctx,"Content");

    # Border
    if !isnull(box.border)
        RoudedBox(ctx, B)
        # rectangle(ctx, getBorderBox(B)...)
        # set_source_rgb(ctx, .7, .3, .7)
        # stroke(ctx);
    end

end


# ==============================================================================
@guarded draw(c) do widget

    ctx = getgc(c)
    h = height(c)
    w = width(c)
    set_antialias(ctx,1)
    # BoxElement(flags,left,top,width,height, color,opacity,padding,border,margin,offset)
    MyElement = BoxElement( falses(64), 100, 100, 250, 200,
                            [.5,.5,.5], 1,
                            BoxOutline(10,10,10,10,20,20),
                            Border(1,1,1,1,2,2, 0,[.0,.3,.6],[7,7,7,7]), #WAS: BoxOutline(1,1,1,1,2,2),
                            BoxOutline(10,20,8,3,18,23),
                            Point(30,40)  )

DrawElement(ctx, MyElement)
    println(MyElement)
    # Paint red rectangle
    # rectangle(ctx, 0, 0, w, h/2)
    # set_source_rgb(ctx, 1, 0, 0)
    # fill(ctx)
    # Paint blue rectangle
    # rectangle(ctx, 0, 3h/4, w, h/4)
    # set_source_rgb(ctx, 0, 0, 1)
    # fill(ctx)
end
show(c)
