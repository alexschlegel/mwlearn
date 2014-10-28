window.obj2str = (obj, indent=0) ->
  if obj? and (typeof obj=='object')
    pre = (if indent>0 then "\n" else "")
    pad = zpad('',indent,"\t")
    str = []

    for key,val of obj
      str.push "#{pad}#{key}:#{obj2str(val,indent+1)}"

    pre+str.join("\n")
  else
    obj
window.getClass = (obj) -> obj.constructor.name
zpad = (x,n,chr='0') -> x=chr + x while (''+x).length < n; x
extend = (obj, prop) -> obj[key]=val for key, val of prop; obj
copyobj = (obj) -> extend {}, obj
copyarray = (arr) -> arr.slice(0)
merge = (obj1, obj2) -> extend copyobj(obj1), obj2
remove = (obj, keys) -> objc = copyobj(obj); delete(objc[key]) for key in keys; objc
swap = (x,i1,i2) -> tmp=x[i1]; x[i1]=x[i2]; x[i2]=tmp
sum = (x,s=0,e=null) -> n=x.length; if 0<=s<n and (not e? or s<=e) then x[s] + sum(x,s+1,e ? n-1) else 0
add = (a,b) -> (a[idx]+b[idx] for idx in [0..a.length-1])
sub = (a,b) -> (a[idx]-b[idx] for idx in [0..a.length-1])
mult = (a,b) -> (a[idx]*b[idx] for idx in [0..a.length-1])
mean = (a) -> sum(a)/a.length
divide = (a,b) -> (a[idx]/b[idx] for idx in [0..a.length-1])
smult = (a,b) -> (a[idx]*b for idx in [0..a.length-1])
mod = (x,n) -> r=x%n; if r<0 then r+n else r
around = (x) -> (Math.round(e) for e in x)
window.nearest = (x,ref) ->
  df = (Math.abs(x-r) for r in ref)
  dfMin = Math.min(df...)
  return ref[i] for i in [0..ref.length-1] when df[i]==dfMin
window.randomInt = (mn,mx) -> Math.floor(Math.random() * (mx - mn + 1)) + mn
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
window.find = (x,v) -> f = []; f.push(i) for e,i in x when equals(e,v); f
setdiff = (x,d) -> e for e in x when not equals(e,d)
fixAngle = (a) ->
  a = mod(a,360)
  if a>180 then a-360 else a
naturalAngle = (a, orientation=false, compact=false) ->
  a = fixAngle(a)
  switch a
      when 0
        ""
      when 180
        "#{Math.abs(a)}°" #upside down"
      else
        if compact
          direction = if a>0 then ' CW' else ' CCW'
        else
          direction = if a>0 then ' clockwise' else ' counter clockwise'

        orient = if orientation then ' rotated' else ''
        "#{Math.abs(a)}°#{direction}#{orient}"
window.naturalDirection = (a, symmetry='none') ->
  a = fixAngle(a)
  switch symmetry
    when "90"
      switch a
        when -90, 0, 90, 180
          ""
        else
          "#{naturalAngle(a)} rotated"
    when "180"
      switch a
        when 0, 180
          "vertical"
        when -90, 90
          "horizontal"
        else
          "#{naturalAngle(a)} rotated"
    else
      switch a
        when 0
          "up facing"
        when 90
          "right facing"
        when 180
          "down facing"
        when -90
          "left facing"
        else
          "#{naturalAngle(a)} rotated"
aan = (str) -> if str.length==0 or find("aeiou",str[0]).length==0 then 'a' else 'an'
capitalize = (str) -> str.charAt(0).toUpperCase() + str.slice(1)
contains = (x,v) ->
  for e in x
    if equals(e,v) then return true
  false
unique = (x) -> u=[]; u.push(e) for e in x when not contains(u,e); u
forceArray = (a) -> if a? then (if Array.isArray(a) then a else [a]) else a
wordCount = (str) -> str.split(' ').length
msPerT = (unit) ->
  switch unit
    when 'day'
      86400000
    when 'hour', 'hr', 'h'
      3600000
    when 'minute', 'min', 'm'
      60000
    when 'second', 'sec', 's'
      1000
    when 'millisecond', 'msec', 'ms'
      1
    when 'dayminus10minutes'
      85800000
    else
      throw 'Invalid unit'
convertTime = (t,unitFrom,unitTo) -> t*msPerT(unitFrom)/msPerT(unitTo)


