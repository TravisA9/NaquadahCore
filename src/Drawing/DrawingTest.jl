include("Drawing.jl")
using Gtk.ShortNames, Cairo, Colors #  Graphics,
using Naquadraw


c = @Canvas()
win = @Window("Canvas", 1000, 800)
push!(win, c)


# ==============================================================================
@guarded draw(c) do widget

    ctx = getgc(c)
    h = height(c)
    w = width(c)
    set_antialias(ctx,1)
    # BoxElement(flags,left,top,width,height, color,opacity,padding,border,margin,offset)
traits = falses(64)
    box = NBox()
    box.flags[IsRoundBox] = true # IsRoundBox IsBox
    # box.flags[BordersSame] = true
      box.color = [.5,.8,.8]
      box.margin = BoxOutline(10,20,8,3,18,23)
      box.offset = Point(30,40)
      box.left    = 100
      box.top     = 100
      box.width   = 450
      box.height  = 400
      box.padding = BoxOutline(10,10,10,10,20,20)
      box.border  = Border(1,3,4,10, 5,13, 0,[.0,.3,.6],[17,17,17,17])


const RelativeTop      = 1
const RelativeBottom   = 2
const RelativeLeft     = 3
const RelativeRight    = 4


    circle = Circle()
        box.flags[IsCircle] = true
        circle.color   = [.2,.5,.5]
        circle.margin  = BoxOutline(10,20,8,3,18,23)
        circle.origin  = Point(10,10)
        circle.radius  = 50
        circle.border  = Border(10,10,10,10,20,20, 0,[.0,.3,.6],[17,7,7,7])

  text = NText()
  text.text = "This is some sample text for testing the text printing capabilities of cairo. . . "



 parentArea = getContentBox(box, getReal(box)... )

        if box.flags[IsRoundBox] == true
            DrawRoudedBox(ctx, traits, 1, box)
        end
        if box.flags[IsBox] == true
            DrawBox(ctx, box)
        end
        if box.flags[IsCircle] == true
            #getContentBox(box::NBox, padding, border, margin)
            DrawCircle(ctx, traits, parentArea, circle)
        end

        textBox(ctx, traits, parentArea, text)
        select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD);
        set_font_size(ctx, 15.0);
        move_to(ctx, 0, 0);
        show_text(ctx, text.text);
end
show(c)
