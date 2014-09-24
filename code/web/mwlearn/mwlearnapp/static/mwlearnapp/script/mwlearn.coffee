zpad = (x,n) -> x='0' + x while (''+x).length < n; x
extend = (obj, prop) -> obj[key]=val for key, val of prop; obj
copyobj = (obj) -> extend {}, obj
merge = (obj1, obj2) -> extend copyobj(obj1), obj2
remove = (obj, keys) -> objc = copyobj(obj); delete(objc[key]) for key in keys; objc
swap = (x,i1,i2) -> tmp=x[i1]; x[i1]=x[i2]; x[i2]=tmp
sum = (x,s=0,e=null) -> n=x.length; if 0<=s<n and (not e? or s<=e) then x[s] + sum(x,s+1,e ? n-1) else 0
add = (a,b) -> (a[idx]+b[idx] for idx in [0..a.length-1])
sub = (a,b) -> (a[idx]-b[idx] for idx in [0..a.length-1])
mult = (a,b) -> (a[idx]*b[idx] for idx in [0..a.length-1])
divide = (a,b) -> (a[idx]/b[idx] for idx in [0..a.length-1])
smult = (a,b) -> (a[idx]*b for idx in [0..a.length-1])
mod = (x,n) -> r=x%n; if r<0 then r+n else r
around = (x) -> (Math.round(e) for e in x)
randomInt = (mn,mx) -> Math.floor(Math.random() * (mx - mn + 1)) + mn
randomize = (x) ->
  iCur = x.length
  while iCur != 0
    iRnd = randomInt(0,iCur-1)
    iCur -= 1
    swap x, iCur, iRnd
pickFrom = (x) -> x[randomInt(0,x.length-1)]
rotate = (p, theta, about=[0,0]) ->
  a = Math.PI*theta/180
  cs = Math.cos a
  sn = Math.sin a
  x = p[0] - about[0]
  y = p[1] - about[1]
  p = [
    x*cs - y*sn + about[0]
    x*sn + y*cs + about[1]
  ]
equals = (x,y) ->
  if Array.isArray(x) and Array.isArray(y)
    if x.length==y.length
      ret = true
      for idx in [0..x.length-1]
        if x[idx] != y[idx]
          ret = false
          break
      ret
    else
      false
  else
    x==y
find = (x,v) -> f = []; f.push(i) for e,i in x when equals(e,v); f
setdiff = (x,d) -> e for e in x when not equals(e,d)
naturalAngle = (a) ->
  a = mod(a,360)
  if a>180 then a-=360
  direction = if a==180 or a==0 then '' else if a>0 then ' clockwise' else ' counterclockwise'
  "#{Math.abs(a)} degrees#{direction}"


