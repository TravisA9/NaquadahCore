# http://giovineitalia.github.io/Compose.jl/latest/#Trees-can-be-visualized-with-introspect-1
using Compose, Gtk, Colors, Measures

c = Gtk.@GtkCanvas(800,600);
w = Gtk.@GtkWindow(c,"Default GUI");
show(c);
# ==============================================================================
function sierpinski(n)
           if n == 0
               compose(context(), polygon([(1,1), (0,1), (1/2, 0)]))
           else
               t = sierpinski(n - 1)
               compose(context(),
                       (context(1/4,   0, 1/2, 1/2), t),
                       (context(  0, 1/2, 1/2, 1/2), t),
                       (context(1/2, 1/2, 1/2, 1/2), t))
           end
end


# composition = compose(context(),
#         (context(), circle(), fill("bisque")),
#         (context(), rectangle(), fill("tomato")))
#draw(SVG("tomato_bisque.svg", 4cm, 4cm), composition)

figsize = 6mm

function Element(top,left,height,width)
    txt = compose(context(),
    text(top,left, "This is some test text to test my text box.", hleft,vtop), fill(LCHab(10, 10, 77)), fontsize(15px))
    t = compose(context(minwidth=figsize + 2px, minheight=figsize),
                      rectangle(top,left,width,height), fill(LCHab(68, 74, 192)),
                      txt)
# stroke(c::(@compat Void))
    #=t = table(3, 2, 1:3, 2:2, y_prop=[1.0, 1.0, 1.0])
    t[1,1] = [compose(context(minwidth=figsize + 2mm, minheight=figsize),
                      rectangle(top,left,width,height), fill(LCHab(68, 74, 192)))]
    t[2,1] = [compose(context(minwidth=figsize + 2mm, minheight=figsize),
                      circle(0.5, 0.5, figsize/2), fill(LCHab(92, 10, 77)))]
    t[3,1] = [compose(context(minwidth=figsize + 2mm, minheight=figsize),
                      polygon([(0.5cx - figsize/2, 0.5cy - figsize/2),
                               (0.5cx + figsize/2, 0.5cy - figsize/2),
                               (0.5, 0.5cy + figsize/2)]),
                      fill(LCHab(68, 74, 29)))]
    t[1,2] = [compose(context(), text(top,left, "This is some test text to test my text box.", hleft, vcenter))]
    t[2,2] = [compose(context(), text(0, 0.5, "Form", hleft, vcenter))]
    t[3,2] = [compose(context(), text(0, 0.5, "Property", hleft, vcenter))]=#
    #composition =
    return compose(context(), t)
end

 composition = Element(100px,100px,200px,250px)




       Gtk.draw(c)
println(".......", composition )
# ==============================================================================
Gtk.draw(c) do widget
       Compose.draw(CAIROSURFACE(c.back),composition)
end
# ==============================================================================
# comp = compose(context(), circle(0.5, 0.5, figsize/2), fill("bisque"))
# Gtk.draw(c)




# ==============================================================================
       function draw_lines(joins)
            if length(joins) == 0
                context()
            else
               compose(compose(context(), line([(5mm, 5mm), (10mm, 10mm), (15mm, 5mm)]), strokelinejoin(joins[1])),
                       compose(context(0, 5mm), draw_lines(joins[2:end])))
            end
       end
# ==============================================================================

       # joins = [Compose.LineJoinRound(), Compose.LineJoinMiter(), Compose.LineJoinBevel()]
       # co = draw_lines(joins)
       # c = Gtk.draw(c)



# ==============================================================================
