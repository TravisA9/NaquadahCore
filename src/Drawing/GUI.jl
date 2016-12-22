# http://giovineitalia.github.io/Compose.jl/latest/#Trees-can-be-visualized-with-introspect-1
using Compose, Gtk, Colors, Measures

c = Gtk.@GtkCanvas(800,600);
w = Gtk.@GtkWindow(c,"Default GUI");
show(c);
# ==============================================================================
function Arc(cx, cy, ox, oy, angle)
    loops = 10
    points = []
      s = sin(angle)
      c = cos(angle)

      # translate point back to origin: seems to invert angle!?
      ox -= cx
      oy -= cy
   for i in 1:loops
      # rotate point
      xnew = ox * c - oy * s
      ynew = ox * s + oy * c

      # translate point back:
      ox = xnew + cx
      oy = ynew + cy
      push!(points,(ox+20,oy+20))
   end
      return points
end

a = Arc(10.0, 10.0, 20.0, 20.0, 45)
println("..................", a)
# ==============================================================================
function Element(left,top,width,height)
  #clp = compose(context(left,top,width/2,height), rectangle(0,0,width/2,height), clip())
  box = compose(context(), rectangle(1px,1px,width,height), fill(RGB(.33, .33, .33)))
  bord = (context(), polygon([(0px,0px),(width+2px,0px),(width+2px,height+2px),(0px,height+2px)]),
          stroke(colorant"black"), linewidth(2px), fill(RGB(.33, .33, .33)) )



    Vtrack = compose(context(), rectangle(width-15px,1px,15px,height-15px), fill(RGB(.4, .4, .4)))
    Htrack = compose(context(), rectangle(1px,height-15px,width-15px,15px), fill(RGB(.4, .4, .4)))
    txt = compose(context(), text(0px,0px, "This is some sample text for my cool program!", hleft, vtop),
          fill(RGB(1, 1, 1)), fontsize(20px))
    bdr =    compose(context(left,top,width,height), rectangle(), stroke(colorant"tomato") ,linewidth(1))

    return compose(context(left-1px,top-1px,width+2px,height+2px, clip=true), txt, Vtrack,Htrack, bord)
end
print(1px)
  #composition =  Element(200px,50px,300px,250px)
#  composition =  compose(context(),curve((0,0.5), (1,0.5), (0.2,0.3), (0.7,-2.4)), stroke(colorant"tomato"))
#composition = (context(), polygon(Arc(10, 10, 20, 20, 45)), stroke(colorant"black"), linewidth(2px), fill(RGB(.33, .33, .33)) )
composition = (context(), line([
                (6.74418px,23.7623px),(-6.67652px,28.2215px),
                (-17.5211px,19.1443px),(-15.4942px,5.14817px),
                (-2.52002px,-0.479588px),(9.08426px,7.60377px),
                (8.30209px,21.7243px),(-4.12398px,28.4765px),
                (-16.3972px,21.4502px),(-16.8659px,7.31586px)
                ]), stroke(colorant"black"), linewidth(2px))
print(composition)
# ==============================================================================
Gtk.draw(c) do widget
       Compose.draw(CAIROSURFACE(c.back),composition)
end
# ==============================================================================

       #co = sierpinski(7);
       Gtk.draw(c)




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