window.MWLearn = class MWLearn
  _mwlearn = []
  _test = false

  im: {}

  constructor: (@container = document.body, options={}) ->
    options.images = options.images ? []

    _mwlearn = @

    @paper = Raphael @container

    @show = new @MWShow
    @input = new @MWInput
    @time = new @MWTime
    @color = new @MWColor
    @exec = new @MWExec
    @queue = new @MWQueue
    @game = new @MWGame

    @background = options.background ? "rgb(128,128,128)"
    @_background = new @show.Rectangle
      color: @background
      width: @width()
      height: @height()

    @fixation = options.fixation ? ["Circle", [{color:"red", r:5}]]

    imConstruct = @game.construct.srcPart("all")
    images = options.images
    images = images.concat imConstruct
    if images.length then @LoadImages images

  width: -> @paper.width
  height: -> @paper.height
  clear: -> @paper.clear()

  LoadImages: (images) ->
    nLoaded = 0
    p = new _mwlearn.show.Progress "Loading Images", steps:20
    f = -> p.update ++nLoaded/images.length

    for i in [0..images.length-1]
      qName = "image_#{images[i]}"
      _mwlearn.queue.add qName, f, {do:false}
      @im[images[i]] = new Image()
      @im[images[i]].src = images[i]
      @im[images[i]].onload = ((name) -> -> _mwlearn.queue.do name)(qName)

  MWShow: class MWShow
    Stimulus: class Stimulus
      _rotation: 0
      _scale: 1
      _translation: [0, 0]

      element: null

      handlers: {}

      _defaults: {
        x: 0
        y: 0
        width: 100
        height: 100
        color: "black"
      }

      constructor: (options={}, addDefaults=true) ->
        options = @parseOptions options, {}, addDefaults
        @attr(name, value) for name, value of options

      parseOptions: (options, defaults={}, addDefaults=true) ->
        def = if addDefaults then merge(@_defaults, defaults) else defaults
        merge(def, options)

      H_STRINGS: ['width','x','cx','l','cl','lc','h']
      V_STRINGS: ['height','y','cy','t','ct','tc','v']
      isH: (type) -> @H_STRINGS.indexOf(type) isnt -1
      isV: (type) -> @V_STRINGS.indexOf(type) isnt -1
      addc: (x, type) -> if type[0]=='c' then "c#{x}" else x
      type2wh: (type) -> if @isH(type) then 'width' else 'height'
      type2xy: (type) -> @addc( (if @isH(type) then 'x' else 'y') , type)
      type2lt: (type) -> @addc( (if @isH(type) then 'l' else 't') , type)
      type2hv: (type) -> if @isH(type) then 'h' else if @isV(type) then 'v' else 'other'

      x2lc: (x) -> x + _mwlearn.width()/2
      lc2x: (l) -> l - _mwlearn.width()/2
      y2tc: (y) -> y + _mwlearn.height()/2
      tc2y: (t) -> t - _mwlearn.height()/2
      x2l: (x, width=null) -> @x2lc(x) - (width ? @attr("width"))/2
      l2x: (l, width=null) -> @lc2x(l) + (width ? @attr("width"))/2
      y2t: (y, height=null) -> @y2tc(y) - (height ? @attr("height"))/2
      t2y: (t, height=null) -> @tc2y(t) + (height ? @attr("height"))/2
      xy2lt: (v, xy) -> if @isH(xy) then @x2l(v) else @y2t(v)
      lt2xy: (v, xy) -> if @isH(xy) then @l2x(v) else @t2y(v)
      xy2ltc: (v, xy) -> if @isH(xy) then @x2lc(v) else @y2tc(v)
      ltc2xy: (v, xy) -> if @isH(xy) then @lc2x(v) else @tc2y(v)

      extent: (type) ->
        switch @type2hv(type)
          when 'h'
            _mwlearn.width()
          when 'v'
            _mwlearn.height()
          else
            (_mwlearn.height() + _mwlearn.width())/2

      norm2px: (x, type) -> x*@extent(type)
      px2norm: (x, type) -> x/@extent(type)

      attr: (name, value) ->
        switch name
          when "color"
            @element.attr "fill", value
          when "width", "height"
            if value?
              sCur = @element.attr(name)
              @element.attr(name, value)

              xy = @type2xy(name)
              @attr xy, @attr(xy) - (value - sCur)/2
            else
              ret = @element.attr name
          when "x", "y"
            lt = @type2lt(name)
            if value?
              @attr lt, @xy2lt(value, name)
            else
              ret = @lt2xy(@attr(lt), name)
          when "l", "t"
            xy = @type2xy(name)

            if value?
              @element.attr(xy, value)
            else
              ret = @element.attr(xy)
          when "cx", "cy"
            wh = @type2wh(name)

            if value?
              @element.attr name, @xy2lt(value, name) + @attr(wh)/2
            else
              ret = @lt2xy(@element.attr(name), name) - @attr(wh)/2
          when "lc", "tc"
            lt = name[0]
            wh = @type2wh(name)

            if value?
              @attr lt, value - @attr(wh)/2
            else
              ret = @attr(lt) + @attr(wh)/2
          when "mousedown"
            ret = @mousedown value
          when "box"
            w = @attr "width"
            h = @attr "height"
            ret = box = [w,h]

            if value?
              if not Array.isArray(value) then value = [value, value]

              r = divide(value,box)
              if r[0] < r[1]
                @attr "width", value[0]
                @attr "height", h*r[0]
              else
                @attr "width", w*r[1]
                @attr "height", value[1]
          else
            ret = @element.attr(name,value)

        if value? then @ else ret

      _settransform: ->
        @element.transform "r#{@_rotation},s#{@_scale},t#{@_translation}"
      rotate: (a, xc=null, yc=null) ->
        if xc? or yc?
          xc = xc ? @attr "x"
          yc = yc ? @attr "y"

          xDiff = (@attr "x") - xc
          yDiff = (@attr "y") - yc
          r = Math.sqrt(Math.pow(xDiff,2) + Math.pow(yDiff,2))
          theta = Math.atan2(yDiff, xDiff)
          theta += a*Math.PI/180

          @attr "x", r*Math.cos(theta) + xc
          @attr "y", r*Math.sin(theta) + yc

        @_rotation = (@_rotation + a) % 360
        @_settransform()
      scale: (s, xc=null, yc=null) ->
        if xc? or yc?
          xc = xc ? @attr "x"
          yc = yc ? @attr "y"

          xDiff = (@attr "x") - xc
          yDiff = (@attr "y") - yc
          r = Math.sqrt(Math.pow(xDiff,2) + Math.pow(yDiff,2))
          theta = Math.atan2(yDiff, xDiff)
          r *= s

          @attr "x", r*Math.cos(theta) + xc
          @attr "y", r*Math.sin(theta) + yc

        @_scale = s*@_scale
        @_settransform()
      translate: (x=0, y=0) ->
        @_translation[0] += x
        @_translation[1] += y
        @_settransform()
      remove: -> @element.remove(); @element = null
      mousedown: (f) -> @element.mousedown(f)
      show: (state) -> if state then @element.show() else @element.hide()

    CompoundStimulus: class CompoundStimulus extends Stimulus
      _p: null

      _show_state: true

      constructor: (elements, options={}, addDefaults=true) ->
        @_p = {l:0, t:0}

        @element = elements
        super options, addDefaults

      attr: (name, value) ->
        switch name
          when "width", "height"
            xy = @type2xy(name)

            n = @element.length
            if n==0
              sCur = 0
            else
              sAll = (el.attr(name) for el in @element)
              pAll = (el.attr(xy) for el in @element)
              pLow = Math.min (pAll[i] - sAll[i]/2 for i in [0..n-1])...
              pHigh = Math.max (pAll[i] + sAll[i]/2 for i in [0..n-1])...
              sCur = pHigh - pLow

            if value?
              fSize = value/sCur
              if n>0
                @element[i].attr(name, fSize*sAll[i]) for i in [0..n-1]
                @element[i].attr(xy, fSize*pAll[i]) for i in [0..n-1]
            else
              ret = sCur
          when "l", "t"
            n = @element.length
            ret = pCur = if n==0 then @_p[name] else Math.min (el.attr(name) for el in @element)...

            if value?
              @_p[name] = value
              pMove = value - pCur

              if n>0 then el.attr(name, el.attr(name)+pMove) for el,i in @element
          when "cl", "ct"
            ret = @attr "#{name[1]}c", value
          when "box", "x", "y", "cx", "cy", "lc", "tc"
            ret = super name, value
          when "element_mousedown"
            for el in @element
              f = ((elm) -> (e,x,y) -> value(elm,x,y))(el)
              el.attr "mousedown", f
          else
            if value?
              el.attr(name, value) for el in @element
            else
              ret = @element[0].attr name

        if value? then @ else ret

      _settransform: -> el._settransform() for el in @element
      rotate: (a, xc=null, yc=null) ->
        xc = xc ? @attr 'x'
        yc = yc ? @attr 'y'

        @_rotation = (@_rotation + a) % 360
        el.rotate(a,xc,yc) for el in @element
      scale: (s, xc=null, yc=null) ->
        xc = xc ? @attr 'x'
        yc = yc ? @attr 'y'

        @_scale = s*@_scale
        el.scale(s,xc,yc) for el in @element
      remove: (el=null) ->
        if el?
          if not (el instanceof Stimulus)
            idx = el
            el = @element[idx]
          else
            idx = find(@element,el)[0]

          el.remove()
          @element.splice(idx,1)
        else
          el.remove() for el in @element
      mousedown: (f) -> @element[0].mousedown(f)
      show: (state) -> @_show_state=state; el.show(@_show_state) for el in @element

      addElement: (el) ->
        @element.push el
        if not @_show_state then el.show(false)
      removeElement: (el) ->
        idx = @getElementIndex(el)
        @element[idx].remove()
        @element.splice idx, 1
      getElement: (el) -> if el instanceof Stimulus then el else @element[el]
      getElementIndex: (el) -> if not (el instanceof Stimulus) then el else find(@element,el)[0]

    Rectangle: class Rectangle extends Stimulus
      constructor: (options={}) ->
        options = @parseOptions options

        l = @x2l(options.x, options.width)
        t = @y2t(options.y, options.height)
        w = options.width
        h = options.height

        @element = _mwlearn.paper.rect l, t, w, h
        options = remove options, ['width', 'height', 'x', 'y']

        super options, false
        @element.attr "stroke", "none"

    Square: class Square extends Rectangle
      constructor: (options={}) ->
        if options.width? then options.height = options.width
        if options.height? then options.width = options.height
        options = @parseOptions options

        super options

      attr: (name, value) ->
        switch name
          when "length", "width", "height"
            super "width", value
            super "height", value
          else
            super name, value

    Circle: class Circle extends Stimulus
      constructor: (options={}) ->
        options = @parseOptions options, {
          r: @_defaults.width/2
        }

        cl = @x2l(options.x, 2*options.r) + options.r
        ct = @y2t(options.y, 2*options.r) + options.r
        r = options.r

        @element = _mwlearn.paper.circle cl, ct, r
        options = remove options, ['x', 'y', 'r', 'width', 'height']

        super options, false
        @element.attr "stroke", "none"

      attr: (name, value) ->
        switch name
          when "width", "height"
            if value?
              super "r", value/2
            else
              2*super("r")
          when "x", "y"
            super "c#{name}", value
          else
            super name, value

    Text: class Text extends Stimulus
      constructor: (text, options={}) ->
        options = @parseOptions options, {
          "font-family": "Arial"
          "font-size": "18pt"
          "text-anchor": "start"
        }

        @element = _mwlearn.paper.text 0,0,text
        options = remove options, ['width', 'height']

        super options, false

      attr: (name, value) ->
        switch name
          when "width", "height"
            if value?
              sCur = @attr name
              f = value / sCur

              @attr "font-size", @attr("font-size")*f
            else
              ret = @element.getBBox()[name]
          when "font-size"
            if value?
              x = @attr "x"
              y = @attr "y"

              super name, value

              @attr "x", x
              @attr "y", y
            else
              ret = super name
          else
            ret = super name, value

        if value? then @ else ret

    Instructions: class Instructions extends Text
      constructor: (text, options={}) ->
        options = @parseOptions options, {
          y: -32
          "font-family": "Arial"
          "font-size": "36pt"
        }

        super text, options

    Image: class Image extends Stimulus
      constructor: (src, options={}) ->
        bAutoSize = src of _mwlearn.im
        options = @parseOptions options, {
          width: if bAutoSize then _mwlearn.im[src].width else @_defaults.width
          height: if bAutoSize then _mwlearn.im[src].height else @_defaults.height
        }

        l = @x2l(options.x, options.width)
        t = @y2t(options.y, options.height)
        w = options.width
        h = options.height

        @element = _mwlearn.paper.image src, l, t, w, h
        options = remove options, ['x', 'y', 'width', 'height']

        super options, false

      attr: (name, value) ->
        switch name
          when "color"
            null
          else
            super name, value

    ColorMask: class ColorMask extends CompoundStimulus
      _background: null
      _im: null

      constructor: (src, options={}) ->
        bAutoSize = src of _mwlearn.im
        options = @parseOptions options, {
          width: if bAutoSize then _mwlearn.im[src].width else @_defaults.width
          height: if bAutoSize then _mwlearn.im[src].height else @_defaults.height
        }

        elements = []
        if options.color != "none" then elements.push (@_background = new _mwlearn.show.Rectangle)
        elements.push (@_im = new _mwlearn.show.Image src)

        super elements, options

      attr: (name, value) ->
        switch name
          when "color"
            if @_background? then ret = @_background.attr name, value
          when "width", "height"
            if value? and @_background? then @_background.attr name, value-1
            ret = @_im.attr name, value
          else
            ret = super name, value

        if value? then @ else ret

    ConstructPart: class ConstructPart extends ColorMask
      @_idx: null
      @_position: null

      constructor: (i, position, options={}) ->
        @_idx = i
        @_position = position
        src = _mwlearn.game.construct.srcPart @_idx, @_position
        super src, options

      idx: -> @_idx

    ConstructFigure: class ConstructFigure extends CompoundStimulus
      @_rot: 0
      @_idx: null

      constructor: (parts, options={}) ->
        if parts.length == 4
          @_idx = parts
        else if parts>=0 and parts<=1
          @_idx = _mwlearn.game.construct.pick(4,parts)
        else
          throw "Invalid parts"

        options = @parseOptions options, {
          width: 2*_mwlearn.im[_mwlearn.game.construct.srcPart(0)].width
          height: 2*_mwlearn.im[_mwlearn.game.construct.srcPart(0)].height
        }

        wPart = options.width/2
        hPart = options.height/2
        owPart = wPart/2
        ohPart = hPart/2

        xl = options.x - owPart
        xr = options.x + owPart
        yt = options.y - ohPart
        yb = options.y + ohPart

        xPart = [xr, xr, xl, xl]
        yPart = [yt, yb, yb, yt]

        optionsPart = {
          width: wPart
          height: hPart
        }

        elements = [new _mwlearn.show.Rectangle(merge options, {
          width: options.width-2
          height: options.height-2
          color: options.color
        })]
        for i in [0..3]
          opt = merge optionsPart, {
            x:xPart[i]
            y:yPart[i]
            color: "none"
          }
          src = _mwlearn.game.construct.srcPart @_idx[i], i
          elements.push (new _mwlearn.show.Image src, opt)

        options = remove options, ['x', 'y', 'width', 'height', 'color']

        super elements, options, false

      idx: -> @_idx

    AssemblagePart: class AssemblagePart extends Stimulus
      _param: null
      _assemblage = null

      part: null

      constructor: (part, options={}) ->
        options.size = options.size ? 100
        options.thickness = options.thickness ? 10

        @part = part

        @_param = merge _mwlearn.game.assemblage.param(@part),
          index: null
          width: options.size
          height: options.size
          l: 0
          t: 0
          orientation: 0
          grid: [0,0]
          parent: null
          attachment: [null,null,null,null]

        @element = mwl.paper.path(@constructPath(@_param,false))
        super options

        @attr "stroke-linecap", "round"
        @attr "stroke-linejoin", "round"
        @attr "fill", _mwlearn.background

      attr: (name, value) ->
        switch name
          when "l", "t", "width", "height", "orientation"
            if value?
              p = {}
              p[name] = value
              @constructPath(p)
            else
              ret = @_param[name]
          when "color"
            ret = super "stroke", value
          when "thickness"
            ret = super "stroke-width", value
          else
            ret = super name, value

        if value? then @ else ret

      rotate: (a,xc=null,yc=null) ->
        if (a%90)!=0 then throw "Invalid rotation."
        steps = a/90

        if xc? or yc?
          xc = xc ? @attr "x"
          yc = yc ? @attr "y"

          xDiff = (@attr "x") - xc
          yDiff = (@attr "y") - yc
          r = Math.sqrt(Math.pow(xDiff,2) + Math.pow(yDiff,2))
          theta = Math.atan2(yDiff, xDiff)
          theta += a*Math.PI/180

          @attr "x", r*Math.cos(theta) + xc
          @attr "y", r*Math.sin(theta) + yc

        @attr "orientation", @attr("orientation")+steps
      scale: (s,xc=null,yc=null) ->
        @attr "thickness", @attr("thickness")*s
        super s,xc,yc

      constructPath: (param={}, setPath=true) ->
        @_param[p]=v for p,v of param

        s = [@_param.width, @_param.height]
        offset = [@_param.l, @_param.t]

        a = 90*@_param.orientation

        origin = add(mult(rotate([0,0],a,[0.5,0.5]),s),offset)
        path = "M" + origin
        for op in @_param.definition
          path += op[0]
          if op.length>1
            for idx in [1..op.length-1] by 2
              f = rotate( op[idx..idx+1], a, [0.5,0.5] )
              p = add( mult(f,s) , offset )
              path += p + ","
        if setPath then @attr "path", path else path

      side2direction: (side) ->
        sideAbs = mod(side + @_param.orientation,4)
        switch sideAbs
          when 0
            [-1,0]
          when 1
            [0,-1]
          when 2
            [1,0]
          when 3
            [0,1]
          else throw 'WTF?'

      naturalLocation: (excludePart=null, excludeNeighbor=null) ->
        if excludePart? then excludePart = @_assemblage.getElementIndex(excludePart)
        if excludeNeighbor? then excludeNeighbor = @_assemblage.getElementIndex(excludeNeighbor)

        loc = ""
        sep = " "
        extra = ""

        nPart = @_assemblage.partCount(@part, excludePart)
        if nPart==1
          #unique!
          sep = ""
        else
          #try for something like "bottom-leftmost"
          iPart = @_assemblage.findPart(@part, excludePart)
          iMe = @_param.idx
          iOther = setdiff(iPart,iMe)
          nOther = iOther.length

          gridMe = @_param.grid
          gridOther = (@_assemblage.element[i]._param.grid for i in iOther)
          gridOx = (g[0] for g in gridOther)
          gridOy = (g[1] for g in gridOther)

          mnX = Math.min gridOx...
          mxX = Math.max gridOx...
          mnY = Math.min gridOy...
          mxY = Math.max gridOy...

          hAbs = null
          if gridMe[0]==mnX and gridMe[0]==mxX
            h = null
          else if gridMe[0] <= mnX
            h = "leftmost"
            hAbs = if gridMe[0]!=mnX then h
          else if gridMe[0] >= mxX
            h = "rightmost"
            hAbs = if gridMe[0]!=mxX then h
          else
            h = null

          vAbs = null
          if gridMe[1]==mnY and gridMe[1]==mxY
            v = null
          else if gridMe[1] <= mnY
            v = "top"
            vAbs = if gridMe[1]!=mnY then v
          else if gridMe[1] >= mxY
            v = "bottom"
            vAbs = if gridMe[1]!=mxY then v
          else
            v = null

          if h? and v?
            loc = "#{v}-#{h}"
          else if hAbs?
            loc = hAbs
          else if vAbs?
            loc = vAbs
          else if nOther==2
            loc = "middle"
          else
            #gettin' weird
            sep = ""
            neighbors = (nbr for nbr in @_param.attachment when nbr? and excludePart!=nbr and excludeNeighbor!=nbr)

            #this should only happen when a weird part has a weird dangler, in
            #which case this function is being called from naturalRelativeLocation,
            #in which case the current part probably isn't a good candidate to
            #include in the other part's location name
            if neighbors.length==0 then return null

            possibleExtra = (@naturalRelativeLocation(nbr,true,excludePart) for nbr in neighbors)
            possibleExtra = (ext for ext in possibleExtra when ext?)

            extraLength = (ext.length for ext in possibleExtra)
            mnLength = Math.min extraLength...
            for length,i in extraLength
              if length==mnLength
                extra = possibleExtra[i]
                break
            extra = " #{extra}"

        "#{loc}#{sep}#{@part}#{extra}"

      naturalRelativeLocation: (neighbor, includeNeighbor=false, excludePart=null) ->
        neighbor = @_assemblage.getElement(neighbor)
        p1 = @_param.grid
        p2 = neighbor._param.grid

        if p1[0] < p2[0]
          loc = "to the left of"
        else if p1[0] > p2[0]
          loc = "to the right of"
        else if p1[1] < p2[1]
          loc = "above"
        else if p1[1] > p2[1]
          loc = "below"
        else #this shouldn't happen
          loc = "on top of"

        if includeNeighbor
          neighborLoc = neighbor.naturalLocation(excludePart, @_param.idx)
          if neighborLoc? then "#{loc} the #{neighborLoc}" else null
        else
          loc
      naturalOrientation: ->
        a = naturalAngle(90*@_param.orientation)
        if not @_param.symmetric and @_param.orientation!=0 then "rotated #{a}" else ""
      naturalName: (fullName=false) ->
        orientation = if fullName then @naturalOrientation() else ""
        if orientation.length then orientation = ", #{orientation},"
        "#{@part}#{orientation}"
      naturalDefinition: ->
        parent = @_assemblage.element[@_param.parent]

        partName = @naturalName(true)
        partLocation = @naturalRelativeLocation(parent,true,@)
        "#{partName} #{partLocation}"


    Assemblage: class Assemblage extends CompoundStimulus
      _options: null
      _history: null
      _instruction: null

      _gridExtent: null

      constructor: (options={}) ->
        @_options = options
        @_history = []
        @_instruction = []
        @_grid = {min: [0,0], max: [0,0]}

        super [], options

      attr: (name, value) ->
        switch name
          when "thickness"
            if not value?
              if @element.length>0 then @element[0].attr(name,value) else null
            else
              super name, value
          when "box"
            wOld = @attr "width"
            ret = super name, value
            wNew = @attr "width"
            @attr "thickness", @attr("thickness") * wNew / wOld
            ret
          else
            super name, value

      rotate: (steps, xc=null, yc=null) ->
        a = 90*steps

        super a, xc, yc
        x = (el._param.grid for el in @element)
        el._param.grid = around(rotate(el._param.grid,a)) for el in @element
        y = (el._param.grid for el in @element)

        @addEvent 'rotate', a

      addEvent: (eventType,info) ->
        @_history.push [eventType, info]

        #get the instruction
        switch eventType
          when "add"
            el = @element[info]
            idxParent = el._param.parent

            if idxParent?
              instruct = "Add a #{el.naturalDefinition()}."
            else
              instruct = "Imagine a #{el.naturalName()}."
          when "remove"
            el = @element[info]
            instruct = "Remove the #{el.naturalLocation()}."
          when "rotate"
            instruct = "Rotate the #{@naturalName()} #{naturalAngle(info)}."
          else
            throw 'Invalid event type.'
        @_instruction.push instruct

      removeElement: (el) ->
        el = @getElement(el)
        idx = el._param.idx

        #remove the connections
        for neighbor in el._param.attachment
          if neighbor?
            neighbor = @element[neighbor]
            conn = find(neighbor._param.attachment,idx)[0]
            neighbor._param.attachment[conn] = null
            if neighbor._param.parent==idx then neighbor._param.parent = null

        #add an event
        @addEvent 'remove', idx

        #remove the element
        super idx

      addElement: (part, neighbor=null, sidePart=0, sideNeighbor=0, options={}) ->
        options = merge(@_options, options)

        xCur = @attr "x"
        yCur = @attr "y"

        aPart = new _mwlearn.show.AssemblagePart part, options
        aPart._assemblage = @

        super aPart
        aPart._param.idx = @element.length - 1

        if neighbor?
          neighbor = @getElement(neighbor)

          aPart._param.parent = neighbor._param.idx
          neighbor._param.attachment[sideNeighbor] = aPart._param.idx
          aPart._param.attachment[sidePart] = neighbor._param.idx

          #orientation of the part to match with the neighbor
          orientation = mod( mod(sideNeighbor+2,4) - sidePart + neighbor._param.orientation,4)
          #direction to move from the neighbor
          gridRel = neighbor.side2direction(sideNeighbor)

          wP = aPart.attr "width"
          hP = aPart.attr "height"

          xN = neighbor.attr "x"
          yN = neighbor.attr "y"
          wN = neighbor.attr "width"
          hN = neighbor.attr "height"

          r = if sideNeighbor==0 or sideNeighbor==2 then (wN+wP)/2 else (hN+hP)/2

          x = xN + r*gridRel[0]
          y = yN + r*gridRel[1]

          aPart._param.grid = add(neighbor._param.grid, gridRel)

          @_grid.min[0] = Math.min(@_grid.min[0], aPart._param.grid[0])
          @_grid.max[0] = Math.max(@_grid.max[0], aPart._param.grid[0])
          @_grid.min[1] = Math.min(@_grid.min[1], aPart._param.grid[1])
          @_grid.max[1] = Math.max(@_grid.max[1], aPart._param.grid[1])
        else
          orientation = options.orientation ? 0
          x = @attr "x"
          y = @attr "y"

        aPart.attr "x", x
        aPart.attr "y", y
        aPart.attr "orientation", orientation
        aPart.scale @._scale

        @attr "x", xCur
        @attr "y", yCur

        @addEvent 'add', aPart._param.idx
        aPart

      addSet: (setParam) -> @addElement param... for param in setParam

      getSet: ->
        setParam = ([] for [1..@element.length])
        for el,i in @element
          part = el.part
          parent = el._param.parent
          if parent?
            sidePart = find(el._param.attachment,parent)[0]
            sideParent = find(@element[parent]._param.attachment,el._param.idx)[0]
          else
            sidePart = sideParent = null

          setParam[i] = [part,parent,sidePart,sideParent]
        setParam

      addRandom: (n=1, iMax=null) ->
        appendage = @pickAppendage(iMax)
        options = if !@element.length>0 then {} else {orientation: randomInt(0,3)}
        ret = if appendage? then @addElement appendage...,options else null
        if n>1 then [ret, @addRandom(n-1,iMax)]

      naturalName: ->
        if @element.length==1 then @element[0].naturalName() else "image"

      getOccupiedPositions: (excludePart=null) ->
        if excludePart? then excludePart = @getElement(excludePart)
        (el._param.grid for el in @element when el!=excludePart)
      getAllParts: (excludePart=null) ->
        if excludePart? then excludePart = @getElement(excludePart)
        (el.part for el in @element when el!=excludePart)
      findPart: (part, excludePart=null) -> find(@getAllParts(excludePart), part)

      findOpenConnections: (excludePart=null) ->
        if @element.length==0
          [[null,0]]
        else
          if excludePart? then excludePart = @getElement(excludePart)

          occupied = @getOccupiedPositions()

          conn = []
          for el,i in @element when el!=excludePart
            for side in _mwlearn.game.assemblage.param(el.part).connects
              if not el._param.attachment[side]?
                grid = add(el._param.grid, el.side2direction(side))
                if find(occupied,grid).length==0
                  conn.push [i, side]
          conn

      partCount: (part, excludePart=null) -> find(@getAllParts(excludePart),part).length

      pickPart: (iMax=null) ->
        parts = _mwlearn.game.assemblage.parts()
        iMax = iMax ? parts.length-1
        pickFrom(parts[0..iMax])
      pickSide: (part) -> pickFrom(_mwlearn.game.assemblage.param(part).connects)
      pickAppendage: (iMax=null, excludePart=null) ->
        conns = @findOpenConnections(excludePart)
        conn = pickFrom(conns)

        if conn?
          #make it's a square if we only have one possible connection
          part = if conn.length==1 and conn[0]? then 'square' else @pickPart(iMax)
          side = @pickSide(part)

          [part, conn[0], side, conn[1]]
        else
          null

    Progress: class Progress extends CompoundStimulus
      _steps: 0
      _width: 0

      constructor: (info, options={}) ->
        options = @parseOptions options, {
          width: 300
          steps: 10
          color: "red"
          r: 5
        }

        @_steps = options.steps
        @_width = options.width

        elements = [new _mwlearn.show.Instructions info]

        for i in [0..@_steps-1]
          bit = new _mwlearn.show.Circle {r: options.r}
          bit.show(false)
          elements.push(bit)

        delete options.r

        super elements, options

      attr: (name, value) ->
        switch name
          when "steps"
            ret = @_steps
          when "width"
            ret = Math.max(@_width, @element[0].attr "width")
          when "height"
            bottom = @element[@_steps].attr("y") + @element[@_steps].attr("height")
            top = @element[0].attr("y") - @element[0].attr("height")/2
            ret = bottom - top
          when "x"
            if value?
              @element[0].attr name, value
              @element[k].attr name, -@_width/2 + (k-1)*@_width/(@_steps-1) for k in [1..@_steps]
            else
              ret = @element[0].attr name
          when "y"
            if value?
              @element[0].attr name, value-32
              @element[k].attr name, value for k in [1..@_steps]
            else
              ret = @element[@_steps].attr name
          when "color"
            if value?
              colBase = Raphael.color(value)
              @element[k].attr "color", "rgba(#{colBase.r},#{colBase.g},#{colBase.b},#{k/@_steps})" for k in [1..@_steps]
            else
              ret = @element[@_steps].attr name
          when "r"
            if value?
              @element[k].attr "r", value for k in [1..@_steps]
            else
              ret = @element[@_steps-1].attr name
          else
            super name, value

        if value? then @ else ret

      update: (f) ->
        f = Math.min(1,Math.max(0,f))
        kLast = Math.round(@_steps*f)
        if kLast>0 then @element[k].show(true) for k in [1..kLast]
        if kLast<@_steps then @element[k].show(false) for k in [kLast+1..@_steps]

        if f>=1 then @remove()

  MWInput: class MWInput
    _event_handlers: null

    _handleEvent: (evt, handlerType, fCheckHandler) ->
      handlers = @_event_handlers[handlerType]

      #execute the handlers
      idxRemove = []
      for handler,idx in handlers
        if fCheckHandler(handler)
          handler.f(evt)
          handler.count++
          if handler.expires!=0 and handler.count>=handler.expires then idxRemove.push idx

      #remove expired handlers
      handlers.splice(idx,1) for idx in idxRemove

    _handleKey: (evt, eventType) ->
      handlerType = "key_#{eventType}"
      fCheckHandler = (h) -> h.button=='any' or evt.which==h.button

      @_handleEvent(evt,handlerType,fCheckHandler)

    _handleMouse: (evt, eventType) ->
      handlerType = "mouse_#{eventType}"
      fCheckHandler = (h) -> h.button=='any' or evt.which==h.button

      @_handleEvent(evt,handlerType,fCheckHandler)

    constructor: ->
      @_event_handlers = {
        key_down: []
        mouse_down: []
      }

      fKey = (obj,eventType) -> ((evt) -> obj._handleKey(evt,eventType))
      fMouse = (obj,eventType) -> ((evt) -> obj._handleMouse(evt,eventType))

      $(document).keydown( fKey(@,'down') )
      $(document).mousedown( fMouse(@,'down') )

    addHandler: (type,options=null) ->
      #common options
      if not options? then options={}
      options.f = options.f ? null
      options.expires = options.expires ? 0

      #type specific options
      switch type
        when 'key'
          options.event = options.event ? 'down'
          options.button = @key2code(options.button ? 'any')
        when 'mouse'
          options.event = options.event ? 'down'
          options.button = @mouse2code(options.button ? 'any')
        else
          throw "Invalid handler type"

      #record
      options.count = 0

      handlerType = "#{type}_#{options.event}"
      @_event_handlers[handlerType].push options

    key2code: (key) ->
      switch key
        when 'any'
          'any'
        when 'enter'
          13
        when 'left'
          37
        when 'up'
          38
        when 'right'
          39
        when 'down'
          40
        else
          if (typeof key)=='string'
            key.toUpperCase().charCodeAt(0)
          else
            key

    mouse2code: (button) ->
      switch button
        when 'any'
          'any'
        when 'left'
          1
        when 'middle'
          2
        when 'right'
          3
        else throw "Invalid button"

  MWTime: class MWTime
    Now: -> new Date().getTime()

  MWColor: class MWColor
    colors: {
      default: [
        'crimson'
        'red'
        'tomato'
        'orangered'
        'orange'
        'gold'
        'yellow'
        'chartreuse'
        'lime'
        'limegreen'
        'springgreen'
        'aqua'
        'turquoise'
        'deepskyblue'
        'blue'
        'darkviolet'
        'magenta'
        'deeppink'
      ]
    }

    constructor: ->
      @colors['difficulty'] = ['blue','limegreen','gold','orange','red']

    pick: (colorSet='default', interpolate=false) ->
      if interpolate
        @blend @colors[colorSet], Math.random()
      else
        nColor = @colors[colorSet].length
        iColor = Math.floor(Math.random()*nColor)
        @colors[colorSet][iColor]

    blend: (colorSet='default', f) ->
      nColor = @colors[colorSet].length

      iBlend = Math.max(0,Math.min(nColor-1,f*(nColor-1)))
      iFrom = Math.floor(iBlend)
      iTo = Math.min(nColor-1,iFrom + 1)

      fBlend = iBlend - iFrom

      colFrom = Raphael.color(@colors[colorSet][iFrom])
      colTo = Raphael.color(@colors[colorSet][iTo])

      r = (1-fBlend)*colFrom.r + fBlend*colTo.r
      g = (1-fBlend)*colFrom.g + fBlend*colTo.g
      b = (1-fBlend)*colFrom.b + fBlend*colTo.b

      Raphael.color("rgb(#{r},#{g},#{b})")

  MWExec: class MWExec
    Sequence: class Sequence
      _name: ''
      _fStep: null
      _fCleanup: null
      _next: null

      _idx: 0

      _fCheck: null
      _timer: null

      _tStart: 0
      _tStep: 0

      finished: false

      constructor: (name, fStep, next, options={}) ->
        ###
          name: a unique name for the sequence
          fStep: array specifying the function to execute at each step
          next: array of:
            time: time to move on from the step
            key: a key that must be down to move on
            f: a function that takes the sequence and step start times and returns true to move on
        ###
        options.execute = options.execute ? true
        @mode = options.mode ? "step" #time mode
        @callback = options.callback ? null # a function to call when the sequence finishes
        @_fCleanup = options.cleanup ? null # array specifying function to call after each step

        @_name = name
        @_fStep = fStep
        @_next = next

        @setSequence()

        if options.execute then @Execute()

      stepName: (idx) -> "#{@_name}_#{idx}"

      delayTime: (t) ->
        tExec = switch @mode
          when "step" then @_tStep + t
          when "relative" then @_tStart + t
          when "absolute" then t
          else throw "Invalid time mode"

        tExec - _mwlearn.time.Now()

      checkNext: ->
        if @_fCheck(@_tStart, @_tStep)
          clearInterval(@_timer)
          _mwlearn.queue.do(@stepName(@_idx))

      setSequence: ->
        nStep = @_fStep.length + (if @callback? then 1 else 0)
        for idx in [0..nStep-1]
          fDoStep = ( (obj) -> (->obj.processStep()) )(@)
          _mwlearn.queue.add @stepName(idx), fDoStep, {do: false}

      processStep: ->
        @_tStep = _mwlearn.time.Now()

        @cleanupStep(@_idx-1)

        if @_idx==@_fStep.length
          @finished = true
          if @callback? then @callback()
        else
          @executeStep(@_idx)
          next = @_next[@_idx]
          @_idx++

          @parseNext(@_idx, next)

      executeStep: (idx) -> @_fStep[idx]()
      cleanupStep: (idx) -> if @_fCleanup? and idx>=0 and @_fCleanup[idx]? then @_fCleanup[idx]()

      parseNext: (idx, next) ->
        fDoStepNext = ( (obj,i) -> (-> _mwlearn.queue.do(obj.stepName(i))) )(@, idx)

        if !isNaN(parseFloat(next)) #number
          window.setTimeout fDoStepNext, @delayTime(next)
        else if (typeof next)=='string'
          @parseNext(['key',{button: next}])
        else if (typeof next)=='function'
          fCheckNext = ( (obj) -> (->obj.checkNext()) )(@)
          @_fCheck = next
          @_timer = setInterval(fCheckNext,1)
        else if Array.isArray(next) and next.length>=1
          switch next[0]
            when 'key', 'mouse'
              options = if next.length>=2 then next[1] else {}

              options.event = options.event ? 'down'
              options.button = options.button ? 'any'
              options.expires = 1
              options.f = fDoStepNext

              _mwlearn.input.addHandler(next[0],options)
            else throw "Invalid next value"
        else
          throw "Invalid next value"

      Execute: ->
        @_tStart = _mwlearn.time.Now()

        @finished = false
        @_idx = 0

        _mwlearn.queue.do(@stepName(0))

    Show: class Show extends Sequence
      _stim: null
      _stimObj: null

      _fixation: false

      constructor: (name, stim, next, options={}) ->
        options.fstep = options.fstep ? (null for [1..stim.length])
        @_fixation = options.fixation ? false

        @_stim = stim
        @_stimObj = []

        super name, options.fstep, next, options

      executeStep: (idx) ->
        @_stimObj.push new _mwlearn.show[s[0]](s[1..]...) for s in @_stim[idx]

        if @_fixation
          fixObj = _mwlearn.fixation[0]
          fixArg = _mwlearn.fixation[1]

          @_stimObj.push new _mwlearn.show[fixObj](fixArg...)

      cleanupStep: (idx) ->
        super idx
        stim.remove() for stim in @_stimObj
        @_stimObj = []

  MWQueue: class MWQueue
    _queue = []

    length: -> _queue.length

    add: (name, f, options={}) ->
      options.do = options.do ? true
      _queue.push {name:name, f:f, ready:false}

      if options.do then @do name

    do: (name) ->
      if _queue.length > 0
        if _queue[0].name==name
          _queue[0].ready = true
          _queue.shift().f() while _queue.length>0 and _queue[0].ready
        else
          for i in [0.._queue.length-1]
            if _queue[i].name==name
              _queue[i].ready = true
              break

  MWGame: class MWGame
    constructor: ->
      @construct = new MWGameConstruct
      @assemblage = new MWGameAssemblage

    MWGameConstruct: class MWGameConstruct
      constructor: ->
        @nPart = 100

      srcPart: (i, position=0) ->
        if i=="all"
          srcAll = ( (@srcPart(i, p) for i in [0..@nPart-1]) for p in [0..3] )
          [].concat srcAll...
        else
          "/static/mwlearnapp/images/construct/part/#{position}/#{zpad i,3}.png"

      partRange: (d) ->
        iLast = Math.min(@nPart-1,1 + Math.floor(d*(@nPart-1)))
        iFirst = Math.max(0, iLast - 25)

        [iFirst, iLast]


      pick: (n, d) ->
        rng = @partRange(d)
        rngMid = (rng[0] + rng[1])/2

        parts = (0 for [1..n])
        soFar = 0
        pickNext = (i) ->
          if i==n-1 #get us around the mid point
            iMid = rngMid*n - soFar
            iMin = Math.max(rng[0], Math.floor(iMid - 0.5))
            iMax = Math.min(rng[1], Math.ceil(iMid + 0.5))
            nextPart = randomInt(iMin, iMax)
          else #choose one that allows us to reach the mid point by the end
            loop
              nextPart = randomInt(rng[0], rng[1])
              endMin = ( soFar + nextPart + rng[0]*(n-i-1) ) / n
              endMax = ( soFar + nextPart + rng[1]*(n-i-1) ) / n
              break if endMin<=rngMid and rngMid<=endMax

          soFar += nextPart
          nextPart

        parts[i] = pickNext(i) for i in [0..n-1]
        randomize parts
        parts


      difficultyColor: (d, dMin=0, dMax=0.4) ->
        _mwlearn.color.blend('difficulty', (d-dMin)/dMax)

    MWGameAssemblage: class MWGameAssemblage
      _map: null
      _param: null

      constructor: ->
        @_map = {}
        @_param = []

        @addPart('square',
          [ ['L',0,1], ['L',1,1], ['L',1,0], ['Z'] ]
          {
            symmetric: true
            inside: true
          }
        )
        @addPart('circle',
          [ ['M',0,0.5], ['C',0,0.5,0,1,0.5,1], ['C',0.5,1,1,1,1,0.5], ['C',1,0.5,1,0,0.5,0], ['C',0.5,0,0,0,0,0.5] ]
          {
            symmetric: true
            inside: true
          }
        )
        @addPart('triangle',
          [ ['M',0,1], ['L',0.5,0], ['L',1,1], ['Z'] ]
          {
            connects: [1,3]
          }
        )
        @addPart('diamond'
          [ ['M',0.5,0], ['L',0,0.5], ['L',0.5,1], ['L',1,0.5], ['Z'] ]
          {
            symmetric: true
          }
        )
        @addPart('right triangle',
          [ ['M',0,1], ['L',1,1], ['L',1,0], ['M',1,0], ['L',0,1] ]
          {
            connects: [2,3]
          }
        )
        @addPart('line',
          [ ['M',0.5,0], ['L',0.5,1], ['M',1,1] ] #last move just to fill the space
          {
            connects: [1,3]
          }
        )
        @addPart('cross'
          [ ['M',0.5,0], ['L',0.5,1], ['M',0,0.5], ['L',1,0.5] ]
          {
            symmetric: true
          }
        )
        @addPart('T',
          [ ['L',1,0], ['M',0.5,0], ['L',0.5,1] ]
          {
            connects: [1,3]
          }
        )
        @addPart('D',
          [ ['L',0,1], ['L',0.5,1], ['C',0.5,1,1,1,1,0.5], ['C',1,0.5,1,0,0.5,0], ['Z'] ]
          {
            connects: [0,2]
          }
        )
        @addPart('E'
          [ ['M',1,0], ['L',0,0], ['L',0,1], ['L',1,1], ['M',0,0.5], ['L',1,0.5] ]
        )
        @addPart('5',
          [ ['M',1,0], ['L',0,0], ['L',0,0.5], ['L',1,0.5], ['L',1,1], ['L',0,1] ]
          {
            connects: [1,3]
          }
        )
        @addPart('B',
          [ ['L',0,1], ['L',0.75,1], ['C',0.75,1,1,1,1,0.75], ['C',1,0.75,1,0.5,0.75,0.5], ['L',0,0.5], ['L',0.75,0.5], ['C',0.75,0.5,1,0.5,1,0.25], ['C',1,0.25,1,0,0.75,0], ['Z'] ]
          {
            connects: [0,1,3]
          }
        )
        @addPart('F',
          [ ['M',1,0], ['L',0,0], ['L',0,1], ['M',0,0.5], ['L',1,0.5] ]
          {
            connects: [0,1]
          }
        )
        @addPart('J',
          [ ['L',1,0], ['M',0.5,0], ['L',0.5,0.75], ['C',0.5,0.75,0.5,1,0.25,1], ['C',0.25,1,0,1,0,0.75] ]
          {
            connects: [1]
          }
        )

      param: (part) -> @_param[@_map[part]]
      parts: (iMax=null) -> p.name for p,i in @_param when ((not iMax?) or i<=iMax)

      addPart: (name, definition, options={}) ->
        options.name = name
        options.definition = definition
        options.connects = options.connects ? [0,1,2,3]
        options.symmetric = options.symmetric ? false
        options.inside = options.inside ? false

        @_map[name] = @_param.push(options) - 1

      findReplacements: (part, iMax=null) ->
        conn = @param(part).connects

        possibleParts = []
        for replacement in @parts(iMax)
          if part!=replacement
            goodReplacement = true
            for c in conn
              if find(@param(replacement).connects,c).length==0
                goodReplacement = false
                break
            if goodReplacement then possibleParts.push replacement
        possibleParts

      pickReplacement: (part,iMax=null) -> pickFrom(@findReplacements(part,iMax))

      replacePartInSet: (setParam, iMax=null) ->
        idx = randomInt(0,setParam.length-1)
        setParam[idx][0] = @pickReplacement(setParam[idx][0],iMax)
        setParam

      create: (nPart, iMax) ->
        a = new _mwlearn.show.Assemblage #make a new assemblage
            color: _mwlearn.color.pick()

        a.show false #hide it
        a.addRandom(nPart, iMax) #add the parts
        a
      createDistractor: (target, iMax=null) ->
        distractor = new _mwlearn.show.Assemblage
          color: target.attr "color"

        targetSet = target.getSet()
        distractorSet = @replacePartInSet targetSet, iMax
        distractor.addSet distractorSet
        distractor
      instruct: (a) ->
        alert a._instruction.join("\n") #***
      test: (target, iMax=null) ->
        target.attr "mousedown", (e,x,y) -> alert "Yes!"

        test = (@createDistractor(target, iMax) for [1..3])
        test.push target
        randomize test

        x = smult([-1,1,1,-1],250)
        y = smult([-1,-1,1,1],250)

        t.attr("x", x[i]) for t,i in test
        t.attr("y", y[i]) for t,i in test

        target.show true