window.MWLearn = class MWLearn
  base: null

  container: null
  el: null
  im: null

  status: null
  background: null

  _background: null
  _isbase: false

  constructor: (options={}) ->
    if options.base?
      @base = options.base
    else
      @_isbase = true
      @base = @

    options.type = options.type ? 'main'

    defaults = switch options.type
      when "main"
        {
          loadimages: true
          background: 'white'
          container: 'experiment'
        }
      when "status"
        {
          loadimages: false
          background: 'white'
          container: 'status'
        }
      else
        {
          loadimages: false
          background: 'white'
          container: document.body
        }

    @container = options.container ? defaults.container
    options.images = options.images ? []
    options.loadimages = options.loadimages ? defaults.loadimages
    @background = options.background ? defaults.background
    @fixation = options.fixation ? ["Circle", [{color:"red", r:5}]]

    @im = {}

    @paper = Raphael @container

    @show = @Show()
    @input = @Input()
    @time = @Time()
    @color = @Color()
    @exec = @Exec()
    @queue = @Queue()
    @game = @Game()
    if @_isbase then @data = @Data()

    @_background = @show.Rectangle
      color: @background
      width: @width()
      height: @height()

    if options.loadimages
      imConstruct = @game.construct.srcPart("all")
      images = options.images.concat imConstruct
      if images.length then @LoadImages images

    @el = {}

    timerName = 'session'
    switch options.type
      when 'main'
        @data = @Data()
        @el.status = new MWLearn
          base: @
          type: 'status'
          practice_time: options.practice_time
      when 'status'
        @el.timer = @show.Timer options.practice_time ? convertTime(25,'minute','ms'),
          name: timerName
          color: 'gray'
          t: 10

        @el.timer.contain()
      else
        null

  width: -> @paper.width
  height: -> @paper.height
  clear: -> @paper.clear()

  LoadImages: (images) ->
    nLoaded = 0
    p = @show.Progress "Loading Images", steps:20
    f = -> p.update ++nLoaded/images.length

    for i in [0..images.length-1]
      qName = "image_#{images[i]}"
      @queue.add qName, f, {do:false}
      @im[images[i]] = new Image()
      @im[images[i]].src = images[i]
      @im[images[i]].onload = ((name) => => @queue.do name)(qName)


  MWClass: class MWClass
    root: null
    base: null

    constructor: (root) ->
      @root = root
      @base = root.base

  Show: -> new MWClassShow(@)
  MWClassShow: class MWClassShow extends MWClass

    Stimulus: (options={}, addDefaults=true) -> new @MWClassShowStimulus(@root, options, addDefaults)
    MWClassShowStimulus: class MWClassShowStimulus extends MWClass
      element: null

      handlers: null

      auto_scale: 0

      _rotation: 0
      _scale: 1
      _translation: [0, 0]

      _defaults: {
        x: 0
        y: 0
        width: 100
        height: 100
        color: "black"
      }

      _show_state: true
      _mousedown: null

      constructor: (root, options, addDefaults) ->
        super root

        @handlers = {}

        options = @parseOptions options, {}, addDefaults

        @auto_scale = options.auto_scale ? 1

        @attr(name, value) for name, value of options

      parseOptions: (options, defaults={}, addDefaults=true) ->
        def = if addDefaults then merge(@_defaults, defaults) else copyobj(defaults)

        if options.l? and def.x? then delete def.x
        if options.t? and def.y? then delete def.y

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

      x2lc: (x) -> x + @root.width()/2
      lc2x: (l) -> l - @root.width()/2
      y2tc: (y) -> y + @root.height()/2
      tc2y: (t) -> t - @root.height()/2
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
            @root.width()
          when 'v'
            @root.height()
          else
            (@root.height() + @root.width())/2

      norm2px: (x, type) -> x*@extent(type)
      px2norm: (x, type) -> x/@extent(type)

      maxBox: ->
        wTotal = @root.width()
        hTotal = @root.height()

        wMax = wTotal - 2*Math.abs(@attr('x'))
        hMax = hTotal - 2*Math.abs(@attr('y'))

        [@auto_scale*wMax, @auto_scale*hMax]

      attr: (name, value) ->
        switch name
          when "color"
            ret = @element.attr "fill", value
          when "width", "height"
            if value?
              if value=='auto'
                @attr('box',@maxBox())
              else
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
            if value?
              @_mousedown = value
              @element.mousedown(value)
            else
              ret = @_mousedown
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
          when "show"
            if value?
              @_show_state = value
              if value then @element.show() else @element.hide()
            else
              ret = @_show_state
          else
            ret = @element.attr(name,value)

        if value? then @ else ret

      contain: ->
          wTotal = @root.width()
          hTotal = @root.height()

          w = @attr "width"
          h = @attr "height"
          l = @attr "l"
          t = @attr "t"

          if l+w > wTotal
            @attr "box", [Math.max(0,2*(wTotal-(l+w/2))), h]
          else if l < 0
            @attr "box", [Math.max(0,2*(l+w/2)), h]

          if t+h > hTotal
            @attr "box", [w, Math.max(0,2*(hTotal-(t+h/2)))]
          else if t < 0
            @attr "box", [w, Math.max(0,2*(t+h/2))]

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

      remove: -> if @element? then @element.remove(); @element = null

      mousedown: (f) -> @attr "mousedown", f

      show: (state=null) -> @attr "show", state

      exists: () -> @element?

    CompoundStimulus: (elements, options={}) -> new @MWClassShowCompoundStimulus(@root,elements,options)
    MWClassShowCompoundStimulus: class MWClassShowCompoundStimulus extends MWClassShowStimulus
      _defaultElement: 0

      _background: null

      constructor: (root, elements, options) ->
        options.background = options.background ? null

        @element = copyarray (if elements instanceof MWClassShowCompoundStimulus then elements.element else elements)
        super root, options, false

        if options.background?
          if options.background==true then options.background = @root.background

          @_background = @root.show.Rectangle
            color: options.background

          if @element.length>0 then @_background.element.insertBefore @element[0].element

          @updateBackground(["width","height","x", "y", "show","mousedown"])

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

                @updateBackground [name, xy]
            else
              ret = sCur
          when "l", "t"
            n = @element.length
            if n==0
              ret = pCur = switch name
                when "l"
                  @root.width()/2
                when "t"
                  @root.height()/2
                else
                  #nothing
            else
              ret = pCur = Math.min (el.attr(name) for el in @element)...

            if value?
              pMove = value - pCur
              if n>0
                el.attr(name, el.attr(name)+pMove) for el in @element
                @updateBackground name
          when "cl", "ct"
            ret = @attr "#{name[1]}c", value
          when "box", "x", "y", "cx", "cy", "lc", "tc"
            ret = super name, value
            if value? then @updateBackground name
          when "element_mousedown"
            ffEvent = (elm) -> (e,x,y) -> value(elm,x,y)
            el.attr("mousedown",ffEvent(el)) for el in @element
            if @_background?
              @_background.attr "mousedown", ffEvent(@_background)
          else
            if value?
              el.attr(name, value) for el in @element

              switch name
                when "show", "mousedown"
                  @updateBackground(name)
                else
                  #nothing
            else
              ret = if @element.length>0 then @element[@_defaultElement].attr(name) else null

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

      remove: (el=null, removeElement=true) ->
        if el?
          if not (el instanceof MWClassShowStimulus)
            idx = el
          else
            idx = find(@element,el)[0]

          if removeElement then @element[idx].remove()
          @element.splice(idx,1)
        else
          if removeElement then (el.remove() for el in @element)
          @element = []
      exists: -> @element.length > 0

      addElement: (el) ->
        @element.push el
        if not @_show_state then el.show(false)
      removeElement: (el) ->
        idx = @getElementIndex(el)
        @element[idx].remove()
        @element.splice idx, 1
      getElement: (el) -> if el instanceof MWClassShowStimulus then el else @element[el]
      getElementIndex: (el) -> if not (el instanceof MWClassShowStimulus) then el else find(@element,el)[0]

      updateBackground: (param) ->
        if @_background?
          for p in forceArray(param)
            @_background.attr(p,@attr(p))

    Choice: (elements, options={}) -> new MWClassShowChoice(@root,elements,options)
    MWClassShowChoice: class MWClassShowChoice extends MWClassShowCompoundStimulus
      choiceMade: false
      choice: null
      callback: null

      timeout: null
      _tStart: 0
      _tChoice: 0

      constructor: (root, elements, options) ->
        ###
          elements: an array of Stimulus objects
          options:
            choice_include: an array of indices of Stimulus objects to include
                            as choices
            callback: a function that takes this object and the chosen index as
                      inputs
            timeout: number of milliseconds before the choice times out
        ###
        super root, elements, options

        options.choice_include = options.choice_include ? [0..@element.length-1]
        @callback = options.callback ? null
        @timeout = options.timeout ? null


        for idx in options.choice_include
          fDown = ((i) => (e,x,y) => @choiceEvent(i))(idx)
          @element[idx].mousedown fDown

        @_tStart = @root.time.Now()

        if @timeout? then window.setTimeout (=> @choiceEvent(null)), @timeout

      choiceEvent: (idx) ->
        if not @choiceMade
          @_tChoice = @root.time.Now()
          @choiceMade = true
          @choice = idx
          that = @
          if @callback? then @callback(that,idx)

    Test: (elements, options={}) -> new MWClassShowTest(@root,elements,options)
    MWClassShowTest: class MWClassShowTest extends MWClassShowChoice
      correct: null

      constructor: (root,elements, options={}) ->
        ###
          elements: an array of Stimulus objects
          options:
            instruct: the instruction to give
            choice_include: an array of indices of Stimulus objects to include
                            as choices
            correct: the index of the correct choice / array of indices. if this
                     is unspecified, then each Stimulus object should have a
                     boolean property named "correct" the specifies whether the
                     Stimulus is a correct choice.
            pad: the padding in between each choice as a percentage of the total
                 canvas size
        ###
        @root = root

        options.instruct = options.instruct ? "Choose one."
        options.choice_include = forceArray(options.choice_include ? [0..elements.length])
        options.correct = forceArray(options.correct ? null)
        options.pad = options.pad ? 5

        #record which choices are correct
        if options.correct? then (elements[i]=options.correct[i] for i in [0..elements.length-1])

        #create the instructions
        instruct = root.show.Instructions options.instruct
        hInstruct = instruct.attr "height"

        #line up the choices and make them fill the screen

        #get the maximum final element dimensions
        nEl = elements.length

        wTotal = root.width()
        hTotal = root.height()
        padWPx = wTotal*options.pad/100
        padHPx = hTotal*options.pad/100

        wFinalMax = Math.max(10,(wTotal - (nEl+1)*padWPx)/nEl)
        hFinalMax = Math.max(10,2*(hTotal/2 - hInstruct - padHPx))

        #maximum current dimensions
        elW = (el.attr "width" for el in elements)
        elH = (el.attr "height" for el in elements)

        wMax = Math.max(elW...)
        hMax = Math.max(elH...)

        #target scale
        wScale = wFinalMax/wMax
        hScale = hFinalMax/hMax
        scale = Math.min(wScale,hScale)

        #scale the elements
        for el in elements
          el.attr "box", [scale*el.attr("width"), scale*el.attr("height")]

        #line up the choices
        elW = (el.attr "width" for el in elements)
        elH = (el.attr "height" for el in elements)
        hMax = Math.max(elH...)

        wTotal = sum(elW) + padWPx*(nEl-1) - elW[0]/2 - elW[-1..]/2
        xCur = -wTotal/2
        for el,idx in elements
          el.attr "x", xCur
          el.attr "y", 0
          xCur += elW[idx] + padWPx

        #position the instructions
        instruct.attr "y", hMax/2+padHPx

        #add the instructions to the elements
        elements = copyarray(elements)
        elements.push instruct

        options = remove options, ['pad']
        super root, elements, options

      choiceEvent: (idx) ->
        @correct = if idx? then @element[idx].correct else false
        super idx

    Rectangle: (options={}) -> new MWClassShowRectangle(@root,options)
    MWClassShowRectangle: class MWClassShowRectangle extends MWClassShowStimulus
      constructor: (root,options) ->
        @root = root

        options = @parseOptions options

        l = @x2l(options.x, options.width)
        t = @y2t(options.y, options.height)
        w = options.width
        h = options.height

        @element = root.paper.rect l, t, w, h
        options = remove options, ['width', 'height', 'x', 'y']

        super root, options, false
        @element.attr "stroke", "none"

    Square: (options={}) -> new MWClassShowSquare(@root,options)
    MWClassShowSquare: class MWClassShowSquare extends MWClassShowRectangle
      constructor: (root,options) ->
        @root = root

        if options.width? then options.height = options.width
        if options.height? then options.width = options.height
        options = @parseOptions options

        super root, options

      attr: (name, value) ->
        switch name
          when "length", "width", "height"
            super "width", value
            super "height", value
          else
            super name, value

    Circle: (options={}) -> new MWClassShowCircle(@root,options)
    MWClassShowCircle: class MWClassShowCircle extends MWClassShowStimulus
      constructor: (root,options) ->
        @root = root

        options = @parseOptions options, {
          r: @_defaults.width/2
        }

        cl = @x2l(options.x, 2*options.r) + options.r
        ct = @y2t(options.y, 2*options.r) + options.r
        r = options.r

        @element = root.paper.circle cl, ct, r
        options = remove options, ['x', 'y', 'r', 'width', 'height']

        super root, options, false
        @element.attr "stroke", "none"

      attr: (name, value) ->
        switch name
          when "width", "height"
            if value?
              if value=='auto' then super(name, value) else super("r", value/2)
            else
              2*super("r")
          when "l", "t"
            xy = "c#{@type2xy(name)}"
            wh = @type2wh(name)

            if value?
              @element.attr(xy, value + @attr(wh)/2)
            else
              ret = @element.attr(xy) - @attr(wh)/2
          else
            super name, value

    Text: (text, options={}) -> new MWClassShowText(@root,text,options)
    MWClassShowText: class MWClassShowText extends MWClassShowStimulus
      _max_width: 0
      _max_height: 0

      constructor: (root, text, options) ->
        @root = root

        @element = root.paper.text 0,0,text

        options = @parseOptions options, {
          "font-family": "Arial"
          "font-size": 18
          "text-anchor": "start"
          "max-width": root.width()
          "max-height": root.height()
        }

        options = remove options, ['width', 'height']

        super root, options, false

      attr: (name, value) ->
        switch name
          when "t"
            if value?
              tActual = Math.min(@root.height()-@attr("height")/2,value+@attr("height")/2)
              super name, tActual
            else
              ret = super(name)-@attr("height")/2
          when "width", "height"
            if value?
              if value=='auto'
                super name, value
              else
                sCur = @attr name
                f = value / sCur

                fontSize = @attr 'font-size'
                fontSizeNew = f*fontSize

                @attr "font-size", fontSizeNew
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
          when "max-width"
            if value?
              @_max_width = value

              if @attr("width") > @_max_width then @attr("width",@_max_width)
            else
              ret = @_max_width
          when "max-height"
            if value?
              @_max_height = value

              if @attr("height") > @_max_height then @attr("height",@_max_height)
            else
              ret = @_max_height
          else
            ret = super name, value

        if value? then @ else ret

    Path: (path, options={}) -> new MWClassShowPath(@root, path, options)
    MWClassShowPath: class MWClassShowPath extends MWClassShowStimulus
      _param: null

      constructor: (root, path, options) ->
        @root = root

        options.width = options.width ? 100
        options.height = options.height ? 100
        options['stroke-width'] = options['stroke-width'] ? 0

        bWidthAuto = options.width=='auto'
        bHeightAuto = options.height=='auto'
        bAuto = bWidthAuto or bHeightAuto
        if bWidthAuto
          if not bHeightAuto
            options.width = options.height
          else
            options.width = 100
            options.height = 100
        else if bHeightAuto
          options.height = options.width

        @_param = {
          path: path
          width: options.width
          height: options.height
          l: 0
          t: 0
          orientation: 0
        }

        options = remove options, ['width', 'height']
        @element = root.paper.path(@constructPath(null,false))

        super root, options

        if bAuto
          @attr 'width', 'auto'

      _bottomRightCorner: ->
        p = [@_param.width/2, @_param.height/2]
        rotate(p, @_param.orientation)
      _topRightCorner: ->
        p = [@_param.width/2, -@_param.height/2]
        rotate(p, @_param.orientation)
      _maxExtent: (idx) ->
        2*Math.max(Math.abs(@_bottomRightCorner()[idx]),Math.abs(@_topRightCorner()[idx]))

      rotatedWidth: -> @_maxExtent(0)
      rotatedHeight: -> @_maxExtent(1)

      attr: (name, value) ->
        switch name
          when "path", "width", "height", "l", "t", "orientation"
            if value?
              if value=='auto'
                super name, value
              else
                p = {}
                p[name] = value

                if name=='width'
                  p.l = @_param.l + (@_param.width-value)/2
                else if name=='height'
                  p.t = @_param.t + (@_param.height-value)/2

                @constructPath(p)
            else
              ret = @_param[name]
          else
            ret = super name, value

        if value? then @ else ret

      rotate: (a,xc=null,yc=null) ->
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

        @attr "orientation", @attr("orientation")+a

      constructPath: (param={}, setPath=true) ->
        @_param[p]=v for p,v of param

        s = [@_param.width, @_param.height]
        offset = [@_param.l, @_param.t]

        a = @_param.orientation

        origin = add(mult(rotate([0,0],a,[0.5,0.5]),s),offset)
        path = "M" + origin

        for op in @_param.path
          path += op[0]
          if op.length>1
            for idx in [1..op.length-1] by 2
              f = rotate( op[idx..idx+1], a, [0.5,0.5] )
              p = add( mult(f,s) , offset )
              path += p + ","
        if setPath then @element.attr "path", path else path

    Instructions: (text, options={}) -> new MWClassShowInstructions(@root, text, options)
    MWClassShowInstructions: class MWClassShowInstructions extends MWClassShowText
      constructor: (root, text, options) ->
        @root = root

        options = @parseOptions options, {
          "font-family": "Arial"
          "font-size": 36
        }

        super root, text, options

    Timer: (tTotal, options={}) -> new MWClassShowTimer(@root, tTotal, options)
    MWClassShowTimer: class MWClassShowTimer extends MWClassShowText
      tTotal: 0
      tTimer: 0
      tGo: null

      name: null

      showms: false
      prefix: null
      suffix: null

      _intervalID: null

      _setTimer: (t) ->
        @tTimer.set t
        @render()

      constructor: (root, tTotal, options) ->
        @root = root
        @base = root.base

        @tTotal = tTotal
        @name = options.name ? 'timer'
        @showms = options.showms ? false
        @prefix = options.prefix ? null
        @suffix = options.suffix ? 'remaining'
        @tUpdate = options.update_interval ? (if @showms then 10 else 250)

        @tTimer = @base.data.variable "#{@name}_remaining", @tTotal,
          timeout: msPerT('dayminus10minutes')

        super root, @string(), options

      remaining: ->
        Math.max(0,if @tGo? then (@tTimer.get()-(@root.time.Now()-@tGo)) else @tTimer.get())

      string: ->
        t = @remaining()

        hours = Math.floor(convertTime(t,'ms','hour'))
        t -= convertTime(hours,'hour','ms')

        minutes = Math.floor(convertTime(t,'ms','minute'))
        t -= convertTime(minutes,'minute','ms')

        seconds = Math.floor(convertTime(t,'ms','second'))
        t -= convertTime(seconds,'second','ms')

        strHours = if hours>0 then "#{zpad(hours,2)}:" else ''
        strMinutes = "#{zpad(minutes,2)}:"
        strSeconds = zpad(seconds,2)
        strMS = if @showms then ".#{t}" else ''

        prefix = if @prefix? then "#{@prefix}: " else ''
        suffix = if @suffix? then " #{@suffix}" else ''
        "#{prefix}#{strHours}#{strMinutes}#{strSeconds}#{strMS}#{suffix}"

      render: -> @attr "text", @string()

      update: ->
        if @remaining()<=0 then @stop()
        @render()

      go: ->
        @tGo = @root.time.Now()
        @_intervalID = window.setInterval (=> @update()), @tUpdate

      stop: ->
        if @_intervalID? then clearInterval(@_intervalID)
        tRemain = @remaining()
        @tGo = null
        @_setTimer(tRemain)

    Image: (src, options={}) -> new MWClassShowImage(@root, src, options)
    MWClassShowImage: class MWClassShowImage extends MWClassShowStimulus
      constructor: (root, src, options) ->
        @root = root

        bAutoSize = src of root.im
        options = @parseOptions options, {
          width: if bAutoSize then root.im[src].width else @_defaults.width
          height: if bAutoSize then root.im[src].height else @_defaults.height
        }

        l = @x2l(options.x, options.width)
        t = @y2t(options.y, options.height)
        w = options.width
        h = options.height

        @element = root.paper.image src, l, t, w, h
        options = remove options, ['x', 'y', 'width', 'height']

        super root, options, false

      attr: (name, value) ->
        switch name
          when "color"
            null
          else
            super name, value

    ColorMask: (src, options={}) -> new MWClassShowColorMask(@root,src,options)
    MWClassShowColorMask: class MWClassShowColorMask extends MWClassShowCompoundStimulus
      _background: null
      _im: null

      constructor: (root, src, options) ->
        @root = root

        bAutoSize = src of root.im
        options = @parseOptions options, {
          width: if bAutoSize then root.im[src].width else @_defaults.width
          height: if bAutoSize then root.im[src].height else @_defaults.height
        }

        elements = []
        if options.color != "none" then elements.push (@_background = root.show.Rectangle())
        elements.push (@_im = root.show.Image src)

        super root, elements, options

      attr: (name, value) ->
        switch name
          when "color"
            if @_background? then ret = @_background.attr name, value
          when "width", "height"
            ret = @_im.attr name, value
            if value? and @_background? then @_background.attr name, @attr(name)-1
          else
            ret = super name, value

        if value? then @ else ret

    ConstructPart: (i, position, options={}) -> new MWClassShowConstructPart(@root,i,position,options)
    MWClassShowConstructPart: class MWClassShowConstructPart extends MWClassShowColorMask
      @_idx: null
      @_position: null

      constructor: (root, i, position, options) ->
        @_idx = i
        @_position = position
        src = root.game.construct.srcPart @_idx, @_position
        super root, src, options

      idx: -> @_idx

    ConstructFigure: (parts, options={}) -> new MWClassShowConstructFigure(@root,parts,options)
    MWClassShowConstructFigure: class MWClassShowConstructFigure extends MWClassShowCompoundStimulus
      @_rot: 0
      @_idx: null
      @_d: 0

      constructor: (root, parts, options) ->
        @root = root

        if Array.isArray(parts)
          @_idx = parts
          @_d = mean(@_idx)/@root.game.construct.nPart
        else if parts>=0 and parts<=1
          @_idx = root.game.construct.pick(4,parts)
          @_d = parts
        else
          throw "Invalid parts"

        options = @parseOptions options, {
          # width: 2*root.im[root.game.construct.srcPart(0)].width
          # height: 2*root.im[root.game.construct.srcPart(0)].height
          width: 200
          height: 200
        }

        wPart = options.width/2
        hPart = options.height/2
        owPart = wPart/2
        ohPart = hPart/2

        xFigure = options.x ? @l2x(options.l,options.width)
        yFigure = options.y ? @t2y(options.t,options.height)

        xl = xFigure - owPart
        xr = xFigure + owPart
        yt = yFigure - ohPart
        yb = yFigure + ohPart

        xPart = [xr, xr, xl, xl]
        yPart = [yt, yb, yb, yt]

        optionsPart = {
          width: wPart
          height: hPart
        }

        elements = [root.show.Rectangle(merge options, {
          width: options.width-4
          height: options.height-4
          color: options.color
        })]
        for i in [0..3]
          opt = merge optionsPart, {
            x:xPart[i]
            y:yPart[i]
            color: "none"
          }
          src = root.game.construct.srcPart @_idx[i], i
          elements.push (root.show.Image src, opt)


        options = remove options, ['x', 'y', 'width', 'height', 'color']

        super root, elements, options, false

      idx: -> @_idx

      createDistractors: (n) ->
        distractors = (null for [1..n])

        replace = [0..@_idx.length-1]
        randomize(replace)

        for idx in [0..n-1]
          parts = copyarray(@_idx)
          parts[replace[idx]] = @root.game.construct.pickOne(@_d, parts[replace[idx]])
          distractors[idx] = @root.show.ConstructFigure parts,
            width: @attr "width"
            height: @attr "height"
            color: @attr "color"


    ConstructPrompt: (figure, options={}) -> new MWClassShowConstructPrompt(@root,figure,options)
    MWClassShowConstructPrompt: class MWClassShowConstructPrompt extends MWClassShowCompoundStimulus
      _idx: null

      constructor: (root, figure, options) ->
        @_idx = figure._idx
        nPart = @_idx.length

        w = figure.attr("width")/2
        h = figure.attr("height")/2
        xPad = w/2

        options = @parseOptions options, {
          color: figure.attr("color")
          width: nPart*w + (nPart-1)*xPad
          height: h
        }

        xPrompt = options.x ? @l2x(options.l,options.width)
        yPrompt = options.y ? @t2y(options.t,options.height)

        xStart = xPrompt - nPart/2*w - Math.floor(nPart/2)*xPad

        cp = (0 for [1..nPart])
        for part,idx in @_idx
          x = xStart + (w+xPad)*idx + w/2
          cp[idx] = root.show.ConstructPart part, idx,
            width: w
            height: h
            x: x
            y: yPrompt

        super root, cp, options

    AssemblagePart: (part, options={}) -> new MWClassShowAssemblagePart(@root,part,options)
    MWClassShowAssemblagePart: class MWClassShowAssemblagePart extends MWClassShowStimulus
      _param: null
      _assemblage = null

      part: null

      constructor: (root, part, options) ->
        options.size = options.size ? 100
        options.thickness = options.thickness ? 10

        @part = part

        @_param = merge root.game.assemblage.param(@part),
          index: null
          width: options.size
          height: options.size
          l: 0
          t: 0
          orientation: 0
          grid: [0,0]
          parent: null
          attachment: [null,null,null,null]

        @element = root.paper.path(@constructPath(@_param,false))
        super root, options

        @attr "stroke-linecap", "round"
        @attr "stroke-linejoin", "round"
        @attr "fill", root.background

      attr: (name, value) ->
        switch name
          when "l", "t", "width", "height", "orientation"
            if value?
              if value=='auto'
                super name, value
              else
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
        if excludePart? then excludePart = @_assemblage.part(excludePart)._param.idx
        if excludeNeighbor? then excludeNeighbor = @_assemblage.part(excludeNeighbor)._param.idx

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
          gridOther = (@_assemblage.part(idx)._param.grid for idx in iOther)
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
            h = "left"
            hAbs = if gridMe[0]!=mnX then h
          else if gridMe[0] >= mxX
            h = "right"
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
        neighbor = @_assemblage.part(neighbor)
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
      naturalOrientation: -> naturalDirection(90*@_param.orientation, @_param.symmetry)
      naturalName: (fullName=false) ->
        orientation = if fullName then @naturalOrientation() else ""
        if orientation.length then orientation = "#{orientation} "
        "#{orientation}#{@part}"
      naturalDefinition: ->
        parent = if @_param.parent? then @_assemblage.part(@_param.parent) else null

        partName = @naturalName(true)
        partLocation = if parent? then " #{@naturalRelativeLocation(parent,true,@)}" else ""
        "#{partName}#{partLocation}"

    Assemblage: (options={}) -> new MWClassShowAssemblage(@root, options)
    MWClassShowAssemblage: class MWClassShowAssemblage extends MWClassShowCompoundStimulus
      _options: null
      _history: null
      _instruction: null

      _gridExtent: null

      existingParts: null
      possibleParts: null

      correct: true

      constructor: (root, options) ->
        parts = root.game.assemblage.parts()

        options.x = options.x ? 0
        options.y = options.y ? 0
        options.imax = options.imax ? parts.length-1
        options.background = options.background ? true
        options.correct = options.correct ? true

        @existingParts = []
        @possibleParts = parts[0..options.imax]

        @_options = options
        @_history = []
        @_instruction = []
        @_grid = {min: [0,0], max: [0,0]}

        @correct = options.correct

        super root, [], options

      attr: (name, value) ->
        switch name
          when "thickness"
            if value?
              super name, value
            else
              if @numParts()>0 then @part(0).attr(name) else null
          when "box"
            if value?
              wOld = @attr "width"
              ret = super name, value
              wNew = @attr "width"
              @attr "thickness", @attr("thickness") * wNew / wOld
              ret
            else
              super name, value
          when "color"
            if value? then part.attr("color",value) for part in @part() else super(name)
          else
            super name, value

      rotate: (steps, xc=null, yc=null) ->
        a = 90*steps

        super a, xc, yc
        el._param.grid = around(rotate(el._param.grid,a)) for el,i in @part()

        @addEvent 'rotate', a

      numParts: () -> @element.length
      numSteps: () -> @_history.length

      part: (part=null) ->
        if part instanceof MWClassShowStimulus
          part
        else if part?
          @element[@partElementIndex(part)]
        else if @numParts()>0
          @element[@partElementIndex(0)..]
        else
          []
      partElementIndex: (part) ->
        if part instanceof MWClassShowStimulus
          @partElementIndex(part._param.idx)
        else
          part

      addEvent: (eventType,info) ->
        @_history.push [eventType, info]

        switch eventType
          when "add"
            el = @part(info)

            action = if el._param.parent? then "Add" else "Imagine"
            thing = el.naturalDefinition()
            instruct = "#{action} #{aan(thing)} #{thing}"
          when "remove"
            el = @part(info)
            instruct = "Remove the #{el.naturalLocation()}"
          when "rotate"
            instruct = "Rotate the #{@naturalName()} #{naturalAngle(info)}"
          else
            throw 'Invalid event type'
        @_instruction.push instruct

      removePart: (part) ->
        part = @part(part)
        idx = part._param.idx

        #remove the connections
        for neighbor in part._param.attachment
          if neighbor?
            neighbor = @part(neighbor)
            conn = find(neighbor._param.attachment,idx)[0]
            neighbor._param.attachment[conn] = null
            if neighbor._param.parent==idx then neighbor._param.parent = null

        #add an event
        @addEvent 'remove', idx

        #remove the element
        @removeElement(@partElementIndex(idx))

      addPart: (partName, neighbor=null, sidePart=0, sideNeighbor=0, options={}) ->
        options = merge(@_options, options)

        xCur = @attr "x"
        yCur = @attr "y"

        part = @root.show.AssemblagePart partName, options
        part._assemblage = @

        @addElement part
        part._param.idx = @numParts()-1

        if find(@existingParts,partName).length==0 then @existingParts.push partName

        if neighbor?
          neighbor = @part(neighbor)

          part._param.parent = neighbor._param.idx
          neighbor._param.attachment[sideNeighbor] = part._param.idx
          part._param.attachment[sidePart] = neighbor._param.idx

          #orientation of the part to match with the neighbor
          orientation = mod( mod(sideNeighbor+2,4) - sidePart + neighbor._param.orientation,4)
          #direction to move from the neighbor
          gridRel = neighbor.side2direction(sideNeighbor)

          wP = part.attr "width"
          hP = part.attr "height"

          xN = neighbor.attr "x"
          yN = neighbor.attr "y"
          wN = neighbor.attr "width"
          hN = neighbor.attr "height"

          r = if sideNeighbor==0 or sideNeighbor==2 then (wN+wP)/2 else (hN+hP)/2

          x = xN + r*gridRel[0]
          y = yN + r*gridRel[1]

          part._param.grid = add(neighbor._param.grid, gridRel)

          @_grid.min[0] = Math.min(@_grid.min[0], part._param.grid[0])
          @_grid.max[0] = Math.max(@_grid.max[0], part._param.grid[0])
          @_grid.min[1] = Math.min(@_grid.min[1], part._param.grid[1])
          @_grid.max[1] = Math.max(@_grid.max[1], part._param.grid[1])
        else
          orientation = options.orientation ? 0
          x = @attr "x"
          y = @attr "y"

        part.attr "x", x
        part.attr "y", y
        part.attr "orientation", orientation
        part.scale @._scale

        @attr "x", xCur
        @attr "y", yCur

        @addEvent 'add', part._param.idx
        part

      addSet: (setParam) -> @addPart param... for param in setParam

      getSet: ->
        setParam = ([] for [1..@numParts()])
        for part,i in @part()
          partName = part.part
          parent = part._param.parent
          if parent?
            sidePart = find(part._param.attachment,parent)[0]
            sideParent = find(@part(parent)._param.attachment,part._param.idx)[0]
          else
            sidePart = sideParent = null

          setParam[i] = [partName,parent,sidePart,sideParent]
        setParam

      addRandom: (n=1) ->
        appendage = @pickAppendage()
        options = if !@numParts()>0 then {} else {orientation: randomInt(0,3)}
        ret = if appendage? then @addPart appendage...,options else null
        if n>1 then [ret, @addRandom(n-1)]

      naturalName: -> if @numParts()==1 then @part(0).naturalName() else "image"

      getUniqueParts: -> unique (part.part for part in @part())

      getOccupiedPositions: (excludePart=null) ->
        if excludePart? then excludePart = @part(excludePart)
        (part._param.grid for part in @part() when part!=excludePart)

      getAllParts: (excludePart=null) ->
        if excludePart? then excludePart = @part(excludePart)
        (part.part for part in @part() when part!=excludePart)

      findPart: (part, excludePart=null) -> find(@getAllParts(excludePart), part)

      findOpenConnections: (excludePart=null) ->
        if @numParts()==0
          [[null,0]]
        else
          if excludePart? then excludePart = @part(excludePart)

          occupied = @getOccupiedPositions()

          conn = []
          for part,i in @part() when part!=excludePart
            for side in @root.game.assemblage.param(part.part).connects
              if not part._param.attachment[side]?
                grid = add(part._param.grid, part.side2direction(side))
                if find(occupied,grid).length==0
                  conn.push [i, side]
          conn

      partCount: (part, excludePart=null) -> @findPart(part,excludePart).length

      pickPart: -> pickFrom @possibleParts

      pickSide: (part) -> pickFrom(@root.game.assemblage.param(part).connects)

      pickAppendage: (excludePart=null) ->
        conns = @findOpenConnections(excludePart)
        conn = pickFrom(conns)

        if conn?
          #make it's a square if we only have one possible connection
          part = if conn.length==1 and conn[0]? then 'square' else @pickPart()
          side = @pickSide(part)

          [part, conn[0], side, conn[1]]
        else
          null

      findReplacementsGivenParts: (part, parts) ->
        conn = @root.game.assemblage.param(part).connects

        replacementParts = []
        for replacement in parts
          if part!=replacement
            goodReplacement = true
            for c in conn
              if find(@root.game.assemblage.param(replacement).connects,c).length==0
                goodReplacement = false
                break
            if goodReplacement then replacementParts.push replacement

        replacementParts

      findReplacements: (part) ->
        #first try with existing parts unless we're a small assemblage
        if @numParts() > 2
          replacementParts = @findReplacementsGivenParts(part, @existingParts)
        else
          replacementParts = []

        #expand to all parts
        if replacementParts.length==0
          replacementParts = @findReplacementsGivenParts(part, @possibleParts)

        replacementParts

      pickReplacement: (part) -> pickFrom(@findReplacements(part))

      createDistractor: (options={}) ->
        options.color = options.color ? @attr "color"
        options.correct = options.correct ? false

        #construct the distractor set
        setParam = @getSet()
        idx = randomInt(0,setParam.length-1)
        setParam[idx][0] = @pickReplacement(setParam[idx][0])

        #create the distractor
        distractor = @root.show.Assemblage options
        distractor.addSet setParam
        distractor.rotate @_rotation/90

        distractor

    AssemblageInstruction: (a, step=null, options={}) -> new MWClassShowAssemblageInstruction(@root, a, step, options)
    MWClassShowAssemblageInstruction: class MWClassShowAssemblageInstruction extends MWClassShowInstructions
      constructor: (root, a, step=null, options) ->
        options.y = options.y ? 0
        instructions = if step? then a._instruction[step] else a._instruction.join("\n")
        super root, instructions, options

    RotateStimulus: (idx, options={}) -> new MWClassShowRotateStimulus(@root, idx, options)
    MWClassShowRotateStimulus: class MWClassShowRotateStimulus extends MWClassShowCompoundStimulus
      precision: 0

      _idx: null
      _path: null

      _initialOrientation: 0
      _distractorOrientation: 0

      #                    1/4 1/6 1/8 1/12 1/18 1/24 1/36 1/45 1/60 1/72 1/90 1/120 1/180 1/360
      referencePrecision: [90, 60, 45, 30,  20,  15,  10,  8,   6,   5,   4,   3,    2,    1]

      rotatedWidth: -> @_path.rotatedWidth()
      rotatedHeight: -> @_path.rotatedHeight()

      constructor: (root, idx, options) ->
        @root = root

        @_idx = idx

        @precision = options.precision ? 30
        options.orientation = options.orientation ? randomInt(0,359)
        options.auto_scale = options.auto_scale ? 0.5

        if not options.width?
          if not options.height?
            options.width = 'auto'
          else
            options.width = options.height
        else if not options.height?
          options.height = options.width

        @_path = root.show.Path root.game.rotate.path[@_idx], options

        options = remove options, ['orientation','width','height']
        options.background = options.background ? root.background

        super root, [@_path], options

        @_distractorOrientation = @generateDistractorOrientation()
        @_initialOrientation = @generateInitialOrientation()

      attr: (name, value) ->
        switch name
          when "orientation"
            ret = @_path.attr name, value
            @updateBackground(['orientation'])
          else
            ret = super name, value

        if value? then @ else ret

      updateBackground: (param) ->
        if @_background?
          for p in forceArray(param)
            switch p
              when 'orientation', 'width', 'height'
                @_background.attr "width", @rotatedWidth()
                @_background.attr "height", @rotatedHeight()
              else
                @_background.attr(p,@attr(p))

      operation: -> naturalAngle(@attr('orientation') - @_initialOrientation,null,true)

      generateDistractorOrientation: ->
        @attr('orientation') + @precision*(2*randomInt(0,1)-1)

      generateInitialOrientation: ->
        #find the non-wonky precision nearest to ours
        refPrec = nearest(@precision,@referencePrecision)

        nStep = Math.floor(90/refPrec)
        steps = randomInt(1,nStep) * (2*randomInt(0,1)-1)

        @attr('orientation') - steps*refPrec

      createVariant: (orientation, options={}) ->
        options.color = options.color ? @attr "color"
        options.correct = options.correct ? false
        options.orientation = orientation

        variant = @root.show.RotateStimulus @_idx, options

      createPrompt: (options={}) -> @createVariant @_initialOrientation, options

      createDistractor: (options={}) -> @createVariant @_distractorOrientation, options

    Progress: (info, options={}) -> new MWClassShowProgress(@root,info,options)
    MWClassShowProgress: class MWClassShowProgress extends MWClassShowCompoundStimulus
      _steps: 0
      _width: 0

      constructor: (root, info, options) ->
        @root = root

        options = @parseOptions options, {
          width: 300
          steps: 10
          color: "red"
          r: 5
        }

        @_steps = options.steps
        @_width = options.width

        elements = [root.show.Instructions info]

        for i in [0..@_steps-1]
          bit = root.show.Circle {r: options.r}
          bit.show(false)
          elements.push(bit)

        delete options.r

        super root, elements, options

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

  Input: -> new MWClassInput(@)
  MWClassInput: class MWClassInput extends MWClass
    _event_handlers: null

    constructor: (root) ->
      super root

      @_event_handlers = {
        key_down: []
        mouse_down: []
      }

      $(document).keydown( (evt) => @_handleKey(evt,'down') )
      $(document).mousedown( (evt) => @_handleMouse(evt,'down') )

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

  Time: -> new MWClassTime(@)
  MWClassTime: class MWClassTime extends MWClass
    Now: -> new Date().getTime()

  Color: -> new MWClassColor(@)
  MWClassColor: class MWClassColor extends MWClass
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

    constructor: (root) ->
      super root

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

  Exec: -> new MWClassExec(@)
  MWClassExec: class MWClassExec extends MWClass

    Sequence: (name, fStep, next, options={}) -> new MWClassExecSequence(@root,name,fStep,next,options)
    MWClassExecSequence: class MWClassExecSequence extends MWClass
      _name: ''
      _fStep: null
      _fCleanup: null
      _next: null

      _idx: 0

      _fCheck: null
      _timer: null
      _countdown: false

      _tStart: 0
      _tStep: 0

      _fPre: null
      pre: null

      finished: false
      result: null

      constructor: (root, name, fStep, next, options) ->
        ###
          name: a unique name for the sequence
          fStep: array specifying the function to execute at each step
          next: array of:
            time: time to move on to the next step
            key: a key that must be down to move on
            f: a function that takes the sequence and step start times and
              returns true to move on
            ['key'/'mouse', options]: specify input event that must occur
            ['event', f] specify a function that will register an event that will
              call the function to move to the next step
            ['lazy', f] specify a function that will be called after the step is
              executed, take this object and the current step index as inputs,
              and returns one of the above
          options:
            execute:  true to execute the sequence immediately
            countdown: true to count down the session timer while executing the
              sequence
            mode: time mode ('step', 'sequence', or 'absolute')
            pre: a function that takes this object as input and returns an
              object of info to be stored in this object's pre property. the
              function is executed immediately before the first step.
            callback: a function to call when the sequence finishes. takes this
                      object as an input argument
            cleanup:  array specifying function to call after each step
        ###
        super root

        @_fPre = options.pre ? null
        options.execute = options.execute ? true
        @_countdown = options.countdown ? false
        @mode = options.mode ? "step"
        @callback = options.callback ? null
        @_fCleanup = options.cleanup ? null

        @_name = name
        @_fStep = fStep
        @_next = next

        @pre = {}

        @setSequence()

        if options.execute then @Execute()

      stepName: (idx) -> "#{@_name}_#{idx}"

      delayTime: (t) ->
        tExec = switch @mode
          when "step" then @_tStep + t
          when "relative" then @_tStart + t
          when "absolute" then t
          else throw "Invalid time mode"

        tExec - @root.time.Now()

      checkNext: ->
        if @_fCheck(@_tStart, @_tStep)
          clearInterval(@_timer)
          @getFDoStep(@_idx)()

      setSequence: ->
        nStep = @_fStep.length + (if @callback? then 1 else 0)
        for idx in [0..nStep-1]
          @root.queue.add @stepName(idx), (=> @processStep()), {do: false}

        @result = ({t:{}, output:{}} for [0..@_fStep.length-1])

      processStep: ->
        @_tStep = @root.time.Now()

        if @_idx>0
          @cleanupStep(@_idx-1)
        else if @_fPre?
          @pre = @_fPre(@)

        if @_idx==@_fStep.length
          @finishSequence()
        else
          @executeStep(@_idx)
          @parseNext(@_idx)
          @_idx++

      executeStep: (idx) ->
        @result[idx].t.start = @root.time.Now()
        @result[idx].output.step = if @_fStep[idx]? then @_fStep[idx]() else null

      cleanupStep: (idx) ->
        @result[idx].t.end = @root.time.Now()

        doFCleanup = @_fCleanup? and @_fCleanup[idx]?
        @result[idx].output.cleanup = if doFCleanup then @_fCleanup[idx]() else null

      getFDoStep: (idx) -> ((i) => => @root.queue.do(@stepName(i)))(idx)

      parseNext: (idx, next=null) ->
        fDoStepNext = @getFDoStep(idx+1)

        next = next ? @_next[idx]

        if !isNaN(parseFloat(next)) #number
          window.setTimeout fDoStepNext, @delayTime(next)
        else if (typeof next)=='string' #key name
          @parseNext(idx,['key',{button: next}])
        else if (typeof next)=='function' #function to check periodically
          @_fCheck = next
          @_timer = setInterval (=> @checkNext()), 1
        else if Array.isArray(next) and next.length>=1
          switch next[0]
            when 'key', 'mouse' #input event
              fRegister = (f) =>
                options = if next.length>=2 then next[1] else {}

                options.event = options.event ? 'down'
                options.button = options.button ? 'any'
                options.expires = 1

                if options.f?
                  fUser = options.f
                  options.f = -> fUser(); f();
                else
                  options.f = f

                @root.input.addHandler(next[0],options)

              @parseNext(idx,['event', fRegister])
            when 'event' #a function that registers an event
              next[1](fDoStepNext)
            when 'lazy'
              @parseNext idx, next[1](@, idx)
            else throw "Invalid next value"
        else
          throw "Invalid next value"

      finishSequence: () ->
        if @callback? then @callback(@)
        @finished = true

      Execute: ->
        @_tStart = @root.time.Now()

        @finished = false
        @_idx = 0

        @getFDoStep(0)()

    Show: (name, stim, next, options={}) -> new MWClassExecShow(@root,name,stim,next,options)
    MWClassExecShow: class MWClassExecShow extends MWClassExecSequence
      contain: true

      _stim: null
      _stimStep: null
      _stimSequence: null

      _fixation: false
      _cleanupStim: null

      constructor: (root, name, stim, next, options) ->
        ###
          name: a name for the sequence
          stim: an array of arrays of:
            [<name of show class>, <arg1 to show class>, ...]
            a Stimulus (hidden)
            a function that takes this object and the current step index and
              returns an array of the above
          next: see MWExecute.Sequence, or
            ['choice', options] (create MWShow.Choice from current stimuli)
            ['test', options] (create MWShow.Test from current stimuli)
          options:
            cleanupStim: the type of stimulus cleanup to perform. one of:
              'step': cleanup stimuli at the start of the next step
              'sequence': cleanup stimuli at the end of the sequence
              'none': don't cleanup stimuli
            fixation: true to show the fixation dot at each step
            contain: true to contain stimuli within the screen
            (see Sequence super class)
        ###
        @_cleanupStim = options.cleanupStim ? 'step'
        @_fixation = options.fixation ? false
        @contain = options.contain ? true

        @_stim = stim
        @_stimStep = ([] for [1..stim.length])
        @_stimSequence = []

        super root, name, (null for [1..stim.length]), next, options

      storeStimulus: (stim, idx) ->
        @_stimStep[idx].push stim
        @_stimSequence.push stim
        stim

      executeStep: (idx) ->
        super idx

        stimuli = forceArray(@_stim[idx])

        if @_fixation
          fixObj = @root.fixation[0]
          fixArg = @root.fixation[1]
          stimuli.push [fixObj, fixArg...]

        @parseStimulus(stim, idx) for stim in stimuli

        @result[idx].t.show = @root.time.Now()

      parseStimulus: (stim, idx) ->
        if Array.isArray(stim) and stim.length>0 and (typeof stim[0] == 'string')
          @parseStimulus (@root.show[stim[0]](stim[1..]...)), idx
        else if stim?
          wTotal = @root.width()
          hTotal = @root.height()

          for s in forceArray(stim)
            if s instanceof @root.show.MWClassShowStimulus
              @storeStimulus s, idx

              if @contain then s.contain()
              s.show(true)
            else if s instanceof Function
              @parseStimulus s(@, idx), idx
            else if Array.isArray(s)
              @parseStimulus s, idx
            else
              throw "Invalid stimulus"
        else
          null

      cleanupStep: (idx) ->
        super idx

        #cleanup the stimuli
        if @_cleanupStim=='step'
          stim.remove() for stim in @_stimStep[idx]
        else
          stim.show(false) for stim in @_stimStep[idx]

        @result[idx].t.remove = @root.time.Now()

      parseNext: (idx, next=null) ->
        next = next ? @_next[idx]

        if Array.isArray(next) and (next[0]=='choice' or next[0]=='test')
          fDoStepNext = @getFDoStep(idx+1)

          options = next[1] ? {}
          fCallback = options.callback ? null
          options.callback = (obj,i) =>
            @result[idx].t.choice = obj._tChoice
            @result[idx].t.rt = @result[idx].t.choice - @result[idx].t.show
            @result[idx].choice = i
            if obj instanceof @root.show.MWClassShowTest then @result[idx].correct = obj.correct
            if fCallback? then fCallback(i)
            fDoStepNext()

          stim = @root.show[capitalize(next[0])](@_stimStep[idx], options)
          @storeStimulus stim, idx
        else
          super idx, next

      finishSequence: () ->
        super()

        if @_cleanupStim=='sequence' then stim.remove() for stim in @_stimSequence
        if @_cleanupStim!='none'
          @_stimSequence = []
          @_stimStep = []

  Queue: -> new MWClassQueue(@)
  MWClassQueue: class MWClassQueue extends MWClass
    _queue: null

    constructor: (root) ->
      super root

      @_queue = []

    length: -> @_queue.length

    add: (name, f, options={}) ->
      options.do = options.do ? true
      @_queue.push {name:name, f:f, ready:false}

      if options.do then @do name

    do: (name) ->
      if @_queue.length > 0
        if @_queue[0].name==name
          @_queue[0].ready = true
          @_queue.shift().f() while @_queue.length>0 and @_queue[0].ready
        else
          for i in [0..@_queue.length-1]
            if @_queue[i].name==name
              @_queue[i].ready = true
              break

  Game: -> new MWClassGame(@)
  MWClassGame: class MWClassGame extends MWClass
    constructor: (root) ->
      super root

      @construct = @Construct()
      @assemblage = @Assemblage()
      @rotate = @Rotate()

    MWClassGameBase: class MWClassGameBase extends MWClass
      name: ''

      current_trial: null
      trial_result: null

      nDistractor: 3

      tPrompt: 2000
      tOperate: 6000
      tTest: 3000
      tFeedback: 2000

      _doOperate: true

      constructor: (root, name) ->
        super root

        @name = name

        @trial_result = []

      trialName: (trial=null) ->
        trial = trial ? @current_trial
        "#{@name}trial#{trial}"

      create: (param) -> throw 'not implemented'
      createDistractor: (target) -> (target.createDistractor({show:false}) for [1..@nDistractor])

      prompt: (target) -> @root.show.Text 'Do something'
      promptStim: -> (s, idx) => @prompt s.pre.target
      promptNext: -> @tPrompt

      operate: (target) -> null
      operateStim: -> (s, idx) => @operate s.pre.target
      operateNext: -> @tOperate

      test: (target) ->
        target.correct = true
        test = forceArray(@createDistractor(target))
        distractor.correct = false for distractor in test
        test.push target
        randomize test
        test
      testStim: -> (s, idx) => @test s.pre.target
      testNext: -> ['test', {timeout: @tTest}]

      feedback: (target, correct, choice) ->
        xFeedback = target.attr "x"
        yFeedback = target.attr("y") + target.attr("height")/2 + 36
        strFeedback = if correct then "Yes!" else if choice? then "No!" else 'Too Slow!'
        text = @root.show.Text strFeedback,
          x: xFeedback
          y: yFeedback
          "font-size": 36
        [target, text]
      feedbackStim: -> (s, idx) => @feedback s.pre.target, s.result[idx-1].correct, s.result[idx-1].choice
      feedbackNext: -> @tFeedback

      trial: (param={}, options={}) ->
        ###
          options:
            result: a function that takes the trial show object (at the end of
              the trial) and returns an object recording the results of the
              trial
        ###
        #default returns the result of the penultimate show stimulus (i.e. the
        #test screen)
        options.result = options.result ? (shw) -> shw.result[shw.result.length-2]
        fCallback = (shw) => @trial_result.push options.result(shw)
        options.callback = options.callback ? fCallback
        options.cleanupStim = options.cleanupStim ? 'sequence'
        options.countdown = options.countdown ? true

        #increment the trial
        @current_trial = if @current_trial? then @current_trial+1 else 0

        #pre step to construct the trial target
        options.pre = options.pre ? (shw) => {
          target: @create param
        }

        stim = []
        next = []

        #add the trial start prompt
        stim.push [['Instructions', "Click to begin #{@name} trial #{@current_trial+1}"]]
        next.push ['mouse', {
          f: => @root.el.status.el.timer.go()
        }]

        #prompt
        stim.push @promptStim()
        next.push @promptNext()

        #operate
        if @_doOperate
          stim.push @operateStim()
          next.push @operateNext()

        #test
        stim.push @testStim()
        next.push @testNext()

        #feedback
        stim.push @feedbackStim()
        next.push @feedbackNext()

        #add the bit to stop the timer
        fCallback = options.callback
        fStopTimer = => @root.el.status.el.timer.stop()
        options.callback = (obj) -> fCallback(obj); fStopTimer();

        #do it now!
        shw = @root.exec.Show "#{@trialName()}", stim, next, options

      color: (x) -> @root.color.pick()

    Construct: -> new MWClassGameConstruct(@root)
    MWClassGameConstruct: class MWClassGameConstruct extends MWClassGameBase
      nPart: 100

      constructor: (root) -> super root, 'construct'

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

      pickOne: (d, exclude=null) ->
        loop
          part = randomInt(@partRange(d)...)
          break if not exclude? or part!=exclude
        part
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
        @root.color.blend('difficulty', (d-dMin)/dMax)

      create: (param={}) ->
        param.d = param.d ? 0.2

        target = @root.show.ConstructFigure param.d,
          color: @color()
          show: false
      createDistractor: (target) -> target.createDistractors(@nDistractor)

      prompt: (target) -> @root.show.ConstructPrompt(target,{show:false})

    Assemblage: -> new MWClassGameAssemblage(@root)
    MWClassGameAssemblage: class MWClassGameAssemblage extends MWClassGameBase
      tPerPromptWord: 300
      tImagine: 500

      _map: null
      _param: null

      _doOperate: false

      constructor: (root) ->
        super root, 'assemblage'

        @_map = {}
        @_param = []

        @addPart('square',
          [ ['L',0,1], ['L',1,1], ['L',1,0], ['Z'] ]
          {symmetry:'90', inside:true}
        )
        @addPart('circle',
          [ ['M',0,0.5], ['C',0,0.5,0,1,0.5,1], ['C',0.5,1,1,1,1,0.5], ['C',1,0.5,1,0,0.5,0], ['C',0.5,0,0,0,0,0.5] ]
          {symmetry:'90', inside:true}
        )
        @addPart('triangle',
          [ ['M',0,1], ['L',0.5,0], ['L',1,1], ['Z'] ]
          {symmetry:'vertical', connects:[1,3]}
        )
        @addPart('diamond'
          [ ['M',0.5,0], ['L',0,0.5], ['L',0.5,1], ['L',1,0.5], ['Z'] ]
          {symmetry:'90'}
        )
        @addPart('line',
          [ ['M',0.5,0], ['L',0.5,1], ['M',1,1] ] #last move just to fill the space
          {symmetry:'180', connects:[1,3]}
        )
        @addPart('cross'
          [ ['M',0.5,0], ['L',0.5,1], ['M',0,0.5], ['L',1,0.5] ]
          {symmetry:'90'}
        )

      param: (part) -> @_param[@_map[part]]
      parts: (iMax=null) -> p.name for p,i in @_param when ((not iMax?) or i<=iMax)

      addPart: (name, definition, options={}) ->
        options.name = name
        options.definition = definition
        options.connects = options.connects ? [0,1,2,3]
        options.symmetry = options.symmetry ? 'none'
        options.inside = options.inside ? false

        @_map[name] = @_param.push(options) - 1

      create: (param={}) ->
        param.steps = param.steps ? 1
        param.imax = param.imax ? null

        target = @root.show.Assemblage #make a new assemblage
            color: @color()
            imax: param.imax
            show: false

        #add the first part
        target.addRandom()

        #add the parts, interleaving with image rotations
        iStep = 1
        while iStep < param.steps
          target.addRandom()
          iStep++
          if iStep < param.steps
            target.rotate randomInt(1,3)
            iStep++
        target

      prompt: (target) ->
        @root.show.AssemblageInstruction(target,null,{show:false})
      promptTime: (target, step=null) ->
        instruct = target._instruction

        nWord = wordCount(if step? then instruct[step] else instruct.join(' '))
        tWord = nWord*@tPerPromptWord

        nImagine = if step? then 1 else target.numSteps()
        tImagine = nImagine*@tImagine

        tWord + tImagine
      promptNext: ->
        that = @
        fPromptTimeout = (s) -> that.promptTime s.pre.target
        fPromptNext = (s,idx) -> ['choice', {timeout: fPromptTimeout(s)}]
        ['lazy', fPromptNext]

    Rotate: -> new MWClassGameRotate(@root)
    MWClassGameRotate: class MWClassGameRotate extends MWClassGameBase
      nDistractor: 1

      path: [
        [['M',.692,.607],['C',.694,.6,.7,.591,.704,.586,.707,.581,.714,.571,.718,.564,.723,.554,.727,.549,.735,.542,.742,.535,.745,.532,.746,.527,.748,.516,.763,.48,.77,.466,.786,.435,.804,.407,.811,.4,.819,.393,.82,.393,.83,.403],['L',.836,.41,.83,.419],['C',.825,.428,.823,.439,.825,.448,.827,.455,.831,.454,.837,.444,.847,.426,.859,.411,.877,.39,.887,.379,.896,.368,.898,.366,.9,.363,.9,.337,.898,.314,.897,.308,.898,.298,.9,.291,.906,.263,.905,.235,.894,.201,.887,.18,.878,.164,.862,.146],['L',.862,.146],['C',.849,.132,.845,.129,.83,.128,.822,.127,.821,.127,.817,.121,.812,.114,.812,.114,.809,.117,.806,.12,.803,.119,.798,.116,.791,.113,.789,.113,.787,.117,.786,.122,.782,.121,.778,.114,.776,.111,.768,.1,.759,.089,.751,.077,.741,.065,.738,.06,.731,.051,.729,.051,.717,.057,.71,.06,.709,.061,.709,.064,.71,.067,.709,.067,.704,.067,.7,.068,.697,.069,.693,.073,.69,.075,.685,.079,.682,.081,.665,.091,.659,.101,.657,.119,.655,.135,.649,.163,.646,.165,.644,.168,.646,.192,.649,.196,.654,.201,.657,.216,.655,.231,.654,.244,.653,.25,.646,.264,.639,.28,.638,.281,.626,.292,.614,.304,.61,.306,.567,.328,.542,.341,.517,.355,.512,.358,.502,.364,.501,.365,.486,.365,.448,.367,.426,.373,.402,.39,.392,.397,.389,.4,.385,.406,.383,.41,.377,.417,.372,.422,.363,.43,.362,.43,.35,.432,.335,.434,.32,.433,.315,.431,.311,.429,.309,.429,.307,.432,.305,.434,.301,.436,.299,.436],['S',.285,.444,.272,.452],['L',.248,.466,.226,.468],['C',.208,.47,.203,.471,.201,.474,.2,.476,.192,.482,.183,.489,.165,.503,.162,.508,.153,.532,.15,.542,.146,.55,.143,.552,.141,.554,.139,.558,.138,.561,.136,.565,.134,.568,.127,.573,.119,.579,.118,.581,.114,.591,.111,.597,.108,.604,.107,.606,.105,.61,.088,.623,.071,.635],['L',.063,.641,.069,.648],['C',.073,.652,.075,.656,.075,.658,.074,.664,.079,.672,.091,.68,.103,.689,.111,.691,.121,.69,.126,.689,.128,.69,.132,.694,.136,.698,.136,.701,.136,.706],['L',.136,.713,.112,.732,.089,.752,.09,.759],['C',.09,.762,.09,.769,.091,.774,.091,.782,.091,.782,.102,.795,.109,.803,.114,.809,.114,.81,.114,.812,.115,.813,.122,.817,.126,.82,.128,.82,.13,.818,.132,.816,.137,.815,.141,.815,.148,.815,.15,.814,.155,.808,.16,.802,.166,.789,.169,.778,.17,.773,.171,.771,.176,.768,.18,.765,.181,.764,.18,.761,.178,.754,.187,.735,.196,.729,.2,.727,.204,.726,.214,.727,.227,.728,.228,.728,.234,.734,.239,.74,.241,.741,.246,.741,.254,.74,.26,.748,.259,.757,.259,.761,.259,.765,.26,.767,.263,.773,.266,.793,.265,.803,.264,.811,.264,.812,.273,.824,.285,.84,.286,.848,.281,.858,.278,.862,.275,.867,.273,.869,.27,.872,.27,.873,.273,.882,.274,.887,.277,.892,.279,.893,.281,.895,.283,.899,.284,.903,.287,.911,.293,.918,.305,.926,.315,.932,.315,.932,.323,.928,.33,.924,.331,.924,.337,.914,.341,.908,.346,.9,.35,.896,.354,.891,.356,.887,.355,.886,.354,.885,.355,.883,.37,.864,.378,.854,.385,.847,.392,.842,.398,.837,.41,.826,.42,.817,.44,.798,.477,.773,.497,.763,.51,.757,.547,.734,.577,.713,.592,.702,.594,.701,.606,.699,.64,.691,.665,.664,.692,.607],['Z'],['M',.825,.19],['C',.824,.19,.822,.188,.821,.187,.819,.185,.817,.183,.816,.18,.816,.178,.816,.176,.817,.175,.818,.173,.821,.172,.824,.173,.826,.174,.828,.176,.828,.178,.829,.18,.828,.182,.828,.184,.827,.186,.827,.189,.825,.19],['Z'],['M',.49,.683,.494,.684,.494,.686,.485,.697,.477,.707,.471,.711,.456,.725,.47,.709,.472,.708,.472,.702,.475,.698,.478,.693,.481,.686,.49,.683],['Z'],['M',.394,.776,.38,.782,.369,.79,.361,.798,.353,.805,.348,.806,.341,.809,.334,.813,.328,.806,.325,.791,.322,.777,.324,.765,.325,.76,.33,.753,.336,.752,.342,.757,.35,.762,.36,.761,.367,.762,.378,.767,.387,.767,.394,.769,.408,.767,.408,.767,.409,.77,.407,.773,.394,.776],['Z']]
        [['M',.958,.288],['S',.928,.275,.912,.254],['C',.895,.233,.855,.219,.855,.219,.859,.213,.869,.209,.894,.217,.86,.195,.845,.188,.823,.18,.809,.175,.808,.187,.798,.175,.789,.165,.784,.157,.777,.15,.762,.134,.756,.133,.745,.143,.746,.144,.747,.144,.749,.145,.747,.147,.746,.151,.746,.154,.748,.151,.75,.149,.753,.147,.756,.148,.758,.15,.759,.151,.757,.153,.755,.155,.755,.158,.757,.156,.76,.155,.763,.154,.766,.156,.768,.158,.769,.161,.767,.162,.765,.163,.763,.165,.766,.164,.769,.164,.772,.164,.774,.167,.775,.17,.777,.172,.774,.173,.772,.175,.771,.177,.773,.176,.776,.176,.778,.176,.78,.178,.781,.181,.782,.183,.778,.184,.777,.187,.776,.19,.778,.188,.78,.187,.785,.189,.786,.192,.787,.194,.789,.196,.787,.197,.785,.198,.783,.201,.786,.2,.788,.199,.792,.2,.798,.206,.805,.209,.815,.211,.801,.218,.791,.219,.781,.213,.782,.211,.783,.209,.785,.208,.783,.208,.78,.209,.778,.211,.777,.21,.777,.21,.776,.209,.774,.207,.772,.206,.771,.204,.772,.202,.774,.201,.777,.2,.774,.2,.771,.2,.768,.201,.766,.198,.764,.196,.762,.193,.763,.191,.765,.19,.768,.189,.765,.189,.762,.189,.759,.19,.757,.187,.756,.185,.754,.183,.755,.18,.757,.178,.76,.177,.756,.177,.753,.178,.751,.179,.749,.177,.748,.176,.746,.174,.747,.171,.749,.169,.752,.168,.747,.168,.744,.169,.742,.171,.741,.17,.739,.17,.738,.169,.738,.167,.738,.164,.741,.16,.736,.161,.734,.164,.732,.167,.731,.167,.731,.167,.73,.167,.725,.18,.712,.176,.711,.191,.711,.191,.721,.179,.74,.189,.759,.199,.78,.222,.779,.241,.778,.251,.784,.26,.789,.267,.791,.246,.81,.25,.813,.267,.816,.284,.791,.297,.765,.286,.738,.276,.629,.221,.574,.261,.405,.356,.608,.502,.502,.579,.452,.615,.374,.583,.333,.566,.301,.553,.286,.535,.28,.508,.268,.456,.325,.453,.344,.469,.361,.484,.39,.515,.378,.571,.394,.58,.41,.583,.425,.584,.431,.534,.427,.52,.413,.475,.375,.353,.227,.388,.218,.464,.211,.513,.218,.569,.301,.628,.352,.665,.426,.686,.498,.675,.497,.685,.499,.697,.515,.715,.513,.693,.513,.682,.52,.671,.533,.668,.545,.664,.555,.659,.557,.668,.563,.679,.582,.691,.574,.672,.572,.661,.574,.65,.586,.643,.597,.635,.606,.627,.611,.635,.62,.644,.642,.649,.628,.633,.622,.623,.621,.611,.629,.602,.636,.592,.64,.582,.649,.587,.661,.59,.685,.582,.665,.576,.655,.571,.647,.562,.65,.55,.651,.537,.65,.522,.659,.522,.67,.519,.686,.504,.667,.507,.656,.507,.647,.503,.644,.491,.64,.477,.633,.464,.641,.461,.65,.456,.66,.443,.644,.447,.634,.449,.626,.447,.62,.435,.615,.423,.612,.412,.62,.412,.631,.409,.646,.397,.626,.398,.616,.397,.606,.392,.605,.387,.604,.382,.603,.376,.601,.361,.615,.341,.621,.332,.625,.339,.633,.348,.651,.355,.64,.338,.636,.328,.636,.316,.65,.308,.669,.305,.686,.309,.681,.317,.677,.329,.683,.352,.691,.332,.696,.322,.707,.315,.718,.319,.728,.321,.739,.323,.736,.332,.735,.344,.743,.362,.748,.344,.751,.334,.759,.326,.783,.329,.805,.326,.822,.315,.825,.332,.82,.35,.804,.375,.831,.347,.845,.323,.848,.293,.865,.309,.878,.338,.876,.372,.891,.343,.886,.312,.864,.277,.88,.284,.907,.306,.917,.351,.916,.308,.896,.276,.874,.26,.874,.26,.89,.25,.909,.269,.925,.284,.958,.288,.958,.288],['Z'],['M',.834,.195],['C',.826,.198,.817,.197,.815,.193,.813,.191,.815,.186,.819,.189,.822,.191,.826,.195,.834,.195],['Z'],['M',.407,.679],['C',.393,.677,.386,.677,.356,.666,.356,.666,.312,.716,.24,.707,.173,.699,.123,.745,.119,.819,.117,.816,.114,.815,.109,.819,.102,.826,.101,.876,.146,.928,.125,.878,.13,.852,.14,.842,.146,.836,.144,.828,.139,.821,.137,.818,.134,.817,.131,.819,.15,.747,.189,.74,.25,.744,.322,.749,.376,.725,.407,.679],['Z']]
        #TODO add rest of rotate shapes
      ]

      constructor: (root) -> super root, 'rotate'

      create: (param={}) ->
        param.precision = param.precision ? null

        target = @root.show.RotateStimulus randomInt(0,@path.length-1),
            color: @color()
            precision: param.precision
            show: false

      prompt: (target) ->
        initial = target.createPrompt()

        y = initial.attr "y"
        h = initial.rotatedHeight()
        yInstruct = y + h/2 + 36

        instruction = @root.show.Instructions target.operation(),
          y: yInstruct

        [initial, instruction]

  Data: -> new MWClassData(@)
  MWClassData: class MWClassData extends MWClass
    _data: null

    _idle: null

    constructor: (root) ->
      super root
      @_data = {}

      @load()

    load: ->
      @block()
      @read 'keys',
        callback: (result) => @finish_load(result)

    finish_load: (result) ->
      keys = result.value

      for key in keys
        that._data[key] = @variable key, null,
          init_callback: (x) => @checkUnblock() #TODO init_callback

    save: ->
      @block()

      for key,variable of @_data
        @write key, variable._info
          callback: (result) => that.checkUnblock()

    block: -> null #@root.queue.add 'data_block', (-> null), {do:false} ***

    unblock: -> null #@root.queue.do 'data_block' ***

    checkUnblock: ->
      return for key,val of @_idle when not val
      return for key,val of @_data when not @idle[key] #TODO variable.idle
      @unblock()

    variable: (key, value, options={}) ->
      overwrite = options.overwrite ? false

      bNew = not (key of @_data)
      if bNew or overwrite
        @_data[key] = new MWClassDataVariable(@, key, value, options)

        if bNew then @write 'keys', Object.keys(@_data)

      @_data[key]

    read: (key, options={}) ->
      options.callback = options.callback ? null
      #TODO implement data.read

    write: (key, value, options={}) ->
      options.callback = options.callback ? null
      #TODO implement data.write

    MWClassDataVariable: class MWClassDataVariable
      idle: true

      _data: null
      _info: null

      _initialized: false
      _initCallback: null

      constructor: (data, key, value, options) ->
        ###
          data: the parent MWClassData object
          key: the variable name
          value: the variable value
          options:
            overwrite: true to overwrite an existing variable with the same key
            timeout: the number of milliseconds before the variable value resets
              to its initial value
            timeout_type: one of the following:
              'session': value will only reset in between sessions
              'instant': value will reset immediately after timeout
        ###
        @_data = data

        options.overwrite = options.overwrite ? false
        options.timeout = options.timeout ? null
        options.timeout_type = options.timeout_type ? 'session'

        @_initCallback = options.init_callback ? null

        @_info = remove options, ['overwrite']
        @_info.key = key
        @_info.value = value

        if options.overwrite then @initialize() else @update()

      initialize: ->
        @_info.initial = @_info.value
        @reset()

      update: ->
        @_data.read @_info.key,
          callback: (result) => @readWriteCallback(result)

      reset: ->
        @_info.reset_time = @_data.root.time.Now()
        @_info.value = @_info.initial
        @_data.write(@_info.key, @_info)

      readWriteCallback: (result) ->
        switch result.status
          when 'nonexistent'
            @initialize()
          when 'read', 'write'
            @_info = result.value
            @checkTimeout()
          else
            null

        if not @_initialized
          if @initCallback then @initCallback(@)
          @_initialized = true

      checkTimeout: ->
        if @_info.timeout? and (@_info.timeout_type=='instant' or not @_initialized)
          tNextReset = @_info.reset_time + @_info.timeout
          if @_data.root.time.Now() >= tNextReset then @reset()

      get: -> @_info.value

      set: (value) ->
        @_info.value = value

        @_data.write @_info.key, @_info,
          callback: (result) => @readWriteCallback(result)

        @


  Session: -> new MWClassSession(@)
  MWClassSession: class MWClassSession extends MWClass
    constructor: (root) ->
      super root

    run: ->



