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
naturalAngle = (a, orientation=false) ->
  a = fixAngle(a)
  switch a
      when 0
        ""
      when 180
        "#{Math.abs(a)}°" #upside down"
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
    when 'hour', 'hr', 'h'
      3600000
    when 'minute', 'min', 'm'
      60000
    when 'second', 'sec', 's'
      1000
    when 'millisecond', 'msec', 'ms'
      1
    else
      throw 'Invalid unit'
convertTime = (t,unitFrom,unitTo) -> t*msPerT(unitFrom)/msPerT(unitTo)

window.MWLearn = class MWLearn
  container: null
  el: null
  im: null

  status: null
  background: null

  _background: null

  constructor: (options={}) ->
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
    options.practice_minutes = options.practice_minutes ? 30
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

    @_background = @show.Rectangle
      color: @background
      width: @width()
      height: @height()

    if options.loadimages
      imConstruct = @game.construct.srcPart("all")
      images = options.images.concat imConstruct
      if images.length then @LoadImages images

    @el = {}
    switch options.type
      when 'main'
        @el.status = new MWLearn
          type: 'status'
          practice_minutes: options.practice_minutes
      when 'status'
        @el.timer = @show.Timer convertTime(options.practice_minutes,'minute','ms'),
          prefix: 'remaining'
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

    that = @
    for i in [0..images.length-1]
      qName = "image_#{images[i]}"
      @queue.add qName, f, {do:false}
      @im[images[i]] = new Image()
      @im[images[i]].src = images[i]
      @im[images[i]].onload = ((name) -> -> that.queue.do name)(qName)


  MWClass: class MWClass
    root: null

    constructor: (root) ->
      @root = root

  Show: -> new MWClassShow(@)
  MWClassShow: class MWClassShow extends MWClass

    Stimulus: (options={}, addDefaults=true) -> new @MWClassShowStimulus(@root, options, addDefaults)
    MWClassShowStimulus: class MWClassShowStimulus extends MWClass
      _rotation: 0
      _scale: 1
      _translation: [0, 0]

      element: null

      handlers: null

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

      attr: (name, value) ->
        switch name
          when "color"
            ret = @element.attr "fill", value
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
      exists: () -> @element.length > 0

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
          fDown = ((that,i) -> ((e,x,y) -> that.choiceEvent(i)))(@,idx)
          @element[idx].mousedown fDown

        @_tStart = @root.time.Now()

        if @timeout?
          that = @
          window.setTimeout (-> that.choiceEvent(null)), @timeout

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
            pad: the padding in between each choice
        ###
        options.instruct = options.instruct ? "Choose one."
        options.choice_include = forceArray(options.choice_include ? [0..elements.length])
        options.correct = forceArray(options.correct ? null)
        options.pad = options.pad ? 50

        #record which choices are correct
        if options.correct? then (elements[i]=options.correct[i] for i in [0..elements.length-1])

        #create the instructions
        instruct = root.show.Instructions options.instruct
        hInstruct = instruct.attr "height"

        #line up the choices and make them fill the screen

        #get the maximum final element dimensions
        nEl = elements.length

        wFinalMax = (root.width() - (nEl+1)*options.pad)/nEl
        hFinalMax = 2*(root.height()/2 - hInstruct - 2*options.pad)

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

        wTotal = sum(elW) + options.pad*(nEl-1) - elW[0]/2 - elW[-1..]/2
        xCur = -wTotal/2
        for el,idx in elements
          el.attr "x", xCur
          el.attr "y", 0
          xCur += elW[idx] + options.pad

        #position the instructions
        instruct.attr "y", hMax/2+2*options.pad

        #add the instructions to the elements
        elements = copyarray(elements)
        elements.push instruct

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
              super "r", value/2
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
              super name, value+@attr("height")/2
            else
              ret = super(name)-@attr("height")/2
          when "width", "height"
            if value?
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

        @_param = {
          path: path
          width: options.width
          height: options.height
          l: 0
          t: 0
          orientation: 0
        }

        @element = root.paper.path(@constructPath(null,false))

        super root, options

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
              p = {}
              p[name] = value
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
      _intervalID: null

      tTotal: 0
      tTimer: 0
      tGo: null

      showms: false
      prefix: null

      constructor: (root, tTotal, options) ->
        @tTotal = tTotal
        @showms = options.showms ? false
        @prefix = options.prefix ? null
        @tUpdate = options.update_interval ? (if @showms then 10 else 250)

        @reset false

        super root, @string(), options

      remaining: -> Math.max(0,if @tGo? then (@tTimer-(@root.time.Now()-@tGo)) else @tTimer)

      reset: (render=true) ->
        @tTimer = @tTotal
        if render then @render()

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
        "#{prefix}#{strHours}#{strMinutes}#{strSeconds}#{strMS}"

      render: -> @attr "text", @string()

      update: ->
        if @remaining() <= 0 then @stop
        @render()

      go: ->
        @tGo = @root.time.Now()

        that = @
        fInterval = -> that.update()
        @_intervalID = window.setInterval fInterval, @tUpdate

      stop: ->
        if @_intervalID? then clearInterval(@_intervalID)
        @tTimer = @remaining()
        @tGo = null

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
            if value? and @_background? then @_background.attr name, value-1
            ret = @_im.attr name, value
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

      constructor: (root, idx, options) ->
        @root = root

        @_idx = idx

        @precision = options.precision ? 30
        options.orientation = options.orientation ? randomInt(0,359)
        options.width = options.width ? 400
        options.height = options.height ? 400

        @path = root.show.Path root.game.rotate.path[@_idx], options

        options = remove options, ['orientation']
        options.background = options.background ? 'black' #root.background***

        super root, [@path], options

        @_distractorOrientation = @generateDistractorOrientation()
        @_initialOrientation = @generateInitialOrientation()

      attr: (name, value) ->
        switch name
          when "orientation"
            ret = @path.attr name, value
            @updateBackground(['orientation'])
          else
            ret = super name, value

        if value? then @ else ret

      updateBackground: (param) ->
        if @_background?
          for p in forceArray(param)
            switch p
              when 'orientation', 'width', 'height'
                @_background.attr "width", @path.rotatedWidth()
                @_background.attr "height", @path.rotatedHeight()
              else
                @_background.attr(p,@attr(p))

      operation: -> naturalAngle(@attr('orientation') - @_initialOrientation)

      generateDistractorOrientation: ->
        @attr('orientation') + @precision*(2*randomInt(0,1)-1)

      generateInitialOrientation: ->
        #find the non-wonky precision nearest to ours
        refPrec = nearest(@precision,@referencePrecision)

        nStep = Math.floor(90/refPrec)
        steps = randomInt(1,nStep)

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

      fKey = (obj,eventType) -> ((evt) -> obj._handleKey(evt,eventType))
      fMouse = (obj,eventType) -> ((evt) -> obj._handleMouse(evt,eventType))

      $(document).keydown( fKey(@,'down') )
      $(document).mousedown( fMouse(@,'down') )

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
          fDoStep = ( (obj) -> (->obj.processStep()) )(@)
          @root.queue.add @stepName(idx), fDoStep, {do: false}

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

      getFDoStep: (idx) -> ((root,that,i) -> (-> root.queue.do(that.stepName(i))) )(@root,@,idx)

      parseNext: (idx, next=null) ->
        fDoStepNext = @getFDoStep(idx+1)

        next = next ? @_next[idx]

        if !isNaN(parseFloat(next)) #number
          window.setTimeout fDoStepNext, @delayTime(next)
        else if (typeof next)=='string' #key name
          @parseNext(idx,['key',{button: next}])
        else if (typeof next)=='function' #function to check periodically
          fCheckNext = ( (that) -> (->that.checkNext()) )(@)
          @_fCheck = next
          @_timer = setInterval(fCheckNext,1)
        else if Array.isArray(next) and next.length>=1
          switch next[0]
            when 'key', 'mouse' #input event
              root = @root
              fRegister = (f) ->
                options = if next.length>=2 then next[1] else {}

                options.event = options.event ? 'down'
                options.button = options.button ? 'any'
                options.expires = 1

                if options.f?
                  fUser = options.f
                  options.f = -> fUser(); f();
                else
                  options.f = f

                root.input.addHandler(next[0],options)

              @parseNext(idx,['event', fRegister])
            when 'event' #a function that registers an event
              next[1](fDoStepNext)
            when 'lazy'
              that = @
              @parseNext idx, next[1](that, idx)
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
        fDoStepNext = @getFDoStep(idx+1)

        next = next ? @_next[idx]

        if Array.isArray(next) and (next[0]=='choice' or next[0]=='test')
          options = next[1] ? {}
          fCallback = options.callback ? null
          options.callback = ((root,that,step_idx) -> (obj,i) ->
            that.result[step_idx].t.choice = obj._tChoice
            that.result[step_idx].t.rt = that.result[step_idx].t.choice - that.result[step_idx].t.show
            that.result[step_idx].choice = i
            if obj instanceof root.show.MWClassShowTest then that.result[step_idx].correct = obj.correct
            if fCallback? then fCallback(i)
            fDoStepNext())(@root,@,idx)

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
      promptStim: -> ((that) -> (s, idx) -> that.prompt s.pre.target)(@)
      promptNext: -> @tPrompt

      operate: (target) -> null
      operateStim: -> ((that) -> (s, idx) -> that.operate s.pre.target)(@)
      operateNext: -> @tOperate

      test: (target) ->
        target.correct = true
        test = forceArray(@createDistractor(target))
        distractor.correct = false for distractor in test
        test.push target
        randomize test
        test
      testStim: -> ((that) -> (s, idx) -> that.test s.pre.target)(@)
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
      feedbackStim: -> ((that) -> (s, idx) -> that.feedback s.pre.target, s.result[idx-1].correct, s.result[idx-1].choice)(@)
      feedbackNext: -> @tFeedback

      trial: (param={}, options={}) ->
        ###
          options:
            result: a function that takes the trial show object (at the end of
              the trial) and returns an object recording the results of the
              trial
        ###
        that = @
        root = @root

        #default returns the result of the penultimate show stimulus (i.e. the
        #test screen)
        options.result = options.result ? (shw) -> shw.result[shw.result.length-2]
        fCallback = (shw) -> that.trial_result.push options.result(shw)
        options.callback = options.callback ? fCallback
        options.cleanupStim = options.cleanupStim ? 'sequence'
        options.countdown = options.countdown ? true

        #increment the trial
        @current_trial = if @current_trial? then @current_trial+1 else 0

        #pre step to construct the trial target
        options.pre = options.pre ? (shw) -> {
          target: that.create param
        }

        stim = []
        next = []

        #add the trial start prompt
        stim.push [['Instructions', "Click to begin #{@name} trial #{@current_trial+1}"]]
        next.push ['mouse', {
          f: -> root.el.status.el.timer.go()
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
        fStopTimer = -> root.el.status.el.timer.stop()
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
          {
            symmetry: "90"
            inside: true
          }
        )
        @addPart('circle',
          [ ['M',0,0.5], ['C',0,0.5,0,1,0.5,1], ['C',0.5,1,1,1,1,0.5], ['C',1,0.5,1,0,0.5,0], ['C',0.5,0,0,0,0,0.5] ]
          {
            symmetry: "90"
            inside: true
          }
        )
        @addPart('triangle',
          [ ['M',0,1], ['L',0.5,0], ['L',1,1], ['Z'] ]
          {
            symmetry: "vertical"
            connects: [1,3]
          }
        )
        @addPart('diamond'
          [ ['M',0.5,0], ['L',0,0.5], ['L',0.5,1], ['L',1,0.5], ['Z'] ]
          {
            symmetry: "90"
          }
        )
        @addPart('line',
          [ ['M',0.5,0], ['L',0.5,1], ['M',1,1] ] #last move just to fill the space
          {
            connects: [1,3]
            symmetry: "180"
          }
        )
        @addPart('cross'
          [ ['M',0.5,0], ['L',0.5,1], ['M',0,0.5], ['L',1,0.5] ]
          {
            symmetry: "90"
          }
        )
        ###@addPart('right triangle',
          [ ['M',0,1], ['L',1,1], ['L',1,0], ['M',1,0], ['L',0,1] ]
          {
            connects: [2,3]
          }
        )
        @addPart('T',
          [ ['L',1,0], ['M',0.5,0], ['L',0.5,1] ]
          {
            connects: [1,3]
            symmetry: "vertical"
          }
        )
        @addPart('D',
          [ ['L',0,1], ['L',0.5,1], ['C',0.5,1,1,1,1,0.5], ['C',1,0.5,1,0,0.5,0], ['Z'] ]
          {
            connects: [0,2]
            symmetry: "horizontal"
          }
        )
        @addPart('E'
          [ ['M',1,0], ['L',0,0], ['L',0,1], ['L',1,1], ['M',0,0.5], ['L',1,0.5] ]
          {
            symmetry: "horizontal"
          }
        )
        @addPart('S',
          [ ['M',1,0], ['L',0,0], ['L',0,0.5], ['L',1,0.5], ['L',1,1], ['L',0,1] ]
          {
            connects: [1,3]
            symmetry: "180"
          }
        )
        @addPart('B',
          [ ['L',0,1], ['L',0.75,1], ['C',0.75,1,1,1,1,0.75], ['C',1,0.75,1,0.5,0.75,0.5], ['L',0,0.5], ['L',0.75,0.5], ['C',0.75,0.5,1,0.5,1,0.25], ['C',1,0.25,1,0,0.75,0], ['Z'] ]
          {
            connects: [0,1,3]
            symmetry: "horizontal"
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
        )###

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
        [['M',.321,.968],['C',.339,.973,.355,.968,.359,.952,.364,.931,.392,.844,.392,.814],['S',.371,.734,.355,.7],['C',.342,.673,.366,.623,.373,.597],['S',.39,.552,.4,.554,.429,.551,.442,.543],['C',.455,.535,.469,.525,.479,.539,.489,.552,.51,.569,.549,.587,.588,.605,.66,.616,.708,.611],['S',.871,.546,.907,.514],['C',.943,.481,.976,.363,.978,.344,.98,.326,.991,.315,1,.334,1.009,.352,1.021,.347,1.021,.347],['S',1.041,.325,1.044,.312],['C',1.048,.299,1.046,.285,1.046,.285],['S',1.07,.274,1.073,.264],['C',1.076,.254,1.06,.23,1.051,.211,1.042,.193,1.006,.15,.987,.148,.968,.146,.935,.135,.924,.124,.913,.113,.885,.094,.847,.082,.809,.069,.702,.034,.674,.026],['S',.636,.022,.62,.032],['C',.604,.041,.623,.063,.626,.083,.629,.103,.597,.089,.586,.089],['S',.542,.1,.524,.095,.513,.073,.492,.057],['C',.472,.041,.447,-.002,.422,-.013],['S',.337,-.035,.314,-.033],['C',.292,-.03,.289,-.012,.304,.006,.319,.023,.357,.058,.361,.073,.366,.088,.364,.104,.348,.114,.332,.123,.32,.115,.297,.12,.274,.125,.258,.154,.253,.172,.249,.19,.241,.209,.23,.218,.221,.226,.211,.256,.205,.276,.199,.298,.208,.306,.212,.321,.217,.336,.196,.35,.186,.348,.176,.345,.127,.341,.107,.344,.087,.347,.06,.376,.043,.388,.026,.4,.028,.437,.044,.452],['S',.052,.495,.063,.517,.082,.583,.094,.6],['C',.106,.616,.14,.636,.152,.639,.165,.643,.173,.645,.17,.655],['S',.167,.679,.161,.702,.159,.833,.181,.903],['C',.186,.918,.199,.918,.216,.918,.227,.917,.234,.914,.242,.88,.251,.847,.263,.886,.269,.906],['S',.287,.952,.309,.964],['C',.313,.966,.317,.967,.321,.968],['Z']]
        [['M',.092,.864],['C',.11,.867,.138,.867,.154,.884,.165,.902,.19,.896,.202,.906,.208,.91,.21,.916,.212,.921,.223,.92,.232,.916,.235,.904,.243,.906,.25,.911,.257,.904,.259,.899,.262,.894,.271,.889,.273,.881,.272,.875,.271,.866,.288,.841,.345,.773,.367,.727,.375,.715,.38,.714,.397,.714,.426,.714,.467,.702,.495,.686,.547,.666,.606,.656,.663,.638,.772,.608,.791,.552,.804,.516,.824,.467,.795,.429,.775,.389,.775,.389,.775,.389,.775,.389,.772,.376,.773,.37,.775,.364,.781,.336,.785,.324,.81,.298,.824,.283,.87,.269,.891,.272,.909,.272,.94,.28,.955,.293,.96,.295,.963,.29,.956,.285,.942,.272,.922,.263,.913,.262,.862,.25,.817,.268,.778,.303,.794,.28,.81,.25,.821,.227,.826,.206,.806,.187,.785,.112,.782,.105,.779,.099,.773,.1,.762,.101,.743,.106,.736,.115,.732,.117,.731,.115,.726,.117,.727,.12,.728,.124,.731,.126,.735,.133,.74,.135,.747,.134,.758,.135,.758,.13,.764,.135,.776,.159,.79,.204,.778,.224,.772,.232,.765,.24,.759,.249,.749,.226,.74,.195,.734,.178,.729,.166,.727,.158,.714,.162,.709,.163,.704,.165,.701,.166,.696,.167,.688,.169,.685,.172,.682,.171,.68,.172,.679,.174,.676,.174,.674,.174,.672,.175,.674,.182,.675,.181,.678,.186,.689,.197,.7,.187,.707,.19,.717,.203,.724,.229,.731,.256,.732,.262,.735,.273,.736,.282,.734,.285,.731,.289,.729,.293,.712,.307,.694,.334,.685,.352,.678,.361,.674,.371,.673,.382,.664,.392,.661,.415,.662,.428,.662,.443,.669,.487,.661,.503,.641,.526,.617,.519,.564,.524,.527,.521,.486,.492,.461,.488,.424,.483,.389,.483,.355,.498,.355,.495,.356,.485,.357,.483,.355,.473,.349,.467,.345,.459,.324,.428,.316,.378,.3,.342,.293,.326,.297,.3,.287,.286,.276,.269,.258,.254,.246,.237,.246,.221,.234,.235,.222,.221,.215,.22,.203,.222,.192,.229,.184,.233,.184,.238,.179,.238,.18,.246,.193,.248,.201,.248,.207,.25,.211,.251,.214,.252,.208,.253,.205,.251,.199,.255,.194,.258,.195,.262,.189,.262,.192,.267,.197,.271,.204,.27,.209,.272,.214,.272,.22,.27,.248,.292,.255,.348,.268,.384,.283,.423,.276,.47,.285,.507,.266,.53,.255,.605,.248,.655,.247,.682,.233,.707,.227,.736,.223,.74,.221,.743,.223,.751,.212,.767,.211,.807,.204,.805,.189,.802,.169,.815,.161,.814,.155,.81,.151,.808,.138,.814,.129,.818,.108,.818,.101,.82,.094,.823,.082,.831,.077,.842,.071,.846,.066,.847,.068,.859,.074,.862,.078,.863,.092,.864],['Z']]
        [['M',.974,.211],['C',.975,.21,.975,.209,.975,.208,.985,.161,.954,.141,.917,.135,.905,.111,.88,.072,.87,.08,.867,.082,.875,.104,.873,.122,.867,.166,.826,.157,.801,.144,.776,.131,.771,.133,.751,.131,.731,.129,.556,.111,.482,.165,.396,.228,.314,.201,.311,.199,.318,.16,.326,.106,.324,.078,.324,.069,.33,.058,.331,.049,.331,.049,.338,.036,.339,.03,.339,.024,.334,.016,.334,.016],['S',.329,.028,.326,.031],['C',.323,.033,.317,.033,.317,.033],['L',.309,.026,.306,.043],['S',.298,.043,.298,.045],['C',.29,.08,.288,.115,.277,.147,.277,.147,.272,.156,.237,.168,.235,.169,.234,.176,.234,.176],['L',.223,.181,.232,.184],['S',.23,.193,.232,.192],['C',.248,.183,.287,.156,.291,.163,.291,.163,.289,.171,.285,.186,.274,.228,.268,.247,.284,.275,.299,.303,.326,.308,.313,.341,.3,.375,.231,.432,.212,.435,.199,.437,.172,.434,.157,.423,.149,.418,.145,.411,.147,.404,.151,.383,.161,.354,.162,.33,.163,.322,.15,.307,.15,.307],['L',.139,.361,.132,.35],['S',.118,.39,.119,.404],['C',.12,.42,.126,.43,.126,.43],['L',.116,.447],['S',.138,.452,.143,.455],['C',.148,.459,.126,.48,.126,.48],['L',.136,.484,.129,.492,.142,.495,.168,.456,.267,.482],['S',.284,.509,.279,.528],['C',.274,.546,.242,.582,.24,.608,.239,.629,.261,.675,.261,.675],['S',.22,.784,.217,.796,.188,.844,.187,.856],['C',.186,.868,.16,.943,.167,.939,.17,.937,.196,.933,.2,.923,.212,.89,.207,.925,.209,.924,.225,.918,.245,.906,.252,.9,.264,.891,.316,.829,.358,.774,.37,.758,.385,.747,.391,.742,.402,.734,.402,.72,.414,.709,.455,.673,.52,.605,.544,.581,.587,.548,.625,.528,.64,.508,.662,.48,.725,.395,.779,.349,.813,.319,.918,.31,.943,.275,.96,.25,.97,.228,.974,.211],['Z'],['M',.932,.175],['C',.931,.181,.925,.185,.919,.183],['S',.91,.176,.911,.17],['C',.913,.165,.919,.161,.924,.162],['S',.934,.17,.932,.175],['Z'],['M',.928,.174],['C',.929,.171,.927,.167,.923,.167,.92,.166,.917,.168,.916,.171],['S',.917,.177,.921,.178],['C',.924,.179,.927,.177,.928,.174],['Z']]
        [['M',.425,.792],['C',.519,.757,.638,.745,.685,.654,.722,.555,.691,.398,.638,.322,.647,.281,.722,.25,.785,.205,.834,.162,.871,.095,.826,.041,.782,.005,.726,.005,.694,.049,.663,.085,.606,.208,.587,.239,.581,.248,.572,.256,.562,.257,.543,.26,.482,.306,.468,.319,.417,.367,.344,.384,.289,.428,.273,.441,.241,.452,.245,.472,.247,.485,.266,.488,.279,.488,.305,.488,.35,.453,.35,.453],['L',.38,.46],['S',.352,.494,.34,.512],['C',.331,.528,.318,.561,.318,.561],['S',.228,.586,.182,.585],['C',.146,.566,.09,.569,.133,.611,.151,.626,.18,.618,.201,.625,.218,.631,.248,.649,.248,.649],['S',.21,.679,.198,.699],['C',.186,.72,.19,.748,.179,.769,.17,.787,.147,.797,.143,.816,.14,.837,.143,.881,.162,.875,.186,.868,.268,.881,.281,.879,.336,.869,.374,.816,.425,.792],['Z']]
        [['M',.291,.23],['C',.311,.246,.362,.287,.374,.298,.382,.305,.387,.312,.386,.314,.383,.32,.354,.316,.32,.304,.304,.299,.284,.292,.276,.29],['L',.265,.28,.257,.296,.252,.307,.299,.336],['C',.367,.377,.433,.422,.435,.428,.436,.432,.415,.446,.385,.507],['L',.355,.596,.321,.596],['C',.299,.604,.295,.618,.288,.616,.278,.612,.271,.62,.275,.629,.277,.632,.277,.647,.274,.653,.27,.662,.267,.655,.26,.655,.248,.654,.242,.661,.25,.672,.254,.678,.252,.69,.255,.701,.26,.715,.27,.726,.267,.727,.265,.727,.216,.685,.182,.66,.163,.645,.138,.63,.135,.621,.13,.607,.122,.604,.122,.605,.114,.62,.104,.638,.104,.645,.105,.647,.135,.678,.17,.713,.206,.748,.22,.773,.222,.776,.223,.779,.223,.781,.22,.782,.218,.783,.197,.778,.156,.763,.112,.747,.085,.744,.076,.735,.064,.723,.064,.725,.061,.732,.058,.738,.053,.753,.054,.754,.055,.756,.098,.781,.15,.811],['L',.229,.862,.261,.862],['C',.275,.86,.296,.858,.314,.865,.326,.87,.339,.888,.363,.903,.388,.918,.409,.93,.41,.931],['S',.412,.933,.412,.935],['C',.41,.938,.398,.936,.331,.922,.283,.911,.276,.909,.254,.898,.231,.885,.23,.885,.208,.885,.195,.886,.169,.871,.166,.871,.159,.872,.177,.895,.19,.906,.208,.921,.223,.927,.248,.927,.267,.927,.29,.931,.385,.955,.447,.971,.479,.982,.483,.982,.493,.982,.543,.977,.553,.943,.556,.934,.578,.948,.683,.721,.747,.582,.791,.437,.804,.409],['L',.822,.377,.852,.372],['C',.865,.378,.878,.383,.88,.383,.888,.381,.887,.371,.877,.347,.872,.335,.869,.322,.87,.32,.872,.316,.878,.315,.89,.315,.911,.316,.928,.311,.928,.305,.928,.303,.923,.295,.915,.289,.906,.28,.902,.273,.9,.266,.899,.26,.87,.243,.872,.222,.874,.203,.87,.167,.867,.149,.864,.131,.86,.114,.858,.111,.852,.104,.837,.104,.814,.111],['L',.796,.118,.788,.139],['C',.782,.157,.78,.161,.769,.169,.759,.177,.755,.183,.741,.211,.732,.23,.722,.246,.72,.248,.713,.253,.665,.265,.641,.268,.63,.269,.608,.269,.592,.269,.556,.267,.523,.271,.505,.278],['L',.491,.284,.461,.27],['C',.445,.263,.401,.245,.364,.23],['L',.31,.209,.299,.197,.29,.214],['C',.285,.224,.285,.225,.291,.23],['Z']]
        [['M',.861,.151],['C',.864,.155,.867,.159,.869,.163,.891,.201,.891,.236,.867,.256,.852,.269,.844,.272,.829,.271,.815,.27,.794,.274,.793,.278,.792,.279,.793,.284,.795,.288,.798,.296,.799,.296,.807,.298,.815,.3,.818,.303,.826,.313,.832,.321,.839,.326,.846,.331,.852,.334,.856,.337,.857,.338,.859,.34,.854,.345,.848,.346,.84,.347,.84,.346,.841,.358,.842,.366,.841,.372,.833,.387,.795,.457,.81,.542,.782,.617,.771,.625,.689,.588,.689,.588,.69,.591,.678,.591,.671,.587,.647,.578,.673,.563,.669,.56,.66,.553,.649,.554,.647,.552,.645,.553,.642,.553,.64,.555,.626,.568,.628,.568,.611,.553,.606,.548,.601,.544,.601,.545,.601,.545,.598,.549,.594,.554,.581,.573,.552,.592,.495,.617,.45,.636,.407,.658,.395,.667,.381,.678,.376,.692,.376,.715,.375,.733,.37,.761,.362,.798],['L',.357,.815,.325,.825],['C',.324,.829,.326,.834,.329,.843,.332,.856,.332,.856,.32,.863,.315,.867,.313,.867,.306,.861,.302,.857,.297,.855,.296,.856,.294,.857,.291,.864,.29,.872,.286,.887,.281,.893,.26,.903,.247,.909,.239,.909,.233,.904,.228,.901,.231,.893,.241,.883,.25,.874,.255,.866,.256,.856],['L',.256,.85],['C',.247,.852,.237,.856,.23,.858,.225,.86,.22,.86,.22,.86],['S',.204,.837,.221,.814],['C',.24,.791,.276,.734,.314,.67],['L',.348,.615,.409,.572],['C',.443,.549,.474,.528,.478,.525,.484,.52,.484,.52,.479,.52,.466,.521,.293,.554,.29,.556,.289,.557,.279,.581,.268,.608,.245,.668,.231,.698,.212,.728,.194,.755,.169,.789,.167,.789,.166,.789,.153,.776,.136,.757,.132,.758,.125,.763,.117,.768,.107,.776,.107,.776,.096,.767,.091,.763,.09,.762,.094,.753,.096,.747,.096,.743,.095,.741,.093,.74,.086,.74,.078,.741,.062,.743,.055,.74,.039,.724,.029,.713,.026,.706,.028,.698,.03,.693,.039,.693,.051,.699,.062,.705,.072,.706,.081,.704,.083,.704,.085,.703,.088,.703,.085,.7,.083,.698,.08,.695,.059,.671,.06,.672,.064,.67,.067,.67,.114,.639,.117,.637,.146,.614,.178,.583,.21,.555,.212,.553,.225,.541,.239,.527],['L',.264,.502,.285,.493],['C',.314,.481,.345,.472,.404,.459,.481,.443,.485,.442,.493,.424],['L',.498,.414,.519,.406],['C',.543,.396,.555,.39,.585,.371,.606,.357,.637,.332,.637,.328,.637,.325,.625,.319,.621,.32,.614,.322,.56,.326,.556,.325,.549,.322,.549,.311,.553,.26],['L',.558,.212,.549,.208],['C',.536,.203,.529,.195,.53,.183],['L',.531,.174,.541,.174],['C',.547,.175,.552,.174,.553,.174,.553,.173,.553,.166,.551,.158],['S',.548,.138,.548,.132],['C',.549,.122,.55,.12,.557,.114,.564,.108,.566,.107,.57,.108,.572,.109,.576,.109,.578,.107,.582,.103,.587,.104,.591,.109,.592,.111,.595,.111,.598,.11,.603,.108,.604,.108,.608,.113,.614,.122,.613,.136,.604,.153,.592,.178,.593,.181,.605,.182],['L',.612,.182,.614,.191],['C',.616,.202,.616,.202,.604,.206,.596,.209,.595,.209,.594,.217,.592,.231,.594,.256,.598,.265,.601,.272,.602,.273,.609,.274,.613,.274,.625,.273,.636,.27,.646,.268,.657,.266,.658,.266,.66,.267,.658,.264,.654,.26,.65,.257,.647,.252,.647,.25,.647,.245,.646,.245,.666,.252,.672,.255,.683,.256,.69,.255,.698,.254,.709,.255,.715,.257,.721,.259,.728,.26,.731,.259,.736,.258,.736,.258,.73,.251,.725,.244,.724,.247,.726,.238,.727,.235,.73,.228,.73,.224,.73,.221,.726,.221,.725,.22,.722,.215,.729,.211,.74,.198,.751,.187,.754,.177,.753,.161,.749,.121,.79,.1,.829,.123,.843,.131,.853,.14,.861,.151],['Z'],['M',.785,.401],['C',.752,.436,.714,.483,.674,.524,.673,.521,.68,.537,.697,.527,.701,.524,.703,.521,.709,.514,.713,.509,.725,.518,.729,.519,.731,.519,.724,.535,.727,.539,.731,.543,.728,.544,.728,.547,.728,.556,.756,.568,.756,.565,.759,.494,.759,.461,.785,.401],['Z']]
        [['M',.292,.489,.241,.501],['C',.228,.504,.217,.511,.206,.518,.189,.528,.151,.549,.118,.567,.101,.576,.08,.583,.066,.593,.053,.603,.043,.605,.042,.605,.041,.606,.042,.609,.042,.612,.044,.618,.048,.621,.05,.627],['L',.043,.629],['C',.034,.631,.023,.627,.012,.622,0,.616,-.008,.616,-.01,.621,-.013,.629,-.008,.639,.002,.649,.017,.665,.024,.668,.04,.666,.048,.666,.052,.662,.056,.664,.06,.668,.057,.673,.055,.678,.054,.682,.052,.684,.052,.686,.052,.689,.054,.69,.057,.692,.07,.702,.068,.701,.078,.694,.089,.687,.094,.682,.097,.683,.1,.683,.101,.688,.105,.693,.112,.704,.114,.705,.117,.702,.126,.689,.16,.646,.171,.635,.18,.625,.188,.624,.209,.605,.227,.59,.242,.572,.256,.554,.284,.56,.311,.561,.338,.564],['L',.41,.569,.41,.58],['C',.411,.594,.403,.628,.394,.637,.382,.649,.366,.684,.361,.699,.357,.712,.357,.714,.331,.746,.324,.754,.307,.776,.292,.797,.266,.833,.255,.845,.233,.863],['L',.215,.878],['C',.211,.881,.213,.884,.218,.886,.23,.895,.218,.896,.207,.895,.195,.892,.182,.887,.18,.899,.195,.925,.223,.943,.252,.947],['L',.246,.963,.26,.976],['S',.28,.959,.287,.947],['C',.3,.952,.305,.954,.319,.954,.322,.944,.326,.933,.331,.926,.378,.867,.389,.781,.42,.719,.432,.695,.437,.687,.458,.661,.467,.65,.474,.644,.475,.642,.477,.639,.48,.635,.48,.635,.484,.634,.486,.636,.487,.628,.487,.627,.488,.625,.489,.624,.491,.623,.494,.624,.495,.624,.496,.623,.497,.62,.5,.614,.509,.598,.526,.564,.541,.53],['L',.552,.504,.576,.485],['C',.582,.482,.587,.474,.593,.469,.602,.47,.623,.459,.63,.456,.632,.454,.635,.454,.638,.453,.638,.454,.634,.475,.632,.502,.63,.529,.634,.526,.631,.533,.63,.536,.629,.541,.629,.545,.628,.552,.632,.554,.63,.557,.627,.564,.619,.575,.617,.586,.617,.59,.614,.594,.612,.596,.607,.601,.592,.621,.59,.624,.588,.63,.589,.637,.577,.637,.565,.637,.554,.639,.548,.645,.544,.648,.542,.653,.54,.656,.533,.666,.534,.669,.542,.666,.546,.665,.548,.661,.55,.664,.552,.667,.551,.669,.551,.671,.552,.675,.553,.676,.557,.678,.559,.679,.563,.677,.565,.678,.571,.681,.575,.68,.579,.678,.583,.677,.583,.68,.586,.679,.588,.679,.594,.675,.596,.672,.605,.654,.613,.649,.617,.651,.629,.656,.641,.664,.653,.669,.653,.655,.65,.642,.647,.629],['L',.659,.604],['C',.666,.589,.673,.578,.676,.57,.683,.557,.682,.552,.686,.542,.692,.525,.691,.5,.688,.481,.687,.477,.686,.474,.687,.47,.688,.469,.688,.466,.688,.465,.686,.462,.683,.462,.683,.459,.683,.457,.687,.459,.686,.455,.685,.447,.687,.439,.69,.437,.708,.422,.696,.407,.687,.386,.684,.383,.686,.382,.699,.383],['L',.713,.383],['C',.704,.374,.694,.366,.685,.358,.68,.352,.68,.351,.683,.348,.693,.338,.698,.339,.714,.348,.737,.358,.77,.36,.79,.348,.846,.312,.853,.255,.817,.211,.789,.176,.738,.175,.723,.181,.721,.169,.719,.155,.718,.145,.718,.145,.706,.139,.706,.139,.706,.138,.712,.13,.718,.123,.728,.112,.731,.109,.743,.103],['L',.758,.096,.766,.081],['C',.775,.063,.78,.05,.776,.051,.775,.051,.771,.057,.766,.062,.757,.076,.757,.075,.754,.07,.751,.063,.742,.06,.732,.064,.725,.067,.724,.069,.723,.074,.723,.077,.721,.081,.718,.082,.716,.084,.709,.091,.703,.098,.698,.106,.686,.122,.682,.125],['L',.647,.135],['C',.647,.137,.648,.162,.647,.165,.642,.171,.634,.174,.633,.182,.627,.191,.619,.202,.616,.208,.613,.213,.608,.223,.604,.229,.597,.239,.597,.249,.595,.254,.589,.269,.591,.272,.587,.276,.582,.281,.572,.285,.553,.298,.529,.312,.516,.321,.507,.33,.478,.358,.451,.402,.431,.456,.428,.465,.425,.476,.423,.478,.42,.48,.389,.479,.376,.477,.346,.473,.317,.483,.292,.489],['Z'],['M',.643,.278],['C',.643,.274,.643,.269,.643,.265,.643,.264,.649,.258,.649,.255,.651,.247,.659,.237,.662,.229,.664,.224,.667,.215,.671,.206,.675,.199,.68,.191,.683,.188,.692,.171,.691,.168,.694,.169,.699,.17,.717,.181,.717,.182,.702,.191,.685,.202,.676,.215,.661,.236,.662,.259,.656,.273,.648,.279,.649,.287,.649,.291,.649,.292,.65,.295,.65,.295,.65,.3,.641,.285,.643,.278],['Z']]
        [['M',.281,1.004],['C',.281,.998,.282,.991,.281,.985,.28,.971,.28,.955,.28,.95,.282,.94,.286,.939,.293,.949,.35,.912,.419,.857,.472,.808,.493,.788,.518,.764,.527,.755,.545,.736,.546,.733,.549,.693,.552,.66,.55,.636,.544,.595,.537,.545,.536,.535,.539,.52,.542,.503,.554,.474,.56,.47,.565,.467,.603,.472,.605,.476,.606,.477,.606,.483,.605,.49,.602,.511,.615,.612,.622,.623,.623,.624,.625,.622,.626,.619,.627,.615,.631,.611,.635,.609],['L',.641,.604,.649,.617],['C',.66,.633,.685,.651,.692,.646,.697,.643,.696,.64,.687,.637,.682,.634,.681,.633,.682,.629,.683,.626,.685,.622,.687,.621,.691,.619,.707,.623,.715,.628,.724,.635,.726,.632,.72,.623,.716,.616,.712,.614,.703,.611,.696,.609,.686,.608,.68,.608,.669,.607,.667,.606,.668,.596],['L',.669,.59,.687,.585],['C',.697,.582,.705,.579,.705,.578],['S',.701,.573,.697,.569],['C',.693,.566,.681,.55,.67,.535],['L',.651,.507,.666,.496],['C',.674,.489,.692,.477,.706,.468,.72,.459,.743,.443,.757,.433,.778,.417,.782,.413,.783,.407,.785,.398,.776,.384,.76,.374,.753,.37,.746,.365,.746,.364,.746,.36,.764,.344,.771,.341,.775,.34,.78,.34,.783,.341,.783,.341,.784,.341,.784,.342,.779,.349,.776,.363,.795,.362,.806,.361,.814,.351,.816,.343,.817,.345,.818,.347,.819,.349,.824,.356,.827,.359,.833,.36,.845,.362,.853,.359,.861,.35,.867,.343,.87,.341,.88,.339,.893,.337,.895,.334,.895,.321,.896,.311,.899,.307,.91,.305,.918,.303,.923,.291,.916,.278,.911,.269,.912,.26,.917,.255,.92,.242,.92,.24,.913,.229,.906,.222,.903,.213,.905,.208,.904,.204,.903,.198,.901,.196,.897,.189,.879,.175,.866,.169,.857,.167,.849,.163,.848,.159,.846,.154,.841,.149,.828,.153,.824,.154,.811,.153,.806,.151,.792,.145,.781,.178,.777,.18,.775,.184,.755,.183,.753,.193,.751,.204,.754,.213,.753,.221],['L',.753,.221],['C',.752,.224,.747,.233,.743,.238,.737,.238,.732,.238,.723,.245,.712,.254,.713,.261,.718,.268,.718,.268,.717,.268,.717,.268,.716,.269,.714,.276,.714,.284,.713,.292,.711,.303,.71,.308,.707,.319,.709,.32,.682,.301,.663,.288,.648,.285,.629,.289,.591,.298,.546,.297,.516,.287,.498,.281,.477,.263,.455,.252,.449,.249,.439,.235,.432,.242,.427,.246,.423,.253,.419,.261],['L',.415,.261],['C',.406,.263,.404,.262,.403,.25,.402,.244,.4,.235,.398,.228,.394,.219,.391,.215,.385,.212,.375,.206,.372,.208,.379,.217,.386,.225,.391,.241,.389,.245,.388,.247,.385,.249,.382,.25,.377,.251,.376,.251,.373,.245,.369,.237,.366,.236,.363,.241,.36,.248,.379,.272,.396,.281],['L',.408,.288],['C',.402,.304,.399,.317,.4,.315],['L',.419,.322],['C',.505,.338,.6,.335,.6,.341,.6,.343,.597,.346,.593,.348],['S',.583,.357,.579,.363],['C',.568,.377,.556,.39,.551,.391,.548,.392,.539,.39,.53,.386,.498,.373,.471,.373,.447,.386,.42,.401,.406,.42,.386,.477,.364,.536,.353,.556,.33,.581,.322,.589,.31,.6,.301,.606,.278,.621,.268,.623,.164,.638,.143,.641,.124,.645,.122,.646,.12,.648,.119,.652,.121,.661,.123,.674,.122,.678,.116,.68,.114,.681,.098,.69,.081,.7],['L',.05,.719,.057,.73],['C',.065,.742,.067,.743,.081,.737,.111,.724,.119,.744,.094,.766],['L',.085,.774,.106,.805,.127,.837,.142,.828],['C',.159,.816,.161,.812,.156,.79],['L',.153,.774,.165,.792],['C',.174,.806,.178,.809,.181,.808,.185,.807,.314,.719,.35,.692,.379,.67,.386,.661,.427,.587,.444,.557,.459,.532,.459,.533,.46,.533,.461,.573,.46,.622],['L',.459,.71,.413,.74],['C',.367,.769,.365,.771,.294,.802,.255,.82,.221,.835,.219,.836,.217,.838,.218,.841,.229,.856],['L',.242,.874,.219,.887],['C',.207,.894,.193,.901,.189,.903,.181,.906,.182,.91,.191,.925],['L',.196,.933,.21,.928],['C',.223,.923,.236,.923,.239,.928,.24,.93,.24,.934,.239,.938,.237,.945,.236,.947,.223,.958,.217,.964,.217,.965,.221,.971,.227,.981,.228,.986,.222,.988,.222,.988,.239,1.025,.25,1.029,.265,1.034,.28,1.007,.281,1.004],['Z'],['M',.811,.337],['C',.811,.337,.812,.338,.814,.341,.813,.351,.801,.359,.795,.36,.778,.361,.782,.349,.787,.342,.795,.344,.808,.343,.811,.337],['Z'],['M',.724,.247],['C',.728,.243,.733,.24,.74,.24,.737,.242,.735,.245,.735,.245,.736,.246,.726,.26,.72,.266,.714,.262,.716,.254,.724,.247],['Z']]
        [['M',.457,.105],['C',.459,.107,.469,.107,.478,.103,.489,.099,.495,.099,.496,.103,.497,.107,.504,.109,.512,.107,.522,.105,.528,.108,.532,.118,.538,.13,.54,.131,.548,.125,.563,.113,.577,.119,.581,.138,.583,.153,.585,.154,.597,.149,.613,.142,.628,.156,.629,.178,.629,.186,.632,.191,.636,.191,.648,.189,.658,.197,.661,.213,.663,.225,.666,.229,.674,.227,.681,.225,.685,.229,.688,.239,.692,.251,.686,.262,.653,.302,.631,.328,.612,.355,.612,.362,.611,.368,.615,.382,.621,.394],['L',.632,.414,.644,.391],['C',.66,.364,.675,.364,.676,.391,.677,.413,.691,.427,.705,.421,.717,.415,.719,.42,.711,.432,.707,.439,.708,.44,.716,.439,.721,.438,.726,.44,.725,.444,.724,.453,.73,.455,.835,.486,.874,.498,.909,.511,.912,.514,.916,.518,.927,.524,.937,.528,.984,.548,1.03,.588,1.035,.614,1.037,.627,1.028,.626,1.018,.612,1.002,.589,.962,.562,.935,.555,.921,.552,.881,.55,.847,.551,.775,.553,.724,.55,.698,.542,.665,.531,.65,.541,.652,.571,.652,.582,.656,.587,.666,.589,.674,.591,.681,.595,.681,.597,.682,.602,.646,.62,.632,.623,.619,.625,.596,.611,.581,.591,.554,.555,.531,.562,.416,.646,.309,.724,.164,.868,.131,.93,.117,.955,.101,.975,.105,.955,.106,.951,.102,.935,.096,.935,.089,.934,.081,.946,.08,.939,.079,.933,.076,.91,.072,.909,.066,.908,.067,.904,.073,.893,.078,.884,.07,.879,.068,.874,.066,.867,.081,.852,.091,.844,.101,.837,.107,.827,.106,.821,.105,.815,.107,.806,.111,.801,.115,.796,.11,.792,.11,.787,.109,.783,.122,.771,.13,.766,.138,.76,.153,.742,.164,.726,.203,.666,.234,.622,.239,.621,.242,.621,.239,.617,.238,.614],['S',.248,.607,.254,.606,.266,.602,.265,.599],['C',.265,.596,.27,.586,.276,.577],['S',.288,.557,.287,.553],['C',.286,.549,.29,.546,.294,.547,.299,.548,.304,.544,.305,.539,.306,.533,.311,.53,.316,.531,.321,.532,.326,.528,.327,.522,.328,.512,.367,.468,.374,.468,.376,.468,.38,.463,.382,.458,.386,.45,.388,.449,.393,.454,.398,.459,.399,.459,.402,.452,.405,.445,.409,.445,.424,.45],['L',.442,.457,.458,.426],['C',.466,.409,.472,.391,.469,.385,.464,.371,.412,.352,.339,.337,.303,.33,.269,.321,.264,.318,.249,.308,.255,.292,.276,.288],['L',.294,.285,.275,.268],['C',.253,.248,.254,.232,.277,.228,.286,.226,.294,.221,.295,.216,.296,.21,.302,.205,.309,.204,.315,.203,.32,.198,.319,.193,.317,.181,.33,.174,.346,.179,.358,.183,.359,.182,.357,.168,.353,.15,.367,.14,.382,.151,.393,.158,.394,.157,.398,.139,.402,.123,.405,.119,.417,.119,.426,.12,.433,.116,.434,.111,.435,.101,.45,.097,.457,.105],['Z']]
        [['M',.09,.895],['C',.092,.899,.098,.91,.102,.912,.107,.914,.111,.912,.116,.906,.118,.909,.12,.911,.123,.911,.126,.911,.129,.909,.132,.905,.135,.91,.138,.912,.142,.912,.145,.912,.15,.91,.153,.907,.155,.905,.156,.9,.155,.897,.155,.894,.153,.892,.15,.89,.154,.888,.157,.886,.158,.883,.16,.881,.16,.878,.159,.874,.16,.876,.165,.872,.175,.864,.178,.861,.182,.858,.187,.854],['L',.181,.861,.202,.884],['C',.203,.885,.204,.885,.204,.886,.205,.887,.205,.889,.204,.89,.21,.892,.215,.894,.218,.898,.222,.901,.224,.907,.226,.909,.229,.91,.231,.908,.232,.906,.234,.905,.236,.903,.235,.9,.233,.897,.227,.892,.224,.888,.221,.884,.22,.88,.22,.876,.217,.877,.215,.877,.214,.877,.213,.876,.212,.875,.212,.873],['L',.192,.85,.192,.85],['C',.198,.845,.205,.839,.213,.833,.212,.833,.212,.833,.212,.833],['L',.23,.852],['C',.23,.854,.23,.855,.23,.856,.231,.857,.232,.857,.232,.857,.234,.856,.235,.856,.234,.859,.234,.862,.23,.87,.231,.874,.233,.878,.238,.881,.242,.883,.247,.884,.253,.884,.258,.882,.262,.881,.265,.878,.266,.873,.268,.868,.268,.859,.267,.855,.266,.85,.263,.848,.26,.846,.257,.845,.254,.845,.251,.846,.249,.846,.248,.848,.247,.848,.245,.848,.244,.847,.243,.846,.244,.844,.244,.843,.243,.842,.243,.842,.242,.842,.24,.842],['L',.223,.823,.398,.676],['C',.404,.685,.413,.692,.426,.7,.439,.707,.458,.717,.475,.72,.493,.722,.513,.72,.529,.715,.545,.71,.558,.701,.572,.689,.585,.677,.599,.656,.608,.644,.617,.633,.619,.628,.626,.624,.633,.619,.641,.616,.651,.616],['L',.655,.601],['C',.647,.597,.642,.592,.64,.586,.638,.58,.638,.572,.643,.563,.65,.553,.663,.54,.675,.531,.688,.521,.705,.511,.719,.507,.733,.503,.75,.502,.76,.507,.771,.511,.777,.52,.78,.533],['L',.794,.53],['C',.795,.523,.797,.517,.802,.512,.807,.507,.811,.505,.825,.497,.84,.49,.869,.477,.889,.464,.908,.451,.928,.437,.941,.419,.954,.401,.965,.381,.967,.358,.97,.335,.963,.302,.957,.281,.952,.26,.945,.245,.937,.231,.928,.218,.919,.208,.907,.201,.909,.195,.908,.19,.904,.185,.9,.181,.894,.177,.885,.173,.877,.161,.864,.15,.845,.138,.826,.127,.795,.112,.77,.107,.746,.102,.72,.102,.698,.109,.675,.115,.653,.131,.636,.146,.619,.162,.607,.185,.597,.201,.587,.216,.582,.23,.574,.239,.566,.249,.557,.254,.546,.257],['L',.542,.269],['C',.548,.27,.553,.272,.557,.277,.561,.281,.565,.287,.566,.296,.566,.305,.565,.317,.558,.33,.552,.343,.537,.362,.528,.373,.519,.384,.511,.391,.504,.395,.497,.399,.493,.401,.486,.399,.478,.397,.47,.391,.46,.381],['L',.445,.384],['C',.444,.391,.441,.397,.438,.402,.434,.408,.432,.412,.423,.419,.413,.425,.396,.432,.382,.442,.369,.452,.352,.465,.342,.478,.332,.491,.326,.504,.324,.52,.321,.536,.321,.555,.326,.574,.331,.593,.341,.611,.355,.631],['L',.177,.803,.16,.784],['C',.158,.783,.157,.783,.156,.782,.156,.78,.157,.778,.158,.776,.154,.775,.15,.773,.147,.77,.143,.767,.139,.76,.136,.758,.133,.756,.131,.758,.129,.759,.128,.761,.125,.763,.126,.765,.128,.768,.134,.771,.136,.775,.139,.779,.141,.784,.142,.79,.144,.789,.145,.789,.146,.79,.147,.79,.147,.791,.147,.793],['L',.167,.814],['C',.163,.818,.16,.821,.157,.825,.156,.826,.155,.827,.154,.828],['L',.14,.812],['C',.141,.81,.141,.809,.14,.808,.139,.808,.138,.808,.137,.808,.135,.807,.135,.806,.135,.804,.135,.803,.137,.802,.138,.8,.139,.798,.139,.794,.138,.791,.137,.788,.135,.785,.131,.783,.127,.782,.117,.781,.113,.782,.108,.783,.105,.785,.102,.789,.1,.793,.099,.8,.1,.804,.101,.809,.104,.815,.108,.816,.111,.818,.12,.815,.122,.815,.125,.815,.126,.816,.124,.817,.124,.818,.124,.819,.125,.819,.126,.82,.127,.82,.128,.821],['L',.143,.838],['C',.141,.841,.138,.843,.135,.846,.133,.845,.131,.845,.128,.847,.126,.849,.123,.852,.119,.857,.117,.852,.114,.85,.11,.85,.106,.851,.099,.855,.097,.859,.095,.862,.097,.866,.1,.871,.096,.874,.094,.877,.094,.88,.093,.882,.095,.884,.098,.886,.092,.888,.09,.89,.09,.895],['Z']]
        [['M',.572,.073],['C',.599,.076,.649,.102,.649,.102],['S',.676,.095,.689,.097],['C',.699,.098,.708,.106,.717,.109,.741,.117,.789,.126,.789,.126],['L',.751,.104],['S',.774,.102,.785,.105],['C',.805,.11,.826,.119,.842,.132,.856,.144,.866,.16,.874,.177,.881,.192,.887,.209,.887,.226,.888,.235,.883,.243,.882,.252,.876,.28,.875,.308,.868,.336,.858,.376,.844,.417,.826,.455,.807,.493,.781,.528,.755,.562,.735,.588,.711,.611,.689,.636,.661,.669,.638,.706,.607,.737,.597,.746,.586,.755,.574,.763,.567,.767,.559,.769,.552,.773,.542,.778,.535,.788,.525,.792,.517,.796,.506,.793,.498,.797,.493,.799,.491,.805,.486,.807,.478,.811,.468,.809,.46,.812,.453,.814,.448,.821,.441,.822,.433,.824,.425,.82,.418,.82,.383,.823,.351,.84,.317,.843,.305,.844,.28,.842,.28,.842,.278,.843,.229,.839,.228,.836,.201,.862,.183,.844,.182,.818,.182,.818,.151,.814,.136,.811,.121,.808,.106,.799,.09,.799,.085,.799,.079,.805,.074,.803,.066,.801,.061,.793,.057,.787,.053,.781,.05,.774,.049,.767,.046,.756,.044,.745,.046,.735,.047,.728,.056,.717,.056,.717],['S',.056,.714,.057,.712],['C',.068,.695,.086,.682,.105,.676,.112,.674,.118,.679,.125,.677,.131,.676,.135,.671,.141,.669,.155,.665,.17,.67,.184,.666,.19,.664,.199,.656,.199,.656],['S',.193,.645,.195,.639],['C',.199,.629,.212,.623,.223,.62,.232,.617,.25,.622,.25,.622],['S',.252,.607,.258,.603],['C',.263,.599,.271,.598,.278,.599,.285,.601,.297,.611,.297,.611],['L',.304,.607],['S',.287,.591,.279,.582],['C',.271,.575,.264,.568,.257,.56,.255,.557,.252,.552,.252,.552],['S',.234,.549,.23,.548],['C',.228,.548,.221,.547,.219,.547,.216,.547,.214,.548,.212,.548,.209,.547,.207,.545,.205,.545,.187,.55,.194,.558,.172,.549,.182,.527,.205,.507,.222,.487,.222,.487,.232,.486,.236,.488,.239,.488,.24,.491,.242,.492,.247,.493,.257,.489,.262,.49,.27,.492,.287,.505,.29,.505,.293,.506,.309,.509,.309,.509],['S',.306,.495,.304,.489],['C',.303,.486,.302,.484,.3,.482,.297,.479,.285,.474,.282,.471,.281,.47,.281,.468,.279,.467,.277,.466,.274,.469,.271,.468,.27,.467,.27,.465,.268,.465,.264,.464,.26,.466,.257,.468,.252,.476,.245,.475,.232,.472],['L',.241,.459],['C',.247,.449,.256,.441,.264,.432,.267,.419,.271,.416,.282,.41,.29,.406,.298,.415,.301,.416,.303,.417,.308,.422,.313,.424,.317,.426,.33,.43,.334,.432,.342,.438,.345,.449,.353,.454,.356,.456,.359,.455,.362,.456,.365,.458,.37,.464,.37,.464],['L',.382,.448],['S',.394,.406,.403,.387],['C',.412,.367,.424,.349,.435,.33,.443,.315,.447,.295,.461,.283,.465,.279,.471,.28,.476,.277,.493,.267,.506,.251,.522,.24,.53,.233,.55,.223,.55,.223,.543,.217,.536,.212,.529,.206,.529,.206,.518,.208,.51,.208,.502,.208,.493,.201,.485,.201,.479,.201,.448,.198,.448,.198,.452,.189,.457,.18,.462,.172,.463,.162,.471,.161,.477,.154],['L',.491,.14],['C',.501,.138,.515,.14,.528,.14,.535,.14,.541,.137,.547,.136,.539,.133,.535,.128,.529,.121],['L',.524,.123],['C',.518,.13,.507,.129,.496,.131,.499,.125,.509,.116,.513,.112,.514,.098,.524,.095,.533,.085,.533,.085,.536,.07,.54,.067,.551,.058,.559,.072,.572,.073],['Z']]
        [['M',.249,.899],['C',.251,.899,.252,.899,.254,.898,.282,.895,.307,.88,.331,.866,.345,.858,.357,.846,.366,.832,.383,.807,.383,.771,.406,.752,.442,.72,.492,.708,.536,.687,.578,.667,.609,.65,.668,.63,.708,.617,.744,.595,.782,.578,.759,.583,.736,.587,.713,.592,.732,.582,.751,.572,.77,.562,.794,.549,.818,.536,.842,.524,.862,.514,.883,.506,.903,.498,.915,.493,.928,.493,.939,.489,.927,.491,.913,.489,.9,.492,.908,.487,.915,.483,.923,.479],['L',.899,.475],['C',.917,.467,.935,.461,.953,.453,.968,.447,.982,.44,.997,.433],['L',.965,.427],['C',.97,.419,.979,.412,.979,.403,.978,.397,.97,.393,.964,.393,.945,.393,.926,.397,.907,.402,.869,.412,.832,.43,.793,.439,.777,.443,.759,.441,.743,.439,.731,.438,.72,.432,.708,.43,.681,.425,.654,.421,.626,.417],['L',.642,.404],['C',.637,.404,.633,.403,.628,.402,.636,.399,.643,.395,.65,.392],['L',.612,.392],['C',.618,.388,.625,.385,.632,.381,.62,.38,.609,.379,.597,.379,.573,.379,.549,.38,.525,.381,.529,.364,.539,.339,.531,.323,.523,.309,.523,.303,.516,.294,.513,.291,.509,.289,.504,.289],['L',.48,.251,.46,.214],['C',.485,.216,.491,.22,.511,.207],['L',.491,.209],['C',.485,.196,.467,.205,.456,.199,.456,.199,.443,.195,.439,.19,.429,.162,.41,.166,.399,.138,.391,.132,.385,.133,.376,.133],['L',.369,.125,.376,.142,.393,.167],['C',.381,.168,.374,.169,.36,.165,.349,.162,.332,.155,.319,.154],['L',.311,.144,.316,.16,.346,.176],['S',.365,.179,.362,.18],['C',.352,.181,.346,.185,.335,.185,.322,.185,.305,.182,.297,.188],['L',.289,.186],['S',.305,.193,.313,.195],['C',.328,.198,.331,.196,.354,.195,.378,.194,.385,.185,.4,.191,.434,.216,.466,.261,.487,.301,.487,.301,.487,.301,.487,.301,.478,.303,.469,.304,.46,.306,.455,.307,.451,.308,.446,.308,.426,.309,.406,.302,.386,.304,.382,.305,.378,.307,.374,.308,.369,.308,.36,.307,.36,.307],['S',.375,.314,.383,.316],['C',.393,.318,.409,.309,.415,.318,.416,.319,.414,.321,.412,.323,.405,.328,.394,.326,.385,.327,.378,.328,.372,.328,.365,.327,.362,.327,.357,.325,.357,.325],['S',.367,.335,.373,.337],['C',.388,.342,.405,.326,.419,.332,.422,.333,.425,.336,.424,.339,.423,.346,.415,.348,.409,.351,.406,.353,.398,.354,.398,.354],['S',.406,.358,.41,.358],['C',.42,.356,.425,.343,.434,.341,.437,.341,.441,.341,.443,.343,.451,.347,.455,.357,.459,.364,.462,.369,.465,.374,.468,.38,.461,.385,.454,.388,.448,.393,.437,.403,.43,.418,.417,.426,.398,.436,.374,.435,.354,.445,.33,.457,.308,.475,.287,.492,.268,.508,.246,.522,.235,.544,.222,.57,.224,.602,.217,.63,.211,.656,.201,.681,.197,.707,.195,.719,.201,.731,.197,.743,.193,.755,.184,.766,.174,.774,.163,.783,.149,.791,.134,.794,.101,.802,.067,.803,.033,.805,.028,.805,.024,.802,.019,.801,.027,.843,.115,.856,.165,.875,.172,.878,.176,.885,.183,.887,.205,.893,.227,.901,.249,.899],['Z'],['M',.2,.84],['C',.193,.841,.187,.836,.187,.829],['S',.191,.816,.198,.816,.211,.821,.211,.827,.207,.84,.2,.84],['Z'],['M',.2,.837],['C',.205,.837,.208,.833,.208,.828],['S',.203,.819,.198,.819,.19,.824,.19,.829],['C',.19,.834,.195,.838,.2,.837],['Z'],['M',.198,.834],['C',.196,.834,.194,.833,.194,.831,.194,.829,.195,.828,.197,.828,.199,.828,.201,.829,.201,.831,.201,.833,.2,.834,.198,.834],['Z'],['M',.478,.368],['C',.473,.359,.468,.348,.466,.339,.464,.334,.462,.327,.465,.322,.468,.317,.475,.315,.482,.313,.481,.316,.48,.318,.48,.32,.478,.327,.483,.335,.482,.343,.481,.351,.481,.36,.478,.368],['Z']]
        [['M',.258,.899],['C',.262,.86,.263,.815,.294,.785,.325,.755,.35,.719,.381,.689,.395,.674,.403,.697,.41,.716,.418,.736,.418,.751,.42,.771,.421,.79,.424,.825,.444,.823,.458,.822,.445,.778,.444,.758,.443,.729,.451,.7,.453,.673,.455,.648,.472,.63,.493,.623,.568,.717,.706,.742,.815,.675,.933,.603,.973,.453,.904,.339,.896,.327,.888,.316,.879,.305,.879,.282,.872,.259,.856,.24,.854,.238,.852,.235,.85,.232,.869,.194,.87,.149,.841,.114,.807,.073,.783,-.058,.753,-.034,.724,-.01,.79,.081,.82,.132,.832,.152,.834,.172,.831,.193,.809,.14,.79,.074,.769,.092,.744,.112,.787,.179,.819,.23,.816,.237,.812,.244,.808,.251,.735,.214,.642,.216,.565,.263,.454,.33,.412,.467,.465,.578,.465,.578,.464,.579,.464,.579,.452,.596,.43,.602,.413,.587,.39,.567,.361,.542,.361,.515,.361,.496,.328,.461,.327,.488,.326,.511,.348,.53,.356,.552,.366,.578,.374,.616,.348,.634,.314,.657,.27,.637,.234,.647,.198,.657,.166,.667,.129,.666,.092,.665,.051,.666,.017,.648,.01,.644,-.005,.631,-.007,.641,-.011,.671,.031,.689,.06,.694,.099,.7,.139,.694,.178,.698,.211,.701,.243,.724,.246,.758,.251,.804,.227,.847,.233,.894,.236,.921,.214,.943,.199,.965,.181,.991,.217,.985,.23,.973,.251,.954,.255,.925,.258,.899],['Z'],['M',.835,.257],['C',.835,.257,.835,.257,.835,.257,.838,.262,.841,.267,.842,.272,.838,.269,.834,.266,.83,.264,.831,.261,.833,.259,.835,.257],['Z'],['M',.508,.405],['C',.485,.368,.512,.309,.568,.274,.531,.298,.514,.337,.529,.362,.545,.388,.589,.389,.629,.365,.668,.341,.687,.301,.672,.275,.656,.249,.611,.247,.572,.271,.572,.271,.572,.271,.572,.271,.63,.236,.697,.238,.72,.276,.744,.315,.715,.375,.656,.411,.598,.446,.531,.444,.508,.405],['Z'],['M',.602,.272],['C',.612,.265,.623,.266,.628,.272],['S',.627,.29,.616,.296],['C',.606,.302,.595,.302,.591,.295,.587,.288,.592,.278,.602,.272],['Z']]
        [['M',.484,.24],['C',.502,.224,.525,.215,.538,.194,.546,.182,.556,.173,.564,.161,.579,.138,.609,.133,.633,.12,.65,.112,.67,.104,.682,.088,.682,.079,.696,.057,.713,.06,.733,.064,.736,.043,.752,.036,.772,.021,.779,.033,.77,.043,.751,.066,.734,.092,.708,.108,.684,.118,.662,.131,.643,.149,.623,.169,.601,.187,.58,.205,.577,.214,.559,.236,.575,.236,.586,.233,.596,.218,.606,.23,.614,.238,.593,.254,.593,.268,.586,.29,.563,.302,.549,.32,.542,.326,.526,.347,.543,.347,.569,.334,.595,.32,.622,.309,.644,.282,.67,.26,.698,.241,.712,.231,.721,.219,.732,.208,.745,.194,.756,.18,.773,.17,.787,.162,.797,.15,.803,.136,.813,.129,.812,.109,.822,.106,.82,.128,.822,.118,.83,.102,.845,.084,.828,.134,.84,.107,.855,.09,.848,.11,.84,.119,.83,.132,.823,.148,.812,.16,.785,.188,.757,.225,.737,.248,.717,.271,.694,.277,.687,.296,.68,.314,.671,.328,.662,.344,.667,.353,.689,.367,.692,.351,.696,.334,.71,.322,.727,.317,.746,.311,.769,.318,.783,.332,.795,.345,.796,.363,.789,.38,.782,.398,.762,.406,.747,.41,.737,.413,.715,.422,.714,.406,.713,.389,.698,.403,.688,.406,.687,.421,.681,.433,.678,.448,.676,.458,.677,.462,.673,.48,.669,.499,.647,.526,.64,.551,.632,.578,.627,.608,.61,.63,.599,.644,.596,.661,.586,.675,.578,.694,.576,.714,.573,.733,.571,.745,.567,.762,.56,.755,.541,.78,.567,.72,.559,.711,.554,.704,.531,.733,.537,.716,.551,.707,.552,.687,.567,.679,.58,.637,.59,.595,.606,.554,.615,.53,.619,.504,.629,.481,.625,.465,.598,.469,.588,.473,.575,.478,.561,.465,.547,.463,.533,.462,.52,.451,.507,.45,.487,.447,.47,.463,.459,.48,.444,.502,.428,.525,.405,.54,.391,.55,.379,.564,.362,.571,.357,.557,.372,.547,.367,.533,.364,.521,.368,.509,.371,.497,.378,.474,.363,.487,.352,.494,.331,.509,.308,.517,.283,.52,.258,.53,.235,.544,.216,.563,.187,.585,.153,.599,.122,.617,.105,.623,.095,.638,.078,.644,.067,.653,.062,.668,.049,.673,.039,.679,.02,.689,.014,.673,.006,.662,.021,.648,.03,.642,.039,.634,.057,.631,.06,.617,.055,.604,.078,.59,.088,.602,.105,.6,.117,.583,.13,.572,.15,.554,.166,.531,.191,.521,.206,.513,.224,.507,.234,.493,.277,.467,.312,.431,.354,.404,.365,.393,.381,.386,.39,.374,.394,.353,.396,.331,.412,.316,.43,.295,.449,.274,.467,.253,.471,.247,.478,.244,.484,.24],['L',.484,.24],['Z']]
        [['M',1.047,.431,.947,.092,.51,.254],['C',.485,.203,.438,.236,.42,.273,.386,.297,.345,.307,.308,.325,.274,.272,.248,.212,.206,.166,.164,.121,.151,.207,.181,.236,.223,.277,.249,.336,.283,.386,.269,.449,.255,.512,.242,.575,.139,.62,.02,.647,-.029,.705,-.05,.731,.013,.729,.05,.766,.088,.805,.171,.865,.178,.905,.185,.945,.23,.915,.251,.886,.262,.87,.288,.867,.306,.858,.338,.893,.361,.939,.4,.962,.458,.996,.478,.894,.477,.848,.485,.797,.595,.757,.605,.787,.615,.815,.543,.841,.585,.886,.623,.928,.688,.931,.695,.867,.703,.792,.652,.722,.676,.649,.686,.616,.667,.559,.704,.544,.818,.507,.932,.469,1.047,.431],['Z'],['M',.608,.71,.537,.597],['S',.617,.564,.625,.563],['L',.608,.71],['Z'],['M',.552,.722,.484,.749,.503,.647,.552,.722],['Z'],['M',.246,.834],['C',.245,.842,.227,.85,.221,.846,.169,.813,.116,.758,.064,.713,.115,.694,.166,.674,.217,.654,.219,.653,.221,.653,.223,.652],['L',.201,.792],['C',.216,.804,.233,.814,.245,.828,.246,.83,.247,.832,.246,.834],['Z']]
        [['M',.64,-.041],['C',.684,.015,.705,.1,.773,.127,.834,.152,.919,.192,.96,.202,.976,.206,.947,.093,.967,.108,1.132,.29,1.013,.546,.848,.678,.802,.705,.772,.736,.767,.79,.744,.89,.62,.978,.526,.997,.271,1.01,.128,.824,.145,.581,.151,.534,.092,.523,.084,.57,.063,.629,-.037,.576,.008,.531,.051,.497,.103,.444,.162,.479,.224,.492,.229,.634,.256,.662,.292,.698,.351,.482,.323,.438,.295,.396,.2,.418,.165,.354,.129,.291,.204,.272,.229,.242,.261,.202,.313,.195,.329,.254,.341,.297,.387,.345,.431,.339,.475,.333,.477,.259,.528,.235,.579,.211,.597,.142,.55,.148,.513,.154,.413,.1,.453,.053,.494,.005,.545,-.049,.611,-.054,.622,-.054,.633,-.049,.64,-.041],['Z']]
        [['M',.04,.931],['C',.062,.91,.085,.882,.096,.871,.106,.861,.104,.862,.117,.864,.13,.866,.132,.866,.146,.863,.16,.861,.165,.859,.175,.866,.186,.873,.198,.885,.228,.915,.258,.944,.264,.919,.263,.895],['L',.263,.895],['C',.263,.888,.257,.874,.252,.853,.246,.833,.245,.822,.24,.803,.235,.785,.229,.782,.229,.777,.228,.74,.225,.73,.24,.714,.248,.706,.277,.682,.287,.669,.296,.657,.333,.64,.356,.632,.38,.624,.36,.637,.463,.595,.565,.553,.661,.409,.65,.308,.639,.207,.65,.172,.652,.152,.654,.131,.66,.124,.695,.108,.715,.099,.741,.104,.807,.104,.88,.104,.951,.124,.951,.198,.951,.271,.913,.317,.871,.318,.804,.319,.844,.352,.876,.351,.921,.349,1,.299,1,.195,1,.13,.961,.059,.808,.048,.654,.038,.61,.062,.602,.063,.594,.064,.577,.06,.551,.063,.526,.066,.509,.069,.5,.069,.492,.07,.494,.062,.417,.068,.34,.073,.337,.086,.336,.102,.335,.117,.351,.124,.351,.124],['S',.314,.158,.305,.215],['C',.297,.266,.301,.297,.301,.297],['S',.288,.27,.28,.205],['C',.277,.18,.263,.14,.249,.111,.237,.084,.184,.082,.168,.083,.134,.085,.132,.113,.143,.122,.155,.132,.179,.145,.184,.147,.19,.149,.192,.166,.195,.179,.198,.192,.196,.303,.196,.314],['S',.2,.317,.194,.325],['C',.187,.334,.179,.349,.16,.38,.142,.411,.139,.398,.106,.449,.074,.5,.074,.518,.076,.552,.077,.569,.077,.569,.077,.588],['S',.079,.607,.074,.616],['C',.069,.625,.06,.658,.056,.689,.052,.719,.036,.748,.033,.772,.028,.799,.021,.788,.019,.807,.015,.84,0,.872,0,.909,0,.946,.018,.952,.04,.931],['Z']]
        [['M',.118,.845],['C',.12,.844,.135,.83,.138,.829,.14,.828,.149,.824,.151,.822,.153,.819,.16,.814,.162,.812,.164,.811,.169,.808,.173,.807,.177,.806,.185,.804,.19,.8,.196,.796,.206,.787,.208,.786,.209,.785,.215,.781,.218,.781,.222,.781,.227,.781,.231,.778,.236,.775,.242,.77,.246,.769,.249,.767,.255,.765,.26,.764,.266,.763,.275,.761,.279,.76,.284,.758,.303,.754,.309,.753,.314,.751,.328,.747,.33,.746,.331,.745,.336,.743,.336,.743],['S',.348,.745,.351,.746],['C',.353,.746,.369,.752,.37,.754,.371,.756,.378,.76,.38,.762,.382,.764,.388,.767,.392,.77,.395,.773,.399,.778,.405,.779,.41,.781,.415,.784,.421,.785,.426,.785,.433,.786,.438,.787,.443,.788,.449,.791,.452,.791,.455,.792,.449,.794,.45,.796,.451,.798,.454,.8,.457,.801],['S',.467,.804,.47,.804],['C',.472,.803,.475,.8,.475,.8],['S',.484,.802,.486,.803],['C',.488,.804,.496,.807,.498,.808],['S',.507,.81,.507,.81],['L',.529,.797,.546,.792],['S',.569,.783,.575,.775],['C',.582,.767,.585,.762,.586,.761],['S',.591,.758,.597,.755],['C',.603,.753,.608,.753,.614,.75,.619,.748,.634,.743,.636,.741,.638,.739,.684,.753,.684,.753],['S',.693,.762,.71,.753],['C',.726,.744,.754,.723,.755,.72,.757,.718,.785,.688,.785,.688],['L',.801,.675,.815,.661,.82,.662],['S',.873,.603,.883,.582],['C',.894,.562,.9,.526,.899,.512,.899,.498,.895,.481,.893,.473,.891,.465,.889,.457,.888,.454,.887,.452,.885,.434,.887,.426,.89,.418,.888,.415,.891,.411],['S',.909,.405,.913,.4],['C',.918,.396,.933,.379,.935,.374,.938,.369,.955,.34,.956,.333,.956,.327,.961,.318,.958,.314],['S',.958,.305,.955,.299,.947,.275,.943,.272],['C',.939,.268,.94,.268,.936,.264,.933,.261,.92,.245,.913,.245],['S',.867,.243,.859,.245],['C',.851,.247,.829,.253,.819,.259,.81,.266,.8,.269,.793,.277,.787,.284,.758,.301,.755,.305,.753,.31,.746,.318,.743,.323,.741,.328,.74,.336,.729,.338,.718,.341,.719,.343,.713,.342,.708,.34,.705,.343,.705,.343],['L',.71,.35,.714,.355],['S',.72,.358,.722,.357],['C',.724,.356,.717,.365,.717,.365],['S',.705,.37,.696,.376],['C',.688,.382,.687,.385,.682,.388,.677,.392,.675,.391,.671,.396],['S',.665,.401,.662,.406],['C',.659,.41,.659,.411,.653,.414],['S',.639,.42,.638,.421,.631,.422,.629,.424],['C',.626,.426,.622,.43,.622,.43],['L',.625,.438],['S',.598,.458,.594,.46],['C',.59,.463,.579,.471,.578,.473,.576,.475,.561,.485,.559,.484,.557,.484,.546,.483,.546,.483],['L',.535,.479,.532,.475,.537,.42],['S',.56,.407,.564,.402],['C',.567,.396,.564,.392,.562,.392,.559,.391,.55,.394,.55,.394],['L',.54,.399,.542,.374,.551,.269,.554,.237,.559,.23,.564,.222,.568,.218],['S',.562,.21,.562,.21,.559,.203,.559,.203,.567,.2,.564,.198],['C',.562,.195,.557,.195,.557,.195],['L',.556,.188],['S',.562,.184,.56,.182],['C',.557,.179,.554,.179,.554,.179],['L',.553,.17],['S',.56,.165,.558,.163],['C',.556,.162,.552,.163,.552,.163],['L',.551,.154],['S',.559,.151,.556,.149],['C',.554,.148,.55,.148,.55,.148],['L',.549,.139],['S',.556,.132,.552,.13],['C',.548,.129,.546,.129,.546,.129],['S',.54,.121,.536,.121],['C',.532,.121,.528,.122,.525,.125,.521,.128,.515,.127,.515,.133,.516,.14,.515,.146,.518,.149],['S',.524,.153,.522,.156],['C',.521,.159,.511,.175,.512,.18,.513,.184,.52,.206,.52,.207,.521,.209,.523,.232,.523,.232],['L',.521,.27,.514,.316,.505,.385,.497,.384],['S',.49,.383,.488,.386],['C',.487,.39,.486,.394,.485,.396,.484,.397,.481,.403,.481,.403],['S',.476,.409,.475,.411,.471,.418,.473,.418],['C',.474,.418,.466,.422,.464,.423,.462,.423,.455,.424,.455,.428,.456,.431,.459,.436,.46,.437,.461,.438,.47,.45,.47,.45],['S',.467,.475,.468,.477],['C',.47,.48,.482,.5,.482,.5],['L',.478,.535,.465,.544],['S',.456,.546,.452,.538],['L',.442,.52],['C',.441,.518,.439,.502,.437,.499,.436,.495,.432,.489,.428,.488,.425,.488,.422,.487,.417,.49],['S',.41,.495,.408,.497],['C',.406,.499,.397,.507,.397,.507],['S',.393,.517,.392,.521],['C',.391,.525,.4,.572,.401,.578,.402,.585,.402,.586,.402,.585,.402,.584,.385,.581,.385,.581],['L',.296,.547],['S',.284,.542,.282,.542],['C',.281,.542,.27,.54,.264,.542,.259,.543,.252,.544,.247,.547,.242,.55,.202,.574,.198,.578,.193,.582,.186,.589,.181,.593,.176,.598,.167,.608,.16,.613,.154,.618,.133,.633,.132,.634,.13,.635,.125,.64,.12,.643],['S',.089,.664,.086,.667,.067,.681,.065,.682,.054,.686,.05,.688],['L',.045,.69,.037,.697,.118,.845],['Z']]
        [['M',.882,.458],['S',.886,.445,.886,.44],['C',.885,.435,.88,.421,.881,.42,.881,.419,.886,.412,.886,.412],['L',.902,.408],['S',.918,.405,.927,.394],['C',.937,.383,.94,.384,.942,.382,.945,.381,.958,.372,.959,.371],['S',.978,.361,.981,.339],['C',.984,.317,.981,.308,.977,.302],['S',.96,.28,.952,.276,.928,.271,.921,.272],['C',.915,.273,.907,.278,.904,.281],['S',.896,.288,.895,.289,.889,.292,.889,.292],['L',.878,.288,.876,.291],['S',.872,.293,.871,.294],['C',.871,.296,.869,.298,.868,.298,.868,.299,.865,.302,.865,.302],['L',.863,.304],['S',.86,.301,.857,.301],['C',.854,.301,.852,.3,.849,.3,.847,.3,.844,.3,.844,.3],['L',.838,.291,.832,.284,.831,.281],['S',.831,.278,.827,.279],['C',.823,.281,.821,.282,.819,.283,.817,.284,.813,.287,.812,.287],['S',.807,.29,.807,.29],['L',.803,.288,.798,.286,.794,.285],['S',.789,.28,.788,.278],['C',.786,.277,.78,.273,.78,.273],['L',.768,.264,.757,.261],['S',.748,.259,.742,.258],['C',.737,.257,.728,.255,.723,.256,.717,.257,.71,.258,.708,.258,.707,.258,.67,.258,.661,.257],['S',.648,.257,.645,.257,.637,.258,.636,.258],['C',.634,.257,.612,.25,.612,.25],['L',.606,.249],['S',.603,.248,.604,.246],['C',.604,.243,.601,.24,.601,.24],['L',.605,.232,.614,.214,.616,.206],['S',.617,.199,.618,.198],['C',.618,.197,.628,.184,.629,.183,.63,.182,.638,.173,.639,.17,.64,.167,.642,.161,.637,.159,.631,.158,.627,.158,.625,.16,.623,.162,.62,.163,.617,.166,.614,.169,.608,.175,.607,.176,.606,.178,.604,.181,.603,.182,.603,.183,.6,.19,.6,.19],['L',.595,.188],['S',.592,.185,.592,.184],['C',.593,.183,.593,.179,.591,.178,.589,.178,.586,.174,.585,.173,.584,.171,.581,.166,.581,.165,.581,.165,.579,.159,.579,.159],['S',.579,.155,.572,.147],['C',.564,.138,.561,.133,.561,.133],['S',.558,.128,.555,.129],['C',.553,.129,.552,.129,.55,.13,.547,.131,.546,.131,.545,.132,.545,.134,.544,.135,.544,.135],['S',.536,.13,.532,.134],['C',.527,.138,.526,.144,.533,.156,.54,.167,.539,.169,.539,.169],['L',.542,.176,.544,.18,.544,.181],['S',.536,.175,.532,.177],['C',.529,.18,.526,.18,.526,.183,.525,.187,.525,.196,.525,.196],['L',.525,.198],['S',.52,.205,.519,.207],['C',.517,.21,.516,.215,.516,.217,.516,.219,.522,.24,.522,.241],['S',.528,.251,.531,.251],['C',.533,.252,.538,.249,.538,.249],['S',.539,.25,.538,.257],['C',.537,.264,.536,.266,.533,.268],['S',.526,.272,.53,.284],['C',.534,.296,.536,.303,.537,.305,.538,.308,.54,.313,.542,.314,.544,.315,.552,.318,.554,.321,.556,.325,.557,.33,.561,.331,.565,.331,.588,.34,.592,.342,.595,.344,.606,.352,.609,.352,.612,.352,.626,.354,.631,.35],['S',.643,.345,.643,.345,.639,.359,.639,.359,.636,.365,.636,.366],['C',.635,.367,.625,.373,.625,.373],['S',.618,.376,.614,.379],['C',.611,.381,.607,.385,.607,.385],['L',.6,.391],['S',.57,.399,.56,.402],['C',.551,.405,.542,.408,.542,.408],['S',.525,.415,.524,.416],['C',.522,.418,.516,.422,.516,.422],['S',.503,.424,.499,.425],['C',.496,.426,.487,.427,.478,.431],['S',.47,.432,.466,.437],['C',.463,.442,.46,.448,.459,.45,.457,.452,.453,.456,.453,.456],['S',.445,.456,.446,.461,.445,.471,.445,.471],['L',.419,.478],['S',.393,.486,.387,.489],['C',.38,.492,.375,.494,.373,.496,.37,.499,.366,.504,.362,.505,.359,.506,.345,.511,.344,.512,.343,.512,.334,.513,.326,.516,.319,.52,.317,.521,.312,.526,.306,.53,.301,.533,.297,.536,.293,.539,.288,.544,.285,.546],['S',.273,.551,.271,.552],['C',.27,.553,.236,.569,.232,.571,.227,.572,.216,.578,.215,.578],['S',.197,.586,.197,.586,.18,.592,.173,.595],['C',.167,.599,.167,.6,.164,.601],['S',.16,.603,.154,.605,.14,.613,.14,.613,.131,.618,.13,.618],['C',.129,.619,.122,.624,.122,.624],['L',.117,.628],['S',.113,.625,.112,.625,.107,.626,.107,.626,.103,.63,.102,.631,.099,.634,.098,.634],['C',.096,.634,.094,.635,.092,.637,.09,.638,.087,.64,.087,.64],['S',.083,.641,.083,.641],['L',.064,.639],['S',.05,.631,.034,.63,.014,.631,.009,.633,-.001,.639,-.001,.641],['C',-.002,.642,-.001,.672,.03,.682,.03,.682,.051,.683,.054,.683,.057,.683,.079,.686,.082,.687,.084,.687,.091,.691,.092,.692,.093,.692,.111,.705,.116,.705,.12,.705,.126,.707,.129,.705,.133,.704,.137,.703,.137,.703],['S',.139,.701,.142,.701],['C',.144,.701,.149,.7,.149,.7],['S',.159,.688,.16,.687],['C',.161,.687,.163,.686,.163,.686],['S',.174,.686,.175,.686],['C',.176,.686,.186,.681,.187,.68,.187,.68,.235,.662,.24,.66,.245,.658,.254,.654,.256,.653,.259,.653,.278,.647,.278,.647],['S',.334,.638,.338,.637],['C',.342,.636,.38,.629,.383,.628],['S',.415,.622,.417,.622],['C',.42,.621,.44,.617,.44,.617],['L',.443,.621,.439,.631],['S',.415,.667,.414,.669],['C',.412,.672,.403,.686,.401,.689,.399,.692,.394,.704,.393,.705,.393,.706,.382,.726,.382,.727,.382,.728,.376,.735,.376,.735],['S',.371,.749,.37,.75],['C',.37,.751,.363,.762,.363,.762],['L',.361,.767,.36,.769,.35,.774],['S',.345,.78,.344,.781],['C',.343,.782,.336,.786,.333,.79,.33,.793,.325,.801,.322,.803,.319,.805,.304,.818,.303,.818],['S',.289,.835,.288,.836,.278,.848,.278,.848],['L',.273,.851,.267,.854],['S',.262,.854,.257,.858,.251,.864,.251,.865,.243,.869,.241,.879],['C',.239,.89,.241,.898,.244,.903,.248,.909,.254,.916,.253,.92],['S',.247,.954,.246,.956],['C',.245,.957,.242,.98,.242,.981,.242,.982,.251,1.003,.258,1.01,.264,1.018,.272,1.019,.278,1.014,.284,1.009,.287,1.001,.288,.997,.288,.993,.293,.979,.293,.979],['L',.294,.958,.295,.941,.298,.934,.3,.93],['S',.305,.919,.305,.918],['C',.305,.918,.307,.913,.307,.913],['L',.313,.912],['S',.322,.912,.323,.912],['C',.324,.912,.339,.9,.344,.896,.349,.891,.365,.879,.366,.879],['S',.377,.87,.377,.87],['L',.387,.859,.399,.849],['S',.408,.839,.411,.834],['C',.413,.829,.417,.825,.417,.825],['S',.428,.817,.43,.814],['C',.432,.811,.457,.788,.456,.788,.455,.789,.465,.778,.467,.776],['S',.483,.766,.483,.766],['L',.504,.754],['S',.524,.735,.527,.731],['C',.53,.727,.536,.721,.538,.719],['S',.549,.704,.55,.703,.559,.693,.559,.693,.561,.692,.561,.693,.56,.698,.56,.698],['L',.562,.702],['S',.574,.701,.575,.701],['C',.576,.701,.588,.695,.588,.696,.588,.696,.586,.684,.586,.684],['L',.585,.677,.588,.667,.591,.654],['S',.597,.654,.599,.653,.627,.629,.637,.616,.653,.597,.654,.596],['C',.656,.595,.676,.579,.676,.579],['L',.695,.562,.718,.545],['S',.715,.557,.715,.557],['C',.714,.558,.715,.573,.716,.576,.716,.578,.719,.587,.719,.587],['S',.741,.592,.742,.592],['C',.743,.591,.746,.59,.746,.59],['L',.753,.589,.766,.589,.797,.581,.802,.58,.807,.574,.821,.553,.837,.531],['S',.855,.505,.856,.502],['C',.858,.5,.862,.496,.862,.496],['L',.867,.49,.868,.486,.874,.48],['S',.879,.472,.88,.468],['C',.881,.465,.882,.458,.882,.458],['Z']]
        [['M',.918,.22],['C',.9,.186,.875,.154,.841,.125,.81,.123,.814,.109,.78,.121,.69,.156,.588,.198,.505,.256,.382,.139,.285,.095,.276,.103,.266,.11,.335,.182,.443,.309],['L',.422,.324,.407,.341,.401,.354,.379,.367,.346,.372,.364,.404],['C',.359,.406,.356,.412,.351,.407,.348,.404,.344,.39,.341,.392,.318,.405,.289,.411,.264,.414,.228,.373,.208,.384,.18,.373,.21,.453,.249,.498,.183,.624,.17,.684,.129,.753,.152,.804,.17,.842,.166,.882,.163,.912],['L',.169,.952],['C',.183,.943,.22,.89,.236,.881,.285,.852,.336,.819,.326,.753],['L',.305,.666,.345,.666],['C',.355,.701,.377,.773,.424,.765,.436,.76,.448,.755,.453,.742,.463,.741,.477,.745,.486,.732],['L',.491,.72,.504,.723,.53,.703,.552,.734],['C',.558,.741,.566,.743,.578,.738],['L',.603,.692,.626,.641],['C',.638,.649,.648,.648,.663,.646,.674,.637,.685,.627,.696,.617,.793,.743,.856,.833,.865,.825,.873,.818,.837,.707,.758,.572,.799,.505,.862,.448,.914,.397,.931,.365,.938,.326,.934,.306,.927,.279,.932,.245,.918,.22],['Z']]
        [['M',.529,.184],['C',.496,.15,.438,.149,.409,.119,.406,.115,.405,.111,.41,.106,.415,.101,.419,.096,.426,.094,.464,.052,.569,.086,.61,.107,.628,.118,.644,.122,.667,.143,.712,.164,.754,.201,.797,.232,.806,.24,.813,.246,.819,.253,.825,.256,.832,.257,.838,.266,.842,.264,.842,.259,.85,.261,.855,.262,.858,.259,.867,.268,.884,.279,.897,.32,.911,.347,.918,.351,.924,.354,.928,.366,.933,.369,.932,.373,.931,.376,.931,.379,.93,.379,.929,.38,.97,.45,1.001,.525,1.035,.598,1.031,.6,1.034,.613,1.034,.622,1.036,.629,1.019,.638,1.039,.641,1.05,.646,1.054,.654,1.055,.662,1.043,.692,1.021,.685,1.013,.682,1.003,.676,1.005,.668,1.005,.66,1.017,.638,1.002,.644,.996,.641,.989,.638,.985,.63,.979,.624,.97,.63,.964,.628,.957,.629,.938,.623,.929,.641,.916,.651,.897,.67,.879,.682,.863,.673,.83,.652,.851,.624,.855,.618,.844,.614,.834,.609,.825,.6,.799,.628,.773,.651,.744,.632,.709,.654,.675,.674,.641,.694,.627,.712,.641,.729,.583,.749,.565,.76,.555,.769,.559,.795,.588,.781,.588,.798,.596,.805,.598,.822,.613,.838,.561,.858,.549,.859,.539,.849,.522,.888,.517,.895,.508,.892,.508,.91,.509,.915,.509,.921,.505,.924,.497,.929,.499,.934,.509,.938,.513,.94,.528,.944,.515,.965,.513,.967,.499,.98,.481,.969,.473,.954,.479,.953,.48,.948,.488,.94,.481,.936,.471,.932,.468,.932,.466,.929,.465,.925,.464,.922,.463,.918,.448,.91,.44,.915,.436,.93,.431,.94,.424,.947,.413,.944,.401,.936,.391,.928,.388,.941,.382,.944,.362,.975,.319,.959,.314,.949,.293,.968,.262,.951,.249,.941,.234,.93,.21,.896,.206,.909,.192,.916,.182,.908,.17,.906,.16,.893,.153,.879,.133,.872,.13,.876,.134,.882,.118,.884],['L',.119,.888],['C',.138,.897,.131,.912,.131,.914,.12,.939,.099,.931,.089,.926,.076,.897,.087,.895,.089,.89,.101,.886,.092,.883,.087,.875,.084,.868,.086,.859,.076,.853,.065,.766,.088,.637,.094,.529,.063,.51,-.006,.515,-.011,.497,-.008,.486,-.006,.485,-.004,.48,.069,.433,.139,.435,.208,.451,.314,.362,.418,.274,.529,.184],['Z'],['M',.323,.914],['C',.316,.903,.305,.9,.293,.899,.29,.906,.285,.912,.288,.917,.293,.908,.312,.913,.313,.922,.313,.919,.321,.913,.323,.914],['Z']]
        [['M',.994,.288],['C',.999,.291,1.008,.296,1.007,.302,1.006,.314,.996,.331,.986,.342,.974,.356,.951,.363,.941,.377,.942,.382,.942,.399,.938,.409,.929,.418,.922,.432,.911,.44,.898,.45,.882,.461,.869,.468,.861,.489,.844,.504,.839,.505,.837,.505,.841,.51,.839,.512,.836,.513,.827,.516,.822,.52,.821,.521,.823,.525,.821,.525,.82,.526,.808,.527,.805,.529,.788,.523,.784,.525,.771,.528,.76,.535,.744,.548,.726,.542,.71,.536,.693,.521,.677,.512,.668,.507,.666,.499,.665,.499,.66,.507,.648,.507,.647,.507,.646,.51,.645,.512,.643,.515,.642,.515,.641,.516,.638,.515,.633,.515,.615,.518,.607,.523,.604,.529,.586,.558,.582,.566,.577,.573,.566,.594,.557,.602,.557,.62,.545,.631,.538,.643,.533,.656,.53,.672,.527,.683,.524,.697,.531,.717,.535,.721,.533,.723,.511,.747,.511,.747,.51,.752,.51,.785,.502,.804,.493,.826,.5,.827,.497,.837,.48,.896,.441,.928,.415,.974,.413,.976,.413,.981,.412,.984,.406,.991,.399,.997,.393,1.001,.386,1.005,.373,1.007,.371,1.013,.368,1.023,.362,1.036,.357,1.044,.355,1.047,.349,1.048,.35,1.039,.35,1.032,.352,1.03,.354,1.027,.355,1.02,.359,1.013,.363,1.007,.363,1.007,.363,1.005,.362,1.005,.35,1.009,.339,1.019,.328,1.022,.322,1.024,.323,1.018,.325,1.016,.332,1.006,.345,.999,.345,.998,.343,.999,.339,1.002,.338,1.002,.337,1.003,.337,1.004,.334,1.006,.327,1.011,.33,1.01,.325,1.012,.322,1.013,.318,1.008,.321,1.004,.323,1.002,.328,.999,.33,.996,.33,.994,.332,.99,.335,.987,.341,.979,.347,.973,.354,.966,.355,.964,.355,.961,.359,.96,.368,.956,.378,.957,.389,.954,.391,.954,.396,.952,.397,.95,.406,.933,.417,.916,.422,.897,.428,.872,.434,.853,.437,.843,.441,.831,.444,.827,.449,.817,.455,.805,.453,.791,.454,.778,.455,.777,.453,.776,.453,.776,.454,.772,.456,.766,.456,.762,.456,.76,.455,.758,.455,.757,.455,.753,.456,.752,.457,.747,.457,.746,.455,.743,.455,.741,.454,.739,.455,.737,.455,.735,.454,.733,.452,.731,.452,.728,.452,.727,.453,.726,.453,.726,.451,.717,.447,.709,.447,.701,.447,.699,.449,.697,.446,.693,.443,.688,.445,.675,.442,.673,.439,.677,.436,.686,.431,.683,.429,.682,.429,.688,.428,.688,.43,.688,.429,.688,.43,.689,.429,.69,.423,.699,.422,.701,.422,.702,.424,.701,.424,.702,.423,.704,.42,.707,.419,.709,.419,.71,.421,.709,.42,.71,.42,.711,.42,.716,.419,.717,.418,.718,.413,.719,.411,.72,.389,.73,.365,.734,.341,.716,.337,.713,.335,.707,.331,.704,.327,.701,.32,.702,.317,.699,.318,.699,.318,.698,.32,.697,.318,.696,.313,.689,.314,.687],['L',.316,.686],['C',.313,.678,.312,.671,.311,.664],['L',.314,.665,.315,.65,.32,.642],['C',.322,.639,.322,.636,.324,.633,.325,.631,.327,.629,.328,.628,.33,.626,.333,.624,.335,.623,.338,.62,.342,.618,.345,.616,.347,.615,.348,.613,.349,.612,.347,.61,.34,.609,.336,.607,.334,.605,.339,.603,.337,.601,.322,.597,.323,.593,.321,.592,.314,.595,.31,.593,.307,.59,.301,.585,.289,.583,.284,.582,.278,.581,.249,.574,.241,.574],['L',.241,.572],['C',.229,.572,.219,.572,.206,.576,.161,.589,.11,.609,.071,.633,.063,.638,.07,.653,.068,.662,.065,.672,.059,.68,.056,.689,.055,.693,.057,.697,.056,.7,.055,.702,.051,.702,.049,.699,.049,.699,.049,.698,.048,.697,.049,.7,.046,.705,.042,.708,.037,.711,.03,.714,.025,.716,.023,.716,.02,.717,.019,.716,.017,.715,.016,.712,.018,.71,.018,.71,.019,.708,.019,.708,.015,.71,.009,.711,.006,.711,.003,.711,0,.706,.003,.704,.006,.702,.022,.695,.021,.692,.015,.694,.004,.701,-.003,.702,-.007,.702,-.008,.694,-.004,.693,.001,.689,.01,.687,.015,.682,.019,.678,.024,.668,.023,.666,.02,.668,.015,.673,.011,.675,.007,.677,.002,.681,-.001,.682,-.007,.684,-.006,.678,-.005,.676,-.004,.674,0,.671,.003,.669,.005,.668,.007,.667,.009,.666,.012,.662,.017,.659,.018,.654,.021,.637,.03,.624,.042,.612,.045,.61,.05,.609,.053,.607,.093,.574,.136,.55,.178,.53,.182,.528,.185,.525,.189,.523,.195,.522,.202,.524,.208,.523,.231,.52,.259,.521,.274,.521],['L',.297,.493],['C',.3,.491,.305,.498,.309,.499,.311,.5,.313,.498,.315,.498,.326,.499,.337,.501,.347,.5,.357,.5,.368,.498,.377,.493,.398,.48,.418,.463,.437,.445,.443,.439,.447,.43,.453,.423,.457,.42,.463,.419,.467,.415,.469,.414,.469,.411,.471,.409,.474,.405,.478,.403,.481,.399,.482,.397,.482,.394,.483,.392,.485,.39,.488,.388,.489,.385,.491,.383,.492,.381,.492,.379,.493,.373,.494,.366,.492,.361,.49,.355,.48,.35,.48,.345,.479,.338,.488,.331,.491,.323,.495,.316,.499,.309,.502,.302,.503,.3,.505,.297,.505,.295,.497,.274,.48,.252,.478,.233,.477,.227,.493,.224,.496,.218,.5,.209,.495,.196,.498,.187,.499,.181,.506,.178,.508,.173,.51,.169,.507,.163,.509,.16,.516,.152,.528,.146,.536,.138,.541,.134,.543,.125,.548,.122,.551,.119,.556,.121,.56,.12,.582,.114,.603,.106,.624,.1,.637,.097,.65,.093,.663,.093,.667,.093,.671,.101,.675,.1,.684,.099,.693,.09,.701,.085,.717,.075,.734,.057,.748,.056,.761,.055,.772,.07,.771,.079,.77,.096,.753,.123,.74,.137,.733,.144,.721,.141,.714,.148,.707,.156,.708,.168,.702,.177,.694,.187,.684,.197,.673,.201,.667,.203,.658,.199,.653,.195,.648,.192,.647,.183,.644,.179,.642,.178,.639,.178,.638,.179,.636,.18,.635,.184,.634,.185,.627,.19,.62,.195,.612,.199,.611,.2,.609,.198,.608,.199,.607,.199,.605,.2,.606,.201,.606,.204,.61,.207,.61,.209,.611,.211,.609,.212,.609,.213,.619,.232,.633,.25,.642,.27,.651,.289,.652,.312,.662,.331,.667,.341,.676,.349,.685,.356,.698,.366,.713,.373,.727,.382,.742,.392,.759,.399,.773,.411,.777,.415,.776,.425,.78,.429,.782,.43,.787,.427,.79,.426,.796,.424,.802,.42,.808,.417,.809,.417,.811,.418,.812,.418,.818,.414,.826,.41,.83,.405,.833,.399,.832,.391,.835,.385,.837,.381,.842,.379,.846,.375,.849,.372,.852,.369,.856,.366,.859,.364,.862,.365,.864,.362,.868,.356,.865,.348,.87,.343,.877,.335,.889,.325,.901,.325,.908,.324,.914,.326,.918,.321,.923,.315,.925,.308,.93,.303,.935,.296,.943,.29,.951,.288,.965,.285,.982,.282,.994,.288],['Z']]
        [['M',.598,.389],['C',.611,.369,.635,.328,.635,.328,.649,.306,.662,.284,.675,.262,.682,.249,.697,.222,.697,.222,.701,.216,.704,.209,.706,.202,.707,.199,.707,.192,.707,.192,.707,.185,.713,.179,.718,.172,.722,.166,.732,.155,.732,.155,.735,.152,.739,.151,.743,.149,.751,.143,.759,.137,.765,.129,.769,.123,.774,.111,.774,.111,.776,.108,.774,.105,.773,.102,.773,.099,.772,.096,.77,.094,.769,.092,.767,.09,.765,.088,.763,.087,.761,.087,.76,.087,.759,.087,.756,.088,.756,.088,.754,.088,.756,.083,.756,.081,.755,.078,.752,.073,.752,.073,.751,.07,.748,.068,.746,.066,.744,.065,.74,.063,.74,.063,.739,.063,.737,.062,.736,.062,.734,.061,.729,.06,.729,.06,.727,.06,.729,.055,.728,.052,.728,.05,.725,.045,.725,.045,.724,.043,.72,.043,.717,.043,.714,.043,.708,.045,.708,.045,.704,.046,.703,.053,.7,.056,.697,.058,.693,.059,.692,.061,.692,.061,.687,.067,.686,.07,.684,.075,.685,.079,.685,.084,.685,.084,.685,.096,.683,.102,.682,.109,.68,.115,.677,.122,.674,.129,.671,.135,.667,.142,.66,.155,.646,.179,.646,.179,.638,.193,.63,.206,.621,.22,.609,.238,.584,.272,.584,.272,.579,.28,.574,.287,.569,.293,.565,.298,.562,.302,.558,.306,.555,.31,.547,.316,.547,.316,.544,.319,.538,.319,.534,.32,.528,.321,.517,.323,.517,.323,.511,.324,.506,.324,.5,.324,.495,.324,.487,.323,.487,.323,.484,.322,.482,.32,.48,.318,.475,.315,.466,.31,.466,.31,.462,.308,.457,.306,.456,.301,.455,.299,.459,.294,.459,.294],['L',.471,.274],['C',.475,.267,.479,.259,.483,.252,.488,.244,.497,.228,.497,.228,.502,.219,.507,.21,.512,.201,.517,.193,.527,.178,.527,.178,.53,.173,.533,.169,.536,.164,.538,.162,.542,.156,.542,.156,.543,.154,.544,.151,.545,.148,.546,.145,.546,.138,.546,.138,.547,.133,.552,.13,.554,.125,.557,.121,.561,.116,.561,.111,.562,.106,.558,.098,.558,.098,.557,.095,.559,.092,.56,.089,.562,.084,.565,.074,.565,.074,.566,.069,.566,.064,.566,.059,.566,.055,.565,.046,.565,.046,.565,.043,.563,.04,.56,.038,.558,.036,.554,.034,.552,.033,.55,.032,.545,.031,.542,.032,.54,.033,.54,.037,.537,.037,.535,.037,.535,.032,.535,.032,.533,.026,.529,.02,.525,.015,.522,.012,.519,.009,.515,.008,.512,.007,.509,.008,.506,.009,.505,.009,.504,.01,.503,.012,.502,.014,.501,.018,.501,.018,.501,.019,.498,.018,.497,.018,.495,.019,.492,.021,.492,.021,.49,.023,.489,.024,.489,.026,.488,.029,.489,.034,.489,.034,.489,.043,.493,.052,.495,.06,.497,.067,.502,.08,.502,.08,.503,.085,.505,.089,.505,.094,.505,.1,.501,.112,.501,.112,.5,.119,.496,.125,.492,.13,.483,.147,.458,.177,.458,.177,.451,.186,.444,.195,.435,.204,.43,.21,.423,.215,.416,.221,.416,.221,.408,.23,.403,.234,.399,.238,.395,.242,.391,.246,.386,.25,.383,.256,.378,.261,.374,.264,.366,.269,.366,.269,.36,.273,.353,.276,.346,.278,.34,.28,.328,.283,.328,.283,.321,.284,.314,.287,.308,.291,.302,.294,.292,.303,.292,.303,.284,.31,.28,.321,.274,.33,.265,.343,.247,.368,.247,.368,.24,.378,.23,.384,.222,.392,.216,.399,.211,.407,.206,.414,.206,.414,.191,.438,.182,.448,.178,.453,.174,.457,.169,.461,.169,.461,.154,.474,.146,.481,.142,.485,.134,.492,.134,.492],['S',.13,.497,.128,.5],['C',.121,.507,.114,.515,.107,.522,.101,.529,.095,.536,.089,.543,.085,.548,.081,.554,.075,.558,.072,.561,.069,.563,.065,.563,.065,.563,.055,.564,.05,.564,.042,.564,.033,.562,.025,.561,.018,.56,.012,.559,.006,.559,0,.558,-.006,.557,-.012,.558,-.012,.558,-.025,.557,-.03,.559,-.034,.56,-.037,.562,-.041,.564],['L',-.056,.574],['C',-.059,.576,-.062,.576,-.065,.578,-.067,.579,-.069,.581,-.07,.583,-.072,.586,-.072,.591,-.074,.594,-.076,.598,-.085,.603,-.085,.603,-.088,.606,-.088,.611,-.088,.615,-.088,.616,-.088,.618,-.088,.618,-.088,.623,-.095,.625,-.097,.63,-.098,.632,-.098,.637,-.098,.637,-.098,.639,-.098,.641,-.097,.643,-.095,.646,-.087,.651,-.087,.651,-.081,.657,-.073,.66,-.065,.664,-.06,.667,-.049,.674,-.049,.674,-.042,.677,-.037,.681,-.03,.684,-.026,.686,-.02,.686,-.015,.688,-.014,.689,-.012,.689,-.012,.691,-.012,.693,-.017,.697,-.017,.697],['S',-.02,.702,-.02,.705],['C',-.021,.71,-.019,.72,-.019,.72,-.019,.724,-.015,.727,-.012,.73,-.009,.733,0,.737,0,.737,.002,.739,.004,.74,.006,.742,.012,.749,.019,.765,.019,.765,.025,.776,.037,.782,.047,.789,.061,.799,.074,.809,.089,.816,.096,.819,.109,.823,.109,.823,.112,.824,.115,.822,.118,.821,.121,.82,.123,.817,.126,.816,.13,.816,.133,.82,.137,.821,.141,.823,.148,.824,.148,.824,.152,.826,.157,.822,.161,.822,.168,.821,.181,.82,.181,.82,.187,.819,.193,.814,.198,.813],['S',.206,.812,.209,.81],['C',.214,.807,.216,.801,.22,.798,.222,.797,.225,.798,.227,.797,.231,.795,.236,.789,.236,.789,.24,.785,.244,.779,.247,.773,.248,.77,.249,.763,.249,.763,.25,.76,.25,.756,.251,.753,.251,.751,.25,.749,.251,.747,.252,.744,.259,.74,.259,.74,.269,.732,.276,.719,.286,.71,.293,.703,.309,.691,.309,.691,.314,.686,.323,.688,.33,.688,.334,.689,.343,.692,.343,.692,.348,.693,.353,.698,.356,.699,.359,.7,.366,.707,.37,.711,.375,.716,.379,.722,.382,.728,.386,.733,.392,.743,.392,.743,.397,.751,.401,.759,.407,.766,.412,.772,.419,.777,.426,.782],['L',.503,.838],['C',.517,.848,.532,.856,.545,.867,.547,.868,.552,.877,.556,.883],['S',.561,.894,.564,.9],['L',.576,.925],['S',.585,.938,.589,.944],['C',.594,.95,.598,.957,.604,.961,.609,.966,.629,.983,.622,.978,.62,.976,.63,.984,.635,.986,.639,.988,.647,.99,.647,.99,.65,.991,.654,.99,.657,.989,.66,.987,.661,.984,.662,.981,.663,.979,.663,.977,.664,.975,.664,.971,.664,.968,.662,.965,.66,.959,.655,.955,.651,.95,.647,.943,.645,.934,.638,.93,.631,.925,.63,.922,.628,.914,.627,.909,.623,.899,.623,.899,.621,.893,.62,.886,.619,.88,.618,.875,.617,.864,.617,.864,.616,.856,.613,.848,.61,.84,.606,.834,.597,.821,.597,.821,.594,.817,.593,.812,.59,.808,.588,.805,.584,.8,.584,.8,.575,.79,.6,.781,.61,.773,.618,.765,.633,.749,.633,.749,.64,.741,.647,.733,.654,.724,.659,.717,.664,.709,.668,.701,.671,.695,.672,.689,.676,.683,.677,.681,.681,.677,.681,.677,.686,.672,.697,.667,.699,.666,.7,.664,.712,.659,.717,.654,.717,.654,.728,.641,.733,.634,.744,.621,.763,.593,.763,.593,.766,.588,.773,.581,.774,.58,.776,.578,.787,.568,.789,.567,.791,.565,.804,.553,.807,.551,.809,.548,.822,.541,.829,.536,.837,.53,.845,.524,.854,.519,.858,.516,.869,.512,.869,.512,.874,.509,.88,.506,.885,.503,.889,.502,.892,.501,.895,.499,.896,.497,.898,.493,.898,.493,.899,.49,.902,.487,.902,.484,.902,.483,.9,.481,.9,.481,.899,.48,.896,.482,.896,.481,.895,.48,.897,.479,.898,.478,.899,.476,.899,.474,.9,.472,.9,.469,.901,.467,.9,.465,.9,.465,.899,.46,.897,.458,.896,.456,.894,.453,.892,.454,.892,.454,.89,.457,.888,.457,.887,.456,.889,.453,.888,.452,.888,.452,.886,.448,.884,.446,.883,.445,.881,.443,.879,.444,.879,.444,.876,.449,.874,.449,.872,.448,.872,.446,.87,.445,.87,.445,.869,.443,.868,.443,.866,.443,.864,.442,.863,.443,.861,.444,.861,.449,.859,.449,.857,.449,.856,.445,.856,.445,.855,.443,.852,.442,.85,.443,.846,.443,.843,.447,.84,.449,.838,.451,.835,.456,.835,.456],['S',.819,.479,.81,.491],['C',.806,.496,.797,.507,.797,.507,.786,.519,.773,.529,.76,.539,.754,.544,.74,.552,.74,.552,.733,.556,.729,.564,.722,.569,.717,.572,.705,.574,.705,.574,.696,.577,.687,.581,.679,.584,.673,.586,.661,.589,.661,.589,.657,.59,.654,.592,.65,.594,.647,.596,.644,.599,.641,.601,.637,.603,.634,.606,.629,.606,.626,.607,.619,.604,.619,.604,.614,.602,.611,.597,.608,.593,.605,.589,.603,.58,.603,.58,.601,.576,.6,.571,.601,.567,.602,.564,.606,.562,.609,.56,.613,.558,.621,.555,.621,.555,.626,.552,.631,.55,.635,.547,.637,.544,.641,.539,.641,.539,.645,.533,.648,.525,.65,.517,.652,.511,.652,.505,.654,.499,.656,.493,.66,.481,.66,.481,.662,.476,.669,.469,.671,.467],['S',.68,.455,.683,.449],['C',.684,.445,.687,.44,.686,.436,.686,.434,.681,.43,.681,.43,.68,.428,.677,.431,.675,.43,.674,.429,.673,.426,.673,.426,.671,.423,.672,.419,.671,.417,.668,.413,.664,.412,.661,.41],['L',.656,.407],['C',.655,.405,.652,.405,.65,.406,.649,.406,.648,.408,.648,.408,.647,.41,.646,.404,.646,.401,.646,.399,.643,.392,.639,.392],['L',.631,.391],['C',.629,.391,.627,.395,.625,.394,.623,.393,.623,.388,.621,.387,.619,.387,.618,.389,.617,.389,.616,.39,.612,.393,.612,.393,.61,.395,.61,.398,.61,.4,.609,.404,.607,.411,.607,.411,.606,.416,.611,.423,.613,.424],['S',.618,.435,.62,.44],['C',.622,.446,.625,.451,.625,.456,.625,.461,.623,.469,.623,.469,.623,.473,.621,.477,.619,.481,.616,.485,.609,.492,.609,.492,.606,.495,.601,.495,.596,.495,.593,.496,.586,.495,.586,.495,.584,.495,.583,.493,.581,.491,.579,.489,.578,.483,.578,.483,.576,.476,.573,.469,.572,.461,.571,.457,.572,.452,.571,.447,.57,.445,.57,.442,.568,.44,.559,.433,.585,.404,.598,.389],['Z']]
        [['M',.723,.126],['S',.706,.101,.678,.091],['C',.651,.082,.632,.085,.619,.087,.606,.088,.588,.097,.575,.107],['S',.547,.131,.538,.149],['C',.53,.167,.529,.184,.528,.194],['S',.529,.213,.531,.224],['L',.528,.236],['S',.521,.241,.52,.247],['C',.52,.247,.515,.247,.503,.261,.492,.274,.479,.295,.479,.295],['S',.446,.321,.399,.359],['L',.338,.317],['S',.344,.314,.34,.31],['C',.337,.306,.334,.303,.334,.303],['S',.332,.302,.329,.305],['L',.328,.306,.313,.297,.298,.282],['S',.291,.276,.284,.284,.283,.297,.284,.298],['C',.285,.3,.286,.301,.293,.304],['S',.306,.31,.306,.31],['L',.33,.327,.332,.327,.389,.367,.383,.372,.375,.368,.363,.355],['S',.358,.352,.352,.358],['C',.345,.364,.349,.369,.351,.371,.353,.372,.369,.379,.369,.379],['L',.371,.381,.277,.457],['S',.252,.477,.249,.506],['C',.246,.535,.247,.544,.247,.544],['S',.235,.544,.221,.557],['C',.221,.557,.196,.528,.167,.521,.138,.513,.126,.515,.1,.522,.074,.528,.052,.551,.047,.557,.041,.562,.025,.588,.021,.616],['S',.028,.667,.035,.68,.063,.718,.089,.727],['C',.116,.737,.124,.735,.124,.735],['S',.084,.764,.084,.777],['C',.085,.785,.089,.788,.092,.789],['S',.122,.805,.17,.797],['C',.17,.797,.17,.802,.178,.801,.186,.8,.217,.79,.242,.763,.242,.763,.255,.751,.254,.748,.254,.748,.259,.743,.261,.74,.261,.74,.26,.745,.266,.744],['L',.269,.744],['S',.268,.749,.27,.75],['C',.271,.751,.272,.751,.272,.751],['S',.271,.754,.277,.759],['C',.283,.764,.301,.768,.304,.763,.304,.763,.307,.766,.311,.762,.311,.762,.313,.757,.327,.761,.34,.765,.448,.815,.448,.815],['L',.438,.817],['S',.434,.818,.438,.82],['C',.442,.822,.442,.819,.46,.823,.46,.823,.462,.826,.466,.827,.47,.828,.476,.829,.476,.83,.477,.831,.476,.836,.472,.84,.468,.844,.464,.844,.462,.846],['S',.452,.853,.45,.862,.459,.889,.463,.893],['C',.466,.897,.479,.91,.488,.91],['S',.51,.894,.513,.888,.518,.874,.518,.864],['L',.521,.861],['S',.523,.863,.526,.86,.537,.845,.54,.836],['C',.54,.836,.541,.832,.54,.83,.54,.83,.543,.828,.544,.827,.546,.825,.546,.822,.546,.822],['L',.559,.812],['S',.561,.802,.555,.799],['C',.548,.795,.546,.798,.546,.798],['L',.539,.804],['S',.535,.797,.532,.799],['C',.532,.799,.53,.8,.528,.798,.528,.798,.533,.785,.522,.781,.511,.776,.507,.787,.507,.787],['L',.504,.797,.483,.787],['S',.473,.774,.462,.767],['C',.45,.76,.416,.745,.416,.745],['S',.438,.747,.45,.728],['C',.461,.709,.443,.68,.431,.656,.42,.632,.402,.6,.393,.588,.384,.575,.366,.549,.357,.547,.348,.545,.342,.542,.327,.551,.327,.551,.328,.535,.343,.523,.343,.523,.347,.527,.356,.52],['S',.399,.483,.453,.443],['C',.453,.443,.456,.443,.458,.44,.461,.437,.462,.435,.46,.434,.46,.434,.497,.41,.537,.438,.537,.438,.546,.443,.555,.454,.555,.454,.555,.456,.556,.459],['L',.555,.46],['S',.552,.459,.55,.462,.546,.471,.546,.471,.544,.476,.548,.474,.55,.47,.555,.467],['C',.56,.464,.557,.463,.559,.463,.56,.463,.563,.468,.566,.479,.566,.479,.565,.482,.563,.482,.557,.481,.555,.482,.56,.488,.568,.496,.567,.484,.567,.485,.569,.495,.57,.51,.567,.53,.56,.576,.548,.583,.557,.589,.566,.595,.572,.595,.572,.595],['S',.56,.594,.558,.594],['C',.557,.594,.554,.596,.554,.599,.553,.603,.555,.611,.555,.611,.555,.611,.557,.614,.557,.611,.557,.607,.554,.601,.558,.597],['S',.572,.601,.576,.598],['L',.578,.596],['S',.584,.595,.585,.598],['C',.586,.6,.582,.602,.581,.603,.58,.603,.572,.608,.572,.608],['S',.569,.609,.568,.612],['C',.568,.615,.566,.618,.568,.621,.571,.625,.58,.635,.583,.643,.587,.651,.598,.656,.601,.656,.604,.656,.608,.656,.615,.651,.621,.646,.645,.626,.657,.617,.669,.608,.711,.587,.715,.585],['S',.721,.582,.732,.58],['C',.743,.579,.752,.574,.76,.564,.76,.564,.777,.561,.785,.553],['S',.789,.541,.789,.54,.786,.535,.779,.536],['C',.772,.536,.743,.542,.743,.542],['S',.732,.538,.729,.537],['C',.727,.535,.725,.534,.723,.535,.72,.536,.719,.537,.717,.538,.715,.538,.692,.543,.692,.543],['S',.672,.537,.656,.546],['C',.639,.555,.631,.566,.631,.566],['L',.63,.564,.635,.553],['S',.636,.552,.635,.551],['C',.634,.55,.634,.55,.634,.55],['L',.692,.499],['S',.694,.503,.7,.498],['L',.703,.496,.705,.498,.704,.499,.706,.501,.707,.5],['S',.709,.503,.718,.495,.723,.487,.723,.487],['L',.725,.486,.722,.483,.719,.485,.718,.484,.72,.482,.72,.481,.723,.478],['S',.725,.475,.729,.479,.732,.483,.735,.481],['C',.735,.481,.733,.484,.737,.489],['S',.762,.521,.77,.515],['C',.778,.509,.845,.453,.845,.453],['S',.849,.45,.854,.448],['C',.859,.446,.865,.446,.881,.431,.898,.417,.897,.418,.899,.411,.901,.405,.901,.401,.897,.397],['S',.889,.387,.888,.383,.881,.376,.875,.372],['C',.869,.368,.859,.363,.859,.363],['L',.862,.355],['S',.862,.352,.859,.348,.855,.344,.853,.345],['C',.851,.347,.827,.362,.82,.365],['L',.816,.343],['S',.828,.315,.833,.277],['L',.855,.259,.855,.257],['S',.881,.238,.868,.221],['C',.868,.221,.869,.217,.868,.216,.868,.216,.874,.203,.871,.2,.869,.197,.854,.179,.854,.179],['S',.851,.179,.842,.186],['C',.842,.186,.839,.184,.834,.186],['L',.836,.174,.807,.086],['S',.806,.083,.803,.084,.8,.101,.8,.101,.797,.093,.789,.096],['C',.781,.099,.773,.104,.773,.104],['S',.763,.099,.723,.126],['Z']]
        [['M',.884,.405],['C',.885,.4,.878,.388,.878,.388],['L',.87,.378],['S',.859,.36,.859,.357],['C',.858,.355,.854,.342,.853,.338,.852,.334,.848,.332,.848,.332],['S',.845,.329,.844,.333],['C',.842,.336,.838,.336,.837,.339,.835,.341,.827,.342,.827,.342],['S',.8,.343,.795,.342],['C',.789,.342,.792,.347,.792,.347],['L',.787,.35],['S',.777,.349,.775,.349],['C',.773,.349,.762,.346,.762,.346],['L',.759,.352,.752,.354,.745,.354,.739,.362,.733,.363,.727,.369,.72,.371,.711,.375,.711,.385,.716,.404,.706,.402,.696,.394],['S',.685,.386,.674,.381,.65,.387,.645,.388],['C',.639,.389,.6,.407,.6,.407],['S',.581,.409,.575,.407],['C',.568,.406,.529,.413,.529,.413],['L',.514,.409,.493,.394,.455,.382,.4,.345,.396,.332,.392,.312,.365,.296,.356,.289,.35,.299,.321,.218,.244,.033],['S',.236,.014,.234,.006],['C',.232,-.003,.24,.002,.244,.001,.248,.001,.252,.005,.256,.005,.261,.006,.267,-.001,.267,-.001],['S',.267,-.009,.263,-.017,.253,-.024,.248,-.025],['L',.234,-.029],['S',.217,-.024,.216,-.022],['C',.214,-.02,.204,.004,.204,.004],['L',.221,.055,.262,.156,.304,.241,.323,.287,.325,.3],['S',.319,.307,.316,.308],['C',.314,.308,.326,.319,.326,.319],['L',.328,.334,.335,.355,.356,.371,.377,.421,.367,.436,.374,.438,.383,.438,.376,.447,.381,.453,.382,.466],['S',.388,.48,.388,.482],['C',.388,.484,.41,.495,.41,.495],['L',.427,.497,.429,.502,.438,.506,.458,.53,.471,.546,.498,.57,.526,.592,.521,.603,.513,.61,.497,.594,.478,.573,.456,.555,.435,.542,.415,.543,.385,.557,.355,.573,.342,.571,.305,.584,.231,.608,.212,.614,.196,.613,.185,.605],['S',.173,.597,.171,.596],['C',.169,.595,.161,.587,.159,.586,.157,.585,.149,.569,.147,.566,.146,.563,.14,.561,.138,.56,.136,.559,.125,.569,.126,.571,.126,.573,.119,.591,.119,.591],['L',.113,.619],['S',.116,.644,.121,.643],['C',.125,.642,.129,.653,.129,.653],['L',.125,.67,.134,.688],['S',.154,.688,.156,.689],['C',.158,.689,.178,.684,.178,.684],['S',.192,.679,.194,.678],['C',.196,.677,.234,.668,.234,.668],['L',.268,.664,.296,.663],['S',.329,.66,.331,.659],['C',.333,.659,.366,.65,.37,.648,.373,.646,.383,.635,.385,.634,.387,.633,.397,.629,.4,.629,.404,.629,.414,.633,.414,.633],['L',.423,.651,.416,.651,.395,.665],['S',.344,.709,.342,.709],['C',.34,.708,.327,.716,.327,.716],['L',.317,.729,.311,.751],['S',.308,.751,.305,.749],['C',.302,.747,.295,.759,.295,.759],['L',.28,.786],['S',.226,.848,.224,.848],['C',.222,.848,.211,.86,.211,.862,.212,.864,.204,.871,.203,.873,.202,.875,.195,.871,.192,.868,.188,.865,.183,.871,.179,.871,.175,.872,.167,.879,.164,.879,.161,.879,.152,.883,.149,.885,.145,.887,.133,.888,.128,.888,.124,.887,.116,.878,.112,.874,.109,.869,.101,.869,.097,.867,.093,.866,.093,.873,.093,.875,.093,.878,.095,.903,.095,.903],['L',.108,.928,.124,.941,.145,.943],['S',.172,.945,.177,.946,.184,.954,.188,.96,.194,.965,.194,.965,.212,.972,.215,.973],['C',.218,.974,.228,.975,.233,.976],['S',.241,.97,.244,.967],['C',.246,.965,.246,.952,.247,.948,.247,.944,.249,.928,.249,.928],['L',.256,.908,.276,.892,.302,.862,.325,.853],['S',.354,.827,.357,.824],['C',.36,.821,.367,.811,.369,.806,.371,.801,.375,.789,.376,.786,.378,.784,.397,.778,.399,.779,.4,.779,.431,.771,.431,.771],['L',.465,.767,.492,.755,.497,.759],['S',.509,.768,.511,.77],['C',.513,.772,.526,.778,.532,.779,.538,.779,.549,.782,.555,.781,.56,.781,.582,.784,.586,.784,.589,.784,.604,.78,.609,.779,.614,.777,.635,.758,.64,.755,.645,.752,.661,.733,.665,.728,.668,.723,.696,.688,.697,.686,.699,.684,.745,.619,.745,.619],['S',.774,.58,.775,.573],['C',.776,.566,.786,.523,.786,.523],['L',.783,.501],['S',.786,.481,.789,.479],['C',.792,.477,.797,.477,.8,.478,.802,.479,.814,.473,.816,.473,.818,.472,.825,.475,.825,.475],['L',.838,.47],['S',.851,.462,.853,.462],['C',.855,.461,.864,.463,.865,.465,.865,.467,.87,.46,.87,.46],['L',.874,.441,.877,.425],['S',.881,.411,.884,.407],['C',.884,.407,.884,.406,.884,.405],['Z'],['M',.609,.466,.605,.479,.598,.496,.581,.514,.576,.543,.569,.543,.554,.535,.489,.496,.485,.49,.455,.469,.441,.452],['S',.416,.426,.414,.425],['C',.412,.423,.4,.423,.4,.423],['L',.385,.385,.418,.416,.437,.435,.464,.449],['S',.489,.461,.489,.463],['C',.49,.465,.519,.469,.522,.469,.525,.469,.562,.471,.562,.471],['L',.609,.466],['Z']]
        [['M',.344,.137],['C',.35,.137,.355,.143,.361,.142,.376,.137,.391,.13,.408,.131,.42,.13,.434,.13,.444,.138,.453,.14,.462,.159,.47,.15,.481,.138,.494,.127,.511,.126,.533,.123,.555,.123,.577,.126,.599,.13,.621,.137,.644,.141,.656,.139,.646,.122,.646,.114,.646,.102,.652,.091,.65,.078,.653,.069,.662,.062,.671,.059,.682,.058,.685,.044,.694,.038,.705,.026,.721,.019,.737,.015,.75,.014,.762,.02,.775,.021,.791,.027,.803,.04,.815,.052,.818,.046,.821,.037,.829,.039,.839,.041,.836,.055,.846,.057,.854,.062,.863,.066,.87,.073,.879,.077,.88,.088,.884,.096,.885,.101,.888,.105,.889,.11,.887,.124,.881,.137,.877,.15,.875,.161,.875,.173,.874,.184,.872,.197,.874,.213,.863,.222,.849,.23,.832,.22,.824,.209,.82,.204,.814,.2,.809,.197,.813,.225,.815,.254,.813,.282,.813,.294,.815,.307,.812,.319,.809,.336,.801,.35,.793,.365,.779,.394,.752,.414,.729,.435,.719,.443,.71,.452,.7,.458,.694,.46,.688,.455,.685,.461,.652,.492,.619,.522,.589,.555,.574,.572,.563,.593,.548,.61,.541,.619,.522,.622,.528,.636,.529,.647,.536,.654,.545,.658,.559,.67,.572,.682,.58,.698,.594,.722,.601,.75,.603,.778,.602,.789,.61,.799,.606,.81,.604,.827,.6,.845,.588,.857,.571,.871,.563,.892,.545,.904,.527,.921,.504,.93,.481,.938,.468,.94,.456,.946,.444,.945,.43,.944,.415,.942,.401,.945,.392,.945,.38,.947,.369,.943,.355,.938,.34,.935,.326,.93,.312,.923,.299,.913,.286,.903,.277,.897,.268,.89,.263,.88,.257,.868,.253,.855,.252,.841,.25,.829,.25,.817,.246,.806,.24,.802,.25,.788,.237,.789,.229,.784,.248,.779,.241,.771,.244,.759,.23,.754,.222,.748,.21,.742,.216,.73,.223,.723,.225,.712,.223,.699,.235,.693,.244,.687,.258,.679,.246,.668,.24,.665,.229,.654,.239,.648,.246,.647,.255,.643,.253,.634,.255,.621,.242,.617,.234,.61,.218,.597,.209,.578,.194,.565,.17,.544,.147,.521,.12,.505,.106,.497,.09,.495,.078,.483,.059,.467,.043,.446,.027,.427,.013,.412,0,.396,-.017,.386,-.028,.38,-.041,.386,-.053,.386,-.064,.387,-.09,.378,-.084,.37,-.081,.366,-.076,.369,-.075,.366,-.072,.36,-.079,.364,-.076,.359,-.073,.354,-.054,.35,-.043,.343,-.028,.338,-.012,.339,.003,.333,.011,.331,.019,.329,.027,.327,.03,.318,.031,.307,.041,.302,.046,.296,.061,.298,.054,.307,.049,.32,.065,.325,.068,.335,.071,.339,.067,.348,.073,.349,.092,.356,.109,.368,.128,.376,.144,.383,.157,.394,.169,.406,.177,.412,.188,.411,.196,.418,.223,.438,.236,.47,.262,.491,.267,.495,.275,.506,.279,.494,.296,.468,.302,.437,.323,.414,.335,.4,.347,.388,.355,.371,.367,.351,.376,.329,.391,.311,.401,.298,.413,.288,.426,.278,.418,.262,.408,.248,.399,.233],['L',.369,.206],['C',.346,.216,.32,.221,.295,.226,.284,.226,.27,.225,.262,.217,.255,.21,.242,.198,.256,.192,.259,.177,.276,.188,.284,.191,.293,.188,.272,.178,.283,.172,.293,.165,.304,.175,.314,.17,.322,.166,.329,.161,.335,.155,.333,.15,.326,.142,.333,.137,.337,.135,.34,.136,.344,.137],['Z']]
        [['M',.738,.755],['C',.741,.751,.733,.742,.732,.74],['S',.715,.738,.713,.738],['C',.711,.738,.696,.732,.694,.731,.693,.73,.678,.715,.678,.713,.678,.71,.653,.694,.653,.694],['L',.661,.646,.677,.586],['S',.688,.542,.693,.527],['C',.697,.512,.686,.494,.686,.494],['L',.648,.469,.6,.431,.615,.422,.617,.416,.629,.4,.636,.397],['S',.666,.386,.665,.387],['C',.663,.388,.672,.392,.675,.394],['S',.69,.393,.691,.396],['C',.693,.398,.703,.399,.703,.399],['S',.709,.397,.713,.396],['C',.717,.396,.718,.389,.718,.389],['S',.725,.39,.729,.389],['C',.733,.388,.729,.373,.729,.373],['L',.898,.355],['S',.969,.367,.971,.368],['C',.974,.368,.985,.364,.985,.364],['L',1.004,.357,.911,.315,.899,.327,.868,.329,.788,.339],['S',.741,.34,.742,.339,.741,.336,.739,.332,.715,.344,.715,.344],['L',.654,.351],['S',.655,.319,.654,.318,.659,.306,.661,.304],['C',.662,.302,.669,.28,.671,.278],['S',.668,.262,.665,.255],['C',.662,.248,.667,.251,.669,.25,.672,.249,.665,.243,.664,.24,.663,.237,.654,.227,.654,.22,.654,.212,.666,.182,.669,.177,.672,.172,.677,.171,.677,.171],['S',.686,.174,.692,.178,.698,.18,.704,.178,.718,.177,.727,.179],['C',.736,.18,.737,.175,.741,.171,.746,.168,.745,.166,.747,.158],['S',.747,.152,.751,.15],['C',.754,.147,.757,.139,.758,.134,.759,.129,.755,.133,.748,.131,.741,.129,.742,.126,.743,.121],['S',.749,.11,.752,.107],['C',.754,.103,.757,.097,.762,.089,.767,.081,.757,.054,.753,.05,.749,.045,.737,.031,.731,.029,.726,.027,.704,.022,.698,.023,.692,.023,.687,.032,.686,.034,.685,.036,.68,.04,.677,.041,.674,.042,.665,.052,.663,.052],['S',.656,.029,.657,.028],['L',.653,.025],['S',.646,.034,.644,.035,.632,.048,.628,.049],['C',.624,.051,.623,.067,.624,.07],['S',.628,.088,.628,.088],['L',.629,.103,.626,.114,.612,.111,.593,.1,.556,.083],['S',.532,.094,.529,.095],['C',.526,.096,.484,.128,.483,.129,.481,.13,.473,.135,.471,.136,.47,.137,.476,.154,.476,.154],['S',.451,.21,.45,.211],['C',.449,.212,.446,.24,.446,.24],['L',.432,.277],['S',.424,.294,.424,.296],['C',.424,.298,.302,.27,.302,.27],['L',.306,.284],['S',.322,.293,.324,.293],['C',.325,.294,.393,.335,.393,.336,.393,.337,.382,.347,.382,.347],['L',.346,.391],['S',.281,.468,.28,.47],['C',.279,.471,.264,.48,.261,.482,.258,.484,.249,.489,.246,.489,.242,.489,.235,.49,.233,.49,.23,.49,.217,.499,.214,.5,.21,.501,.166,.51,.164,.511,.162,.511,.127,.531,.126,.531,.124,.532,.119,.531,.119,.529,.119,.527,.102,.53,.1,.528,.098,.525,.091,.533,.086,.536,.081,.539,.075,.549,.074,.551,.073,.553,.061,.555,.06,.553,.058,.551,.041,.564,.039,.566,.038,.567,.011,.589,.01,.59,.008,.591,-.003,.602,-.003,.602],['L',-.007,.622],['C',-.004,.653,.033,.664,.032,.666],['S',.047,.659,.047,.659],['L',.052,.653],['S',.07,.636,.072,.632,.102,.619,.102,.619],['L',.112,.606,.122,.605],['S',.146,.597,.15,.596],['C',.154,.594,.175,.586,.179,.583,.183,.581,.224,.567,.229,.565,.234,.563,.251,.557,.255,.557,.259,.556,.28,.551,.283,.549,.286,.547,.321,.529,.321,.529],['L',.352,.504],['S',.376,.491,.379,.49],['C',.381,.489,.434,.463,.434,.463],['L',.397,.531,.493,.486,.495,.488,.515,.498,.619,.546,.6,.646],['S',.589,.692,.588,.695],['C',.587,.698,.59,.71,.595,.714],['S',.593,.733,.592,.736,.593,.763,.593,.763,.643,.764,.645,.765,.681,.764,.684,.764],['C',.688,.765,.719,.764,.723,.763,.728,.763,.735,.759,.738,.755],['Z'],['M',.569,.328],['S',.601,.306,.603,.304],['L',.6,.335,.569,.328],['Z']]
        [['M',.183,.745],['C',.22,.708,.261,.674,.3,.639,.332,.617,.355,.585,.387,.564,.414,.54,.438,.513,.458,.484,.48,.456,.461,.419,.465,.386,.47,.348,.454,.312,.449,.276,.452,.241,.413,.197,.437,.169,.482,.167,.515,.215,.519,.256,.527,.282,.54,.332,.579,.313,.599,.305,.619,.293,.626,.271,.637,.245,.651,.219,.665,.194,.678,.168,.695,.146,.708,.12,.72,.095,.739,.075,.759,.056,.78,.072,.789,.102,.772,.123,.762,.146,.75,.168,.742,.191,.736,.214,.725,.239,.72,.261,.754,.217,.8,.181,.833,.134,.853,.092,.909,.136,.879,.166,.859,.197,.831,.222,.813,.254,.805,.28,.758,.308,.77,.33,.799,.313,.829,.299,.857,.281,.885,.27,.921,.219,.948,.254,.959,.289,.901,.308,.881,.333,.85,.354,.822,.38,.79,.396,.783,.42,.839,.396,.859,.398,.888,.396,.913,.38,.941,.378,.985,.403,.932,.438,.902,.441,.87,.453,.837,.463,.802,.47,.768,.485,.738,.511,.707,.533,.679,.549,.652,.569,.623,.584,.585,.593,.576,.636,.55,.661,.528,.694,.5,.723,.477,.755,.454,.787,.43,.818,.411,.852,.395,.876,.389,.904,.369,.926,.348,.954,.328,.983,.308,1.011],['L',.113,.813],['C',.136,.79,.16,.768,.183,.745],['Z']]
        [['M',.238,.31],['C',.242,.308,.243,.308,.245,.309,.247,.309,.249,.31,.251,.31],['S',.255,.311,.257,.311],['C',.258,.312,.259,.312,.259,.311,.259,.311,.26,.31,.26,.31,.26,.31,.26,.309,.26,.309,.259,.307,.26,.3,.262,.296,.265,.29,.266,.288,.27,.285,.272,.284,.274,.282,.275,.281,.277,.279,.286,.279,.289,.282,.289,.282,.29,.283,.291,.283,.293,.283,.295,.285,.295,.288,.295,.288,.295,.29,.295,.291,.296,.291,.296,.293,.296,.295,.296,.297,.297,.298,.298,.299,.299,.3,.3,.301,.3,.302,.299,.303,.301,.304,.307,.311,.314,.318,.314,.319,.318,.32,.32,.321,.322,.321,.322,.321,.324,.321,.328,.323,.329,.325,.331,.327,.332,.327,.333,.327,.334,.326,.336,.327,.338,.329,.339,.33,.342,.333,.345,.335,.349,.338,.35,.339,.354,.34,.359,.341,.368,.345,.378,.349,.38,.351,.385,.353,.389,.354,.393,.356,.396,.357,.397,.358,.397,.358,.399,.359,.401,.359,.407,.361,.411,.362,.413,.364,.415,.365,.416,.366,.417,.365,.419,.365,.424,.362,.427,.357,.435,.348,.444,.335,.445,.332,.445,.332,.446,.331,.446,.33,.448,.329,.449,.326,.449,.325,.449,.325,.449,.324,.45,.324],['S',.452,.321,.453,.319],['C',.454,.316,.462,.304,.466,.298,.467,.296,.47,.293,.472,.291,.474,.288,.477,.285,.478,.283,.482,.279,.499,.263,.505,.259,.513,.253,.519,.249,.523,.247,.531,.242,.538,.237,.54,.236,.541,.235,.541,.235,.538,.23,.537,.227,.535,.224,.535,.223],['L',.535,.221,.533,.221],['C',.532,.221,.53,.221,.529,.221],['S',.526,.22,.525,.219],['C',.524,.219,.522,.219,.519,.218,.517,.217,.514,.216,.513,.216,.512,.216,.51,.215,.508,.213,.505,.212,.502,.21,.501,.21,.5,.21,.498,.209,.498,.209],['S',.497,.209,.495,.208],['C',.493,.208,.491,.208,.489,.209,.487,.21,.483,.214,.483,.215,.483,.216,.482,.216,.481,.217,.48,.217,.478,.218,.473,.222,.469,.225,.469,.225,.464,.224,.463,.223,.461,.224,.458,.225,.452,.227,.448,.228,.445,.228,.44,.226,.439,.226,.438,.224,.438,.223,.437,.222,.436,.222,.435,.221,.435,.221,.435,.221,.435,.219,.437,.216,.44,.212,.443,.209,.444,.208,.444,.206,.445,.204,.445,.203,.448,.201,.453,.196,.465,.186,.466,.186,.467,.186,.468,.186,.471,.183,.477,.177,.482,.17,.483,.169,.484,.166,.501,.153,.505,.152,.506,.152,.507,.152,.507,.152,.508,.151,.513,.149,.516,.149,.524,.149,.531,.149,.543,.153,.55,.154,.558,.156,.56,.156],['S',.566,.157,.568,.157,.572,.158,.572,.157],['C',.573,.157,.574,.157,.575,.158,.576,.159,.578,.159,.578,.158,.578,.157,.58,.157,.584,.157,.587,.157,.59,.157,.59,.157,.591,.157,.594,.157,.598,.158,.61,.158,.614,.16,.621,.168,.624,.171,.625,.172,.625,.173,.625,.175,.628,.18,.63,.183,.631,.184,.633,.184,.634,.185,.636,.185,.637,.186,.636,.187,.635,.187,.636,.189,.637,.189,.64,.19,.652,.186,.658,.182,.66,.181,.662,.18,.663,.18,.665,.179,.665,.179,.666,.177,.666,.176,.666,.176,.667,.176,.668,.176,.67,.175,.669,.174,.669,.174,.668,.173,.668,.173,.665,.172,.662,.165,.659,.158,.659,.156,.658,.154,.657,.153],['S',.655,.15,.655,.149],['C',.655,.148,.654,.148,.653,.148,.652,.148,.642,.137,.636,.129,.633,.126,.632,.125,.632,.125,.631,.125,.631,.125,.63,.123,.63,.121,.629,.121,.628,.12,.627,.119,.624,.117,.621,.114,.616,.109,.616,.108,.616,.106,.616,.105,.615,.104,.615,.103,.614,.103,.613,.102,.613,.101,.612,.099,.612,.099,.61,.099,.609,.099,.608,.099,.607,.097,.606,.096,.606,.095,.605,.096,.604,.096,.602,.096,.6,.096,.598,.097,.594,.097,.591,.098,.586,.099,.578,.099,.576,.099,.575,.098,.573,.093,.574,.092,.574,.092,.574,.092,.574,.092,.573,.092,.573,.09,.573,.089,.573,.087,.574,.086,.577,.083,.58,.079,.581,.079,.582,.079,.582,.08,.583,.08,.583,.079,.584,.078,.584,.077,.585,.077,.586,.076,.585,.075,.584,.073,.584,.073,.583,.07,.583,.068],['L',.582,.063,.585,.061],['C',.587,.059,.59,.057,.594,.056,.603,.053,.609,.051,.611,.049,.612,.048,.613,.048,.613,.047,.614,.047,.614,.047,.614,.047,.614,.047,.614,.044,.615,.042,.615,.039,.616,.037,.616,.037,.617,.037,.62,.032,.619,.031,.619,.03,.62,.03,.62,.029],['S',.622,.028,.622,.027],['C',.623,.025,.624,.025,.629,.024,.632,.023,.635,.023,.635,.022,.635,.022,.638,.019,.641,.016,.647,.009,.651,.007,.654,.007,.657,.007,.657,.007,.658,.009,.659,.011,.66,.014,.661,.017,.662,.021,.662,.022,.661,.027,.661,.03,.66,.034,.659,.037,.657,.044,.657,.046,.658,.05,.659,.053,.661,.055,.665,.058,.667,.06,.67,.062,.672,.064,.677,.067,.682,.07,.683,.071,.684,.071,.692,.078,.694,.08,.694,.081,.699,.086,.704,.091,.711,.098,.715,.102,.717,.105,.721,.11,.728,.118,.73,.119,.731,.12,.734,.12,.742,.119,.747,.119,.756,.12,.76,.121,.763,.122,.77,.128,.778,.134,.787,.142,.81,.157,.824,.165,.828,.166,.832,.169,.833,.169,.837,.171,.848,.176,.848,.175,.849,.175,.848,.174,.848,.173,.846,.17,.845,.163,.846,.161,.847,.157,.849,.157,.856,.16,.863,.162,.87,.167,.879,.176,.882,.179,.885,.182,.886,.183,.889,.185,.901,.199,.908,.208,.915,.217,.92,.226,.925,.237,.928,.243,.929,.246,.931,.248,.932,.249,.933,.251,.934,.252,.937,.259,.943,.27,.944,.27,.944,.27,.945,.271,.95,.283,.951,.287,.953,.292,.954,.294,.962,.326,.962,.329,.96,.369,.959,.399,.958,.409,.954,.421,.954,.424,.953,.427,.954,.429,.954,.431,.953,.437,.952,.441,.951,.444,.95,.448,.949,.45,.948,.454,.946,.46,.945,.462,.945,.463,.945,.465,.945,.465,.946,.466,.94,.48,.938,.482,.938,.483,.937,.484,.937,.484,.937,.486,.932,.496,.931,.497,.93,.497,.929,.499,.929,.501,.927,.504,.926,.505,.922,.509,.92,.512,.917,.515,.916,.515,.916,.516,.914,.52,.912,.522,.909,.528,.906,.53,.882,.554,.861,.575,.854,.581,.852,.582,.851,.582,.85,.583,.847,.586,.846,.588,.836,.597,.826,.606,.799,.631,.785,.644,.781,.65,.776,.657,.774,.658,.773,.658,.772,.657,.769,.66,.76,.67,.757,.674,.752,.68,.75,.682,.748,.684,.744,.688,.741,.692,.738,.695,.734,.7,.731,.703,.724,.711,.716,.719,.713,.724,.711,.726,.708,.729,.706,.731,.704,.734,.699,.739,.696,.743,.692,.747,.687,.753,.685,.755,.683,.758,.679,.762,.677,.765,.67,.773,.664,.779,.658,.785,.655,.788,.652,.791,.653,.791,.653,.792,.652,.792,.652,.792,.652,.792,.647,.796,.643,.8],['S',.632,.808,.631,.809],['C',.629,.81,.626,.812,.623,.814,.618,.817,.614,.819,.612,.819,.61,.819,.608,.821,.602,.825,.593,.831,.585,.835,.581,.836,.579,.836,.577,.837,.576,.839,.572,.842,.56,.849,.542,.856,.538,.858,.534,.86,.533,.861,.532,.861,.532,.861,.531,.86,.531,.859,.53,.86,.523,.864,.518,.866,.509,.869,.507,.869,.505,.869,.502,.87,.488,.874,.486,.875,.484,.875,.482,.876,.481,.876,.477,.877,.474,.878,.471,.878,.468,.879,.466,.878,.464,.878,.46,.879,.458,.879,.456,.88,.453,.88,.452,.88,.45,.881,.446,.881,.443,.881,.437,.882,.424,.882,.416,.88,.413,.88,.411,.88,.408,.881,.404,.882,.399,.883,.399,.882,.399,.882,.399,.881,.399,.881,.4,.881,.4,.88,.4,.88,.4,.88,.394,.881,.391,.882,.388,.883,.386,.883,.385,.882,.384,.881,.381,.882,.375,.885,.373,.886,.368,.888,.364,.889,.361,.89,.357,.891,.356,.892,.354,.893,.352,.894,.35,.894,.346,.895,.345,.895,.343,.898,.342,.899,.339,.903,.337,.907,.332,.916,.33,.919,.329,.918,.329,.918,.328,.918,.328,.918,.327,.919,.326,.918,.324,.916,.323,.915,.322,.911,.321,.904,.32,.9,.32,.893,.321,.889,.322,.885,.322,.884,.324,.883,.325,.881,.326,.88,.326,.88,.325,.88,.312,.88,.311,.88,.311,.88,.307,.882,.303,.883,.293,.885,.288,.885,.278,.883,.272,.881,.27,.88,.271,.879,.271,.878,.27,.877,.268,.875,.267,.874,.265,.871,.264,.868,.262,.865,.261,.863,.26,.862],['S',.259,.86,.26,.859],['C',.26,.858,.259,.857,.259,.857,.258,.857,.258,.856,.258,.856,.259,.855,.254,.845,.253,.844,.252,.844,.252,.843,.252,.843,.253,.843,.244,.833,.242,.832,.242,.832,.24,.83,.237,.828,.235,.826,.231,.824,.229,.822,.227,.821,.224,.818,.222,.816,.218,.813,.217,.812,.214,.812,.213,.812,.21,.811,.206,.809,.203,.808,.2,.807,.2,.807,.199,.807,.194,.805,.187,.803,.181,.8,.174,.798,.172,.797,.164,.795,.159,.795,.156,.795,.155,.795,.152,.795,.149,.795,.144,.795,.143,.796,.141,.801,.14,.805,.139,.806,.139,.802,.14,.799,.139,.797,.138,.798,.138,.798,.136,.799,.133,.799],['L',.129,.799,.128,.803],['C',.127,.807,.126,.807,.126,.803],['L',.127,.8,.124,.799],['C',.122,.799,.119,.798,.117,.797,.115,.797,.113,.796,.113,.796,.113,.796,.112,.797,.112,.799,.112,.801,.111,.802,.111,.803,.11,.805,.109,.803,.11,.8,.11,.799,.111,.797,.111,.796,.111,.795,.111,.794,.106,.792,.101,.789,.101,.789,.1,.79,.1,.79,.098,.792,.097,.793,.095,.795,.095,.796,.095,.795,.094,.794,.096,.792,.099,.788],['L',.099,.787,.093,.78],['C',.085,.773,.085,.772,.085,.774,.084,.776,.08,.779,.08,.778,.08,.778,.081,.777,.082,.775,.084,.773,.084,.771,.082,.769,.078,.766,.077,.765,.077,.766,.076,.766,.065,.766,.064,.766,.063,.765,.068,.763,.071,.763,.072,.763,.074,.763,.074,.763],['S',.073,.761,.071,.759],['C',.068,.756,.068,.756,.067,.757,.066,.759,.062,.76,.061,.759,.06,.759,.061,.756,.062,.756,.062,.756,.063,.756,.065,.755],['L',.067,.753,.065,.751,.062,.749,.058,.75],['C',.055,.75,.053,.75,.053,.75,.052,.75,.053,.748,.055,.747],['L',.058,.744,.055,.742],['C',.053,.739,.051,.739,.048,.739,.046,.74,.04,.739,.039,.737,.038,.736,.039,.736,.041,.736,.044,.737,.049,.736,.05,.735,.051,.735,.05,.733,.049,.73],['L',.047,.726,.044,.725],['C',.04,.725,.035,.723,.034,.722,.031,.72,.033,.72,.038,.721,.044,.722,.045,.722,.046,.721,.046,.721,.046,.719,.045,.717,.045,.713,.044,.712,.043,.711,.042,.71,.04,.709,.04,.709,.039,.708,.038,.707,.037,.707,.034,.706,.032,.705,.032,.704,.032,.703,.034,.703,.038,.705,.041,.706,.043,.707,.044,.707,.044,.706,.045,.697,.045,.696,.045,.695,.044,.695,.043,.695,.041,.694,.04,.693,.041,.692,.041,.692,.042,.692,.043,.692],['L',.045,.692,.048,.687],['C',.05,.684,.052,.681,.053,.68,.055,.678,.055,.677,.055,.677,.054,.675,.055,.67,.06,.658,.061,.657,.062,.655,.062,.654],['S',.063,.652,.063,.652],['C',.063,.651,.064,.65,.065,.65,.066,.65,.068,.647,.07,.643,.071,.64,.083,.622,.087,.618,.093,.61,.111,.594,.115,.591,.121,.587,.133,.581,.137,.58,.14,.579,.142,.578,.142,.578,.142,.578,.144,.577,.147,.576,.149,.575,.152,.574,.154,.574,.155,.573,.158,.572,.16,.572,.161,.571,.166,.57,.17,.569],['L',.177,.567,.177,.565],['C',.177,.564,.177,.562,.176,.561],['S',.175,.559,.176,.558],['C',.177,.554,.18,.56,.179,.564,.179,.565,.179,.567,.179,.567,.18,.567,.186,.566,.187,.565,.187,.564,.188,.564,.189,.563,.19,.563,.191,.563,.19,.562,.19,.562,.19,.561,.191,.561,.192,.56,.192,.56,.193,.561,.194,.563,.194,.563,.198,.563],['L',.202,.563,.202,.562],['C',.203,.561,.203,.559,.203,.557,.203,.556,.203,.555,.203,.555,.204,.554,.204,.556,.205,.559],['L',.205,.563,.207,.563],['C',.209,.563,.212,.562,.215,.561,.215,.561,.218,.561,.22,.561,.223,.561,.227,.56,.23,.56,.235,.559,.249,.56,.252,.561,.253,.562,.254,.563,.255,.563],['S',.257,.565,.258,.565],['C',.26,.566,.272,.574,.277,.578,.279,.579,.279,.579,.281,.579,.283,.578,.284,.578,.284,.577,.284,.575,.286,.571,.289,.569,.291,.567,.292,.565,.293,.561,.293,.56,.294,.558,.295,.556,.296,.554,.297,.553,.297,.553,.297,.552,.296,.552,.295,.551,.294,.55,.293,.548,.292,.542,.29,.532,.289,.528,.288,.531,.288,.533,.288,.532,.286,.529,.284,.525,.283,.518,.283,.511,.283,.505,.282,.503,.279,.504,.278,.504,.278,.504,.278,.501,.277,.5,.276,.498,.272,.492,.264,.482,.262,.479,.262,.478,.262,.477,.261,.476,.259,.473,.257,.471,.254,.468,.253,.465,.252,.463,.249,.457,.246,.453,.242,.446,.242,.444,.242,.442,.242,.441,.242,.439,.242,.439,.243,.437,.239,.437,.235,.437,.233,.438,.229,.438,.226,.438],['S',.219,.437,.218,.437],['C',.216,.437,.207,.442,.205,.444,.204,.444,.203,.444,.201,.444,.199,.444,.199,.444,.195,.447,.192,.45,.191,.45,.188,.45,.186,.451,.185,.451,.185,.451,.184,.451,.183,.451,.182,.451,.181,.451,.178,.452,.176,.453,.171,.457,.161,.458,.158,.455,.157,.455,.156,.455,.156,.455,.154,.456,.153,.454,.153,.452,.153,.451,.154,.449,.155,.447,.156,.445,.157,.442,.157,.441,.158,.439,.158,.438,.159,.44,.159,.441,.159,.441,.16,.437,.161,.436,.162,.434,.163,.434,.163,.433,.164,.432,.164,.431,.164,.43,.165,.429,.166,.427,.168,.425,.17,.423,.171,.422,.173,.42,.174,.419,.176,.418,.178,.417,.178,.416,.179,.415,.179,.415,.18,.414,.182,.412,.184,.411,.186,.409,.186,.409,.187,.408,.187,.407,.186,.406,.186,.405,.186,.404,.186,.402,.187,.4,.191,.396,.193,.396,.194,.396,.194,.395,.194,.394,.194,.393,.204,.385,.209,.38,.211,.379,.212,.378,.212,.378,.212,.377,.209,.376,.208,.377,.207,.378,.206,.378,.205,.377,.205,.376,.204,.376,.202,.376,.2,.377,.199,.376,.198,.376,.198,.375,.197,.375,.197,.375,.196,.375,.196,.375,.194,.373],['L',.191,.37,.193,.365],['C',.194,.36,.196,.355,.199,.352,.201,.35,.207,.347,.208,.347,.209,.347,.21,.347,.21,.346,.211,.345,.213,.345,.215,.344],['S',.218,.343,.218,.342],['C',.22,.341,.227,.34,.23,.34,.233,.341,.233,.34,.233,.339,.233,.338,.232,.337,.232,.337,.229,.334,.229,.332,.229,.325,.229,.32,.229,.318,.231,.317,.231,.316,.232,.316,.232,.315,.232,.314,.234,.312,.238,.31],['Z'],['M',.15,.798],['C',.151,.798,.151,.801,.15,.802,.149,.802,.149,.802,.149,.801,.149,.799,.15,.798,.15,.798],['Z']]
        [['M',.859,.395],['C',.875,.37,.907,.305,.917,.276,.936,.221,.926,.192,.924,.193,.922,.193,.93,.225,.912,.28,.899,.319,.864,.367,.86,.383,.854,.373,.825,.337,.817,.339,.815,.335,.814,.331,.811,.328,.822,.319,.833,.305,.849,.283,.852,.271,.861,.261,.876,.201,.876,.201,.87,.2,.87,.201,.862,.212,.858,.24,.844,.283,.842,.29,.817,.314,.807,.322,.794,.308,.775,.299,.775,.28,.775,.278,.731,.221,.727,.236,.724,.243,.733,.29,.725,.294,.712,.299,.708,.32,.707,.338,.704,.383,.715,.409,.732,.423,.718,.422,.695,.433,.673,.447,.666,.442,.667,.435,.657,.431,.654,.43,.688,.413,.701,.401,.704,.398,.706,.39,.705,.388,.708,.385,.696,.357,.682,.322,.671,.294,.66,.272,.655,.266,.652,.258,.64,.239,.631,.226,.621,.214,.612,.204,.607,.2,.609,.197,.607,.188,.605,.18,.603,.172,.6,.167,.599,.167,.601,.164,.604,.157,.607,.149,.61,.142,.611,.137,.61,.139,.608,.141,.604,.149,.601,.157,.599,.162,.598,.166,.597,.167,.596,.17,.597,.178,.6,.187,.601,.191,.603,.195,.604,.198,.602,.2,.613,.22,.629,.236,.645,.253,.649,.263,.651,.266,.651,.274,.659,.302,.672,.333,.683,.361,.694,.38,.7,.386,.698,.386,.696,.387,.695,.387,.693,.381,.682,.365,.667,.347,.653,.329,.64,.316,.635,.312,.635,.311,.63,.307,.622,.303,.615,.299,.608,.297,.607,.298,.606,.299,.612,.303,.619,.307,.625,.31,.63,.312,.633,.312,.634,.317,.645,.333,.66,.353,.674,.369,.686,.383,.692,.387,.586,.396,.567,.419,.565,.431,.564,.444,.588,.463,.622,.474,.627,.475,.631,.476,.636,.478,.636,.478,.636,.478,.636,.478,.625,.488,.605,.497,.593,.507,.577,.507,.554,.505,.534,.492,.495,.467,.456,.449,.436,.45,.427,.446,.413,.44,.397,.434,.381,.427,.367,.422,.359,.419,.353,.417,.347,.414,.341,.412,.315,.401,.295,.395,.296,.396,.297,.398,.318,.408,.344,.418,.36,.425,.374,.43,.382,.432,.382,.432,.382,.432,.382,.432,.388,.435,.394,.437,.401,.44,.417,.447,.431,.452,.439,.454,.455,.465,.515,.495,.538,.52,.513,.521,.505,.518,.484,.551,.513,.602,.494,.594,.447,.602,.436,.605,.426,.61,.415,.615,.372,.607,.336,.599,.327,.599,.327,.599,.327,.599,.327,.599,.313,.598,.3,.596,.286,.6,.272,.601,.248,.606,.241,.617,.256,.616,.27,.611,.283,.603,.298,.605,.314,.609,.328,.602,.337,.606,.365,.614,.401,.623,.346,.652,.295,.697,.297,.726,.299,.765,.407,.764,.474,.74,.484,.736,.493,.731,.501,.725,.502,.747,.504,.766,.506,.774,.495,.771,.462,.772,.421,.776,.379,.781,.343,.788,.334,.793,.324,.79,.298,.787,.269,.785,.231,.783,.2,.784,.2,.788,.2,.789,.2,.789,.2,.789,.194,.791,.185,.795,.174,.8,.166,.804,.158,.808,.152,.811,.153,.81,.153,.81,.153,.809,.152,.809,.144,.815,.134,.824,.124,.833,.117,.841,.118,.842,.118,.843,.126,.836,.136,.827,.14,.824,.143,.82,.146,.817,.152,.816,.163,.811,.176,.805,.188,.8,.198,.794,.203,.791,.212,.794,.239,.798,.27,.8,.3,.801,.326,.801,.335,.798,.345,.801,.379,.801,.42,.797,.463,.792,.5,.784,.508,.779,.508,.779,.508,.779,.508,.779,.509,.779,.509,.779,.51,.778,.513,.773,.515,.751,.514,.724,.514,.721,.514,.718,.514,.715,.532,.698,.546,.677,.551,.658,.567,.661,.58,.663,.586,.664,.621,.667,.649,.668,.653,.663,.653,.663,.653,.663,.653,.662,.653,.662,.653,.662,.653,.662,.624,.625,.619,.618,.604,.607,.589,.596,.58,.585,.569,.581,.584,.578,.583,.57,.591,.58,.607,.597,.653,.577,.694,.537,.704,.527,.713,.516,.72,.506,.74,.478,.752,.445,.745,.43,.749,.432,.753,.434,.758,.435,.786,.44,.814,.392,.817,.353,.831,.345,.849,.387,.859,.395],['Z'],['M',.628,.655],['C',.618,.653,.598,.651,.586,.65,.58,.649,.568,.647,.553,.644,.553,.624,.542,.607,.514,.601,.508,.572,.57,.615,.589,.629,.6,.637,.619,.649,.628,.655],['Z'],['M',.577,.505],['C',.578,.503,.563,.493,.544,.483,.531,.476,.52,.471,.513,.469,.509,.464,.499,.455,.487,.445,.474,.435,.462,.428,.456,.425,.454,.423,.45,.419,.445,.416,.437,.409,.429,.405,.428,.406,.427,.407,.434,.413,.442,.42,.447,.424,.452,.427,.455,.429,.459,.433,.469,.442,.482,.452,.493,.461,.504,.468,.51,.471,.515,.475,.526,.483,.54,.49,.559,.5,.576,.507,.577,.505],['Z']]
        [['M',.113,.703],['S',.067,.754,.114,.812],['C',.162,.871,.293,.973,.348,.886],['L',.335,.882],['S',.312,.926,.283,.88],['C',.316,.873,.351,.84,.37,.82,.375,.823,.382,.822,.388,.817,.394,.812,.396,.804,.393,.799,.493,.753,.437,.706,.437,.674,.437,.66,.442,.647,.448,.636,.461,.65,.468,.661,.468,.661],['S',.554,.653,.648,.562,.644,.549,.634,.531],['L',.844,.306],['S',.871,.31,.903,.352],['L',.921,.333],['S',.873,.26,.821,.23],['L',.833,.217],['C',.868,.212,.936,.247,.936,.247],['L',.954,.228],['C',.859,.131,.809,.143,.809,.143,.786,.115,.756,.102,.756,.102],['L',.589,.279],['C',.557,.249,.509,.262,.507,.286,.505,.312,.518,.311,.531,.297,.543,.284,.537,.309,.537,.309],['L',.518,.329],['C',.505,.325,.496,.326,.496,.326,.387,.424,.342,.588,.342,.588,.361,.586,.378,.59,.394,.596,.375,.615,.361,.622,.356,.617,.303,.568,.243,.61,.243,.61],['S',.22,.586,.201,.595],['C',.162,.613,.164,.628,.172,.638,.159,.63,.149,.625,.149,.625],['S',.09,.667,.113,.703],['Z']]
        [['M',.706,.183,.706,.183,.635,.246],['C',.581,.213,.528,.196,.528,.196,.441,.43,.329,.566,.329,.566],['S',.343,.57,.359,.58],['C',.348,.588,.335,.596,.319,.598,.288,.601,.236,.551,.202,.653],['L',.194,.648],['C',.189,.644,.181,.646,.176,.653,.171,.66,.171,.669,.176,.672],['L',.176,.672,.176,.672],['C',.176,.672,.176,.672,.176,.673,.176,.673,.176,.673,.176,.673],['L',.184,.678],['C',.166,.699,.136,.739,.133,.773,.079,.748,.124,.713,.124,.713],['L',.118,.7],['C',.038,.764,.156,.888,.218,.929,.281,.969,.326,.918,.326,.918,.363,.937,.486,.791,.486,.791],['S',.461,.751,.426,.723],['C',.421,.719,.416,.716,.411,.714,.407,.699,.399,.685,.384,.671,.378,.667,.384,.65,.403,.628,.406,.635,.408,.642,.41,.649,.41,.649,.57,.62,.655,.503,.655,.503,.664,.494,.652,.478],['L',.667,.46],['C',.667,.46,.676,.457,.68,.457,.681,.459,.68,.461,.679,.465,.668,.478,.667,.49,.688,.488,.69,.488,.691,.488,.692,.487,.709,.484,.718,.46,.711,.436,.708,.427,.703,.417,.694,.409,.718,.392,.741,.377,.75,.372,.743,.348,.729,.326,.711,.307],['L',.817,.189],['C',.817,.189,.841,.174,.817,.16,.817,.16,.813,.096,.745,.063],['L',.733,.077],['C',.737,.11,.782,.151,.781,.177],['L',.674,.273],['C',.674,.273,.673,.272,.673,.272],['L',.742,.194],['C',.742,.194,.767,.179,.743,.165,.743,.165,.739,.101,.67,.068],['L',.658,.082],['C',.663,.115,.707,.157,.706,.183],['Z']]
        [['M',.8,.464],['C',.907,.357,.927,.22,.854,.147],['S',.645,.094,.537,.2],['C',.48,.258,.445,.326,.436,.388],['L',.434,.387],['C',.433,.389,.414,.49,.395,.532,.381,.565,.357,.601,.348,.615],['L',.343,.61,.148,.803,.131,.805,.115,.821,.178,.885,.196,.867,.196,.848,.389,.656,.385,.652],['C',.399,.642,.434,.619,.467,.605,.51,.587,.611,.567,.612,.567],['L',.612,.565],['C',.674,.556,.742,.521,.8,.464],['L',.8,.464],['Z'],['M',.853,.343,.853,.344],['C',.847,.357,.84,.371,.832,.384],['L',.822,.374,.853,.343],['Z'],['M',.814,.382,.826,.393],['C',.818,.405,.809,.417,.799,.428],['L',.783,.412,.814,.382],['Z'],['M',.872,.248],['C',.872,.255,.872,.263,.872,.27],['L',.861,.259,.872,.248],['Z'],['M',.817,.15],['C',.824,.154,.831,.159,.836,.165,.841,.17,.845,.175,.849,.18],['L',.815,.213,.785,.182,.817,.15],['Z'],['M',.777,.19,.808,.221,.776,.252,.746,.221,.777,.19],['Z'],['M',.738,.228,.769,.259,.738,.29,.707,.259,.738,.228],['Z'],['M',.7,.267,.731,.298,.7,.328,.669,.297,.7,.267],['Z'],['M',.662,.305,.692,.336,.661,.367,.631,.335,.662,.305],['Z'],['M',.623,.343,.654,.374,.623,.405,.592,.374,.623,.343],['Z'],['M',.585,.381,.616,.412,.585,.443,.554,.412,.585,.381],['Z'],['M',.546,.419,.577,.45,.547,.481,.516,.45,.546,.419],['Z'],['M',.509,.457,.539,.488,.506,.521],['C',.501,.517,.496,.513,.491,.509,.486,.503,.481,.496,.476,.489],['L',.509,.457,.509,.457],['Z'],['M',.76,.13],['C',.778,.132,.794,.137,.808,.144],['L',.777,.175,.746,.144,.76,.13],['Z'],['M',.739,.151,.77,.182,.738,.214,.707,.183,.739,.151],['Z'],['M',.7,.19,.731,.221,.7,.252,.669,.221,.7,.19],['Z'],['M',.662,.228,.693,.259,.662,.29,.631,.259,.662,.228],['Z'],['M',.623,.266,.654,.297,.623,.328,.592,.297,.623,.266],['Z'],['M',.585,.304,.616,.335,.585,.366,.554,.335,.585,.304],['Z'],['M',.547,.343,.577,.374,.546,.404,.516,.373,.547,.343],['Z'],['M',.508,.381,.539,.412,.509,.442,.478,.411,.508,.381],['Z'],['M',.747,.129,.739,.137,.732,.129],['C',.737,.129,.742,.129,.747,.129],['Z'],['M',.672,.142],['C',.687,.136,.703,.133,.719,.131],['L',.732,.144,.7,.175,.669,.144,.672,.142],['Z'],['M',.662,.152,.693,.183,.662,.213,.631,.182,.662,.152],['Z'],['M',.624,.19,.654,.221,.623,.252,.593,.221,.624,.19],['Z'],['M',.585,.228,.616,.259,.585,.29,.554,.259,.585,.228],['Z'],['M',.547,.266,.578,.297,.547,.328,.516,.297,.547,.266],['Z'],['M',.487,.311],['C',.49,.305,.494,.299,.497,.293],['L',.501,.297,.487,.311],['Z'],['M',.509,.29,.503,.284],['C',.51,.272,.519,.26,.529,.248],['L',.54,.259,.509,.29],['Z'],['M',.547,.251,.535,.24],['C',.542,.233,.548,.225,.555,.219,.559,.215,.562,.212,.566,.208],['L',.578,.221,.547,.251],['Z'],['M',.585,.213,.573,.201],['C',.585,.191,.597,.183,.608,.175],['L',.616,.182,.585,.213],['Z'],['M',.624,.175,.617,.169],['C',.627,.163,.636,.158,.646,.153],['L',.624,.175],['Z'],['M',.509,.304,.539,.335,.508,.366,.478,.335,.509,.304],['Z'],['M',.458,.416],['C',.458,.413,.459,.41,.459,.407],['L',.459,.407,.463,.411,.458,.416],['Z'],['M',.47,.404,.46,.394],['C',.462,.378,.467,.361,.473,.345],['L',.473,.345,.501,.373,.47,.404],['Z'],['M',.47,.419,.501,.449,.471,.479],['C',.464,.465,.46,.448,.459,.43],['L',.47,.419],['Z'],['M',.457,.581,.457,.581],['C',.418,.598,.378,.626,.367,.634],['L',.366,.633],['C',.374,.622,.402,.581,.419,.542,.426,.525,.434,.498,.441,.471,.447,.492,.458,.511,.473,.526,.489,.542,.508,.553,.529,.559,.503,.566,.475,.574,.457,.581],['Z'],['M',.563,.541],['C',.546,.539,.53,.534,.515,.526],['L',.547,.495,.578,.526,.563,.541],['Z'],['M',.585,.519,.554,.488,.585,.458,.615,.489,.585,.519],['Z'],['M',.623,.481,.592,.45,.623,.419,.654,.45,.623,.481],['Z'],['M',.661,.443,.63,.412,.661,.381,.692,.412,.661,.443],['Z'],['M',.7,.405,.669,.374,.7,.343,.731,.374,.7,.405],['Z'],['M',.738,.367,.707,.336,.738,.305,.769,.336,.738,.367],['Z'],['M',.776,.329,.745,.298,.776,.267,.807,.298,.776,.329],['Z'],['M',.815,.29,.784,.259,.815,.228,.846,.259,.815,.29],['Z'],['M',.854,.252,.823,.221,.855,.189],['C',.863,.203,.868,.218,.87,.235],['L',.854,.252],['Z'],['M',.577,.542,.585,.534,.593,.541],['C',.587,.542,.582,.542,.577,.542],['Z'],['M',.651,.53],['C',.636,.535,.621,.538,.606,.54],['L',.592,.526,.623,.496,.623,.496,.654,.527,.651,.53],['Z'],['M',.661,.52,.63,.489,.661,.458,.692,.489,.661,.52],['Z'],['M',.699,.481,.669,.45,.7,.42,.73,.451,.699,.481],['Z'],['M',.738,.443,.707,.412,.738,.381,.769,.412,.738,.443],['Z'],['M',.776,.405,.745,.374,.776,.343,.807,.374,.776,.405],['Z'],['M',.814,.367,.784,.336,.815,.305,.845,.336,.814,.367],['Z'],['M',.853,.329,.822,.298,.854,.266,.87,.283],['C',.869,.295,.866,.307,.862,.319],['L',.853,.329],['Z'],['M',.675,.52,.699,.496,.707,.504],['C',.696,.51,.686,.516,.675,.52],['Z'],['M',.716,.498,.707,.489,.738,.458,.752,.473],['C',.74,.482,.728,.491,.716,.498],['Z'],['M',.76,.466,.745,.451,.776,.42,.792,.436],['C',.789,.439,.785,.443,.782,.446,.775,.453,.768,.46,.76,.466],['Z']]
        [['M',.454,.852],['C',.455,.846,.454,.832,.454,.822,.454,.812,.454,.797,.454,.788,.454,.769,.448,.752,.436,.739,.428,.73,.427,.729,.428,.721,.43,.706,.436,.694,.445,.689,.449,.686,.467,.675,.486,.664,.52,.645,.543,.63,.568,.611,.576,.606,.595,.595,.611,.588,.649,.571,.665,.558,.708,.508,.721,.493,.74,.473,.751,.463,.77,.446,.807,.421,.822,.416,.825,.414,.829,.412,.83,.41,.835,.4,.82,.381,.806,.376,.797,.373,.797,.368,.806,.358,.818,.345,.825,.331,.836,.299,.849,.26,.861,.229,.872,.204,.888,.173,.887,.148,.871,.143,.867,.141,.863,.139,.863,.138],['S',.866,.129,.872,.119],['C',.883,.097,.884,.088,.876,.077,.866,.063,.854,.062,.831,.07,.817,.075,.81,.076,.806,.075,.797,.071,.787,.074,.772,.083,.759,.091,.757,.091,.751,.088,.74,.083,.722,.084,.698,.091,.673,.099,.645,.113,.635,.123,.629,.13,.627,.13,.604,.133,.541,.141,.504,.152,.486,.167,.48,.171,.468,.185,.46,.198,.437,.231,.426,.242,.403,.253,.363,.273,.316,.307,.279,.343],['L',.264,.357,.238,.352],['C',.207,.346,.17,.345,.147,.349,.101,.358,.06,.378,.029,.409,.002,.436,-.012,.467,-.013,.499,-.013,.579,.048,.636,.137,.638,.162,.638,.198,.634,.212,.629,.217,.627,.223,.626,.224,.627,.226,.629,.211,.655,.198,.671],['L',.188,.683,.143,.69],['C',.118,.694,.097,.698,.095,.698,.094,.698,.092,.704,.092,.711,.091,.717,.088,.741,.085,.763,.082,.787,.08,.811,.082,.821,.084,.839,.09,.852,.097,.854,.099,.855,.11,.854,.12,.853,.236,.837,.31,.833,.366,.839,.389,.842,.428,.851,.443,.858],['L',.454,.863,.454,.852],['Z'],['M',.666,.143,.666,.139],['C',.669,.14,.669,.141,.666,.143],['Z'],['M',.743,.095,.736,.095],['C',.739,.095,.742,.095,.743,.095],['Z']]
        [['M',.933,.101],['C',.893,.085,.853,.069,.812,.057,.8,.05,.783,.028,.771,.045,.761,.059,.767,.077,.755,.091,.737,.128,.715,.165,.685,.193,.664,.19,.641,.176,.619,.169,.598,.162,.593,.18,.586,.196,.567,.238,.55,.281,.522,.317,.47,.393,.414,.466,.362,.542,.309,.562,.254,.579,.205,.608,.159,.631,.116,.661,.067,.678,.05,.681,.043,.699,.025,.698,.002,.705,-.022,.71,-.046,.706,-.069,.716,-.098,.721,-.113,.742,-.123,.789,-.055,.778,-.029,.762,.018,.746,.067,.754,.113,.761,.146,.751,.181,.744,.211,.727,.235,.705,.268,.714,.296,.703,.318,.699,.341,.703,.363,.696,.407,.669,.459,.667,.506,.65,.523,.643,.553,.654,.546,.677,.539,.7,.508,.691,.49,.697,.44,.705,.39,.718,.343,.737,.314,.739,.285,.736,.256,.736,.24,.752,.243,.774,.263,.786,.279,.795,.297,.779,.312,.774,.331,.766,.339,.784,.357,.783,.389,.781,.419,.795,.449,.805,.49,.799,.53,.806,.569,.818,.591,.822,.61,.843,.633,.832,.657,.828,.677,.808,.701,.807,.723,.819,.707,.854,.711,.877,.71,.895,.711,.912,.73,.919,.754,.939,.793,.936,.809,.908,.821,.891,.822,.871,.819,.851,.832,.838,.827,.81,.808,.805,.793,.791,.791,.768,.782,.75,.789,.706,.817,.667,.817,.621,.823,.588,.803,.558,.786,.531,.775,.513,.76,.494,.738,.491,.723,.496,.708,.502,.691,.494,.676,.487,.65,.484,.644,.505,.642,.522,.609,.52,.61,.511,.625,.474,.639,.436,.657,.401,.677,.388,.692,.372,.702,.351,.722,.312,.737,.269,.753,.228,.763,.196,.775,.164,.79,.134,.817,.095,.863,.1,.904,.108,.915,.107,.926,.111,.933,.101],['Z']]
        [['M',.664,.264,.656,.26],['C',.646,.255,.636,.253,.624,.254,.6,.255,.518,.281,.475,.299,.447,.31,.445,.308,.428,.304,.407,.298,.353,.301,.342,.315,.332,.328,.349,.332,.374,.343,.369,.347,.364,.351,.353,.357,.283,.398,.23,.465,.201,.529,.182,.573,.176,.611,.177,.681,.178,.727,.177,.742,.172,.753,.17,.757,.152,.771,.134,.785,.101,.812,.073,.839,.071,.845,.067,.858,.082,.849,.097,.847,.112,.845,.132,.844,.146,.845],['S',.169,.85,.175,.847],['C',.179,.846,.187,.838,.192,.83,.202,.814,.203,.81,.206,.821,.209,.837,.21,.842,.233,.834,.243,.831,.257,.831,.277,.837,.291,.84,.3,.847,.305,.844,.311,.84,.3,.822,.295,.816,.292,.812,.279,.801,.267,.791,.226,.759,.215,.736,.223,.702,.231,.666,.26,.636,.316,.608,.332,.6,.352,.59,.368,.585,.389,.579,.391,.577,.395,.574,.411,.562,.448,.534,.499,.499,.524,.482,.558,.458,.57,.447,.593,.426,.625,.393,.651,.378,.68,.362,.686,.349,.684,.315,.682,.29,.678,.285,.679,.283,.692,.279,.699,.265,.712,.26,.725,.255,.736,.239,.751,.233,.767,.228,.78,.21,.793,.205,.809,.198,.821,.182,.835,.176,.85,.169,.861,.155,.874,.149,.887,.142,.895,.131,.905,.126,.915,.121,.921,.114,.925,.109,.93,.105,.931,.103,.93,.103,.93,.102,.927,.103,.922,.106],['S',.895,.12,.887,.127],['C',.877,.136,.865,.138,.854,.148,.842,.158,.827,.162,.815,.172,.801,.184,.784,.188,.771,.2,.757,.213,.74,.216,.728,.227,.716,.238,.7,.239,.691,.251,.689,.254,.673,.259,.664,.264],['Z']]
        [['M',.644,.178,.315,.167],['C',.314,.214,.317,.223,.394,.226,.381,.263,.328,.351,.3,.35,.275,.349,.245,.346,.247,.29,.249,.226,.145,.12,.118,.161,.077,.222,.183,.207,.178,.358,.171,.565,.052,.531,.048,.647,.046,.706,.062,.714,.06,.755,.059,.81,.01,.806,.018,.851,.024,.883,.028,.909,.031,.947,.032,.974,.032,1.003,.06,1.002,.093,1.002,.108,.944,.159,.942,.21,.94,.252,.989,.272,.982,.292,.976,.288,.923,.277,.885,.261,.825,.224,.746,.297,.737],['S',.495,.72,.589,.604,.684,.348,.721,.306],['C',.844,.164,.964,.228,.968,.107,.97,.053,.879,.011,.864,.028],['S',.985,.101,.829,.158],['C',.695,.206,.683,.216,.644,.178],['Z']]
        [['M',.894,.032],['C',.889,.023,.882,.023,.874,.026,.856,.023,.85,.029,.838,.032,.804,.059,.769,.079,.737,.124,.711,.153,.661,.174,.613,.196,.585,.214,.549,.231,.53,.251,.501,.268,.461,.286,.444,.301,.414,.317,.378,.326,.354,.35,.315,.363,.331,.336,.235,.392,.181,.408,.143,.42,.1,.433,.075,.425,.054,.422,.031,.417,-.017,.423,.014,.45,.02,.457,.043,.463,.066,.466,.089,.467,.11,.468,.133,.461,.156,.453,.194,.439,.215,.447,.232,.462,.221,.564,.213,.665,.278,.741,.288,.78,.298,.819,.24,.839,.2,.848,.153,.841,.121,.875],['L',.1,.897],['C',.1,.914,.095,.935,.121,.934,.179,.857,.202,.886,.238,.876,.274,.882,.301,.873,.33,.868,.364,.871,.368,.881,.375,.891,.383,.909,.41,.905,.432,.906,.47,.897,.509,.889,.534,.862,.559,.832,.597,.804,.602,.772,.622,.745,.605,.723,.602,.699],['L',.594,.674],['C',.623,.667,.63,.634,.643,.609,.675,.566,.688,.572,.706,.568,.756,.564,.751,.58,.772,.564,.779,.558,.776,.55,.774,.543],['L',.764,.506],['C',.753,.394,.73,.363,.706,.329,.698,.328,.695,.323,.694,.316,.712,.272,.789,.255,.84,.226,.866,.207,.899,.195,.895,.152,.89,.138,.889,.124,.9,.106,.897,.081,.887,.055,.894,.032],['Z'],['M',.65,.334],['C',.622,.341,.6,.36,.576,.374,.585,.424,.605,.475,.595,.521,.588,.53,.596,.537,.598,.545,.596,.555,.63,.601,.574,.604,.579,.615,.581,.624,.584,.634,.653,.557,.68,.541,.729,.531],['L',.679,.356],['C',.676,.339,.669,.328,.65,.334],['Z'],['M',.516,.403,.494,.42,.532,.494,.516,.403],['Z']]
        [['M',.039,.708],['C',.038,.678,.059,.652,.081,.636,.086,.633,.091,.629,.095,.625,.11,.613,.123,.6,.138,.589,.154,.577,.177,.559,.192,.546,.196,.541,.216,.537,.22,.533,.233,.522,.249,.515,.261,.504,.265,.5,.294,.493,.294,.493,.314,.486,.325,.484,.347,.48,.399,.469,.445,.49,.487,.513,.494,.516,.501,.525,.506,.53,.516,.539,.526,.552,.524,.567,.52,.599,.454,.653,.436,.679,.431,.686,.427,.696,.422,.704,.397,.74,.377,.778,.357,.818,.339,.854,.317,.89,.32,.932,.32,.942,.328,.958,.334,.966,.339,.974,.344,.982,.344,.982,.344,.978,.34,.974,.339,.971,.335,.961,.331,.939,.332,.928,.336,.897,.353,.87,.369,.843,.383,.819,.392,.788,.409,.762,.454,.691,.512,.629,.569,.566,.577,.556,.585,.547,.591,.536,.592,.533,.596,.532,.597,.529,.602,.516,.598,.501,.604,.488,.611,.471,.633,.461,.646,.452,.652,.448,.655,.441,.661,.438,.685,.424,.701,.402,.723,.385,.749,.364,.778,.372,.81,.366,.829,.363,.849,.36,.869,.359,.877,.358,.888,.364,.896,.366,.919,.372,.935,.393,.955,.403,.958,.405,.971,.415,.972,.406,.975,.385,.934,.33,.92,.312,.912,.302,.907,.289,.899,.278,.889,.266,.863,.236,.847,.228,.837,.223,.825,.218,.815,.214,.808,.211,.803,.205,.797,.203,.788,.199,.777,.198,.768,.194,.766,.193,.741,.174,.741,.172,.74,.169,.74,.165,.739,.162],['L',.739,.162],['C',.735,.138,.742,.117,.751,.095,.756,.084,.756,.071,.759,.06,.76,.057,.766,.042,.764,.04,.756,.033,.717,.09,.715,.097,.713,.103,.703,.118,.699,.122,.698,.123,.693,.123,.691,.124,.686,.127,.681,.132,.676,.134,.663,.139,.647,.13,.634,.135,.624,.139,.618,.155,.608,.159,.602,.162,.592,.115,.589,.108,.587,.103,.583,.096,.578,.092,.578,.092,.576,.09,.575,.088,.576,.093,.578,.104,.578,.104,.579,.129,.562,.166,.553,.187,.546,.205,.527,.218,.512,.228,.504,.235,.491,.236,.482,.24,.461,.251,.442,.266,.421,.276,.41,.281,.392,.286,.382,.293,.378,.296,.375,.3,.37,.304,.352,.317,.333,.329,.316,.343,.282,.371,.25,.402,.217,.431,.21,.437,.201,.44,.195,.446,.186,.453,.176,.461,.168,.469,.166,.47,.155,.484,.154,.484,.148,.489,.14,.492,.134,.497,.129,.501,.126,.508,.12,.512,.106,.525,.094,.537,.082,.551,.075,.559,.063,.568,.058,.577,.051,.591,.048,.608,.041,.622,.029,.642,.016,.687,.018,.715,.02,.746,.039,.751,.039,.708],['Z'],['M',.713,.184],['C',.722,.175,.717,.207,.71,.208,.711,.201,.708,.191,.713,.184],['Z'],['M',.618,.23],['C',.611,.212,.634,.205,.631,.231,.618,.24,.622,.239,.618,.23],['Z']]
        [['M',.303,.208],['C',.311,.204,.328,.196,.334,.193,.341,.191,.347,.19,.348,.191,.349,.191,.35,.197,.35,.213,.35,.222,.35,.226,.352,.232,.357,.251,.365,.269,.38,.3,.39,.321,.397,.336,.401,.347,.404,.355,.406,.356,.411,.365,.416,.371,.421,.377,.426,.382,.446,.403,.452,.41,.463,.429,.467,.437,.471,.444,.471,.445,.472,.446,.475,.452,.478,.459,.482,.467,.485,.474,.486,.475],['L',.487,.478,.49,.476],['C',.491,.474,.496,.472,.5,.469,.507,.466,.509,.464,.513,.461,.522,.452,.534,.437,.554,.41,.568,.39,.582,.372,.59,.363,.6,.352,.609,.345,.627,.336,.641,.329,.647,.325,.651,.319,.654,.315,.655,.311,.654,.302,.652,.284,.652,.284,.661,.274,.67,.266,.671,.264,.669,.254,.668,.246,.667,.244,.665,.237,.66,.226,.656,.218,.643,.199,.62,.167,.601,.148,.568,.126,.552,.114,.552,.115,.533,.112,.525,.111,.513,.106,.51,.103,.507,.099,.507,.088,.512,.081,.517,.072,.525,.067,.555,.053,.563,.049,.575,.043,.581,.039,.587,.036,.593,.033,.594,.032],['L',.596,.031,.598,.035],['C',.604,.045,.613,.061,.618,.068,.626,.077,.632,.084,.646,.095,.661,.106,.668,.113,.675,.12,.678,.123,.683,.128,.686,.13,.699,.141,.705,.145,.705,.145,.706,.144,.704,.131,.702,.121,.698,.106,.696,.096,.696,.092,.69,.061,.684,.037,.677,.025,.674,.021,.673,.02,.669,.016,.662,.01,.661,.008,.662,.004,.663,-.001,.666,-.005,.675,-.01,.693,-.021,.7,-.025,.707,-.028,.715,-.031,.737,-.04,.738,-.039,.739,-.039,.74,-.031,.741,-.02,.742,-.012,.748,.031,.749,.042,.753,.064,.759,.091,.764,.11,.77,.132,.781,.163,.788,.176,.789,.179,.79,.183,.791,.185,.792,.187,.8,.203,.812,.224,.813,.228,.817,.235,.819,.239,.826,.254,.831,.26,.842,.267,.845,.269,.848,.272,.85,.274,.858,.282,.864,.287,.865,.287,.866,.287,.867,.287,.869,.288,.872,.289,.874,.289,.873,.288,.873,.288,.87,.282,.867,.275,.861,.264,.85,.243,.835,.215,.825,.196,.809,.164,.807,.16,.807,.158,.805,.154,.803,.151,.793,.13,.789,.118,.784,.099,.781,.082,.779,.076,.777,.07],['L',.775,.066,.78,.073],['C',.793,.092,.802,.112,.81,.137,.817,.161,.829,.185,.854,.229,.872,.258,.882,.275,.901,.306,.922,.338,.929,.351,.938,.378,.944,.392,.945,.398,.949,.412,.968,.483,.961,.543,.929,.59,.913,.613,.894,.631,.867,.648,.845,.662,.831,.669,.793,.684,.766,.695,.758,.699,.735,.716,.692,.747,.667,.774,.649,.805,.641,.819,.639,.822,.63,.833,.619,.845,.599,.86,.589,.866,.575,.873,.537,.882,.517,.883,.51,.883,.503,.885,.498,.887,.497,.888,.489,.892,.481,.897,.463,.907,.46,.909,.446,.912,.416,.92,.399,.92,.372,.914,.355,.91,.33,.901,.308,.89,.299,.886,.278,.874,.278,.873,.277,.873,.274,.871,.271,.869,.258,.861,.242,.851,.219,.834,.21,.828,.201,.821,.199,.82,.197,.818,.192,.815,.187,.811,.178,.805,.176,.804,.17,.804,.163,.804,.154,.807,.136,.817,.121,.825,.116,.827,.116,.826,.114,.824,.114,.817,.116,.814,.118,.809,.121,.805,.129,.798,.14,.788,.142,.786,.145,.781,.147,.779,.149,.777,.149,.777,.148,.777,.14,.768,.129,.757,.102,.73,.085,.713,.057,.683,.018,.641,-.028,.585,-.071,.525,-.08,.511,-.087,.503,-.092,.499,-.094,.498,-.095,.497,-.095,.497],['S',-.094,.496,-.093,.495],['C',-.091,.494,-.088,.49,-.085,.486,-.079,.479,-.077,.476,-.074,.475,-.072,.475,-.07,.478,-.067,.485,-.063,.494,-.052,.509,-.027,.536,-.009,.557,.024,.589,.047,.608,.051,.611,.055,.615,.056,.615,.062,.621,.108,.66,.115,.666,.166,.71,.196,.731,.225,.742,.241,.747,.249,.747,.269,.741,.278,.737,.284,.736,.3,.733,.318,.73,.326,.729,.331,.726,.335,.723,.335,.723,.335,.721,.335,.719,.333,.717,.329,.712,.321,.704,.318,.699,.318,.697,.318,.694,.336,.677,.345,.67,.352,.665,.355,.663,.362,.66,.375,.655,.394,.642,.398,.637,.401,.632,.402,.627,.401,.622,.4,.615,.397,.609,.388,.593,.376,.574,.373,.57,.346,.549,.337,.542,.325,.532,.32,.528,.299,.509,.291,.504,.241,.476,.218,.463,.208,.457,.197,.448,.183,.438,.177,.431,.169,.42,.164,.414,.16,.409,.159,.408,.155,.405,.15,.403,.139,.402,.127,.402,.117,.4,.099,.395],['L',.085,.391,.086,.386],['C',.087,.379,.091,.367,.093,.362,.1,.345,.11,.336,.133,.324,.138,.321,.147,.316,.152,.313,.158,.31,.162,.307,.162,.307],['S',.166,.312,.171,.317],['C',.188,.34,.203,.354,.223,.368,.235,.376,.241,.379,.252,.384,.263,.389,.273,.394,.285,.4,.296,.406,.309,.412,.321,.417,.329,.419,.337,.421,.338,.42,.338,.42,.336,.414,.334,.406,.331,.393,.329,.387,.32,.352,.315,.338,.314,.332,.312,.316,.308,.289,.306,.279,.301,.275,.299,.272,.293,.27,.291,.27,.289,.27,.267,.263,.262,.261,.26,.26,.249,.253,.248,.251,.248,.251,.25,.248,.263,.237,.268,.232,.296,.212,.303,.208],['Z']]
        [['M',.84,.14],['C',.919,.268,.888,.427,.75,.498,.687,.526,.782,.546,.804,.564,.779,.574,.769,.58,.768,.591],['S',.789,.621,.802,.643],['C',.779,.643,.751,.616,.732,.633,.714,.648,.755,.67,.759,.696,.74,.692,.709,.66,.685,.675,.666,.687,.683,.729,.674,.741,.651,.688,.621,.665,.573,.669,.571,.667,.573,.662,.584,.64,.595,.618,.598,.598,.571,.589,.544,.58,.535,.579,.54,.626,.546,.728,.474,.784,.37,.802,.351,.803,.362,.834,.367,.849],['S',.369,.865,.365,.868],['C',.329,.864,.313,.861,.298,.904,.283,.9,.274,.885,.258,.883,.24,.879,.231,.909,.218,.91,.206,.898,.213,.879,.199,.87,.181,.859,.142,.871,.137,.854,.145,.848,.154,.842,.149,.836,.142,.826,.107,.82,.108,.814,.108,.809,.143,.807,.12,.787],['S',.097,.725,.112,.695],['C',.147,.634,.139,.572,.126,.505,.119,.478,.128,.47,.147,.47,.166,.471,.184,.486,.19,.511,.196,.536,.203,.544,.237,.578],['S',.279,.626,.282,.64,.275,.681,.27,.687],['C',.266,.692,.288,.684,.306,.676,.324,.668,.331,.653,.304,.577,.275,.504,.261,.432,.311,.37,.347,.328,.406,.303,.52,.346,.65,.395,.764,.352,.763,.209,.753,.121,.66,.085,.602,.151,.567,.197,.595,.254,.659,.238,.691,.229,.697,.239,.674,.257,.644,.28,.592,.27,.56,.239,.504,.186,.532,.114,.59,.079,.681,.023,.781,.061,.84,.14],['Z']]
        [['M',.148,.852],['C',.194,.891,.231,.859,.231,.859],['L',.556,.512],['C',.555,.514,.617,.446,.624,.439],['S',.696,.397,.708,.388],['C',.721,.378,.813,.357,.817,.354,.821,.352,.866,.341,.871,.336],['L',.871,.336],['C',.876,.331,.884,.315,.888,.303,.891,.291,.894,.265,.894,.265],['S',.889,.194,.886,.184],['C',.882,.174,.869,.158,.869,.158],['S',.818,.255,.811,.259],['C',.804,.262,.789,.254,.789,.254],['L',.729,.22,.785,.115],['C',.785,.115,.778,.112,.766,.114,.75,.116,.727,.123,.713,.129,.693,.136,.655,.163,.643,.172],['L',.616,.157],['C',.616,.157,.603,.177,.602,.181,.602,.186,.607,.214,.607,.214],['S',.598,.269,.594,.283],['C',.59,.298,.577,.331,.569,.344,.56,.358,.551,.368,.551,.368],['L',.137,.78],['C',.137,.78,.117,.826,.148,.852],['Z'],['M',.162,.783],['C',.177,.767,.202,.766,.217,.781,.233,.796,.234,.821,.219,.837,.204,.853,.179,.853,.163,.838,.147,.823,.147,.798,.162,.783],['Z']]
        [['M',.731,.239],['C',.708,.235,.681,.242,.659,.232,.608,.211,.576,.149,.543,.108,.53,.092,.508,.078,.498,.06,.486,.038,.52,.018,.531,0,.539,-.012,.543,-.025,.526,-.03,.524,-.037,.518,-.039,.512,-.033,.494,-.015,.481,.007,.462,.024,.461,.013,.456,-.003,.444,.012,.433,.027,.443,.037,.442,.052,.441,.072,.435,.086,.441,.105,.446,.125,.463,.14,.475,.156,.49,.178,.5,.204,.516,.225],['L',.514,.228],['C',.452,.197,.371,.169,.325,.114,.311,.097,.344,.059,.327,.046,.317,.038,.311,.063,.31,.068],['L',.307,.067],['C',.309,.035,.279,.002,.269,.048,.257,.044,.248,.049,.255,.062,.242,.077,.258,.089,.26,.107,.261,.126,.256,.142,.264,.161,.284,.209,.347,.244,.381,.284,.397,.304,.403,.331,.42,.349,.432,.362,.468,.354,.472,.364,.479,.377,.449,.404,.442,.414,.421,.445,.414,.502,.405,.539],['L',.402,.537],['C',.402,.431,.314,.382,.219,.375,.186,.373,.152,.388,.121,.374,.134,.347,.166,.327,.175,.299,.185,.267,.125,.246,.102,.257,.084,.267,.094,.286,.089,.301,.079,.336,.04,.381,.051,.421,.056,.438,.074,.441,.087,.45,.111,.467,.134,.488,.158,.506],['L',.156,.511],['C',.125,.511,.074,.54,.054,.563,.039,.581,.025,.614,-.001,.614,.022,.594,.058,.553,.053,.519,.046,.476,-.002,.535,-.01,.549,-.026,.537,-.048,.532,-.05,.559,-.053,.594,-.045,.641,-.032,.674,-.028,.683,-.029,.695,-.021,.702,-.006,.714,.017,.701,.032,.695,.071,.679,.11,.634,.155,.651,.22,.676,.229,.744,.268,.794,.302,.836,.369,.86,.42,.874,.386,.898,.34,.887,.305,.872,.23,.839,.192,.765,.106,.749,.083,.744,.042,.733,.021,.749,.006,.759,.016,.775,.03,.779,.087,.794,.13,.804,.178,.844,.218,.877,.252,.91,.297,.936,.311,.945,.324,.957,.341,.958,.371,.96,.418,.952,.442,.933,.461,.918,.472,.894,.49,.878,.504,.865,.524,.86,.539,.848,.569,.824,.592,.794,.62,.769,.669,.724,.725,.678,.786,.649,.82,.633,.86,.634,.894,.614,.985,.559,1.056,.432,1.061,.328,1.063,.28,1.04,.236,1.014,.197,1.007,.187,1.002,.17,.99,.164,.978,.158,.964,.165,.952,.165,.931,.166,.908,.161,.888,.155,.866,.148,.86,.125,.839,.117,.821,.11,.782,.098,.764,.106,.723,.125,.725,.203,.731,.239],['Z']]
        [['M',.676,.599,.656,.573,.631,.56,.625,.527,.625,.505,.652,.49,.735,.46,.768,.448,.775,.458,.769,.463],['C',.777,.469,.782,.466,.789,.461],['L',.78,.451,.774,.442,.866,.349,.945,.246,.939,.24],['C',.918,.259,.886,.246,.86,.251,.844,.253,.832,.268,.819,.276,.802,.286,.779,.292,.76,.295,.741,.299,.722,.279,.707,.282,.693,.285,.678,.309,.67,.319,.646,.346,.59,.391,.552,.375,.54,.37,.544,.354,.534,.347],['L',.529,.371],['C',.518,.366,.51,.371,.499,.37,.47,.369,.442,.373,.414,.368,.405,.367,.386,.348,.38,.361,.375,.373,.388,.392,.388,.404,.389,.421,.383,.436,.381,.452,.379,.47,.38,.489,.374,.507,.353,.495,.354,.52,.377,.516,.381,.552,.349,.593,.331,.622,.324,.633,.321,.643,.309,.652,.296,.663,.279,.667,.265,.677,.285,.707,.256,.768,.236,.794,.229,.802,.214,.81,.209,.818,.206,.825,.215,.836,.215,.843,.213,.863,.201,.888,.192,.905,.204,.914,.239,.889,.252,.882,.311,.85,.365,.81,.414,.764,.418,.768,.423,.775,.429,.776,.439,.778,.44,.766,.436,.76],['L',.428,.767,.423,.761],['C',.438,.745,.442,.724,.45,.704,.457,.688,.467,.673,.474,.658,.481,.644,.491,.623,.508,.62,.519,.617,.531,.623,.542,.627,.55,.629,.56,.63,.566,.634,.579,.643,.586,.66,.596,.671],['L',.617,.635,.676,.599],['Z']]
        [['M',.834,.832],['C',.838,.828,.844,.819,.835,.816,.823,.811,.792,.828,.779,.83,.769,.831,.76,.823,.751,.821,.734,.816,.716,.818,.699,.823,.717,.788,.741,.756,.759,.721,.783,.676,.798,.628,.818,.582,.827,.562,.842,.545,.851,.525,.858,.51,.87,.493,.873,.477,.88,.451,.881,.431,.894,.406,.906,.384,.923,.364,.933,.343,.939,.33,.94,.315,.945,.302,.95,.289,.967,.271,.955,.257,.945,.243,.896,.21,.891,.238,.888,.256,.904,.268,.904,.285,.904,.306,.883,.329,.902,.347],['L',.857,.444,.828,.481,.798,.534,.728,.609,.672,.663,.667,.661],['C',.685,.62,.699,.577,.723,.538,.736,.519,.762,.506,.771,.485,.777,.47,.772,.451,.775,.434,.784,.386,.791,.333,.794,.284,.795,.263,.79,.237,.796,.217,.799,.208,.814,.197,.81,.187,.807,.181,.797,.178,.792,.175,.779,.167,.741,.135,.725,.15,.714,.161,.731,.187,.737,.198,.76,.241,.764,.283,.758,.331,.754,.368,.741,.42,.719,.452,.688,.497,.642,.531,.607,.573,.591,.535,.542,.49,.509,.466,.524,.438,.542,.403,.537,.37,.535,.354,.52,.341,.522,.325,.522,.317,.529,.311,.532,.304,.538,.281,.542,.257,.551,.235,.561,.214,.584,.2,.6,.185,.621,.165,.637,.139,.652,.115,.657,.108,.667,.102,.67,.094,.676,.079,.64,.067,.63,.064,.635,.055,.646,.044,.646,.034,.645,.017,.609,0,.596,-.007,.587,-.011,.567,-.031,.556,-.022,.551,-.017,.554,-.008,.555,-.002,.559,.023,.574,.034,.58,.057,.588,.086,.568,.125,.556,.151,.546,.174,.532,.206,.513,.222,.502,.231,.488,.231,.478,.241,.463,.256,.459,.28,.439,.291,.408,.309,.376,.291,.354,.327],['L',.352,.326],['C',.362,.256,.276,.234,.223,.255,.158,.28,.111,.33,.08,.391,.064,.423,.046,.453,.026,.483,.015,.5,.013,.511,-.006,.521],['L',-.008,.52],['C',-.018,.491,-.065,.486,-.074,.519,-.084,.555,-.051,.588,-.028,.612,-.034,.619,-.042,.625,-.047,.634,-.058,.652,-.046,.669,-.028,.676,.003,.688,.039,.691,.071,.687,.102,.684,.146,.669,.164,.641,.174,.626,.174,.607,.185,.592,.201,.652,.185,.73,.165,.787,.158,.807,.131,.819,.132,.842,.132,.853,.14,.86,.146,.868,.162,.889,.19,.915,.216,.924,.273,.944,.308,.84,.36,.89,.384,.913,.352,.94,.35,.962,.345,.999,.382,1.012,.407,1.025,.415,1.029,.421,1.037,.431,1.037,.45,1.039,.469,1.025,.48,1.011,.505,.982,.518,.946,.55,.922,.558,.916,.569,.914,.578,.908,.623,.88,.661,.853,.717,.849,.742,.847,.762,.857,.786,.858,.803,.858,.853,.865,.834,.832],['Z']]
        [['M',.27,.45,.24,.44,.237,.445,.243,.464],['C',.235,.46,.229,.458,.222,.465,.228,.479,.215,.484,.206,.494],['L',.228,.502],['C',.219,.523,.247,.514,.258,.521],['L',.322,.436,.326,.438],['C',.319,.469,.33,.509,.356,.527,.312,.552,.303,.595,.283,.636,.256,.624,.196,.673,.196,.701],['L',.166,.723,.132,.732,.111,.773,.116,.776,.132,.765,.122,.794],['C',.135,.794,.144,.779,.151,.768],['L',.153,.769,.155,.789],['C',.178,.779,.18,.737,.203,.723,.22,.713,.267,.74,.253,.753],['L',.263,.756,.262,.758,.255,.76,.248,.752],['C',.245,.757,.239,.757,.235,.762,.228,.771,.226,.784,.221,.795,.208,.819,.192,.832,.182,.857,.177,.871,.171,.899,.178,.913,.185,.928,.228,.929,.243,.929,.296,.929,.328,.907,.375,.888,.394,.88,.415,.88,.43,.866,.421,.84,.45,.826,.421,.806,.447,.788,.466,.768,.49,.748,.504,.737,.521,.731,.535,.72,.585,.678,.615,.626,.628,.563,.632,.543,.638,.528,.635,.507,.631,.482,.62,.457,.608,.435,.595,.41,.585,.388,.566,.368,.547,.346,.519,.347,.495,.333],['L',.486,.334,.486,.339,.444,.334],['C',.474,.313,.515,.292,.552,.288,.591,.285,.627,.303,.664,.304,.711,.306,.758,.296,.804,.289,.827,.285,.85,.279,.872,.275,.89,.273,.911,.274,.924,.259,.93,.253,.933,.245,.936,.237,.961,.183,.91,.177,.869,.168,.79,.152,.709,.155,.63,.161,.612,.162,.595,.157,.577,.159,.519,.167,.448,.214,.416,.265,.399,.292,.393,.325,.372,.351,.343,.388,.298,.413,.27,.45],['Z']]
        [['M',.568,.086],['C',.559,.094,.545,.119,.566,.122,.578,.123,.603,.11,.612,.103,.626,.092,.625,.057,.602,.067],['L',.593,.055],['C',.611,.045,.635,.056,.65,.068,.66,.077,.665,.095,.672,.106,.693,.136,.715,.165,.738,.193,.747,.205,.768,.221,.769,.236,.769,.251,.76,.266,.758,.28,.757,.291,.761,.301,.758,.312,.751,.334,.737,.35,.75,.373,.71,.372,.674,.369,.638,.348,.612,.334,.599,.3,.58,.278,.567,.263,.55,.253,.537,.238,.521,.218,.509,.195,.493,.177,.484,.165,.468,.158,.459,.147,.444,.126,.458,.08,.43,.066,.416,.06,.404,.072,.395,.081,.375,.1,.361,.126,.348,.151,.344,.16,.337,.168,.338,.177,.343,.201,.381,.203,.394,.219,.404,.231,.406,.249,.413,.263,.427,.292,.444,.32,.464,.345],['L',.463,.347],['C',.44,.332,.408,.317,.381,.311,.365,.307,.336,.308,.322,.298,.298,.28,.308,.231,.266,.229,.225,.227,.224,.29,.213,.316,.208,.33,.192,.344,.203,.361,.218,.383,.249,.38,.271,.391,.295,.403,.315,.424,.341,.435,.359,.444,.388,.444,.404,.456,.415,.464,.423,.482,.433,.493],['L',.347,.542,.308,.56],['C',.291,.549,.272,.535,.254,.526,.245,.522,.232,.524,.226,.516,.213,.501,.224,.452,.202,.449,.189,.447,.177,.458,.168,.466,.147,.484,.096,.538,.105,.57,.11,.584,.126,.594,.137,.602,.166,.622,.194,.646,.227,.659,.194,.673,.159,.657,.125,.652,.113,.65,.093,.649,.085,.639,.073,.624,.081,.56,.045,.567,.035,.569,.027,.579,.019,.585,-.003,.603,-.062,.663,-.04,.694,-.019,.723,.031,.754,.064,.767,.084,.775,.105,.776,.123,.786,.14,.796,.149,.818,.164,.831,.185,.848,.21,.855,.232,.87,.246,.879,.257,.894,.271,.904,.2,.885,.155,.821,.087,.796,.077,.792,.03,.76,.023,.78,.02,.788,.03,.797,.036,.8,.063,.81,.09,.815,.114,.832,.126,.84,.135,.854,.146,.864,.212,.922,.303,1.003,.399,.979,.441,.968,.479,.95,.519,.934,.551,.921,.585,.909,.611,.886,.63,.868,.639,.841,.655,.821,.689,.777,.728,.739,.764,.697,.781,.677,.791,.654,.81,.636,.849,.597,.906,.588,.948,.552,.961,.541,.976,.515,.983,.499,.99,.484,.986,.47,.986,.454,.986,.409,.979,.345,.957,.304,.943,.279,.916,.259,.898,.236,.872,.204,.857,.166,.827,.137,.795,.106,.751,.088,.715,.062,.687,.043,.665,.005,.632,-.004,.585,-.016,.523,.047,.568,.086],['Z']]
        [['M',.73,.073],['C',.719,.083,.72,.097,.716,.11,.712,.127,.703,.143,.69,.155,.664,.18,.626,.191,.593,.205,.586,.208,.582,.215,.575,.219,.559,.229,.543,.235,.527,.247,.491,.276,.468,.318,.433,.347,.414,.363,.387,.357,.37,.379,.357,.396,.361,.425,.347,.439,.342,.475,.303,.485,.279,.507,.264,.521,.25,.536,.234,.549,.224,.557,.211,.56,.2,.567,.184,.576,.169,.589,.153,.599,.145,.604,.14,.614,.131,.619,.119,.628,.106,.63,.092,.636,.08,.642,.069,.651,.057,.657,.048,.661,.033,.662,.024,.659,.016,.657,.004,.652,-.003,.659,-.012,.669,.004,.678,.01,.684,.026,.697,.054,.687,.073,.683,.094,.678,.103,.665,.12,.654,.131,.647,.144,.645,.155,.638,.164,.632,.171,.622,.181,.617,.186,.614,.193,.615,.199,.613,.214,.607,.232,.597,.244,.587],['L',.246,.589],['C',.221,.613,.203,.641,.182,.668,.17,.682,.154,.694,.139,.707,.133,.713,.129,.721,.121,.723,.113,.726,.101,.731,.093,.731,.085,.731,.079,.723,.07,.727,.065,.731,.067,.739,.07,.744,.076,.753,.091,.77,.103,.764,.108,.761,.106,.756,.11,.752,.118,.746,.133,.749,.142,.742,.172,.721,.192,.686,.217,.659,.232,.643,.253,.633,.269,.617,.282,.605,.293,.59,.305,.578,.308,.574,.319,.568,.315,.564],['L',.348,.537],['C',.361,.558,.373,.576,.39,.594,.394,.599,.408,.607,.408,.614,.408,.625,.394,.633,.392,.644,.386,.67,.376,.688,.365,.711,.36,.723,.357,.738,.35,.747,.321,.783,.273,.799,.23,.808,.208,.813,.191,.827,.168,.818,.156,.825,.13,.805,.123,.818,.118,.827,.129,.834,.136,.838,.152,.848,.176,.859,.196,.852,.204,.85,.211,.844,.219,.841,.242,.831,.267,.825,.291,.818,.316,.812,.343,.812,.366,.797,.384,.784,.386,.762,.402,.748],['L',.404,.749],['C',.396,.767,.397,.785,.387,.802,.379,.816,.365,.823,.354,.834,.328,.859,.294,.9,.255,.904,.242,.906,.231,.896,.219,.893],['L',.217,.895],['C',.21,.931,.269,.949,.292,.925,.332,.883,.388,.856,.428,.811,.44,.798,.433,.786,.439,.773,.454,.741,.479,.724,.508,.705,.521,.696,.53,.684,.547,.683,.523,.711,.498,.739,.474,.767,.457,.787,.443,.81,.424,.828,.413,.838,.405,.849,.395,.861,.392,.866,.386,.873,.391,.878,.399,.888,.411,.874,.416,.868,.429,.855,.473,.827,.463,.805,.473,.795,.478,.783,.488,.773,.523,.737,.573,.694,.574,.64,.575,.612,.568,.579,.561,.552,.558,.539,.55,.525,.55,.512,.546,.51,.542,.503,.547,.501,.543,.492,.546,.48,.546,.471,.547,.431,.569,.4,.582,.364,.586,.353,.578,.342,.583,.331,.589,.32,.602,.314,.609,.304,.619,.292,.63,.282,.64,.27,.644,.267,.646,.26,.651,.259,.664,.234,.705,.217,.726,.201,.735,.194,.745,.184,.757,.186,.773,.19,.788,.234,.808,.221,.821,.213,.796,.187,.804,.171,.812,.178,.835,.178,.832,.163,.828,.149,.802,.155,.795,.141,.791,.132,.796,.123,.792,.114,.786,.098,.772,.087,.765,.072,.758,.057,.76,.038,.75,.024,.743,.014,.722,.009,.719,.025,.715,.04,.723,.06,.73,.073],['Z']]
        [['M',.615,.253,.613,.251],['C',.62,.235,.606,.217,.588,.216,.555,.214,.526,.233,.495,.241,.481,.245,.462,.252,.465,.271,.468,.286,.491,.293,.503,.299,.483,.315,.449,.32,.435,.343,.425,.36,.439,.376,.458,.369,.477,.363,.49,.341,.505,.328,.506,.357,.454,.389,.432,.408,.412,.426,.39,.444,.37,.462,.361,.47,.354,.483,.343,.487,.325,.493,.302,.489,.283,.493,.259,.499,.241,.513,.219,.522,.191,.534,.172,.539,.149,.561,.125,.585,.151,.595,.175,.591,.19,.588,.201,.57,.216,.568,.24,.565,.239,.611,.235,.625,.234,.629,.232,.634,.229,.638,.205,.673,.185,.612,.169,.643,.141,.633,.176,.681,.186,.687,.198,.695,.215,.687,.228,.684,.219,.702,.219,.722,.211,.74,.198,.768,.177,.793,.165,.822,.16,.836,.149,.86,.16,.874,.169,.887,.186,.879,.198,.876,.23,.868,.267,.858,.299,.855,.321,.853,.356,.855,.375,.841,.398,.824,.393,.807,.405,.785,.411,.773,.428,.764,.439,.757,.514,.705,.616,.677,.676,.605,.736,.533,.767,.446,.755,.352,.75,.315,.723,.28,.729,.242,.733,.213,.76,.21,.782,.2,.798,.192,.809,.182,.822,.171,.829,.164,.848,.152,.847,.14,.846,.133,.838,.134,.834,.137,.818,.146,.808,.159,.791,.166,.734,.189,.659,.211,.615,.253],['Z']]
        [['M',.987,.188,.933,.192],['C',.938,.168,.928,.154,.927,.132,.926,.122,.932,.113,.931,.103,.931,.095,.926,.089,.919,.088,.884,.081,.87,.137,.86,.16,.834,.156,.811,.164,.785,.157,.763,.151,.746,.132,.722,.134,.695,.138,.678,.173,.65,.17,.616,.165,.587,.134,.557,.12,.533,.109,.485,.099,.474,.131],['L',.492,.128,.484,.141,.557,.152,.556,.154],['C',.533,.15,.499,.148,.486,.172],['L',.496,.172,.495,.186,.513,.184,.509,.19],['C',.523,.196,.526,.177,.54,.177,.566,.175,.582,.196,.6,.211],['L',.599,.213],['C',.585,.216,.578,.226,.566,.234,.534,.253,.501,.272,.487,.308,.429,.298,.369,.311,.313,.287,.321,.253,.35,.197,.317,.169],['L',.286,.285],['C',.26,.252,.295,.195,.307,.161,.312,.144,.316,.117,.298,.106,.288,.158,.263,.206,.249,.258,.245,.273,.232,.3,.239,.315,.245,.328,.264,.33,.276,.333,.261,.394,.318,.383,.356,.404,.339,.433,.334,.467,.332,.501,.307,.502,.282,.512,.259,.519,.22,.53,.176,.543,.144,.569,.124,.587,.11,.614,.096,.635,.046,.71,.02,.801,-.013,.883,.009,.887,.027,.832,.034,.814,.055,.763,.085,.715,.116,.671,.131,.65,.145,.624,.168,.611,.239,.569,.334,.573,.413,.59,.455,.599,.501,.625,.546,.611,.637,.583,.715,.49,.747,.402,.764,.358,.764,.309,.792,.269,.815,.238,.864,.259,.887,.233,.911,.247,.925,.231,.949,.225,.959,.223,.984,.224,.971,.209],['L',.987,.188],['M',.558,.157,.556,.154,.558,.157],['M',.352,.36,.309,.341,.31,.339],['C',.329,.338,.343,.342,.352,.36],['Z']]
        [['M',.909,.31,.908,.311],['C',.889,.311,.875,.326,.857,.33,.838,.334,.818,.333,.8,.34,.781,.347,.767,.362,.748,.369,.727,.377,.702,.379,.684,.394],['L',.683,.393],['C',.697,.376,.744,.341,.724,.316],['L',.725,.315],['C',.744,.323,.783,.317,.778,.289,.776,.272,.751,.248,.736,.24,.746,.227,.772,.203,.771,.185,.77,.173,.754,.166,.747,.157,.726,.129,.703,.079,.662,.082,.635,.084,.62,.133,.633,.153,.644,.171,.668,.176,.684,.189,.665,.209,.624,.216,.599,.226,.562,.239,.532,.267,.518,.303],['L',.516,.302],['C',.525,.271,.532,.227,.528,.195,.525,.174,.512,.151,.515,.129,.516,.119,.529,.112,.535,.104,.543,.094,.547,.08,.552,.068,.567,.076,.576,.082,.586,.064,.587,.068,.587,.076,.591,.079,.601,.087,.607,.067,.607,.061,.608,.047,.596,.041,.587,.033,.569,.016,.551,-.014,.521,-.003,.498,.006,.484,.04,.467,.057,.435,.089,.435,.131,.426,.171,.409,.24,.393,.31,.348,.366,.328,.391,.302,.408,.282,.432,.247,.47,.219,.515,.183,.55,.173,.559,.159,.561,.146,.56,.138,.56,.126,.556,.121,.566,.108,.588,.104,.612,.1,.637,.099,.644,.105,.649,.103,.656,.099,.669,.08,.665,.076,.679,.073,.688,.08,.704,.081,.713,.084,.744,.079,.778,.095,.806,.118,.849,.198,.845,.232,.821,.249,.81,.267,.783,.291,.785,.318,.786,.343,.794,.371,.792,.391,.791,.411,.783,.432,.782,.45,.782,.469,.792,.487,.787,.504,.783,.516,.773,.531,.764,.552,.753,.571,.742,.591,.729,.607,.717,.625,.71,.641,.699,.665,.682,.687,.657,.707,.636,.728,.614,.753,.596,.77,.572,.785,.549,.777,.526,.788,.503,.793,.494,.806,.49,.813,.483,.829,.467,.841,.447,.856,.43,.87,.415,.902,.42,.92,.414,.946,.406,.963,.386,.984,.371,1.001,.36,1.017,.354,1.027,.335,1.038,.311,1.022,.298,1.01,.281,.992,.253,.978,.22,.944,.207,.928,.202,.896,.205,.891,.224,.888,.234,.893,.247,.895,.257,.899,.274,.904,.292,.909,.31],['M',.466,.44,.499,.374,.511,.331,.512,.332],['C',.502,.367,.523,.404,.523,.438],['L',.466,.44],['M',.511,.328,.513,.328,.511,.328],['M',.515,.31,.518,.303,.519,.304,.515,.31],['M',.585,.063,.588,.062,.585,.063],['Z']]
        [['M',.814,.106],['C',.818,.114,.811,.123,.809,.132,.806,.143,.801,.153,.799,.165,.797,.176,.795,.187,.796,.198,.796,.198,.798,.218,.8,.227,.802,.235,.808,.251,.808,.251],['S',.826,.264,.835,.262],['C',.848,.259,.852,.228,.864,.234,.864,.234,.875,.235,.876,.24,.879,.248,.87,.256,.864,.262,.864,.262,.847,.273,.847,.282,.848,.286,.852,.291,.855,.289,.855,.289,.867,.283,.873,.279,.883,.274,.892,.26,.903,.263,.907,.264,.906,.261,.907,.269,.908,.281,.899,.289,.892,.298,.892,.298,.863,.339,.852,.359,.842,.379,.833,.423,.833,.423],['S',.831,.464,.825,.484],['C',.816,.516,.805,.548,.784,.574,.784,.574,.748,.621,.728,.642],['L',.583,.792,.517,.853],['C',.488,.88,.45,.901,.411,.908,.389,.912,.366,.906,.345,.899,.345,.899,.328,.888,.32,.891,.309,.896,.307,.912,.301,.922,.278,.964,.257,.959,.246,.942,.239,.938,.234,.921,.228,.912,.223,.904,.207,.887,.195,.875,.195,.875,.178,.86,.172,.851,.167,.843,.163,.832,.164,.822,.165,.814,.174,.801,.176,.804,.179,.806,.184,.811,.185,.816,.185,.816,.186,.833,.19,.841,.195,.851,.206,.856,.213,.864,.22,.871,.232,.885,.232,.885,.237,.891,.244,.897,.249,.904,.251,.909,.254,.922,.254,.922,.255,.928,.258,.937,.265,.936,.276,.936,.286,.914,.287,.9],['L',.288,.874],['C',.289,.865,.274,.852,.272,.85,.269,.848,.248,.833,.239,.824,.23,.815,.219,.804,.215,.791,.211,.779,.215,.765,.215,.753,.215,.745,.219,.736,.215,.729,.215,.729,.209,.712,.202,.706,.195,.701,.175,.699,.175,.699,.165,.695,.148,.697,.143,.692],['L',.111,.663],['C',.108,.66,.099,.624,.099,.624],['S',.09,.601,.089,.59],['C',.089,.581,.087,.567,.095,.564,.095,.564,.109,.554,.116,.557,.124,.562,.122,.576,.125,.585,.128,.596,.133,.618,.136,.62,.138,.622,.151,.647,.163,.645,.163,.645,.185,.646,.19,.638,.197,.628,.19,.613,.184,.603,.184,.603,.169,.586,.166,.575,.162,.562,.166,.548,.166,.535,.167,.52,.167,.494,.169,.491,.171,.489,.18,.472,.186,.476,.186,.476,.199,.484,.203,.49,.212,.504,.215,.521,.216,.538],['L',.219,.582],['C',.219,.595,.239,.611,.239,.616,.24,.62,.259,.628,.27,.627,.278,.627,.289,.619,.292,.616,.294,.613,.31,.579,.318,.56,.326,.542,.331,.513,.339,.503,.347,.492,.376,.459,.392,.435,.392,.435,.413,.406,.423,.391,.432,.378,.462,.359,.449,.351,.449,.351,.438,.342,.431,.34,.426,.338,.418,.343,.415,.338,.415,.338,.401,.324,.399,.314,.398,.305,.399,.293,.404,.286,.404,.286,.414,.261,.425,.257,.433,.254,.455,.254,.451,.262,.451,.262,.439,.28,.438,.291,.437,.301,.434,.322,.445,.322,.445,.322,.471,.327,.483,.322,.496,.317,.501,.296,.514,.294,.514,.294,.521,.296,.522,.293,.526,.287,.517,.279,.515,.272],['L',.507,.245],['C',.504,.237,.494,.227,.499,.222,.503,.217,.506,.195,.507,.192,.509,.189,.512,.154,.526,.157,.526,.157,.531,.156,.533,.158,.539,.163,.541,.172,.539,.179,.539,.179,.53,.205,.531,.219,.532,.229,.536,.24,.541,.249,.547,.26,.551,.275,.563,.278,.579,.281,.594,.266,.605,.254],['L',.677,.18],['C',.689,.167,.71,.144,.712,.142,.715,.139,.728,.138,.736,.135],['L',.753,.126],['C',.758,.123,.76,.116,.765,.113,.77,.109,.776,.106,.782,.106],['L',.814,.106],['S',.814,.106,.814,.106],['Z']]
        [['M',.76,.46],['C',.799,.418,.814,.401,.822,.388,.825,.383,.826,.382,.826,.379,.826,.373,.825,.372,.808,.341,.806,.338,.804,.333,.802,.33,.798,.323,.791,.301,.79,.296,.789,.29,.79,.282,.792,.276,.793,.271,.794,.269,.797,.265,.798,.262,.801,.26,.802,.259,.803,.259,.806,.258,.809,.258,.819,.256,.82,.256,.832,.246],['L',.84,.239,.84,.236,.841,.233,.85,.224],['C',.871,.203,.871,.203,.871,.201,.872,.197,.872,.175,.871,.172,.871,.17,.867,.163,.863,.158,.861,.156,.86,.154,.859,.152,.856,.147,.849,.142,.839,.139,.837,.138,.835,.137,.833,.136,.832,.134,.83,.133,.826,.132,.823,.132,.816,.131,.81,.131,.802,.131,.8,.131,.797,.132,.79,.136,.773,.152,.77,.157,.769,.159,.767,.162,.759,.171,.756,.175,.75,.181,.749,.184,.747,.186,.747,.19,.748,.194,.748,.196,.748,.198,.747,.199,.746,.201,.745,.204,.745,.206],['L',.743,.211,.737,.217],['C',.733,.22,.729,.223,.728,.224,.727,.224,.722,.225,.717,.225,.712,.225,.706,.226,.703,.226,.699,.227,.696,.227,.694,.227,.69,.226,.659,.213,.642,.204,.628,.198,.623,.197,.616,.199,.607,.202,.599,.207,.571,.227,.567,.23,.56,.234,.556,.237,.522,.262,.524,.26,.507,.277,.491,.293,.475,.311,.471,.316,.469,.319,.46,.33,.431,.363,.412,.383,.413,.383,.408,.398,.404,.411,.402,.42,.402,.423,.402,.424,.401,.425,.4,.425,.4,.426,.396,.429,.392,.431,.388,.434,.383,.438,.38,.44,.373,.444,.367,.449,.366,.45,.366,.451,.367,.454,.368,.456,.37,.458,.37,.458,.364,.466,.342,.497,.329,.517,.323,.527,.318,.535,.3,.562,.296,.569,.295,.571,.284,.583,.273,.595,.245,.628,.242,.63,.223,.651,.214,.661,.195,.681,.182,.695,.169,.709,.152,.727,.145,.735,.137,.743,.131,.75,.13,.751,.127,.755,.129,.763,.136,.771,.137,.773,.139,.775,.139,.775,.139,.776,.126,.781,.114,.784,.108,.785,.107,.786,.104,.788,.1,.792,.098,.796,.098,.8],['L',.099,.804,.11,.815],['C',.121,.826,.122,.827,.129,.832,.134,.835,.138,.837,.138,.837,.14,.838,.141,.837,.146,.834,.151,.831,.152,.831,.155,.833,.16,.837,.165,.835,.173,.829,.178,.824,.179,.823,.18,.819],['L',.18,.816,.183,.816],['C',.185,.817,.185,.816,.198,.805,.227,.781,.229,.779,.248,.75,.255,.741,.262,.73,.264,.727,.266,.725,.269,.721,.271,.718,.275,.714,.284,.704,.287,.701,.292,.694,.334,.654,.352,.638,.38,.613,.416,.58,.444,.555,.451,.548,.457,.543,.457,.543,.457,.545,.452,.554,.446,.563,.441,.57,.431,.583,.426,.59,.414,.604,.405,.614,.404,.615,.403,.616,.4,.621,.396,.625,.393,.629,.389,.633,.389,.634,.388,.635,.385,.639,.381,.643,.378,.647,.374,.652,.372,.654,.37,.656,.368,.659,.366,.661,.361,.667,.352,.677,.35,.679,.349,.68,.347,.683,.345,.686,.342,.688,.34,.691,.339,.692,.333,.699,.304,.728,.295,.738,.287,.745,.283,.748,.257,.767,.242,.777,.225,.792,.208,.81,.193,.824,.193,.825,.192,.828,.191,.831,.19,.834,.191,.836,.191,.836,.19,.837,.187,.838,.182,.841,.177,.846,.175,.85,.173,.854,.173,.857,.174,.863,.175,.866,.175,.869,.174,.874,.174,.878,.174,.882,.174,.882,.175,.885,.19,.9,.196,.905,.202,.91,.205,.911,.212,.912,.219,.913,.22,.913,.223,.91,.226,.906,.228,.899,.23,.887,.233,.872,.234,.871,.243,.876,.25,.881,.253,.882,.255,.881,.256,.881,.263,.875,.282,.856,.312,.826,.314,.824,.365,.776,.409,.733,.42,.723,.442,.706,.46,.691,.466,.686,.476,.679,.479,.676,.486,.67,.491,.667,.501,.66,.517,.646,.533,.63],['L',.542,.621,.544,.623],['C',.546,.624,.548,.626,.548,.626],['L',.55,.628,.555,.623],['C',.558,.62,.565,.612,.571,.605],['L',.582,.592,.588,.591],['C',.592,.59,.598,.589,.601,.588,.616,.586,.629,.579,.653,.563,.67,.551,.672,.549,.7,.522,.728,.495,.732,.492,.76,.46],['Z'],['M',.71,.282],['C',.708,.284,.703,.287,.699,.289,.69,.294,.678,.301,.675,.304,.673,.307,.672,.306,.673,.302,.677,.293,.693,.262,.695,.26,.696,.259,.696,.26,.695,.265,.694,.267,.694,.269,.694,.269,.694,.27,.699,.27,.706,.27,.711,.27,.716,.27,.717,.27,.717,.27,.717,.271,.716,.272,.716,.273,.715,.275,.714,.277,.714,.28,.714,.28,.71,.282],['Z'],['M',.731,.266],['C',.73,.266,.725,.267,.72,.267,.715,.267,.707,.268,.703,.268],['L',.695,.268,.698,.26],['C',.7,.256,.702,.251,.703,.249,.704,.247,.708,.242,.71,.237,.718,.225,.717,.226,.722,.226,.726,.225,.728,.225,.729,.224,.731,.223,.732,.222,.732,.222,.732,.223,.732,.232,.732,.244,.732,.262,.732,.265,.731,.266],['Z'],['M',.719,.339],['C',.716,.341,.711,.344,.708,.347,.704,.349,.701,.351,.7,.351,.7,.351,.7,.349,.702,.347,.704,.343,.71,.33,.714,.317,.716,.313,.718,.307,.719,.306,.72,.304,.721,.3,.722,.296],['L',.723,.289,.73,.289,.738,.289,.738,.296],['C',.738,.3,.739,.304,.739,.306,.74,.309,.74,.309,.741,.309,.742,.309,.748,.309,.754,.308,.76,.306,.765,.306,.765,.306,.765,.306,.731,.331,.719,.339],['Z'],['M',.777,.296],['C',.768,.304,.767,.304,.752,.306,.746,.307,.741,.308,.741,.308,.741,.307,.74,.305,.74,.303,.739,.298,.74,.279,.74,.277,.741,.275,.741,.275,.744,.275,.746,.276,.757,.276,.768,.277,.779,.277,.788,.278,.788,.278],['S',.789,.28,.788,.283],['C',.788,.288,.788,.288,.777,.296],['Z']]
        [['M',.699,.728,.705,.708,.703,.687,.691,.673],['S',.671,.68,.668,.682],['C',.665,.684,.651,.695,.646,.699,.641,.703,.602,.72,.596,.721,.59,.723,.54,.737,.54,.737],['S',.507,.747,.503,.749],['C',.5,.752,.477,.752,.477,.752],['L',.421,.761],['S',.435,.737,.439,.732],['C',.443,.726,.456,.707,.462,.698,.467,.69,.479,.676,.483,.673,.487,.67,.517,.645,.517,.645],['S',.532,.646,.536,.636],['C',.54,.627,.593,.572,.595,.57,.597,.567,.632,.546,.632,.546],['L',.676,.514],['S',.705,.491,.707,.487],['C',.709,.482,.74,.443,.74,.443],['L',.764,.401],['S',.769,.387,.762,.384],['C',.756,.382,.737,.362,.732,.365,.727,.368,.711,.375,.708,.377,.705,.378,.668,.391,.668,.391],['L',.64,.411],['S',.629,.428,.625,.429],['C',.621,.43,.591,.445,.591,.445],['L',.582,.45,.602,.427,.621,.404,.651,.377],['S',.667,.359,.668,.353],['C',.67,.348,.675,.334,.678,.332,.681,.33,.692,.325,.695,.322,.699,.32,.716,.307,.718,.303,.72,.299,.728,.283,.73,.28,.731,.277,.77,.22,.77,.22],['L',.802,.18,.823,.168,.839,.14],['S',.845,.139,.841,.136,.818,.107,.818,.107],['L',.8,.102,.793,.113],['S',.789,.135,.789,.139],['C',.788,.144,.789,.15,.785,.155,.781,.159,.756,.185,.756,.185],['L',.7,.227,.664,.257,.644,.283,.632,.306,.624,.329,.594,.352,.529,.382,.466,.419],['S',.397,.476,.396,.48],['C',.395,.483,.381,.516,.381,.516],['S',.374,.535,.371,.538],['C',.369,.54,.35,.561,.347,.565,.344,.568,.314,.592,.314,.592],['L',.276,.618,.252,.631,.238,.568],['S',.223,.541,.223,.536],['C',.223,.531,.191,.478,.191,.478],['L',.182,.467,.194,.474,.198,.456],['S',.193,.451,.192,.455],['C',.192,.459,.193,.462,.188,.463,.184,.463,.17,.462,.17,.462],['L',.157,.463,.144,.473],['S',.127,.476,.13,.479,.159,.495,.159,.495,.181,.508,.182,.514],['C',.184,.52,.194,.543,.191,.547,.188,.55,.197,.613,.197,.613],['L',.205,.637],['S',.184,.662,.186,.668],['C',.188,.675,.196,.696,.201,.699,.206,.702,.212,.713,.212,.713],['L',.22,.75,.207,.761],['S',.202,.762,.196,.76],['C',.19,.758,.177,.764,.174,.766,.171,.768,.161,.784,.16,.787,.158,.79,.15,.814,.149,.821,.148,.828,.149,.84,.153,.847,.157,.853,.16,.858,.164,.863],['S',.168,.872,.179,.877,.199,.887,.202,.884],['L',.212,.877],['C',.215,.874,.219,.87,.222,.868],['S',.231,.86,.236,.857],['C',.241,.854,.24,.853,.245,.849],['S',.252,.842,.257,.834],['C',.261,.826,.266,.823,.266,.817,.266,.81,.263,.81,.269,.805,.276,.8,.279,.798,.282,.799,.285,.801,.297,.814,.297,.814],['L',.315,.816],['S',.333,.813,.338,.817,.345,.825,.358,.83,.411,.824,.415,.823],['C',.418,.822,.446,.816,.446,.816],['S',.459,.816,.465,.809,.478,.796,.481,.798,.528,.786,.528,.786,.554,.782,.557,.78],['C',.56,.779,.591,.764,.591,.764],['L',.647,.736,.664,.727,.699,.728],['Z']]
        [['M',.683,.264],['S',.674,.251,.67,.244],['C',.664,.231,.661,.212,.654,.204,.648,.196,.642,.189,.642,.189,.641,.188,.64,.19,.636,.188,.632,.185,.626,.176,.62,.17,.62,.17,.617,.165,.614,.164,.61,.163,.6,.166,.6,.166],['L',.589,.166,.559,.177],['C',.556,.178,.553,.176,.551,.177,.546,.177,.538,.182,.538,.182,.536,.182,.532,.179,.531,.181,.529,.183,.534,.187,.533,.189,.529,.197,.513,.191,.508,.199,.507,.201,.508,.203,.509,.204,.509,.204,.516,.209,.515,.212,.513,.219,.492,.214,.495,.22,.495,.22,.498,.225,.5,.228,.503,.231,.51,.232,.509,.235,.509,.239,.5,.235,.5,.238,.499,.243,.511,.248,.511,.248],['L',.518,.252,.489,.262],['C',.488,.263,.489,.265,.49,.267,.49,.268,.491,.27,.491,.27,.494,.274,.478,.269,.476,.272,.474,.276,.476,.278,.478,.28,.479,.282,.482,.281,.482,.283,.481,.288,.471,.283,.469,.287],['L',.468,.291,.477,.298,.474,.3,.478,.302],['S',.508,.305,.52,.313],['C',.522,.314,.525,.32,.525,.32,.529,.325,.533,.33,.535,.336,.538,.342,.539,.355,.539,.355],['S',.523,.365,.516,.371],['C',.512,.375,.504,.385,.504,.385],['S',.501,.369,.5,.365],['C',.499,.362,.493,.35,.488,.343,.484,.337,.478,.331,.472,.326,.467,.322,.456,.315,.456,.315],['L',.437,.292],['C',.432,.286,.425,.283,.419,.278,.415,.273,.406,.263,.406,.263,.403,.259,.402,.252,.398,.249,.396,.247,.39,.245,.39,.245,.386,.243,.381,.245,.376,.246,.371,.246,.367,.246,.363,.247,.357,.248,.347,.252,.347,.252,.343,.253,.339,.252,.335,.253,.332,.254,.325,.258,.325,.258,.324,.258,.323,.26,.323,.261,.323,.264,.33,.265,.33,.269,.329,.271,.32,.272,.316,.272,.312,.272,.309,.27,.306,.271,.304,.273,.3,.278,.303,.279,.303,.279,.305,.28,.305,.281,.305,.282,.299,.281,.296,.282,.294,.283,.291,.284,.291,.286,.29,.289,.298,.29,.296,.292,.296,.292,.29,.296,.289,.299,.288,.301,.289,.303,.29,.305,.29,.305,.293,.308,.295,.31,.296,.311,.296,.314,.298,.315],['L',.306,.318],['C',.313,.321,.322,.32,.329,.322,.331,.323,.333,.324,.335,.325,.339,.328,.346,.334,.346,.334,.35,.337,.35,.342,.354,.346,.358,.35,.367,.356,.367,.356,.374,.361,.382,.365,.387,.371,.394,.378,.402,.396,.402,.396,.404,.401,.398,.415,.391,.421,.385,.425,.37,.425,.37,.425,.364,.427,.359,.433,.353,.434,.347,.435,.337,.431,.337,.431,.333,.43,.329,.43,.326,.432,.32,.435,.317,.446,.313,.446,.31,.447,.308,.436,.304,.431,.3,.426,.288,.418,.288,.418],['L',.278,.413],['C',.274,.412,.274,.407,.272,.404,.269,.401,.262,.396,.262,.396,.258,.393,.253,.39,.25,.387,.243,.377,.235,.354,.235,.354,.234,.351,.233,.349,.232,.347,.228,.344,.217,.343,.217,.343,.209,.341,.2,.345,.192,.347,.183,.349,.165,.356,.165,.356],['S',.158,.357,.155,.358],['C',.153,.359,.151,.36,.151,.36,.149,.361,.152,.363,.153,.365],['L',.155,.369],['C',.156,.372,.147,.368,.144,.37,.14,.371,.135,.375,.135,.375,.133,.376,.136,.379,.135,.38,.134,.383,.126,.384,.126,.384],['S',.12,.385,.119,.387],['C',.118,.388,.122,.391,.12,.391],['L',.112,.396],['C',.11,.398,.115,.4,.118,.401],['S',.132,.406,.139,.408],['C',.146,.41,.151,.408,.159,.414],['S',.173,.437,.181,.447],['C',.19,.458,.2,.467,.208,.477,.213,.483,.221,.494,.221,.494,.226,.501,.222,.511,.224,.52,.225,.527,.227,.534,.227,.541],['L',.228,.558],['C',.229,.563,.222,.566,.219,.569,.214,.573,.208,.576,.205,.581,.201,.586,.201,.594,.197,.599,.193,.603,.187,.604,.182,.608,.177,.612,.168,.622,.168,.622,.161,.629,.156,.638,.149,.645,.144,.65,.133,.659,.133,.659,.126,.665,.116,.67,.109,.676,.104,.681,.096,.693,.096,.693,.09,.699,.086,.707,.083,.715,.081,.721,.085,.73,.08,.733,.079,.734,.077,.728,.077,.728],['S',.074,.732,.072,.735],['C',.069,.742,.068,.757,.068,.757,.067,.763,.069,.773,.07,.775],['S',.075,.789,.081,.793],['L',.094,.802],['C',.101,.806,.11,.808,.118,.81,.123,.81,.133,.809,.133,.809,.14,.809,.144,.817,.15,.82,.158,.824,.176,.826,.176,.826],['S',.176,.814,.178,.808],['C',.18,.801,.189,.789,.189,.789],['L',.199,.788,.217,.786,.207,.807],['S',.195,.825,.19,.833],['C',.185,.841,.18,.849,.175,.857,.175,.857,.166,.872,.161,.879,.159,.883,.156,.887,.155,.891],['L',.15,.906,.147,.912,.146,.918,.149,.921,.156,.918],['S',.164,.905,.169,.899],['C',.174,.893,.18,.887,.186,.882,.191,.877,.199,.871,.202,.87],['S',.232,.841,.232,.841],['L',.246,.822,.234,.851,.217,.879,.206,.9,.199,.923,.193,.943,.194,.95,.198,.951,.201,.945],['S',.212,.927,.219,.919],['C',.225,.911,.239,.899,.239,.899,.248,.89,.255,.88,.263,.87,.271,.861,.28,.853,.286,.842,.286,.842,.296,.825,.301,.815,.305,.808,.311,.801,.312,.793],['L',.314,.78,.332,.772,.359,.775,.393,.781],['S',.409,.789,.417,.789],['C',.432,.788,.44,.778,.448,.767,.452,.761,.459,.749,.459,.749,.462,.744,.465,.738,.466,.732,.467,.728,.465,.72,.465,.72],['S',.499,.72,.516,.721],['C',.545,.721,.575,.718,.604,.715,.661,.709,.717,.681,.751,.634,.779,.595,.807,.541,.813,.509,.819,.482,.822,.453,.822,.425,.822,.409,.821,.392,.818,.376,.818,.376,.81,.343,.807,.325,.805,.313,.803,.301,.801,.289,.801,.289,.797,.265,.796,.254,.794,.244,.793,.234,.794,.225,.795,.217,.798,.21,.801,.204,.804,.198,.807,.191,.812,.187,.812,.187,.819,.179,.824,.175,.828,.173,.832,.171,.837,.169,.837,.169,.843,.167,.846,.166,.864,.161,.886,.181,.899,.174,.903,.171,.892,.156,.885,.152],['L',.849,.134],['C',.843,.131,.836,.13,.829,.129,.821,.128,.812,.127,.804,.128,.804,.128,.787,.129,.779,.131,.772,.133,.766,.136,.761,.139,.754,.142,.747,.147,.742,.152,.735,.157,.729,.164,.723,.17,.723,.17,.712,.184,.707,.191,.702,.2,.697,.209,.694,.218,.691,.227,.69,.236,.688,.244,.686,.251,.683,.264,.683,.264],['Z']]
        [['M',.617,.637],['C',.617,.637,.618,.637,.618,.636,.62,.634,.619,.629,.617,.627,.616,.625,.613,.627,.612,.626,.61,.625,.609,.624,.609,.623,.609,.62,.615,.622,.617,.619,.618,.617,.616,.615,.616,.613,.616,.61,.617,.607,.617,.604,.617,.603,.616,.601,.616,.6,.615,.599,.614,.598,.614,.596,.613,.592,.614,.587,.614,.583,.614,.579,.615,.575,.615,.572,.615,.57,.614,.569,.613,.568,.611,.567,.605,.571,.604,.569,.603,.564,.613,.566,.615,.562,.616,.559,.614,.556,.614,.553,.613,.55,.613,.547,.613,.544,.613,.54,.615,.536,.615,.532,.616,.528,.619,.523,.617,.518,.617,.517,.615,.517,.615,.515,.615,.514,.616,.513,.615,.512,.614,.511,.613,.512,.612,.512,.607,.513,.602,.517,.596,.52,.589,.523,.581,.526,.575,.531],['L',.582,.521,.595,.504,.622,.472,.637,.453,.658,.426,.68,.4,.694,.382,.696,.38,.696,.38,.704,.375],['C',.708,.374,.712,.372,.716,.37,.72,.369,.723,.367,.726,.366,.729,.364,.732,.363,.734,.362],['L',.741,.356,.747,.348,.749,.342,.748,.336,.745,.334,.741,.334],['C',.739,.336,.737,.337,.734,.338,.732,.339,.729,.341,.727,.342,.725,.343,.723,.343,.721,.343],['L',.722,.343,.728,.336,.734,.329,.747,.316,.756,.309,.768,.3,.778,.295,.789,.289,.801,.286,.801,.286,.824,.283,.845,.278,.87,.27,.894,.259,.913,.248,.919,.242,.92,.237,.916,.231,.912,.229,.908,.221,.901,.215,.893,.206,.888,.203,.882,.204,.884,.198,.881,.193,.871,.189,.864,.185,.86,.182,.853,.183,.853,.178,.847,.176,.841,.17,.832,.149,.83,.148,.822,.149,.828,.139,.825,.13,.821,.123,.816,.114,.812,.108,.808,.101,.807,.094,.79,.111,.77,.133,.754,.158,.745,.175,.736,.191,.724,.211,.723,.213,.715,.226,.716,.225,.712,.232,.698,.247,.679,.264,.66,.276,.642,.284],['C',.643,.283,.645,.282,.648,.281],['L',.65,.275],['C',.65,.275,.652,.271,.654,.269,.655,.267,.656,.267,.657,.265,.658,.264,.659,.262,.66,.262,.661,.262,.662,.26,.662,.258,.662,.253,.657,.255,.656,.252,.655,.248,.652,.246,.648,.242,.646,.239,.644,.237,.641,.234,.638,.231,.635,.229,.632,.227,.629,.225,.626,.223,.622,.221,.619,.219,.615,.217,.611,.215,.609,.214,.608,.212,.606,.211,.605,.211,.604,.212,.603,.211,.601,.209,.604,.208,.598,.209,.597,.208,.596,.207,.595,.208,.593,.208,.592,.208,.591,.209,.589,.209,.588,.21,.587,.211,.585,.213,.583,.217,.583,.217],['L',.577,.229,.572,.242,.565,.256,.56,.27,.556,.283,.551,.299,.547,.312,.543,.321,.54,.33,.536,.337,.522,.35,.49,.374,.465,.392,.442,.408,.438,.411,.439,.41,.44,.404,.439,.401,.436,.397,.427,.386,.429,.384,.422,.376,.418,.369,.415,.361,.407,.352,.403,.351,.399,.35,.395,.352,.393,.356,.389,.372,.386,.413,.386,.418,.381,.417,.377,.415,.373,.415,.37,.418,.369,.421,.369,.428,.371,.435,.37,.441,.371,.448,.375,.458,.374,.458,.359,.47,.325,.502,.301,.527,.276,.557,.257,.581,.256,.583,.248,.574,.238,.563,.231,.557,.225,.555,.219,.555,.217,.558,.216,.563,.215,.578,.217,.602,.22,.629,.22,.634,.214,.643,.19,.677,.183,.69,.174,.701,.175,.701,.175,.701,.168,.708,.159,.722,.148,.738,.129,.769,.119,.785,.114,.804,.112,.814,.114,.819,.117,.821,.121,.821,.123,.82,.126,.815,.128,.811,.132,.808,.136,.806,.131,.819,.128,.827,.128,.832,.131,.835,.136,.838,.143,.839,.152,.839,.161,.838,.172,.835,.184,.832,.197,.827,.21,.822,.222,.817,.232,.812,.238,.808,.247,.804,.259,.799,.269,.793],['C',.273,.791,.275,.789,.28,.786],['L',.289,.781,.303,.773,.316,.766,.334,.756,.348,.747,.367,.734,.386,.721,.404,.707,.427,.688,.457,.662,.477,.647,.482,.642],['C',.482,.643,.482,.644,.482,.644,.487,.646,.493,.643,.499,.643,.51,.643,.521,.644,.532,.644,.542,.644,.552,.645,.562,.645,.568,.645,.575,.644,.581,.644,.586,.644,.591,.643,.596,.642,.599,.642,.603,.642,.606,.641,.61,.64,.614,.64,.617,.637],['Z']]
        [['M',.43,.024],['C',.484,.039,.513,.057,.55,.101,.566,.12,.581,.135,.585,.136,.596,.138,.603,.123,.598,.109,.595,.101,.595,.087,.598,.076,.611,.032,.648,.015,.677,.04,.726,.082,.731,.158,.691,.249,.684,.264,.677,.277,.676,.277,.674,.277,.674,.273,.675,.269,.68,.258,.677,.256,.645,.253,.63,.252,.614,.248,.609,.245,.603,.241,.604,.255,.613,.302],['L',.626,.365,.581,.409],['C',.557,.433,.526,.46,.513,.468],['L',.488,.483,.522,.45],['C',.541,.432,.559,.416,.563,.415,.567,.412,.566,.409,.56,.402,.554,.398,.549,.395,.547,.397,.544,.4,.538,.399,.496,.388,.486,.385,.476,.385,.472,.388,.446,.413,.421,.455,.403,.508],['L',.392,.541,.362,.552],['C',.319,.568,.228,.592,.198,.595,.162,.599,.132,.611,.098,.634,.077,.649,.068,.657,.064,.667,.057,.686,.064,.686,.094,.667,.121,.651,.133,.651,.166,.664,.18,.67,.18,.67,.168,.679,.161,.684,.128,.7,.095,.714,.051,.734,.035,.743,.035,.749,.036,.766,.162,.837,.228,.857,.278,.873,.362,.874,.426,.861,.501,.846,.595,.802,.664,.751,.683,.737,.699,.726,.7,.726],['S',.712,.73,.726,.733],['C',.747,.74,.858,.738,.864,.731,.866,.729,.864,.726,.861,.723,.858,.72,.859,.714,.866,.707,.88,.692,.886,.671,.878,.665,.873,.662,.874,.657,.882,.647,.888,.64,.897,.626,.902,.617,.906,.608,.917,.592,.925,.581],['L',.939,.56,.912,.573],['C',.88,.588,.827,.608,.81,.611,.799,.613,.799,.611,.812,.585,.851,.51,.869,.405,.863,.303,.856,.211,.834,.144,.788,.083],['L',.788,.083],['C',.753,.037,.678,-.015,.618,-.035,.553,-.056,.419,-.038,.387,-.003,.377,.007,.383,.011,.43,.024],['Z']]
        [['M',.321,1.013],['C',.333,1.015,.34,1.013,.358,1.002,.392,.98,.428,.949,.449,.922,.466,.902,.468,.897,.466,.883,.464,.861,.459,.853,.433,.824,.403,.79,.4,.783,.41,.772,.414,.768,.423,.763,.43,.761,.454,.753,.521,.669,.539,.621,.544,.608,.561,.588,.619,.524,.698,.436,.748,.37,.792,.292,.818,.247,.861,.152,.857,.148,.856,.148,.844,.167,.829,.192,.77,.292,.706,.37,.645,.417,.586,.462,.515,.503,.491,.504,.486,.505,.475,.509,.465,.514,.448,.522,.43,.526,.426,.522,.425,.52,.423,.507,.423,.493,.422,.478,.419,.464,.416,.461,.413,.458,.409,.445,.408,.433,.407,.42,.403,.408,.4,.406,.394,.399,.336,.36,.327,.355,.319,.352,.293,.37,.279,.389,.274,.396,.269,.398,.262,.396,.257,.395,.252,.393,.251,.393,.249,.393,.24,.4,.229,.409],['L',.229,.409],['C',.218,.419,.208,.429,.207,.432,.205,.435,.201,.441,.197,.445,.194,.448,.192,.453,.194,.455,.199,.459,.224,.457,.229,.452,.233,.448,.255,.454,.256,.46,.258,.466,.248,.475,.24,.475,.235,.475,.234,.476,.237,.478,.242,.484,.263,.482,.269,.476,.272,.473,.275,.465,.276,.459,.278,.445,.285,.444,.303,.457,.319,.469,.321,.475,.326,.532,.33,.576,.336,.596,.347,.607,.356,.615,.349,.63,.335,.631,.33,.631,.321,.636,.314,.641,.298,.652,.289,.652,.286,.639,.283,.628,.286,.623,.296,.622,.302,.622,.302,.621,.298,.617,.294,.614,.294,.611,.298,.609,.302,.607,.303,.605,.299,.601,.28,.583,.249,.62,.26,.645,.265,.655,.265,.655,.255,.656,.246,.656,.245,.655,.24,.639,.237,.629,.238,.619,.241,.614,.244,.609,.247,.608,.247,.612,.248,.615,.25,.615,.252,.614,.253,.612,.253,.607,.25,.603,.246,.595,.249,.588,.255,.594,.258,.596,.258,.595,.257,.59,.255,.579,.252,.578,.236,.579,.219,.58,.211,.587,.207,.605,.204,.618,.206,.627,.222,.66],['L',.231,.679,.264,.681,.298,.683,.314,.703],['C',.326,.719,.33,.728,.33,.739,.329,.79,.331,.803,.343,.83,.35,.845,.356,.863,.356,.87,.355,.887,.345,.91,.327,.937,.303,.972,.299,.982,.303,.997,.305,1.003,.306,1.006,.309,1.008,.311,1.01,.315,1.011,.321,1.013],['Z'],['M',.356,.454],['C',.351,.43,.352,.431,.322,.419,.316,.417,.316,.415,.322,.409,.33,.401,.338,.404,.358,.422,.371,.435,.375,.448,.372,.47,.369,.491,.363,.484,.356,.454],['Z']]
        [['M',.007,.756],['C',.023,.796,.048,.817,.107,.84,.134,.851,.169,.869,.185,.88,.211,.897,.213,.901,.21,.913,.206,.925,.206,.925,.212,.916,.219,.904,.24,.907,.235,.919,.234,.923,.235,.929,.237,.932,.24,.936,.241,.934,.242,.926,.242,.911,.256,.909,.268,.923,.273,.928,.277,.93,.278,.927,.279,.925,.277,.92,.273,.917,.261,.906,.281,.899,.296,.908,.304,.913,.306,.913,.303,.908,.3,.903,.301,.899,.308,.89,.314,.884,.318,.875,.318,.87,.318,.865,.322,.862,.33,.862,.336,.863,.342,.861,.343,.858,.344,.855,.34,.854,.332,.855,.325,.856,.319,.856,.319,.855,.312,.826,.312,.82,.32,.813,.327,.807,.327,.806,.32,.806,.308,.806,.303,.776,.311,.752,.316,.736,.337,.719,.347,.723,.357,.727,.374,.77,.374,.794,.375,.809,.378,.838,.382,.859,.389,.899,.402,.918,.423,.919,.429,.919,.435,.924,.437,.93,.444,.95,.454,.956,.476,.955,.487,.954,.499,.952,.502,.95,.505,.947,.513,.945,.521,.945,.529,.945,.535,.942,.534,.94],['S',.54,.927,.549,.918,.576,.886,.589,.867],['C',.601,.848,.614,.83,.617,.827],['L',.627,.812,.637,.795],['C',.65,.772,.688,.739,.731,.713,.775,.685,.804,.653,.835,.594,.849,.567,.864,.54,.869,.533,.873,.527,.885,.506,.897,.486],['S',.931,.43,.948,.405],['C',.983,.353,1.003,.311,1.011,.277,1.018,.246,1.005,.243,.976,.271,.953,.292,.953,.292,.959,.276,.962,.266,.975,.247,.988,.233],['S',1.011,.204,1.01,.201],['C',1.008,.191,.996,.191,.985,.201,.973,.212,.869,.253,.861,.251,.859,.25,.864,.236,.872,.219,.883,.198,.892,.186,.905,.179,.922,.169,.923,.167,.918,.159,.912,.151,.907,.151,.918,.148],['L',.916,.143],['C',.907,.147,.902,.151,.898,.154,.892,.159,.887,.153,.881,.141,.876,.131,.875,.128,.896,.117],['L',.893,.106],['C',.89,.106,.888,.106,.886,.105,.873,.101,.852,.11,.833,.129,.828,.134,.828,.136,.823,.137],['L',.826,.147],['C',.829,.147,.829,.15,.833,.151,.843,.155,.842,.154,.841,.162,.841,.162,.845,.182,.846,.185,.848,.188,.843,.203,.836,.22,.826,.244,.821,.251,.809,.255,.795,.26,.795,.26,.8,.236,.804,.215,.807,.21,.823,.201,.832,.195,.83,.197,.831,.194],['L',.838,.163],['C',.84,.158,.827,.171,.821,.173,.813,.176,.811,.175,.811,.168,.811,.157,.815,.151,.822,.15],['L',.819,.138],['C',.814,.139,.81,.139,.804,.138,.795,.135,.784,.136,.779,.138,.774,.141,.768,.141,.765,.138],['S',.757,.135,.755,.139],['C',.753,.143,.75,.149,.748,.153,.746,.157,.765,.188,.777,.192,.784,.194,.765,.244,.745,.28,.729,.307,.723,.313,.674,.341,.644,.358,.609,.38,.596,.389,.583,.399,.57,.407,.567,.408,.562,.409,.511,.458,.489,.483,.48,.492,.469,.517,.456,.553,.437,.606,.436,.612,.439,.655,.44,.681,.443,.699,.446,.696,.448,.694,.449,.674,.448,.652,.446,.617,.448,.607,.464,.562,.493,.485,.527,.447,.621,.387,.654,.366,.702,.335,.728,.318],['L',.774,.287,.771,.305],['C',.768,.323,.768,.323,.777,.302,.781,.29,.788,.28,.791,.28,.795,.279,.796,.281,.795,.285,.788,.298,.786,.309,.791,.311,.793,.312,.797,.308,.799,.301,.8,.295,.804,.289,.808,.289,.813,.288,.834,.272,.836,.266,.836,.265,.834,.265,.83,.265,.827,.266,.825,.265,.826,.262,.827,.259,.833,.258,.838,.258,.847,.259,.848,.261,.843,.272,.839,.282,.84,.286,.847,.288,.854,.29,.855,.292,.85,.297,.838,.311,.83,.325,.835,.327,.838,.328,.846,.319,.852,.307,.865,.284,.866,.268,.854,.278,.849,.281,.848,.28,.851,.272,.853,.265,.864,.259,.881,.255,.896,.251,.928,.239,.952,.227,.977,.215,.992,.21,.986,.215,.98,.22,.976,.226,.977,.228,.978,.23,.973,.238,.966,.246,.958,.254,.948,.271,.943,.285,.935,.309,.935,.309,.843,.355,.761,.397,.695,.44,.65,.482,.584,.545,.498,.685,.476,.766,.468,.797,.464,.804,.456,.807,.447,.811,.446,.809,.449,.799,.451,.792,.455,.784,.456,.78,.458,.777,.457,.774,.453,.775,.449,.776,.448,.773,.45,.767,.452,.762,.45,.754,.445,.748,.441,.743,.439,.734,.441,.73,.443,.722,.444,.723,.447,.734,.45,.742,.453,.745,.459,.743,.464,.74,.464,.734,.459,.722,.451,.703,.439,.702,.432,.721,.43,.729,.427,.726,.421,.71,.417,.699,.406,.68,.396,.668,.382,.651,.374,.646,.356,.643,.323,.637,.29,.644,.276,.661],['L',.264,.675,.263,.687,.248,.72],['C',.24,.739,.23,.753,.225,.754,.211,.757,.18,.753,.142,.743,.122,.737,.088,.73,.066,.725,.029,.718,.027,.717,.019,.702,.014,.693,.009,.686,.007,.687,-.003,.692,-.003,.732,.007,.756],['Z']]
        [['M',.959,.166],['C',.984,.187,1.006,.22,1.018,.255,1.024,.272,1.026,.281,1.025,.302,1.024,.339,1.019,.363,1.003,.397,.984,.439,.964,.462,.93,.485,.914,.496,.88,.509,.869,.511,.842,.52,.817,.517,.79,.512,.769,.506,.739,.493,.723,.478,.706,.462,.705,.465,.698,.469,.695,.471,.691,.471,.682,.467,.674,.463,.671,.462,.668,.465,.666,.466,.662,.47,.659,.472,.636,.486,.627,.493,.628,.497,.629,.499,.625,.504,.623,.507,.621,.509,.623,.513,.625,.516,.627,.521,.622,.524,.615,.523,.612,.522,.61,.523,.609,.526,.609,.529,.607,.538,.604,.547,.602,.556,.601,.565,.602,.568,.604,.573,.605,.574,.618,.574,.635,.575,.651,.584,.662,.598,.668,.606,.668,.609,.666,.616,.664,.62,.662,.631,.662,.641,.661,.65,.658,.666,.654,.677,.648,.694,.647,.699,.65,.706,.651,.71,.652,.716,.651,.718,.65,.72,.631,.738,.61,.757,.588,.776,.564,.798,.556,.806,.546,.816,.53,.828,.504,.843,.484,.855,.465,.867,.461,.869,.445,.878,.423,.884,.407,.884,.389,.884,.385,.883,.372,.874,.361,.866,.346,.866,.339,.872,.337,.875,.33,.885,.323,.896,.31,.917,.293,.933,.283,.934,.28,.934,.277,.935,.276,.937,.274,.943,.263,.944,.257,.939,.254,.936,.248,.932,.243,.93,.234,.925,.231,.922,.22,.909,.217,.904,.212,.9,.21,.899,.208,.898,.204,.891,.201,.883,.194,.865,.197,.857,.211,.848,.217,.845,.224,.838,.228,.832,.231,.826,.236,.821,.238,.82,.241,.819,.243,.817,.244,.815,.247,.809,.266,.792,.274,.788,.278,.785,.281,.783,.282,.782,.282,.782,.281,.772,.279,.761,.275,.734,.274,.721,.275,.711,.275,.706,.275,.696,.274,.689,.273,.682,.272,.676,.273,.675,.275,.671,.254,.619,.246,.608,.241,.602,.236,.592,.234,.586,.227,.554,.216,.524,.205,.503,.192,.479,.184,.47,.166,.461,.153,.455,.151,.451,.151,.435,.151,.423,.151,.421,.157,.416,.163,.41,.179,.405,.184,.407,.185,.408,.188,.407,.19,.405,.193,.402,.194,.402,.202,.408,.215,.419,.26,.437,.272,.437,.284,.437,.286,.434,.285,.421,.284,.409,.287,.393,.291,.384,.294,.379,.302,.369,.306,.366,.31,.363,.311,.36,.311,.358,.312,.357,.315,.354,.319,.352,.322,.35,.326,.346,.328,.343],['S',.334,.337,.339,.335],['C',.35,.331,.354,.325,.35,.317,.348,.312,.346,.31,.341,.309,.302,.302,.279,.288,.26,.261,.232,.221,.225,.169,.24,.113,.249,.082,.255,.07,.283,.025,.296,.005,.329,-.024,.346,-.03,.351,-.032,.359,-.036,.364,-.038,.402,-.054,.436,-.049,.474,-.02,.493,-.007,.504,.006,.516,.027,.528,.048,.532,.068,.531,.1,.529,.145,.517,.18,.493,.218,.485,.231,.473,.247,.466,.253,.456,.264,.425,.285,.41,.291,.405,.294,.403,.296,.399,.309,.395,.321,.392,.326,.387,.331,.381,.336,.38,.339,.381,.342,.383,.345,.386,.344,.398,.339,.432,.325,.548,.271,.549,.268,.549,.267,.548,.265,.547,.264,.545,.264,.544,.261,.545,.259,.547,.255,.55,.255,.557,.257,.568,.26,.584,.257,.587,.251,.588,.249,.588,.245,.586,.241,.58,.227,.592,.189,.606,.176,.61,.173,.617,.169,.621,.168,.633,.165,.633,.163,.626,.154,.62,.148,.619,.147,.624,.138,.628,.131,.629,.128,.626,.126,.624,.125,.623,.122,.625,.119,.627,.115,.628,.115,.642,.124,.65,.129,.664,.14,.672,.148,.681,.158,.689,.163,.693,.164,.697,.165,.701,.168,.703,.172,.707,.178,.717,.181,.732,.182,.735,.182,.739,.182,.742,.182,.744,.183,.753,.177,.761,.17],['S',.783,.155,.79,.151],['C',.798,.148,.806,.144,.809,.143,.827,.133,.876,.131,.903,.138,.924,.144,.947,.155,.959,.166],['Z'],['M',.854,.16],['C',.843,.16,.825,.165,.816,.169,.801,.175,.776,.191,.778,.192,.779,.193,.807,.205,.818,.207,.823,.208,.835,.211,.844,.215],['L',.86,.223,.857,.23],['C',.851,.242,.851,.254,.856,.27,.859,.279,.86,.285,.858,.285,.852,.287,.852,.292,.857,.295,.862,.297,.873,.321,.871,.325,.871,.327,.872,.329,.874,.331,.881,.338,.881,.345,.875,.352,.869,.359,.868,.359,.858,.356,.85,.354,.847,.354,.845,.357,.844,.359,.842,.361,.84,.36],['S',.822,.368,.804,.38],['C',.75,.416,.752,.414,.751,.424,.75,.43,.749,.433,.744,.437,.739,.44,.738,.442,.74,.444,.741,.445,.746,.449,.75,.453],['S',.771,.466,.784,.472],['C',.804,.481,.828,.482,.844,.479,.863,.477,.887,.467,.909,.455,.92,.45,.926,.443,.938,.432,.947,.424,.957,.408,.967,.389],['S',.983,.349,.984,.341],['C',.989,.321,.991,.305,.991,.293,.99,.28,.988,.264,.983,.253,.978,.241,.965,.214,.957,.203,.948,.192,.93,.179,.92,.173,.911,.168,.897,.163,.887,.161,.878,.16,.864,.16,.854,.16],['Z'],['M',.412,-.016],['C',.359,-.018,.286,.05,.27,.115,.258,.165,.265,.209,.289,.243,.298,.254,.302,.257,.316,.264,.325,.269,.334,.272,.335,.272,.34,.271,.343,.263,.341,.256,.34,.251,.34,.25,.347,.248],['L',.354,.245,.356,.226],['C',.359,.203,.356,.135,.352,.123,.348,.112,.348,.111,.353,.114,.356,.115,.36,.115,.362,.114,.367,.111,.376,.115,.38,.121,.382,.125,.384,.126,.389,.124,.396,.122,.401,.124,.403,.13,.404,.133,.406,.136,.408,.137,.412,.138,.412,.14,.408,.147,.406,.153,.405,.158,.406,.161,.409,.166,.411,.227,.409,.243,.408,.251,.408,.251,.414,.249,.422,.247,.44,.231,.454,.215,.462,.206,.467,.202,.482,.171],['S',.501,.119,.498,.082],['C',.496,.053,.478,.018,.457,0,.446,-.009,.426,-.016,.412,-.016],['Z'],['M',.813,.212],['C',.807,.21,.797,.207,.793,.206,.786,.202,.779,.202,.773,.199,.772,.196,.764,.204,.759,.209,.754,.213,.749,.221,.746,.225,.743,.229,.748,.233,.75,.233,.753,.234,.759,.236,.765,.237,.77,.238,.778,.24,.781,.241,.786,.243,.815,.249,.825,.251,.829,.251,.84,.237,.835,.234,.831,.232,.827,.228,.827,.224,.827,.215,.824,.215,.813,.212],['Z'],['M',.729,.189],['C',.726,.19,.721,.194,.719,.199,.717,.205,.714,.215,.716,.215,.718,.215,.725,.205,.73,.199,.733,.195,.737,.191,.736,.19,.736,.188,.733,.188,.729,.189],['Z'],['M',.793,.26],['C',.781,.257,.77,.255,.762,.255,.754,.254,.774,.261,.786,.266,.796,.27,.807,.273,.806,.269,.806,.265,.801,.261,.793,.26],['Z'],['M',.749,.256],['C',.736,.252,.733,.256,.743,.262,.746,.264,.75,.267,.751,.269,.753,.274,.807,.3,.811,.298,.816,.296,.815,.286,.81,.282,.804,.278,.763,.261,.749,.256],['Z'],['M',.727,.279],['C',.721,.279,.719,.28,.717,.286,.715,.29,.714,.295,.714,.297,.716,.302,.729,.308,.733,.306,.734,.305,.738,.306,.74,.308,.743,.31,.746,.311,.747,.31,.749,.309,.753,.31,.757,.313,.761,.315,.766,.316,.768,.316,.77,.315,.777,.316,.783,.319,.793,.324,.799,.323,.797,.317,.796,.315,.788,.309,.778,.304,.768,.299,.76,.294,.76,.293,.759,.29,.733,.28,.727,.279],['Z'],['M',.792,.339],['C',.788,.341,.78,.347,.775,.353,.77,.359,.762,.366,.757,.368,.747,.373,.746,.374,.752,.381,.755,.384,.757,.388,.758,.39,.758,.394,.769,.389,.781,.379,.786,.375,.795,.371,.8,.371,.811,.369,.821,.36,.82,.354,.819,.351,.815,.348,.811,.346,.807,.344,.804,.341,.804,.34,.803,.335,.8,.335,.792,.339],['Z'],['M',.76,.323],['C',.75,.321,.737,.317,.73,.315,.71,.308,.707,.31,.705,.332,.703,.346,.707,.378,.711,.38,.715,.382,.781,.336,.78,.331,.78,.328,.78,.328,.76,.323],['Z'],['M',.37,.139],['C',.369,.14,.369,.153,.369,.167,.372,.205,.372,.254,.369,.259,.366,.265,.37,.269,.374,.264,.376,.262,.379,.261,.383,.263,.396,.267,.4,.247,.397,.198,.395,.148,.395,.151,.386,.147,.381,.146,.378,.143,.378,.142,.38,.138,.373,.136,.37,.139],['Z'],['M',.674,.29],['C',.674,.291,.674,.302,.676,.302,.677,.302,.679,.291,.679,.29,.68,.29,.684,.276,.683,.276,.682,.275,.675,.288,.674,.29],['Z'],['M',.662,.339],['C',.661,.341,.657,.343,.653,.345,.649,.348,.645,.352,.642,.358,.637,.368,.625,.45,.628,.452,.629,.452,.632,.449,.636,.445,.639,.442,.65,.432,.66,.424,.679,.408,.681,.406,.677,.398,.676,.395,.673,.38,.672,.364,.668,.338,.666,.331,.662,.339],['Z'],['M',.53,.313],['C',.493,.33,.45,.351,.449,.353,.449,.353,.433,.361,.413,.37],['S',.377,.387,.376,.388],['C',.372,.396,.375,.398,.402,.406,.416,.411,.433,.416,.438,.419,.45,.425,.45,.424,.454,.4,.457,.378,.463,.369,.482,.358,.49,.354,.501,.345,.507,.34,.513,.334,.526,.324,.536,.318,.547,.312,.556,.306,.556,.305,.558,.301,.55,.304,.53,.313],['Z'],['M',.725,.395],['C',.724,.397,.721,.399,.72,.398,.715,.396,.719,.402,.726,.407,.73,.411,.733,.411,.737,.408,.743,.405,.743,.4,.737,.398,.735,.397,.733,.394,.732,.393,.732,.389,.727,.39,.725,.395],['Z'],['M',.679,.427],['C',.674,.428,.668,.436,.672,.437],['S',.689,.432,.688,.429],['C',.688,.425,.686,.424,.679,.427],['Z'],['M',.56,.382],['C',.552,.386,.549,.393,.554,.395,.556,.396,.569,.386,.571,.382,.573,.378,.569,.378,.56,.382],['Z'],['M',.599,.417],['C',.596,.422,.592,.428,.589,.431,.587,.433,.58,.442,.576,.45],['L',.567,.464,.583,.47],['C',.592,.473,.599,.475,.6,.475,.6,.475,.602,.464,.604,.45],['S',.608,.422,.609,.418],['C',.614,.403,.608,.402,.599,.417],['Z'],['M',.689,.454],['C',.688,.455,.689,.456,.691,.457],['S',.695,.458,.697,.457,.697,.455,.694,.453],['C',.692,.452,.689,.452,.689,.454],['Z'],['M',.378,.308],['C',.377,.31,.378,.312,.379,.313],['S',.382,.312,.383,.31],['C',.384,.308,.383,.306,.382,.306],['S',.379,.306,.378,.308],['Z'],['M',.347,.351],['C',.342,.353,.341,.355,.338,.366,.336,.378,.335,.379,.33,.38,.326,.381,.321,.38,.318,.379,.316,.377,.315,.372,.313,.371,.31,.37,.306,.373,.301,.378,.288,.391,.289,.407,.292,.423,.292,.423,.294,.426,.293,.428,.29,.434,.291,.433,.294,.432,.304,.432,.316,.425,.316,.425,.331,.42,.342,.414,.343,.411,.346,.405,.355,.35,.353,.349,.353,.349,.35,.35,.347,.351],['Z'],['M',.57,.499],['C',.566,.507,.578,.544,.585,.544,.59,.545,.594,.532,.592,.521,.591,.516,.591,.512,.591,.511,.592,.509,.588,.506,.582,.503,.575,.5,.57,.498,.57,.499],['Z'],['M',.413,.442],['C',.397,.436,.38,.43,.376,.428,.368,.425,.368,.425,.364,.434,.362,.439,.359,.447,.357,.453,.355,.463,.354,.463,.347,.461,.341,.46,.333,.462,.331,.467,.329,.469,.351,.474,.356,.473,.359,.472,.366,.473,.371,.475,.38,.479,.381,.48,.379,.485,.376,.49,.377,.491,.388,.495,.391,.497,.394,.5,.395,.503,.396,.506,.4,.509,.41,.514,.423,.52,.425,.521,.425,.516,.425,.503,.437,.485,.451,.473,.457,.469,.457,.468,.456,.462,.454,.458,.452,.455,.448,.454,.444,.454,.428,.448,.413,.442],['Z'],['M',.32,.43],['C',.311,.433,.301,.436,.297,.438],['S',.281,.44,.271,.44],['C',.26,.44,.251,.441,.25,.442],['S',.252,.445,.254,.448],['C',.257,.453,.259,.454,.269,.454,.274,.454,.282,.453,.286,.452,.29,.451,.295,.45,.296,.451,.308,.456,.342,.448,.342,.432,.342,.424,.332,.424,.32,.43],['Z'],['M',.19,.421],['C',.18,.423,.181,.429,.191,.428,.195,.428,.203,.429,.207,.431,.22,.434,.22,.43,.208,.424,.201,.421,.195,.42,.19,.421],['Z'],['M',.42,.535],['C',.418,.537,.413,.538,.409,.537,.405,.536,.401,.536,.4,.536,.396,.536,.399,.548,.41,.584,.416,.604,.422,.628,.423,.638],['S',.427,.659,.428,.663],['C',.431,.671,.436,.674,.438,.67,.438,.668,.445,.661,.452,.653,.464,.641,.465,.638,.465,.633,.464,.63,.466,.622,.469,.617,.475,.606,.474,.592,.467,.587,.465,.586,.461,.581,.459,.577,.455,.57,.429,.535,.426,.533,.425,.532,.423,.533,.42,.535],['Z'],['M',.271,.47],['C',.262,.47,.253,.47,.251,.469],['S',.244,.468,.241,.468],['C',.237,.469,.23,.469,.226,.468,.219,.466,.219,.467,.234,.486,.242,.497,.25,.508,.252,.511,.253,.514,.263,.53,.273,.546,.293,.58,.299,.592,.296,.597,.295,.599,.298,.611,.302,.624,.306,.636,.311,.653,.313,.661,.317,.676,.318,.676,.33,.682,.338,.686,.342,.689,.341,.691,.339,.695,.343,.705,.348,.707,.353,.709,.383,.7,.385,.696,.385,.695,.383,.687,.38,.678,.377,.669,.374,.65,.374,.636,.372,.607,.367,.572,.363,.559,.36,.548,.353,.539,.346,.535,.343,.534,.34,.53,.339,.527],['S',.335,.519,.332,.516],['C',.329,.514,.326,.508,.325,.503,.324,.491,.311,.478,.297,.473,.291,.471,.28,.47,.271,.47],['Z']]
        [['M',.631,.947],['C',.652,.938,.671,.928,.687,.917,.847,.813,.788,.631,.788,.631],['S',.817,.62,.836,.563],['C',.855,.506,.839,.467,.839,.467],['S',.866,.447,.874,.419],['C',.881,.392,.892,.318,.903,.306,.914,.295,.92,.292,.92,.292],['S',.93,.288,.938,.276],['C',.94,.272,.943,.26,.944,.244,.953,.242,.974,.235,.984,.231,.993,.228,.993,.229,.995,.228,.995,.228,.996,.228,.997,.226,1.001,.221,1.027,.201,1.035,.193,1.043,.185,1.043,.185,1.045,.175,1.046,.164,1.053,.112,1.046,.114],['S',1.028,.167,1.025,.173],['C',1.022,.179,.992,.208,.984,.209,.977,.211,.951,.217,.945,.219,.944,.193,.94,.166,.927,.159],['L',.931,.16],['C',.931,.16,.966,.075,.973,.062,.98,.05,1.015,.037,1.008,.031,1,.025,.96,.046,.96,.046],['S',.957,.047,.952,.057],['C',.947,.068,.916,.156,.916,.156],['L',.922,.158],['C',.891,.156,.91,.248,.85,.294,.841,.3,.832,.305,.824,.309],['L',.75,.137],['C',.75,.137,.739,.109,.73,.112,.721,.115,.721,.14,.721,.14],['L',.798,.318],['C',.789,.32,.779,.322,.77,.323,.756,.294,.663,.104,.66,.095,.656,.085,.687,.015,.687,.015],['S',.696,-.007,.681,-.014],['C',.666,-.021,.661,-.008,.661,-.008],['L',.624,.081],['C',.624,.081,.623,.084,.625,.096,.627,.108,.65,.15,.65,.15],['L',.739,.329],['C',.715,.334,.691,.343,.67,.366,.659,.378,.633,.41,.603,.449],['L',.511,.366],['C',.511,.366,.455,.326,.434,.318,.414,.309,.384,.329,.382,.344,.381,.359,.392,.356,.392,.356],['S',.425,.35,.438,.352],['C',.451,.354,.573,.48,.573,.48],['L',.601,.451],['C',.536,.535,.444,.658,.376,.756,.338,.749,.291,.738,.277,.736,.255,.734,.245,.745,.221,.75,.196,.756,.097,.799,.097,.799],['S',.069,.809,.069,.824],['C',.068,.838,.092,.843,.092,.843],['L',.25,.791],['C',.25,.791,.29,.794,.312,.802,.317,.804,.328,.805,.341,.807,.31,.855,.289,.89,.29,.898,.293,.934,.402,1.04,.631,.947],['Z']]
        [['M',.149,.851],['C',.167,.857,.19,.859,.212,.864,.253,.873,.299,.882,.356,.885,.383,.887,.412,.883,.442,.878,.464,.875,.494,.87,.517,.854,.533,.843,.54,.823,.543,.806,.546,.788,.54,.77,.532,.757,.521,.763,.51,.77,.499,.776,.482,.785,.47,.791,.454,.794,.438,.797,.423,.796,.408,.793,.445,.78,.484,.768,.518,.75,.546,.735,.572,.719,.598,.699,.624,.68,.65,.662,.679,.648,.698,.639,.714,.634,.734,.633,.754,.631,.772,.638,.789,.645,.8,.65,.809,.654,.825,.653,.838,.651,.851,.649,.863,.637,.873,.627,.879,.611,.882,.594,.908,.581,.931,.571,.956,.556,.971,.546,.982,.54,1.001,.519,1.012,.507,1.03,.489,1.03,.464,1.03,.439,1.004,.422,1,.421],['L',.976,.418,.977,.387],['C',.978,.377,.977,.358,.968,.341,.959,.323,.935,.305,.915,.302,.898,.3,.888,.301,.873,.303,.823,.308,.787,.32,.768,.32,.748,.321,.719,.321,.701,.312,.693,.307,.692,.3,.691,.298,.678,.273,.664,.262,.639,.245,.622,.234,.607,.225,.591,.211,.583,.203,.576,.198,.577,.189,.579,.181,.587,.177,.596,.171,.633,.143,.667,.116,.704,.088,.715,.079,.717,.059,.712,.048,.707,.039,.703,.035,.694,.035,.683,.034,.679,.04,.676,.045,.673,.049,.677,.055,.679,.06,.672,.07,.649,.092,.632,.103],['L',.657,.03],['C',.667,.027,.671,.024,.675,.014,.678,.003,.677,-.006,.669,-.012,.661,-.02,.651,-.022,.643,-.018,.633,-.014,.629,-.005,.628,.005,.628,.011,.631,.016,.636,.021],['L',.597,.109,.592,.033],['C',.603,.024,.608,.013,.603,.001,.599,-.006,.587,-.014,.577,-.012,.564,-.009,.558,.003,.559,.012,.56,.023,.565,.032,.573,.034],['L',.538,.11],['C',.543,.088,.545,.07,.542,.049,.541,.039,.534,.032,.53,.031,.521,.026,.513,.027,.507,.031,.496,.039,.494,.05,.495,.06,.497,.071,.503,.077,.516,.085],['L',.486,.174],['C',.478,.199,.478,.218,.486,.238,.495,.258,.503,.273,.522,.288,.53,.294,.544,.294,.559,.299,.57,.302,.577,.308,.586,.317,.56,.309,.552,.309,.535,.306,.498,.3,.475,.301,.444,.304,.405,.308,.384,.316,.355,.336,.33,.354,.316,.375,.299,.399,.289,.391,.277,.386,.266,.384,.295,.345,.326,.307,.355,.268,.362,.26,.367,.253,.371,.245,.376,.232,.377,.223,.373,.214,.367,.204,.356,.199,.347,.2,.334,.202,.331,.21,.328,.221,.325,.231,.329,.238,.338,.247],['L',.238,.359,.285,.272],['C',.293,.257,.301,.235,.294,.223,.289,.214,.279,.206,.27,.208,.254,.211,.245,.224,.245,.236,.245,.251,.253,.257,.267,.264],['L',.188,.381],['C',.193,.365,.197,.353,.203,.339,.209,.328,.21,.314,.211,.305,.212,.296,.209,.285,.204,.279,.197,.272,.186,.267,.177,.269,.167,.271,.159,.278,.156,.286,.152,.295,.151,.303,.156,.311,.161,.32,.167,.325,.177,.328],['L',.154,.371],['C',.146,.386,.137,.4,.128,.414,.106,.449,.09,.47,.068,.497,.05,.519,.034,.538,.018,.557,-.004,.583,-.016,.605,-.028,.629,-.035,.644,-.035,.658,-.034,.673,-.032,.688,-.027,.7,-.013,.711,-.001,.721,.014,.722,.033,.719,.048,.716,.061,.706,.072,.692,.082,.706,.091,.712,.103,.723,.114,.732,.129,.737,.144,.742,.17,.751,.196,.758,.224,.762,.243,.764,.261,.767,.28,.774,.288,.777,.296,.781,.302,.787,.219,.781,.216,.775,.176,.772,.154,.771,.136,.777,.125,.789,.117,.799,.115,.812,.118,.823,.121,.839,.134,.847,.149,.851],['Z'],['M',.843,.356],['C',.853,.338,.865,.328,.892,.328,.915,.329,.931,.338,.942,.356,.954,.377,.952,.394,.949,.417,.907,.42,.869,.424,.855,.411,.838,.396,.831,.379,.843,.356],['Z'],['M',.801,.52],['C',.785,.507,.781,.484,.794,.467,.807,.45,.831,.447,.848,.46,.848,.46,.848,.46,.849,.46,.865,.473,.868,.497,.856,.514,.843,.531,.819,.534,.802,.521,.802,.521,.802,.521,.801,.52],['Z'],['M',.297,.479],['C',.294,.46,.275,.438,.237,.434,.244,.423,.251,.411,.258,.4,.268,.401,.305,.421,.316,.446,.329,.477,.324,.537,.262,.574,.293,.542,.302,.51,.297,.479],['Z']]
        [['M',.314,.964],['C',.3,.942,.292,.911,.293,.882,.293,.859,.295,.849,.302,.83,.307,.815,.308,.813,.316,.799,.32,.794,.323,.789,.323,.788,.324,.786,.322,.784,.307,.772,.279,.749,.237,.706,.218,.682,.212,.673,.211,.672,.208,.672,.207,.672,.205,.672,.204,.673,.201,.676,.181,.686,.168,.69,.115,.708,.047,.693,.017,.658,-.014,.621,-.02,.574,.001,.535,.006,.525,.02,.509,.03,.502,.054,.485,.088,.482,.123,.494,.141,.5,.159,.51,.179,.525,.19,.533,.193,.534,.195,.53,.205,.514,.224,.493,.238,.482,.248,.475,.248,.473,.237,.47,.214,.462,.2,.454,.187,.441,.176,.43,.172,.423,.169,.411,.164,.392,.168,.369,.18,.347,.189,.331,.204,.32,.224,.316,.237,.313,.248,.313,.26,.314,.267,.315,.274,.316,.276,.316,.279,.316,.281,.317,.281,.317,.281,.317,.285,.318,.29,.319,.3,.322,.318,.328,.339,.337,.349,.341,.358,.344,.359,.345,.368,.348,.371,.35,.377,.352,.389,.357,.414,.37,.424,.376,.43,.38,.436,.383,.437,.383,.439,.383,.439,.38,.435,.364,.429,.342,.426,.314,.428,.293,.428,.287,.429,.282,.429,.281,.429,.281,.43,.275,.431,.267,.434,.254,.437,.241,.443,.229,.445,.224,.446,.218,.446,.215,.447,.209,.449,.207,.459,.2,.463,.197,.469,.193,.472,.19,.479,.185,.48,.182,.476,.179,.473,.175,.474,.172,.488,.162,.501,.15,.517,.141,.534,.135,.541,.132,.547,.129,.547,.128],['S',.547,.125,.545,.122],['C',.531,.102,.518,.068,.518,.052,.519,.046,.524,.032,.528,.024,.534,.015,.546,.002,.556,-.003,.588,-.021,.632,-.017,.666,.008,.671,.011,.678,.018,.683,.024,.702,.045,.712,.069,.712,.094,.711,.106,.709,.113,.7,.124,.695,.129,.691,.134,.691,.135,.69,.136,.695,.14,.707,.146,.74,.161,.775,.188,.8,.216,.812,.23,.814,.232,.824,.247,.839,.269,.851,.293,.857,.312,.859,.317,.861,.317,.872,.312,.901,.3,.937,.305,.968,.325,.976,.331,.98,.334,.989,.343,1.002,.357,1.007,.366,1.013,.384,1.018,.399,1.019,.418,1.015,.43,1.013,.437,1.013,.437,.996,.453,.983,.467,.979,.47,.972,.474,.953,.485,.939,.489,.923,.489,.905,.489,.889,.482,.872,.467,.867,.462,.861,.458,.86,.458,.859,.457,.857,.46,.853,.468,.847,.483,.838,.497,.831,.505],['L',.825,.511,.82,.507],['C',.815,.502,.811,.503,.812,.508,.812,.51,.813,.513,.813,.515,.814,.517,.813,.52,.813,.522,.811,.526,.805,.532,.802,.533,.799,.533,.799,.533,.798,.529,.797,.525,.794,.522,.792,.524,.791,.525,.789,.53,.787,.536],['L',.783,.546,.775,.55],['C',.762,.556,.74,.563,.724,.566,.708,.569,.676,.569,.661,.567,.656,.566,.651,.565,.649,.565,.646,.564,.624,.559,.619,.557,.614,.555,.61,.555,.61,.557,.61,.557,.613,.563,.617,.568,.631,.589,.645,.613,.662,.647,.678,.679,.68,.685,.685,.698,.69,.715,.691,.72,.692,.731,.695,.754,.692,.773,.683,.788,.675,.801,.653,.816,.633,.821,.629,.822,.619,.823,.613,.824,.595,.824,.581,.817,.565,.802,.552,.789,.543,.774,.534,.751,.53,.739,.529,.738,.524,.744,.504,.771,.484,.79,.464,.802,.46,.804,.456,.807,.456,.808],['S',.459,.814,.463,.819],['C',.484,.848,.49,.858,.498,.882,.505,.906,.506,.93,.5,.949,.494,.967,.485,.979,.47,.991,.453,1.005,.434,1.012,.411,1.013,.39,1.014,.371,1.009,.352,.999,.34,.992,.321,.975,.314,.964],['Z']]
        [['M',.057,.726],['C',.058,.724,.059,.724,.06,.725,.061,.726,.062,.727,.064,.726,.067,.724,.055,.705,.039,.688,.024,.673,.016,.658,.011,.637,.009,.63,.009,.625,.011,.624,.013,.624,.011,.619,.008,.614,-.002,.597,-.003,.592,.005,.588,.01,.586,.011,.584,.008,.578,.005,.573,.006,.571,.01,.57,.015,.568,.013,.565,-.013,.532,-.025,.517,-.036,.496,-.035,.489,-.035,.487,-.032,.483,-.028,.481,-.022,.477,-.022,.476,-.028,.466],['L',-.034,.454,-.025,.45],['C',.001,.436,.02,.441,.036,.466,.047,.484,.062,.496,.071,.494,.104,.484,.124,.475,.176,.444,.225,.414,.23,.41,.246,.393,.256,.383,.266,.371,.268,.366,.278,.34,.317,.286,.332,.277,.338,.274,.339,.272,.336,.27,.332,.268,.335,.266,.356,.254,.375,.244,.38,.24,.378,.238,.377,.236,.378,.234,.379,.233,.382,.231,.405,.224,.42,.22,.424,.219,.424,.218,.42,.217,.418,.216,.415,.215,.415,.214,.414,.212,.466,.201,.488,.198,.499,.197,.503,.195,.507,.19,.51,.186,.519,.18,.532,.173,.544,.167,.551,.162,.551,.16,.551,.159,.557,.153,.564,.147,.57,.142,.58,.133,.585,.126,.59,.119,.603,.108,.621,.095,.653,.073,.666,.059,.685,.027,.692,.016,.699,.006,.702,.005,.709,.003,.721,.01,.725,.02],['L',.729,.029,.719,.03],['C',.71,.031,.709,.032,.704,.04,.701,.044,.699,.051,.699,.055,.699,.061,.699,.062,.705,.062,.708,.063,.711,.062,.711,.061,.712,.06,.724,.052,.739,.043],['L',.765,.026,.785,.032],['C',.796,.036,.807,.04,.809,.042,.815,.047,.812,.057,.802,.066,.793,.074,.762,.118,.756,.131,.754,.137,.754,.141,.757,.146,.769,.166,.743,.231,.709,.266,.69,.285,.687,.289,.687,.302,.685,.341,.676,.382,.667,.388,.663,.39,.648,.383,.639,.375],['L',.631,.368,.626,.387],['C',.623,.397,.618,.41,.614,.417,.61,.423,.605,.438,.602,.45,.595,.479,.594,.48,.573,.506,.563,.519,.552,.535,.549,.543,.541,.561,.535,.59,.538,.594,.541,.598,.538,.615,.535,.615,.534,.615,.532,.624,.532,.635,.532,.647,.531,.653,.529,.652,.527,.651,.525,.656,.524,.668,.521,.697,.503,.741,.481,.772,.44,.83,.426,.846,.394,.869],['L',.377,.881,.379,.901],['C',.381,.912,.38,.92,.378,.92,.376,.92,.373,.924,.372,.929],['S',.369,.937,.369,.936],['C',.368,.935,.367,.939,.365,.945,.361,.956,.347,.969,.346,.962,.345,.959,.343,.96,.336,.968,.323,.983,.316,.986,.315,.98,.314,.976,.312,.975,.307,.977,.303,.978,.3,.977,.299,.975,.299,.973,.291,.972,.28,.972,.269,.973,.259,.972,.256,.969,.253,.967,.248,.966,.246,.966,.241,.967,.241,.966,.243,.963,.244,.959,.243,.958,.234,.956,.225,.953,.223,.952,.227,.95,.23,.948,.23,.947,.225,.945,.219,.941,.191,.915,.175,.899,.17,.893,.163,.886,.161,.884,.157,.881,.158,.881,.162,.881,.166,.882,.166,.881,.161,.874,.156,.867,.15,.86,.122,.835,.119,.833,.119,.832,.121,.832,.124,.832,.124,.83,.12,.827,.116,.823,.115,.82,.116,.818,.118,.815,.114,.809,.098,.789,.074,.761,.055,.73,.057,.726],['Z'],['M',.06,.579],['C',.061,.579,.062,.576,.062,.574,.062,.572,.07,.577,.08,.586,.095,.599,.099,.602,.104,.6,.107,.598,.115,.6,.122,.603,.132,.607,.136,.61,.143,.622,.151,.635,.153,.636,.171,.643,.181,.647,.191,.652,.193,.653,.195,.655,.201,.652,.21,.647,.227,.637,.244,.632,.26,.634],['L',.271,.635,.271,.601],['C',.271,.561,.272,.541,.278,.508,.281,.491,.281,.485,.278,.485,.273,.485,.212,.518,.156,.551,.109,.579,.108,.579,.07,.571,.054,.568,.048,.568,.042,.571],['L',.034,.576,.047,.578],['C',.053,.579,.059,.58,.06,.579],['Z']]
        [['M',.385,1.079],['C',.477,1.006,.357,.812,.499,.773,.632,.735,.8,.593,.818,.453,.82,.437,.824,.452,.884,.425,.936,.402,1.004,.329,.99,.327,.981,.326,.973,.326,.964,.326,1.001,.285,1.025,.245,1.005,.238,.774,.158,.767,.361,.721,.365,.639,.374,.603,.365,.488,.428,.449,.449,.391,.505,.379,.526,.377,.483,.327,.287,.229,.594,.187,.728,.324,.831,.273,.99,.22,1.17,.273,1.166,.385,1.079],['Z']]
        [['M',.044,.941],['C',.046,.945,.049,.946,.06,.943,.084,.936,.096,.93,.134,.905],['L',.171,.881,.2,.883],['C',.224,.886,.232,.885,.248,.88],['L',.266,.874,.284,.885],['C',.293,.891,.311,.904,.323,.913,.344,.928,.373,.941,.383,.94,.394,.939,.395,.93,.387,.91,.383,.899,.379,.886,.379,.881,.378,.875,.374,.865,.37,.859],['S',.361,.844,.361,.841],['C',.36,.83,.345,.819,.328,.816,.318,.813,.31,.809,.308,.806,.299,.781,.299,.78,.321,.736,.335,.71,.338,.708,.377,.697,.387,.694,.41,.687,.43,.681,.463,.67,.468,.669,.503,.669,.524,.669,.55,.67,.562,.67,.612,.673,.694,.657,.748,.635,.78,.621,.814,.597,.832,.574,.852,.549,.857,.527,.855,.466,.854,.416,.854,.41,.862,.395,.877,.362,.902,.354,.956,.365,.973,.368,.987,.37,.988,.369,.991,.365,.977,.354,.956,.346,.913,.328,.883,.332,.853,.359,.842,.369,.833,.376,.832,.376,.829,.373,.837,.341,.846,.318,.856,.296,.875,.27,.897,.247,.906,.238,.907,.235,.905,.219,.903,.197,.903,.141,.905,.11,.906,.098,.906,.085,.904,.081,.899,.071,.876,.064,.855,.067,.839,.069,.837,.07,.836,.076,.836,.082,.838,.084,.841,.084,.844,.083,.847,.085,.847,.088],['S',.85,.097,.854,.101],['C',.869,.119,.87,.177,.857,.207,.847,.23,.825,.262,.818,.263,.811,.263,.806,.253,.778,.19,.751,.129,.749,.127,.713,.132,.679,.136,.676,.137,.677,.147,.678,.154,.681,.157,.69,.159,.697,.161,.706,.163,.71,.162,.714,.162,.722,.164,.726,.168,.737,.178,.751,.206,.753,.223,.755,.242,.742,.278,.728,.29,.723,.295,.709,.308,.697,.318,.686,.329,.671,.343,.664,.35,.652,.363,.636,.4,.638,.413,.639,.427,.632,.429,.606,.425,.593,.423,.565,.42,.543,.419,.485,.417,.462,.414,.432,.407,.407,.401,.405,.4,.401,.388,.398,.382,.394,.375,.393,.374,.389,.372,.366,.323,.353,.287,.347,.272,.338,.241,.332,.217,.322,.177,.313,.157,.306,.158,.301,.158,.283,.132,.279,.121,.273,.103,.259,.099,.221,.106,.218,.107,.212,.107,.206,.106,.2,.106,.191,.107,.186,.109,.176,.113,.175,.118,.185,.127,.193,.134,.192,.139,.179,.142,.172,.145,.168,.148,.168,.151,.169,.16,.194,.177,.205,.175,.22,.174,.231,.184,.243,.21,.252,.23,.254,.239,.258,.283,.263,.34,.26,.394,.25,.422,.247,.431,.237,.449,.228,.462,.201,.503,.195,.517,.196,.547,.197,.563,.195,.579,.191,.59,.184,.612,.177,.644,.178,.651,.178,.654,.171,.684,.165,.687,.131,.693,.122,.699,.111,.717,.104,.727,.101,.738,.107,.752,.112,.764,.128,.778,.126,.791,.125,.803,.122,.815,.12,.817,.118,.818,.11,.82,.103,.821,.091,.822,.075,.835,.076,.844,.076,.846,.071,.856,.065,.868,.053,.891,.04,.934,.044,.941],['Z']]
        [['M',.09,1.054],['C',.09,1.054,.169,.972,.231,.901,.243,.889,.252,.877,.259,.867,.309,.863,.384,.845,.384,.845],['S',.373,.854,.387,.862],['C',.402,.87,.552,.879,.715,.727,.878,.576,.848,.473,.861,.442,.868,.425,.907,.39,.934,.343],['L',.934,.344,.939,.358],['C',.942,.366,.931,.38,.931,.38],['S',.945,.366,.957,.338],['L',.957,.338],['C',.958,.336,.959,.334,.96,.332,.96,.33,.961,.328,.962,.326,.976,.29,.96,.223,.96,.223],['L',.96,.224],['C',.959,.219,.958,.215,.957,.211,.927,.099,.823,.094,.823,.094],['S',.734,-.035,.722,-.027,.772,.115,.778,.14],['C',.783,.165,.779,.22,.764,.258,.748,.295,.743,.29,.743,.29],['S',.592,.336,.483,.403],['C',.478,.402,.45,.396,.443,.393,.435,.39,.429,.395,.429,.395],['L',.429,.383],['C',.429,.383,.42,.317,.424,.304,.429,.291,.454,.267,.453,.253,.452,.24,.421,.232,.421,.232],['L',.421,.233],['C',.42,.224,.418,.215,.417,.212,.413,.204,.394,.194,.386,.194],['S',.371,.196,.371,.196],['L',.375,.204],['C',.375,.204,.395,.204,.402,.216,.409,.229,.408,.344,.403,.372,.401,.384,.398,.392,.396,.397,.388,.406,.379,.417,.376,.426,.374,.432,.37,.441,.371,.45,.364,.452,.359,.453,.359,.453],['L',.362,.462],['C',.362,.462,.366,.462,.372,.461,.372,.462,.373,.463,.373,.465],['L',.372,.462],['C',.372,.462,.371,.457,.365,.472,.359,.486,.331,.531,.325,.535,.318,.539,.308,.533,.308,.533],['L',.304,.543],['C',.304,.543,.325,.548,.334,.542],['S',.342,.524,.342,.524],['L',.351,.533],['C',.32,.582,.307,.623,.307,.623],['S',.206,.745,.155,.797],['C',.104,.849,.076,.981,.076,.981],['L',.1,.962],['C',.1,.962,.093,.971,.082,.988,.071,1.004,.066,1.036,.066,1.036],['L',.077,1.027,.106,1.002],['C',.106,1.002,.1,1.013,.092,1.024],['S',.09,1.054,.09,1.054],['Z'],['M',.838,.191],['C',.836,.183,.838,.176,.843,.174,.848,.173,.854,.178,.856,.186,.858,.191,.858,.195,.856,.199,.855,.201,.853,.202,.852,.203,.846,.204,.84,.199,.838,.191],['Z'],['M',.422,.24],['C',.426,.242,.437,.249,.436,.257],['L',.436,.257],['C',.436,.268,.424,.271,.424,.271],['S',.423,.255,.422,.24],['Z'],['M',.384,.486,.387,.484],['C',.386,.485,.385,.486,.384,.487],['L',.384,.486],['Z']]
        [['M',.823,.149],['C',.861,.181,.885,.206,.878,.219],['L',.839,.278],['C',.823,.331,.811,.39,.79,.432,.772,.463,.751,.494,.726,.525,.672,.584,.618,.656,.567,.686,.513,.711,.458,.734,.401,.752,.353,.801,.247,.894,.217,.895,.2,.894,.184,.891,.168,.882,.16,.887,.15,.878,.14,.864],['L',.116,.842,.128,.807,.165,.751,.173,.735],['C',.145,.677,.212,.61,.27,.627],['L',.281,.608,.53,.325,.528,.318,.548,.296],['C',.515,.241,.584,.152,.652,.188],['L',.662,.177,.695,.148,.746,.103],['C',.766,.096,.777,.096,.784,.099],['L',.785,.106,.816,.128],['C',.824,.138,.825,.142,.823,.149],['Z'],['M',.676,.56],['C',.703,.529,.728,.498,.745,.466],['L',.686,.426,.601,.518],['C',.599,.523,.596,.527,.603,.532],['L',.667,.57],['C',.67,.567,.673,.563,.676,.56],['Z'],['M',.748,.461],['C',.759,.439,.767,.416,.769,.393,.77,.384,.767,.378,.762,.374,.748,.366,.738,.369,.73,.379],['L',.69,.422,.748,.461],['Z'],['M',.649,.591,.574,.561],['C',.568,.56,.562,.561,.555,.568],['L',.467,.662],['C',.488,.657,.496,.683,.48,.694,.525,.687,.564,.67,.596,.644,.615,.628,.632,.609,.649,.591],['Z'],['M',.873,.216],['C',.877,.206,.858,.186,.833,.164],['L',.81,.191],['C',.818,.199,.827,.207,.837,.214,.854,.224,.862,.219,.873,.216],['Z'],['M',.698,.371,.677,.396],['C',.675,.398,.672,.398,.67,.396,.668,.395,.668,.392,.67,.39],['L',.691,.365],['C',.693,.363,.696,.363,.698,.364,.7,.366,.7,.369,.698,.371],['Z'],['M',.546,.539,.524,.564],['C',.523,.566,.52,.566,.518,.565],['S',.515,.56,.517,.558],['L',.539,.533],['C',.54,.531,.543,.531,.545,.533],['S',.548,.537,.546,.539],['Z'],['M',.583,.302],['C',.561,.282,.558,.247,.578,.225],['S',.632,.199,.655,.219,.68,.273,.66,.296,.606,.321,.583,.302],['Z'],['M',.209,.747],['C',.186,.727,.183,.693,.203,.67],['S',.257,.645,.28,.664,.305,.718,.285,.741,.231,.766,.209,.747],['Z'],['M',.229,.824,.182,.877],['C',.195,.881,.207,.882,.221,.88],['L',.237,.858],['C',.24,.853,.239,.85,.239,.847],['L',.229,.824],['Z']]
        [['M',.356,1.028],['C',.362,1.033,.369,1.038,.376,1.041,.385,1.046,.395,1.051,.405,1.051,.415,1.051,.426,1.045,.434,1.04,.444,1.035,.451,1.027,.458,1.019,.462,1.014,.46,1.008,.461,1.003,.462,.996,.462,.99,.463,.984,.458,.98,.462,.97,.454,.969,.452,.969,.452,.965,.451,.963,.449,.956,.452,.948,.455,.939],['L',.475,.921,.475,.921],['S',.494,.924,.502,.92],['C',.522,.911,.537,.893,.548,.874,.561,.854,.569,.807,.569,.807],['L',.579,.73],['C',.586,.72,.592,.707,.604,.705],['L',.705,.643,.675,.602,.686,.587,.706,.571],['C',.707,.567,.708,.562,.709,.558],['L',.739,.519],['C',.743,.517,.747,.516,.751,.514],['L',.758,.505,.751,.503,.753,.5,.763,.496],['C',.767,.489,.77,.481,.774,.473],['L',.784,.46,.791,.451,.798,.442,.791,.435,.809,.447,.797,.43,.925,.305,.918,.301,.942,.277],['C',.947,.273,.952,.269,.957,.265,.958,.263,.959,.261,.96,.259],['L',.967,.252],['S',.964,.249,.958,.244],['C',.957,.243,.957,.241,.956,.238,.952,.237,.948,.235,.945,.233,.932,.221,.915,.207,.898,.191,.89,.183,.883,.174,.876,.166,.876,.166,.869,.154,.862,.153,.861,.153,.861,.153,.86,.153,.857,.15,.855,.151,.853,.158,.853,.159,.853,.159,.852,.16,.852,.16,.852,.161,.852,.161,.852,.161,.852,.162,.852,.162,.851,.174,.862,.207,.871,.229],['L',.876,.258,.867,.269,.856,.262,.842,.243,.851,.277,.797,.305,.78,.317,.775,.323,.763,.331,.755,.333,.745,.337,.738,.346,.732,.349,.722,.349,.713,.36,.712,.362,.703,.367,.688,.39,.687,.399,.675,.405,.643,.429,.628,.343,.639,.313,.645,.303,.662,.255,.661,.249,.674,.214,.676,.211,.69,.187,.686,.181,.691,.165,.697,.162,.694,.158,.704,.13,.687,.125,.691,.099,.693,.092],['S',.694,.081,.695,.071],['L',.697,.055,.697,.054],['C',.697,.054,.697,.053,.697,.053],['L',.699,.042],['S',.694,.042,.69,.042],['C',.686,.039,.681,.038,.677,.039,.675,.039,.67,.04,.665,.041,.64,.04,.605,.04,.576,.04,.553,.041,.552,.042,.556,.05],['L',.556,.05],['C',.554,.055,.557,.06,.563,.061,.57,.07,.589,.077,.601,.081],['L',.614,.087,.614,.104,.593,.098,.542,.291],['C',.542,.297,.542,.303,.541,.31],['L',.538,.315,.539,.319],['C',.537,.328,.535,.336,.534,.344],['L',.53,.35,.536,.364,.532,.381,.531,.411,.524,.419,.523,.436,.528,.474,.528,.477,.503,.48,.504,.51],['C',.498,.622,.483,.618,.422,.694],['L',.35,.608,.325,.614,.342,.584,.312,.589,.32,.578,.362,.573,.31,.56,.36,.549,.303,.555,.267,.576,.241,.556],['S',.239,.554,.239,.552],['C',.238,.55,.24,.547,.239,.545,.237,.54,.228,.535,.228,.535],['L',.223,.534,.222,.524,.22,.517],['S',.224,.512,.224,.509],['C',.223,.508,.222,.507,.22,.507,.217,.507,.213,.514,.213,.514],['L',.213,.523,.214,.533],['C',.21,.533,.208,.533,.206,.537],['L',.205,.532,.203,.518,.205,.504],['C',.206,.501,.202,.503,.201,.503,.197,.506,.197,.516,.197,.516],['L',.199,.53,.201,.538,.199,.54,.196,.53,.194,.516],['S',.199,.503,.195,.503],['L',.193,.502],['C',.188,.502,.189,.515,.189,.515],['L',.189,.53,.193,.542,.192,.543,.186,.527,.187,.513],['S',.191,.501,.187,.501],['L',.184,.501],['C',.18,.501,.18,.512,.18,.512],['L',.18,.523,.187,.545,.195,.559,.203,.566,.223,.579,.252,.6,.361,.724,.368,.741,.365,.735,.324,.713,.28,.673,.263,.651,.246,.646,.223,.606,.228,.64,.192,.589,.205,.628,.186,.579,.169,.619,.147,.63,.146,.629,.136,.616],['C',.129,.611,.122,.608,.115,.604],['L',.109,.591],['C',.106,.586,.109,.582,.108,.576],['S',.104,.571,.103,.574],['C',.101,.576,.102,.581,.101,.584,.103,.589,.102,.594,.104,.599,.106,.604,.102,.602,.1,.605,.096,.598,.095,.595,.092,.588,.088,.583,.091,.575,.09,.571,.09,.567,.086,.57,.085,.572,.083,.575,.083,.578,.082,.581,.085,.592,.09,.603,.094,.613],['L',.088,.613,.08,.601],['C',.08,.599,.081,.596,.081,.594,.084,.59,.082,.583,.079,.582,.075,.58,.075,.586,.073,.588,.073,.594,.074,.6,.074,.607,.075,.608,.076,.609,.078,.611,.08,.612,.081,.615,.08,.618,.077,.617,.074,.609,.071,.606,.064,.597,.074,.593,.073,.587,.073,.581,.066,.588,.065,.589,.06,.596,.063,.602,.061,.609],['L',.076,.63],['C',.079,.632,.081,.633,.084,.634,.095,.64,.107,.643,.119,.647,.126,.649,.132,.651,.138,.654],['L',.136,.657],['C',.189,.689,.238,.734,.289,.76],['L',.309,.774,.412,.892,.394,.865,.394,.872,.399,.875,.398,.893],['C',.385,.894,.377,.88,.366,.887,.362,.889,.358,.898,.362,.905,.362,.905,.362,.905,.362,.905,.362,.905,.363,.905,.363,.905,.363,.905,.363,.906,.363,.906,.363,.906,.363,.907,.363,.907,.363,.907,.363,.906,.363,.906,.369,.908,.376,.909,.375,.911,.378,.916,.365,.925,.355,.918,.355,.925,.351,.927,.35,.929,.332,.927,.338,.942,.34,.953,.334,.964,.331,.975,.332,.987,.33,.984,.326,.982,.328,.987,.33,.996,.333,1.006,.34,1.012,.344,1.018,.35,1.023,.356,1.028],['Z']]
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
        yInstruct = y + h/2 + 36 #***

        instruction = @root.show.Instructions target.operation(),
          y: yInstruct

        [initial, instruction]