window.mwl = new MWLearn "experiment",
  background: "white"

fTestStimulus = ->
  el = new mwl.show.Rectangle
  el.attr "x", -100

fTestConstruct = ->
  R = 20; C = 30
  W = 800
  for i in [0..R-1]
    for j in [0..C-1]
      d = 1*( (i*C + j)/(R*C-1) )
      x = new mwl.show.ConstructFigure d,
        width: W/R
        height: W/R
        x: -W/2*(C/R) + j*W/(R-1)
        y: -W/2 + i*W/(R-1)
        #rot: 45
        color: mwl.game.construct.difficultyColor(d,0,1)
        #mousedown: (e,x,y,z) -> alert "#{x}, #{y}, #{z}"

fTestAssemblage = ->
  a = mwl.game.assemblage.create 5, 4
  mwl.game.assemblage.instruct a
  mwl.game.assemblage.test a, 4

fTestInput = ->
  mwl.input.addHandler "mouse", {
    event: 'down'
    button: 'left'
    expires: 0
    f: (evt) -> document.title = mwl.time.Now() #evt.which
  }

fTestExecuteSequence = ->
  f = [
    -> document.title = 1
    -> document.title = 2
    -> document.title = 3
    -> document.title = 'press the key!'
    -> document.title = 'click the button!'
    -> document.title = 'bye'
  ]
  n = [
    (tStart, tStep) -> mwl.time.Now() > tStep + 2000
    1000
    1000
    ['key', {button: 'a'}]
    ['mouse', {button: 'left'}]
    1000
  ]
  cleanup = [
    -> alert 'clean up step 1!'
    null
    null
    null
    null
  ]
  exec = new mwl.exec.Sequence 'test_sequence', f, n, {
    cleanup: cleanup
    callback: -> document.title = 'done!'
  }
  mwl.queue.add "blah", -> alert 'hi'

fTestShowSequence = ->
  stim = [
    [
      ['Text', 'hi there']
      ['Circle', {color: 'red', y: -100}]
    ]
    [
      ['Text', 'what\'s your name?']
      ['Circle', {color: 'green', y: -100}]
    ]
    [
      ['Text', 'do you come here often?']
      ['Circle', {color: 'blue', y: -100}]
    ]
    [
      ['Circle', {color: 'blue', r: 100, y: -100}]
      ['Text', 'is this text properly centering itself, and what is the nature of the universe?']
    ]
  ]
  next = [
    1000
    1000
    1000
    ['mouse', {button: 'left'}]
  ]

  shw = new mwl.exec.Show 'test_show_sequence', stim, next, {
    callback: -> document.title = 'done!'
  }


#mwl.queue.add "teststimulus", fTestStimulus
#mwl.queue.add "figure", fTestConstruct
#mwl.queue.add "figure", fTestAssemblage
#mwl.queue.add "testinput", fTestInput
#mwl.queue.add "testexec", fTestExecuteSequence
mwl.queue.add "testshowsequence", fTestShowSequence
