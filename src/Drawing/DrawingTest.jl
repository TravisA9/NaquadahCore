include("Drawing.jl")
using Gtk.ShortNames, Graphics, Cairo, Colors
import Naquadraw
N = Naquadraw
# include("GeomTypes.jl")
# include("GeoMethods.jl")
c = @Canvas()
win = @Window("Canvas", 800, 600)
push!(win, c)


# ==============================================================================
@guarded draw(c) do widget

    ctx = getgc(c)
    h = height(c)
    w = width(c)
    set_antialias(ctx,1)
    # BoxElement(flags,left,top,width,height, color,opacity,padding,border,margin,offset)

    box = N.Box()
    box.flags[N.IsBox] = true
    box.flags[N.BordersSame] = true
      box.color = [.5,.8,.8]
      box.margin = N.BoxOutline(10,20,8,3,18,23)
      box.offset = N.Point(30,40)
      box.left    = 100
      box.top     = 100
      box.width   = 250
      box.height  = 200
      box.padding = N.BoxOutline(10,10,10,10,20,20)
      box.border  = N.Border(1,3,6,9, 7,12, 0,[.0,.3,.6],[17,17,17,17])


    circle = N.Circle()
        box.flags[N.IsCircle] = true
        circle.color = [.2,.5,.5]
        circle.margin = N.BoxOutline(10,20,8,3,18,23)
        circle.origin    = N.Point(400,80)
        circle.radius    = 50
        circle.border  = N.Border(10,10,10,10,20,20, 0,[.0,.3,.6],[17,7,7,7])

        if box.flags[N.IsRoundBox] == true
            N.DrawRoudedBox(ctx, box)
        end
        if box.flags[N.IsBox] == true
            N.DrawBox(ctx, box)
        end
        if box.flags[N.IsCircle] == true
            N.DrawCircle(ctx, circle)
        end

end
show(c)
