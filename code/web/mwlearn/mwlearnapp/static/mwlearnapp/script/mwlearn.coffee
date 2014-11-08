window.doDebug = ->
  #alert obj2str(mwl.data._local_datastore)
  alert mwl.time.Now()

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
objPath = (obj,path...) ->
  x = obj
  for el in path
    if x?
      x = x[el]
    else
      break
  x
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
window.convertTime = (t,unitFrom,unitTo) -> t*msPerT(unitFrom)/msPerT(unitTo)
window.time2str = (t,showms=false) ->
  hours = Math.floor(convertTime(t,'ms','hour'))
  t -= convertTime(hours,'hour','ms')

  minutes = Math.floor(convertTime(t,'ms','minute'))
  t -= convertTime(minutes,'minute','ms')

  seconds = Math.floor(convertTime(t,'ms','second'))
  t -= convertTime(seconds,'second','ms')

  strHours = if hours>0 then "#{zpad(hours,2)}:" else ''
  strMinutes = "#{zpad(minutes,2)}:"
  strSeconds = zpad(seconds,2)
  strMS = if showms then ".#{t}" else ''
  "#{strHours}#{strMinutes}#{strSeconds}#{strMS}"
window.squareGrid = (n) ->
  #pick a row/column size to optimize holding n things while staying squarish
  rc = [1..Math.max(1,Math.floor(Math.sqrt(n)))]
  cr = (Math.max(1,Math.ceil(n/x)) for x in rc)
  score = (1/((1+rc[i]*cr[i]-n)*Math.pow(1+cr[i]-rc[i],3)) for i in [0..rc.length-1])
  iMax = 0
  iMax = i for i in [1..score.length-1] when score[i]>score[iMax]
  row = Math.min(rc[iMax], cr[iMax])
  col = Math.max(rc[iMax], cr[iMax])
  [row, col]


window.MWLearn = class MWLearn
  base: null

  user: null
  csrf: null

  type: null
  container: null
  el: null
  im: null

  status: null
  background: null

  debug: false

  _background: null
  _isbase: false

  _ready: false

  constructor: (options={}) ->
    if options.base?
      @base = options.base
    else
      @_isbase = true
      @base = @

    @type = options.type ? 'experiment'

    defaults = {
      debug: false
      container: @type
      background: 'white'
      background_stroke: 'none'
      images: []
      loadimages: false
      fixation: ["Circle", [{color:"red", r:5}]]
      run_session: false
    }
    defaults = merge defaults, switch @type
      when 'experiment'
        {
          loadimages: true
          run_session: true
        }
      when 'status'
        {}
      when 'history'
        {}
      when 'popup'
        {
          background_stroke: 'black'
        }
      else
        {}

    options = merge defaults, options

    @debug = options.debug

    @user = options.user
    @csrf = options.csrf

    @container = options.container
    @background = options.background

    @im = {}

    @paper = Raphael @container

    @action = @Action()
    @show = @Show()
    @input = @Input()
    @time = @Time()
    @color = @Color()
    @exec = @Exec()
    @queue = @Queue()

    @_background = @show.Rectangle
      color: @background
      width: @width()
      height: @height()
      stroke: options.background_stroke
      "stroke-width": 16

    @el = {}
    timerName = 'session'
    switch @type
      when 'experiment'
        @el.status = new MWLearn
          base: @
          type: 'status'
          practice_time: options.practice_time
          debug: @debug
        @el.history = new MWLearn
          base: @
          type: 'history'
          debug: @debug
        @el.popup = new MWLearn
          base: @
          type: 'popup'
          debug: @debug
      when 'status'
        @el.timer = @show.Timer options.practice_time ? convertTime(25,'minute','ms'),
          name: timerName
          timeout: msPerT('dayminus10minutes')
          initialize: false
          color: 'gray'
          l: 10
          t: 10

        @el.actions = @show.ItemList {},
          l: 10
          t: @el.timer.attr("t") + @el.timer.attr("height") + 10
        @el.actions.contain()
      when 'history'
        @el.record = @show.TrialRecord
          width: @width()-10
          height: @height()-10
      when 'popup'
        @visible false
      else
        null

    @data = @Data()
    @game = @Game()
    @session = @Session()

    if @_isbase then @el.status.el.timer.initialize()

    if options.loadimages
      imConstruct = @game.construct.srcPart("all")
      images = options.images.concat imConstruct
      if images.length then @LoadImages(images)

    if options.run_session then @queue.add 'session_run', => @session.run()

    @ready(true)

  width: -> @paper.width
  height: -> @paper.height
  clear: -> @paper.clear()

  ready: (state=null) ->
    if state?
      @_ready = state
      if @_ready then @queue.do()

      if @type=='experiment'
        @el.status.ready(state)
        @el.history.ready(state)
        @el.popup.ready(state)
    @_ready

  LoadImages: (images) ->
    @action.start 'loadimages', 'loading images'

    nLoaded = 0
    p = @show.Progress "Loading Images", steps:20
    fUpdate = => p.update ++nLoaded/images.length

    for idx in [0..images.length-1]
      f = if idx==images.length-1 then (=> fUpdate(); @action.stop('loadimages')) else fUpdate

      qName = "image_#{images[idx]}"
      @queue.add qName, f, {do:false}
      @im[images[idx]] = new Image()
      @im[images[idx]].src = images[idx]
      @im[images[idx]].onload = ((name) => => @queue.do name)(qName)

  visible: (state) ->
    elements = if @type=='popup'
      ["\##{@container}", "\##{@container}_dim"]
    else
      ["\##{@container}"]

    (if state then $(el).show() else $(el).hide()) for el in elements

  MWClass: class MWClass
    root: null
    base: null

    constructor: (root) ->
      @root = root
      @base = root.base

  Action: -> new MWClassAction(@)
  MWClassAction: class MWClassAction extends MWClass
    constructor: (root) ->
      super root

    actions: -> objPath(@,'root','el','status','el','actions')

    start: (name, action) -> if @actions()? then @actions().add name, action

    stop: (name) -> if @actions()? then @actions().remove name

    dialog: (prompt, options={}) ->
      ###prompt: for 'info' type, a function that takes an mwl object and
        displays something. for 'yesno' type, the string to prompt.###
      popup = @base.el.popup
      popup.visible true

      options.type = options.type ? 'info'
      options.callback = options.callback ? null

      ffCallback  = ((stm) => (response) =>
          s.remove() for s in stim when s.exists
          popup.visible false
          if options.callback? then options.callback(response)
        )

      switch options.type
        when 'info'
          stim = forceArray(prompt(popup))

          stim.push(popup.show.X
              href: 'javascript:void(0)'
              mouseup: => ffCallback(stim)(null)
              l: 10
              t: 10
            )
        when 'yesno'
          stim = [popup.show.YesNo prompt,
            callback: (responseYes) => ffCallback(stim)(responseYes)
          ]
        when 'ok'
          stim = [popup.show.Ok prompt,
            callback: () => ffCallback(stim)(null)
          ]
        else
          throw 'Invalid dialog type.'

    help: -> @dialog ((m) ->
      fontSize = 24

      l1 = m.show.Text 'For help, email Alex at:',
        "text-anchor": 'middle'
        "font-size": fontSize
      l2 = m.show.Text 'schlegel@gmail.com',
        "text-anchor": 'middle'
        href: 'mailto:schlegel@gmail.com?subject=MWLearn Help!'
        target: 'blank'
        color: 'blue'
        t: l1.attr('t')+l1.attr('height')
        "font-size": fontSize
      l3 = m.show.Text '\nor call:\n424–242–4342',
        "text-anchor": 'middle'
        t: l2.attr('t')+l2.attr('height')
        "font-size": fontSize
      cs = m.show.CompoundStimulus [l1,l2,l3],
        y: 0)


    logoutConfirm: ->
      t = @base.session.remaining()
      prompt = if t>0
        "You still have #{time2str(t)} remaining in your session.\nLogout?"
      else
        'Logout?'

      @dialog prompt,
        type: 'yesno'
        callback: (responseYes) => if responseYes then @logout()

    logout: ->
      @root.queue.clear()
      @root.data.save
        callback: (=> window.location = '/logout/')

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
      _mouseup: null
      _mouseover: null
      _mouseout: null

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
          when "mousedown", "mouseup", "mouseover", "mouseout"
            if value?
              @["_#{name}"] = value
              @element[name](value)
            else
              ret = @["_#{name}"]
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
      mouseup: (f) -> @attr "mouseup", f
      mouseover: (f) -> @attr "mouseover", f
      mouseout: (f) -> @attr "mouseout", f

      show: (state=null) -> @attr "show", state

      exists: () -> @element?

    CompoundStimulus: (elements, options={}) -> new @MWClassShowCompoundStimulus(@root,elements,options)
    MWClassShowCompoundStimulus: class MWClassShowCompoundStimulus extends MWClassShowStimulus
      _defaultElement: 0

      _background: null
      _backgroundOffset: 0

      constructor: (root, elements, options) ->
        options.background = options.background ? null
        @_backgroundOffset = options.background_offset ? 1

        @element = copyarray (if elements instanceof MWClassShowCompoundStimulus then elements.element else elements)

        if options.background?
          if options.background==true then options.background = root.background
          @_background = root.show.Rectangle
            color: options.background

        super root, options, false

        if options.background?
          if @element.length>0 then @_background.element.insertBefore @element[0].element
          @updateBackground(['width','height','x', 'y', 'show','mousedown','mouseup','mouseover','mouseout'])

      attr: (name, value) ->
        switch name
          when "width", "height"
            xy = @type2xy(name)

            n = @element.length
            if n==0
              sCur = 0
              pMid = 0
            else
              sAll = (el.attr(name) for el in @element)
              pAll = (el.attr(xy) for el in @element)
              pLow = Math.min (pAll[i] - sAll[i]/2 for i in [0..n-1])...
              pHigh = Math.max (pAll[i] + sAll[i]/2 for i in [0..n-1])...
              pMid = (pLow+pHigh)/2
              sCur = pHigh - pLow

            if value?
              fSize = value/sCur
              if n>0
                @element[i].attr(name, fSize*sAll[i]) for i in [0..n-1]
                @element[i].attr(xy, fSize*(pAll[i]-pMid)+pMid) for i in [0..n-1]

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
                  throw 'wtf?'
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
                when 'show', 'mousedown', 'mouseup', 'mouseover', 'mouseout'
                  @updateBackground(name)
                else
                  null
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
        if @_background? then @_background.remove()
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
            switch p
              when 'width', 'height'
                @_background.attr(p,Math.max(0,@attr(p)-2*@_backgroundOffset))
              when 'box'
                @updateBackground(['width','height'])
              when 'l', 't'
                @_background.attr(p,@attr(p)+@_backgroundOffset)
              else
                @_background.attr(p,@attr(p))

    StimulusGrid: (elements, options={}) -> new MWClassShowStimulusGrid(@root,elements,options)
    MWClassShowStimulusGrid: class MWClassShowStimulusGrid extends MWClassShowCompoundStimulus
      padding: null

      _attr: null

      constructor: (root, elements, options) ->
        options.width = options.width ? root.width()
        options.height = options.height ? root.height()
        @padding = options.padding ? 8

        @_attr = {
          width: options.width
          height: options.height
        }

        super root, elements, options

      attr: (name, value) ->
        switch name
          when 'width', 'height'
            if value?
              @_attr[name] = value
              @updatePositions()
            else
              ret = @_attr[name]
          else
            super name, value

        if value? then @ else ret

      addElement: (el) -> super el; @updatePositions()
      removeElement: (el) -> super el; @updatePositions()

      updatePositions: (w=null, h=null) ->
        n = @element.length

        [rows,cols] = squareGrid(n)

        w = w ? @attr 'width'
        h = h ? @attr 'height'

        wMax = w - (cols-1)*@padding
        hMax = h - (rows-1)*@padding

        wPer = wMax/cols
        hPer = hMax/rows
        #sPer = Math.min(wPer, hPer)

        wFinal = wPer*cols + @padding*(cols-1)
        hFinal = hPer*rows + @padding*(rows-1)

        for r in [0..rows-1]
          for c in [0..cols-1]
            idx = cols*r + c

            if idx<n
              x = -(wFinal-wPer)/2 + c*(wPer+@padding)
              y = -(hFinal-hPer)/2 + r*(hPer+@padding)

              @element[idx].attr 'box', [wPer, hPer]
              @element[idx].attr 'x', x
              @element[idx].attr 'y', y

    Choice: (elements, options={}) -> new MWClassShowChoice(@root,elements,options)
    MWClassShowChoice: class MWClassShowChoice extends MWClassShowCompoundStimulus
      choiceMade: false
      choice: null
      callback: null
      callback_delay: null

      timeout: null
      _tStart: 0
      _tChoice: 0

      _choiceInclude: null
      _instruction: null
      _padx: null
      _pady: null
      _autoposition: false
      _autosize: false
      _choiceLocation: null

      constructor: (root, elements, options) ->
        ###
          elements: an array of Stimulus objects
          options:
            instruct: the instruction to give
            autoposition: true to autoposition the elements
            autosize: true to autosize the choices
            choice_location: location of the choices (for autoposition). either
                             'middle' or 'bottom'
            choice_include: an array of indices of Stimulus objects to include
                            as choices
            callback: a function that takes this object and the chosen index as
                      inputs
            callback_delay: the delay, in milliseconds, before calling the
                            callback
            timeout: number of milliseconds before the choice times out
            pad: the padding in between each choice as a percentage of the total
                 canvas size
            padx: pad specifically for horizontal padding
            pady: pad specifically for vertical padding
        ###
        super root, elements, options

        options.instruct = options.instruct ? "Choose one."
        @_autoposition = options.autoposition ? true
        @_autosize = options.autosize ? true
        @_choiceLocation = options.choice_location ? 'middle'
        options.pad = options.pad ? null
        @_padx = options.padx ? (options.pad ? 5)
        @_pady = options.pady ? (options.pad ? 10)

        @callback = options.callback ? null
        @callback_delay = options.callback_delay ? 0
        @timeout = options.timeout ? null

        options.choice_include = options.choice_include ? [0..@element.length-1]
        @_choiceInclude = (@element[idx] for idx in options.choice_include)

        for idx in [0..@_choiceInclude.length-1]
          fDown = ((i) => (e,x,y) => @choiceEvent(i))(idx)
          @_choiceInclude[idx].mousedown fDown

        #add the instructions
        if options.instruct!=false
          @_instruction = root.show.Instructions options.instruct
          @element.push @_instruction

        @autoPosition()

        @_tStart = @root.time.Now()

        if @timeout? then window.setTimeout (=> @choiceEvent(null)), @timeout

      autoPosition: ->
        hInstruct = if @_instruction? then @_instruction.attr "height" else 0

        #get the maximum final element dimensions
        nEl = @_choiceInclude.length

        wTotal = @root.width()
        hTotal = @root.height()
        padWPx = wTotal*@_padx/100
        padHPx = hTotal*@_pady/100

        wFinalMax = Math.max(10,(wTotal - (nEl+1)*padWPx)/nEl)
        hFinalMax = Math.max(10,2*(hTotal/2 - hInstruct - padHPx))

        #maximum current dimensions
        elW = (el.attr "width" for el in @_choiceInclude)
        elH = (el.attr "height" for el in @_choiceInclude)
        wMax = Math.max(elW...)
        hMax = Math.max(elH...)

        #scale the elements
        if @_autosize
          #target scale
          wScale = wFinalMax/wMax
          hScale = hFinalMax/hMax
          scale = Math.min(wScale,hScale)

          for el in @_choiceInclude
            el.attr "box", [scale*el.attr("width"), scale*el.attr("height")]

          elW = (el.attr "width" for el in @_choiceInclude)
          elH = (el.attr "height" for el in @_choiceInclude)
          wMax = Math.max(elW...)
          hMax = Math.max(elH...)


        #line up the choices
        if @_autoposition
          yChoice = switch @_choiceLocation
            when 'middle' then 0
            when 'bottom' then (hTotal-hMax)/2-padHPx
            else throw 'Invalid choice location'

          wTotal = sum(elW) + padWPx*(nEl-1) - elW[0]/2 - elW[-1..]/2
          xCur = -wTotal/2
          for el,idx in @_choiceInclude
            el.attr "x", xCur
            el.attr "y", yChoice
            xCur += elW[idx] + padWPx

        #position the instructions
        if @_instruction?
          yInstruct = switch @_choiceLocation
            when 'middle' then hMax/2+padHPx
            when 'bottom' then 0
            else throw 'Invalid choice location'

          @_instruction.attr "y", yInstruct

      choiceEvent: (idx) ->
        if not @choiceMade
          @_tChoice = @root.time.Now()
          @choiceMade = true
          @choice = idx
          if @callback? then window.setTimeout (=> @callback(@,idx)), @callback_delay

    Test: (elements, options={}) -> new MWClassShowTest(@root,elements,options)
    MWClassShowTest: class MWClassShowTest extends MWClassShowChoice
      correct: null

      constructor: (root,elements, options={}) ->
        ###
          elements: an array of Stimulus objects
          options:
            correct: the index of the correct choice / array of indices. if this
                     is unspecified, then each Stimulus object should have a
                     boolean property named "correct" the specifies whether the
                     Stimulus is a correct choice.
        ###
        @root = root

        options.correct = forceArray(options.correct ? null)

        super root, elements, options

        #record which choices are correct
        if options.correct?
          el.correct=false for el in @element
          @element[idx].correct=true for idx in options.correct

      choiceEvent: (idx) ->
        @correct = if idx? then @element[idx].correct else false
        super idx

    Dialog: (prompt,choices,options={}) -> new MWClassShowDialog(@root,prompt,choices,options)
    MWClassShowDialog: class MWClassShowDialog extends MWClassShowChoice
      _userCallback: null

      constructor: (root, prompt, choices, options) ->
        options.autosize = options.autosize ? false
        options['font-size'] = options['font-size'] ? 48

        choice = []
        for ch in choices
          choice.push root.show.Link 'javascript:void(0)', ch,
            'font-size': options['font-size']

        options.instruct = prompt
        options.choice_location = options.choice_location ? 'bottom'

        @_userCallback = options.callback
        options.callback = (choice,idx) =>
          choice.remove()
          if @_userCallback? then @runUserCallback(idx)

        super root, choice, options

      runUserCallback: (idx) -> @_userCallback(idx)

    YesNo: (prompt,options={}) -> new MWClassShowYesNo(@root,prompt,options)
    MWClassShowYesNo: class MWClassShowYesNo extends MWClassShowDialog
      constructor: (root,prompt,options) ->
        super root, prompt, ['YES','NO'], options

      runUserCallback: (idx) -> @_userCallback(idx==0)

    Ok: (prompt,options={}) -> new MWClassShowOk(@root,prompt,options)
    MWClassShowOk: class MWClassShowOk extends MWClassShowDialog
      constructor: (root,prompt,options) ->
        super root, prompt, ['OK'], options

      runUserCallback: (idx) -> @_userCallback()

    Rectangle: (options={}) -> new MWClassShowRectangle(@root,options)
    MWClassShowRectangle: class MWClassShowRectangle extends MWClassShowStimulus
      constructor: (root,options) ->
        @root = root

        options = @parseOptions options
        options.stroke = options.stroke ? "none"

        l = @x2l(options.x, options.width)
        t = @y2t(options.y, options.height)
        w = options.width
        h = options.height

        @element = root.paper.rect l, t, w, h
        options = remove options, ['width', 'height', 'x', 'y']

        super root, options, false

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
          when "l"
            ta = @attr "text-anchor"
            switch ta
              when "middle"
                if value?
                  super(name, value + @attr('width')/2)
                else
                  ret = super(name) - @attr('width')/2
              else
                ret = super name, value
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

    Instructions: (text, options={}) -> new MWClassShowInstructions(@root, text, options)
    MWClassShowInstructions: class MWClassShowInstructions extends MWClassShowText
      constructor: (root, text, options) ->
        @root = root

        options = @parseOptions options, {
          "font-family": "Arial"
          "text-anchor": 'middle'
          "font-size": 36
        }

        super root, text, options

    Link: (url, text, options={}) -> new MWClassShowLink(@root,url,text,options)
    MWClassShowLink: class MWClassShowLink extends MWClassShowText
      color: null
      colorHover: null

      constructor: (root, url, text, options) ->
        options.href = url
        @color = options.color = options.color ? 'blue'
        @colorHover = options.color_hover ? 'deepskyblue'
        options.mouseover = => @attr 'color', @colorHover
        options.mouseout = => @attr 'color', @color

        super root, text, options

    Timer: (tTotal, options={}) -> new MWClassShowTimer(@root, tTotal, options)
    MWClassShowTimer: class MWClassShowTimer extends MWClassShowText
      tTotal: 0
      tTimer: null
      tGo: null

      name: null

      showms: false
      prefix: null
      suffix: null

      _timeout: null
      _initialized: false
      _intervalID: null

      _setTimer: (t) ->
        @tTimer.set t
        @render()

      constructor: (root, tTotal, options) ->
        options.initialize = options.initialize ? true

        @tTotal = tTotal
        @name = options.name ? 'timer'
        @showms = options.showms ? false
        @prefix = options.prefix ? null
        @suffix = options.suffix ? 'remaining'
        @tUpdate = options.update_interval ? (if @showms then 10 else 250)

        @_timeout = options.timeout ? null

        super root, '', options

        if options.initialize then @initialize()


      initialize: ->
        if not @_initialized
          @tTimer = @base.data.Variable "#{@name}_remaining", @tTotal,
            timeout: @_timeout
            callback: (t) => @render()

          @_initialized = true

        @render()

      remaining: ->
        if @_initialized
          Math.max(0,if @tGo? then (@tTimer.get()-(@root.time.Now()-@tGo)) else @tTimer.get())
        else
          0

      nextReset: -> @tTimer.nextReset()

      string: ->
        strTime = time2str(@remaining(),@showms)

        prefix = if @prefix? then "#{@prefix}: " else ''
        suffix = if @suffix? then " #{@suffix}" else ''
        "#{prefix}#{strTime}#{suffix}"

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

    ItemList: (items={}, options={}) -> new MWClassShowItemList(@root, items, options)
    MWClassShowItemList: class MWClassShowItemList extends MWClassShowText
      _items: null

      constructor: (root, items, options) ->
        options['font-size'] = options['font-size'] ? 12

        super root, '', options

        @set items

      set: (items) ->
        @_items = items
        @render()

      add: (key, content) ->
        @_items[key] = content
        @render()

      remove: (key) ->
        delete @_items[key]
        @render()

      render: ->
        content = (val for key,val of @_items)
        t = @attr 't'
        @attr 'text', content.join("\n")
        @attr 't', t

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
          l: (root.width()-options.width)/2
          t: (root.height()-options.height)/2
          orientation: 0
        }

        @element = root.paper.path(@constructPath(null,false))

        options = remove options, ['width', 'height']
        super root, options, false

        if bAuto then @attr('width', 'auto')

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

    X: (options={}) -> new MWClassShowX(@root, options)
    MWClassShowX: class MWClassShowX extends MWClassShowPath
      constructor: (root, options) ->
        options.width = options.width ? 16
        options.height = options.height ? 16
        options['stroke-width'] = options['stroke-width'] ? 4

        path = [['M',0,0],['L',1,1],['M',0,1],['L',1,0]]
        super root, path, options

    Image: (src, options={}) -> new MWClassShowImage(@root, src, options)
    MWClassShowImage: class MWClassShowImage extends MWClassShowStimulus
      constructor: (root, src, options) ->
        @root = root
        @base = root.base

        bAutoSize = src of @base.im
        options = @parseOptions options, {
          width: if bAutoSize then @base.im[src].width else @_defaults.width
          height: if bAutoSize then @base.im[src].height else @_defaults.height
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
      _im: null

      constructor: (root, src, options) ->
        @root = root

        bAutoSize = src of root.im
        options = @parseOptions options, {
          width: if bAutoSize then root.im[src].width else @_defaults.width
          height: if bAutoSize then root.im[src].height else @_defaults.height
        }

        if options.color != "none" then options.background = options.color

        options = remove options, ['color']

        @_im = root.show.Image src

        super root, [@_im], options

      attr: (name, value) ->
        switch name
          when "color"
            if @_background? then ret = @_background.attr name, value
          else
            ret = super name, value

        if value? then @ else ret

    ConstructPart: (i, position, options={}) -> new MWClassShowConstructPart(@root,i,position,options)
    MWClassShowConstructPart: class MWClassShowConstructPart extends MWClassShowColorMask
      @_idx: null
      @_position: null

      constructor: (root, i, position, options) ->
        @root = root
        @base = root.base

        @_idx = i
        @_position = position
        src = @root.game.construct.srcPart @_idx, @_position

        super @root, src, options

      idx: -> @_idx

    ConstructFigure: (parts, options={}) -> new MWClassShowConstructFigure(@root,parts,options)
    MWClassShowConstructFigure: class MWClassShowConstructFigure extends MWClassShowCompoundStimulus
      @_rot: 0
      @_idx: null
      @_d: 0

      constructor: (root, parts, options) ->
        @root = root
        @base = root.base

        if Array.isArray(parts)
          @_idx = parts
          @_d = mean(@_idx)/@root.game.construct.nPart
        else if parts>=0 and parts<=1
          @_idx = @root.game.construct.pick(4,parts)
          @_d = parts
        else
          throw "Invalid parts"

        options = @parseOptions options, {
          # width: 2*root.im[@root.game.construct.srcPart(0)].width
          # height: 2*root.im[@root.game.construct.srcPart(0)].height
          width: 200
          height: 200
          color: 'black'
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

        elements = []
        for i in [0..3]
          opt = merge optionsPart, {
            x:xPart[i]
            y:yPart[i]
            color: "none"
          }
          src = @root.game.construct.srcPart @_idx[i], i
          elements.push (root.show.Image src, opt)

        if options.color != "none" then options.background = options.color
        options = remove options, ['x', 'y', 'width', 'height','color']

        super root, elements, options, false

      attr: (name, value) ->
        switch name
          when "color"
            if @_background? then ret = @_background.attr name, value
          else
            ret = super name, value

        if value? then @ else ret

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
        @root = root
        @base = root.base

        options.size = options.size ? 100
        options.thickness = options.thickness ? 10

        @part = part

        @_param = merge @root.game.assemblage.param(@part),
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
        @root = root
        @base = root.base

        parts = @root.game.assemblage.parts()

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
        @base = root.base

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

        @_path = @root.show.Path @root.game.rotate.path[@_idx], options

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

    TrialRecord: (options={}) -> new MWClassShowTrialRecord(@root,options)
    MWClassShowTrialRecord: class MWClassShowTrialRecord extends MWClassShowStimulusGrid
      colCorrect: null
      colWrong: null

      constructor: (root, options) ->
        @colCorrect = options.col_correct ? 'lime'
        @colWrong = options.col_wrong ? 'red'

        super root, [], options

      append: (trialType, correct, param) -> @addElement trialType, correct, param

      addElement: (trialType, correct, param) ->
        col = if correct then @colCorrect else @colWrong

        el = switch trialType
            when 'construct'
              @root.show.ConstructFigure param.parts,
                color: col
            when 'assemblage'
              x = @root.show.Assemblage
                color: col
              x.addSet param.set
              x.rotate param.rotation/90
              x
            when 'rotate'
              @root.show.RotateStimulus param.shape,
                color: col
                orientation: param.orientation
            else
              throw "#{trialType} is an invalid trial type."

        super el

  Input: -> new MWClassInput(@)
  MWClassInput: class MWClassInput extends MWClass
    _event_handlers: null

    constructor: (root) ->
      super root

      @_event_handlers = {
        key_down: []
        mouse_down: []
      }

      $("\##{@root.container}").keydown( (evt) => @_handleKey(evt,'down') )
      $("\##{@root.container}").mousedown( (evt) => @_handleMouse(evt,'down') )

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

    Pause: (ms) ->
      tStart = @Now()
      null while @Now()<tStart+ms

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

      _tStart: null
      _tStep: null

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
            description: a description of the sequence
            execute:  true to execute the sequence immediately
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
        @mode = options.mode ? "step"
        @callback = options.callback ? null
        @_fCleanup = options.cleanup ? null

        @_name = name
        @_description = options.description ? options.name
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
        nStep = @_fStep.length + 1
        for idx in [0..nStep-1]
          @root.queue.add @stepName(idx), (=> @processStep()), {do: false}

        @result = ({t:{}, output:{}} for [0..@_fStep.length-1])

      processStep: ->
        @_tStep = @root.time.Now()

        if @_idx>0
          @cleanupStep(@_idx-1)
        else
          @startSequence()

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

      startSequence: ->
        @_tStart = @_tStep ? @root.time.Now()

        @base.action.start @_name, @_description

        if @_fPre? then @pre = @_fPre(@)

      finishSequence: ->
        if @callback? then @callback(@)
        @finished = true

        @base.action.stop @_name

      Execute: ->
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
              s.show(true) #***
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

      @clear()

    length: -> @_queue.length

    add: (name, f, options={}) ->
      options.do = options.do ? true
      @_queue.push {name:name, f:f, ready:false}

      if options.do then @do name

    do: (name=null) ->
      if @_queue.length>0
        if not name? and @_queue[0].ready
          @do(@_queue[0].name)
        else if @_queue[0].name==name and @root.ready()
          @_queue[0].ready = true
          @_queue.shift().f() while @_queue.length>0 and @_queue[0].ready
        else
          for i in [0..@_queue.length-1]
            if @_queue[i].name==name
              @_queue[i].ready = true
              break

    clear: -> @_queue = []

  Data: -> new MWClassData(@)
  MWClassData: class MWClassData extends MWClass
    timeout: null

    _local: false

    _local_datastore: null
    _archive: null

    _numBusy: 0

    _failed: false
    _failSafeExecuted: false
    _failSafeCallback: null

    constructor: (root, options={}) ->
      super root

      @timeout = options.timeout ? 10000
      @_local = options.local ? not (@root.type=='experiment')

      @_local_datastore = {}
      @_archive = {}

      @load()

    load: ->
      @block('loading data')

      @read 'keys',
        store: false
        callback: (result) => @loadCallback(result)

    loadCallback: (result) ->
      keys = result.value ? null

      if keys?
        for key in keys
          @_numBusy++
          @read key,
            callback: (result) => @unblock()
      else
        @unblock()

    save: (options={}) ->
      options.callback = options.callback ? null
      options.previous_failure = options.previous_failure ? @_failed

      @block('saving data')

      for key of @_local_datastore
        @_numBusy++
        @write key, @_local_datastore[key],
          store: false
          callback: (result) => @saveCallback(result, options)

      for key of @_archive
        for time of @_archive[key]
          @_numBusy++
          @archive key,
            store: false
            time: time
            callback: (result) => @saveCallback(result, options)

    saveCallback: (result, options) ->
      if options.callback?
        @root.queue.add 'save_callback', => options.callback()

      if not result.success and options.previous_failure
        @failSafe
          callback: => @unblock()
      else

        @unblock()

    block: (description) ->
      @_numBusy = 0
      @root.action.start 'data_process', description
      @root.queue.add 'data_block', (-> null), {do:false}

    unblock: ->
      if @_numBusy>0 then @_numBusy--

      if @_numBusy==0
        @root.action.stop 'data_process'
        @root.queue.do 'data_block'

    ajax: (data, options) ->
      data.csrfmiddlewaretoken = @base.csrf

      $.ajax
        type: 'POST'
        url: '/data/'
        data: data
        success: (result) => @["#{data.action}Callback"](result, options)
        error: (jqXHR, status, err) => @failure()
        timeout: @timeout

    read: (key, options={}) ->
      options.force_remote = options.force_remote ? false
      options.store = options.store ? true
      options.callback = options.callback ? null

      if @_local or (not options.force_remote and key of @_local_datastore)
        result = {
          success: true
          action: 'read'
          key: key
          status: if (key of @_local_datastore) then 'read' else 'nonexistent'
          value: @_local_datastore[key]
        }
        window.setTimeout (=> @readCallback(result, options)), 0
      else
        data = {
          action: 'read'
          key: key
        }

        @ajax data, options

    readCallback: (result, options) ->
      if result.success
        if options.store and result.status=='read'
          @_local_datastore[result.key] = result.value
      else
        @failure()
      if options.callback? then options.callback(result)

    write: (key, value, options={}) ->
      options.store = options.store ? true
      options.callback = options.callback ? null

      #write locally
      if options.store
        newKey = not (key of @_local_datastore)
        @_local_datastore[key] = value
        if newKey then @write 'keys', Object.keys(@_local_datastore),
            store: false

      if @_local
        result = {
          success: true
          action: 'write'
          key: key
          status: 'write'
        }
        window.setTimeout (=> @writeCallback(result, options)), 0
      else
        data = {
          action: 'write'
          key: key
          value: JSON.stringify(value)
        }

        @ajax data, options

    writeCallback: (result, options) ->
      if not result.success then @failure()
      if options.callback? then options.callback(result)

    archive: (key, options={}) ->
      options.store = options.store ? true
      options.callback = options.callback ? null
      options.time = options.time ? @root.time.Now()

      #archive locally
      if options.store
        if not (key of @_archive) then @_archive[key] = {}
        @_archive[key][options.time] = @_local_datastore[key]

      if @_local
        result = {
          success: true
          action: 'archive'
          key: key
          status: 'archive'
          time: options.time
        }
        window.setTimeout (=> @archiveCallback(result, options)), 0
      else
        data = {
          action: 'archive'
          key: key
          time: options.time
          value: JSON.stringify(@_local_datastore[key])
        }

        @ajax data, options

    archiveCallback: (result, options) ->
      if not result.success then @failure()
      if options.callback? then options.callback(result)

    failure: -> @_failed = true

    failSafe: (options) ->
      if not @_failSafeExecuted
        @_failSafeCallback = options.callback ? null
        @_failSafeExecuted = true

        failSafeData = "#{JSON.stringify(@_local_datastore)}\n\n#{JSON.stringify(@_archive)}"

        $('#failsafe_data').val(failSafeData)

        mailSubject = encodeURIComponent("Session Data for #{@base.user}")
        mailBody = if failSafeData.length < 2000
          encodeURIComponent(failSafeData)
        else
          ''

        $('#failsafe_mailto').attr("href", "mailto:schlegel@gmail.com?subject=#{mailSubject}&body=#{mailBody}")
        $('#failsafe').show()
      else
        if options.callback then options.callback()

    failSafeHide: ->
      $('#failsafe').hide()
      if @_failSafeCallback? then @_failSafeCallback()

    Variable: (key, value, options={}) -> new MWClassDataVariable(@, key, value, options)
    MWClassDataVariable: class MWClassDataVariable
      track: false

      _data: null

      _key: null
      _value: null

      _initialized: false

      constructor: (data, key, value, options) ->
        ###
          data: the parent MWClassData object
          key: the variable name
          value: the variable value
          options:
            track: true to archive each change to the variable
            timeout: the number of milliseconds before the variable value resets
              to its initial value
            timeout_type: one of the following:
              'session': value will only reset in between sessions
              'instant': value will reset immediately after timeout
            callback: a function that takes the variable as an input and is
              called after the variable is initialized
        ###
        @_data = data

        @track = options.track ? false
        options.timeout = options.timeout ? null
        options.timeout_type = options.timeout_type ? 'session'
        options.callback = options.callback ? null

        @_key = key
        @_value = {value:value}

        if options.timeout?
          @_value.timeout = options.timeout
          @_value.timeout_type = options.timeout_type

        @update(options)

      update: (options={}) ->
        @_data.read @_key,
          callback: (result) => @dataCallback(result, options)

      initialize: ->
        if @_value.timeout? then @_value.initial = @_value.value
        @reset()

      reset: ->
        if @_value.timeout?
          @_value.reset_time = @_data.root.time.Now()
          @set @_value.initial
        else
          @set @_value.value

      dataCallback: (result, options={}) ->
        options.callback = options.callback ? null

        if result.success
          switch result.status
            when 'nonexistent'
              @initialize()
            when 'read'
              @_value = result.value
              @checkTimeout()
            when 'write'
              if @track and @get()? then @_data.archive @_key,
                callback: (result) => @dataCallback(result)
              @checkTimeout()
            when 'archive'
              null
            else
              null

          if not @_initialized then @_initialized = true

          if options.callback? then options.callback(@)

      checkTimeout: ->
        if @_value.timeout? and (@_value.timeout_type=='instant' or not @_initialized)
          if @_data.root.time.Now() >= @nextReset() then @reset()

      nextReset: -> if @_value.timeout? then @_value.reset_time + @_value.timeout else null

      get: -> @_value.value

      set: (value) ->
        @_value.value = value
        @_data.write @_key, @_value,
          callback: (result) => @dataCallback(result)
        @

  Game: -> new MWClassGame(@)
  MWClassGame: class MWClassGame extends MWClass
    gameNames: null

    constructor: (root) ->
      super root

      @gameNames = ['construct','assemblage','rotate']
      @[game] = @[capitalize(game)]() for game in @gameNames

    MWClassGameBase: class MWClassGameBase extends MWClass
      name: ''

      record: null
      popup: null

      current_trial: 0
      trial_result: null
      trials_finished: null

      nDistractor: 3

      tPrompt: 2000
      tOperate: 6000
      tTest: 3000
      tFeedback: 2000

      lastCorrect: null
      streakLength: 0

      skillInit: 0
      skillStep: 0.01
      skillMin: 0
      skillMax: 1
      skillName: 'skill'
      skill: null

      _doOperate: true

      constructor: (root, name) ->
        super root

        @name = name

        @record = objPath(@,'root','el','history','el','record')
        @popup = objPath(@,'base','el','popup')

        @trial_result = @root.data.Variable "#{@name}_trial_result", null,
          track: true

        @trials_finished = @root.data.Variable "#{@name}_trials_finished", 0

        @skill = @root.data.Variable "#{@name}_skill", @skillInit

      trialName: (options={}) ->
        trial = options.trial ? @current_trial
        "#{@name}trial#{trial}"

      trialDescription: (options={}) ->
        trial = options.trial ? @current_trial
        extra = options.extra ? false
        description = options.description ? "#{capitalize(@name)} trial #{trial+1}"
        param = options.param ? {}
        skill = param[@skillName] ? @skill.get()

        strExtra = if extra then " (#{@skillName}=#{skill})" else ''
        "#{description}#{strExtra}"

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
          "text-anchor": "middle"
        [target, text]
      feedbackStim: -> (s, idx) => @feedback s.pre.target, s.result[idx-1].correct, s.result[idx-1].choice
      feedbackNext: -> @tFeedback

      trial: (param=null, options={}) ->
        ###
          options:
            trial: the trial to run
            skill: the normalized skill level for the current trial (0->1)
            cleanupStim: the show sequence stimulus cleanup option
            countdown: true to countdown the session timer
            description: the trial description
            pre: a function to execute before starting the sequence
            callback: function to run at the end of the show sequence
        ###
        options.trial = options.trial ? @current_trial
        options.skill = options.skill ? null
        options.cleanupStim = options.cleanupStim ? 'sequence'
        options.countdown = options.countdown ? true

        param = @getTrialParam(param,options.skill)

        description = options.description ? null
        options.description = @trialDescription
          trial: options.trial
          description: description
          param: param
          extra: @base.debug

        #pre step to construct the trial target
        options.pre = options.pre ? (shw) => {
          param: param
          target: @create param
        }

        stim = []
        next = []

        #add the trial start prompt
        paramStart = if options.countdown then {f: => @root.session.startTimer()} else {}
        promptDescription = @trialDescription
          trial: options.trial
          description: description
          param: param
        prompt = "Click to begin #{promptDescription}."
        if options.trial==0 then prompt += "\n \nClick the tutorial on the left for a refresher."
        stim.push [['Instructions', prompt]]
        next.push ['mouse', paramStart]

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

        #callback
        f = options.callback ? null
        options.callback = (shw) =>
          @trialEnd(shw, options.countdown)
          if f? then f(shw)

        #do it now!
        trialName = @trialName
          trial: options.trial
        shw = @root.exec.Show "#{trialName}", stim, next, options

      color: (x) -> @root.color.pick()

      stepSkill: (correct) ->
        if correct==@lastCorrect
          @streakLength += 1
        else
          @lastCorrect = correct
          @streakLength = 1

        step = @streakLength*@skillStep*(if correct then 1 else -1)
        skillNew = Math.min(@skillMax,Math.max(@skillMin,@skill.get()+step))
        @skill.set skillNew

      getTrialParam: (param={},skill=null) ->
        param[@skillName] = param[@skillName] ? if skill?
          @skillMin + skill*(@skillMax-@skillMin)
        else
          @skill.get()
        param

      trialResult: (shw) -> merge shw.pre.param, shw.result[shw.result.length-2]

      trialEnd: (shw, countdown) ->
        result = @trialResult(shw)

        @trial_result.set result
        @stepSkill result.correct

        if @record? then @record.append @name, result.correct, shw.pre.param
        if countdown then @root.session.stopTimer()

        #increment the trial
        @current_trial += 1
        @trials_finished.set @trials_finished.get()+1

      tutorial: ->
        if @root.type!='popup'
          @base.el.popup.game[@name].tutorial()
        else
          @root.queue.add 'tutorial_start', ((that) => => that.tutorialStart())(@)
          @root.queue.add 'tutorial_intro', ((that) => => that.tutorialIntro())(@)
          @root.queue.add 'tutorial_step', ((that) => => that.tutorialStep())(@)

      tutorialStart: -> @root.visible true

      tutorialIntro: ->
        stim = []
        next = []

        idx = 1
        while @["tutorialIntro#{idx}"]?
          stimCur = ((fStimIntro) => (s,idx) =>
            stim = forceArray(fStimIntro())
            stim.push(@root.show.Text 'Click anywhere to continue.',
              l: 10
              t: 10
            )
            stim
          )(@["tutorialIntro#{idx}"]())

          stim.push stimCur
          next.push ['mouse']
          idx++

        #***
        shw = @root.exec.Show "#{@name}_tutorial_intro", stim, next,
          description: "#{capitalize(@name)} tutorial introduction"

      tutorialStep: (responseYes=true) ->
        if responseYes then @tutorialTrial() else @tutorialEnd()

      tutorialTrial: ->
        @trial null,
          trial: 'practice'
          callback: (shw) => @tutorialPrompt()
          description: "a practice #{capitalize(@name)} trial"

      tutorialPrompt: ->
        @root.show.YesNo 'Try another trial?',
          callback: (response) => @tutorialStep(response)

      tutorialEnd: -> @root.visible false

    Construct: -> new MWClassGameConstruct(@root)
    MWClassGameConstruct: class MWClassGameConstruct extends MWClassGameBase
      nPart: 100

      skillInit: 0.05
      skillStep: 0.01
      skillMin: 0
      skillMax: 1
      skillName: 'd'

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

      create: (param) ->
        target = @root.show.ConstructFigure param.d,
          color: @color()
          show: false

        param.parts = target._idx

        target
      createDistractor: (target) -> target.createDistractors(@nDistractor)

      prompt: (target) ->
        @root.show.ConstructPrompt(target,{show:false})

      tutorialIntro1: ->
        str = 'In these trials you will mentally\nconstruct four parts into a figure.'
        (s, idx) => @root.show.Instructions str
      tutorialIntro2: ->
        (s, idx) =>
          pad=10
          figure = @create @getTrialParam()
          parts = @prompt figure
          parts.attr 't', pad
          figure.attr 't', @root.height()-figure.attr('height')-pad
          text = @root.show.Instructions 'Construct the parts in this order.',
            color: 'gray'
          arrow = @root.show.Text "↓",
            t: (figure.attr('t')+parts.attr('t'))/2
            "font-size": 72
          stim = [parts, figure, text, arrow]
          for idx in [0..3]
            stim.push @root.show.Text idx+1,
              "font-size": 32
              x: parts.element[idx].attr('x')
              y: parts.element[idx].attr('y')
            stim.push @root.show.Text idx+1,
              "font-size": 32
              x: figure.element[idx].attr('x')
              y: figure.element[idx].attr('y')
          stim

    Assemblage: -> new MWClassGameAssemblage(@root)
    MWClassGameAssemblage: class MWClassGameAssemblage extends MWClassGameBase
      tPerPromptWord: 300
      tImagine: 500

      skillInit: 3
      skillStep: 1
      skillMin: 1
      skillMax: 100
      skillName: 'steps'

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

      getTrialParam: (param={},skill=null) ->
        param = super(param,skill)
        param.imax = param.imax ? null
        param

      create: (param) ->
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

        param.steps = target._history
        param.set = target.getSet()
        param.rotation = target._rotation

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
        #fPromptNext = (s,idx) -> ['choice', {timeout: fPromptTimeout(s)}]
        ['lazy', fPromptTimeout]

      tutorialIntro1: ->
        str = 'In these trials you will mentally\nconstruct assemblages from verbal descriptions.'
        (s, idx) => @root.show.Instructions str
      tutorialIntro2: ->
        (s, idx) =>
          pad=20
          assemblage = @create @getTrialParam()
          instruct = @prompt assemblage
          instruct.attr 'l', pad
          assemblage.attr 'l', @root.width()-assemblage.attr('width')-pad
          arrow = @root.show.Text "→",
            l: (instruct.attr('l')+instruct.attr('width')+assemblage.attr('l'))/2
            "font-size": 72
          [instruct, assemblage, arrow]

    Rotate: -> new MWClassGameRotate(@root)
    MWClassGameRotate: class MWClassGameRotate extends MWClassGameBase
      nDistractor: 1

      path: window._rotate_paths

      skillInit: 45
      skillStep: 1
      skillMin: 0
      skillMax: 89
      skillName: 'precision'

      tOperate: 4000

      constructor: (root) -> super root, 'rotate'

      getTrialParam: (param={},skill=null) ->
        param = super(param,skill)
        param.shape = randomInt(0,@path.length-1)
        param

      create: (param) ->
        target = @root.show.RotateStimulus param.shape,
            color: @color()
            precision: 90 - param.precision
            show: false

        param.orientation = target._path._param.orientation
        param.initialOrientation = target._initialOrientation

        target

      prompt: (target) ->
        initial = target.createPrompt()

        y = initial.attr "y"
        h = initial.rotatedHeight()
        yInstruct = y + h/2 + 36

        instruction = @root.show.Instructions target.operation(),
          y: yInstruct

        [initial, instruction]

      tutorialIntro1: ->
        str = 'In these trials you will\nmentally rotate shapes.'
        (s, idx) => @root.show.Instructions str
      tutorialIntro2: ->
        (s, idx) =>
          pad=20
          target = @create @getTrialParam()
          prompt = @prompt target

          prompt[0].attr 'l', pad
          prompt[1].attr 'x', prompt[0].attr('x')

          target.attr 'l', @root.width()-target.rotatedWidth()-pad
          arrow = @root.show.Text "→",
            l: (prompt[0].attr('l')+prompt[0].rotatedWidth()+target.attr('l'))/2
            "font-size": 72
          [prompt[0], prompt[1], target, arrow]

  Session: -> new MWClassSession(@)
  MWClassSession: class MWClassSession extends MWClass
    timer: null

    sessions_finished: null

    trialsPerBlock: 10

    _started: false

    _blockType: null
    _trialsLeftInBlock: 0

    constructor: (root) ->
      super root

      @timer = objPath(@,'root','el','status','el','timer')

      @sessions_finished = @root.data.Variable "sessions_finished", 0

    stopTimer: -> if @timer? then @timer.stop()

    startTimer: -> if @timer? then @timer.go()

    remaining: -> if @timer? then @timer.remaining() else null

    currentSession: -> @sessions_finished.get()+1

    nextSessionTime: -> if @timer? then @timer.nextReset() else null

    run: ->
      if not @_started
        if @remaining()==0
          @abort('toosoon')
        else
          @start()
      else if @remaining()>0
        @step()
      else
        @finish()

    step: ->
      if @_trialsLeftInBlock==0
        @_trialsLeftInBlock = @trialsPerBlock

        games = @root.game.gameNames
        trialsFinished = (@root.game[game].trials_finished.get() for game in games)
        minTF = Math.min(trialsFinished...)
        possibleBlocks = (game for game,idx in games when trialsFinished[idx]==minTF)

        @_blockType = pickFrom(possibleBlocks)

        @root.action.dialog "You will now begin a block of #{capitalize(@_blockType)} trials.",
          type: 'ok'
          callback: => @step()
      else
        @_trialsLeftInBlock--
        mwl.game[@_blockType].trial null,
          callback: (shw) => @run()

    start: ->
      @_started = true

      @base.action.dialog "Hi, #{capitalize(@base.user)}! Welcome to Session #{@currentSession()}!\n \nSee the menu on the left if you need help.\n \nThe timer in the upper left shows how much\ntime is remaining in the session.",
        type: 'ok'
        callback: => @run()

    finish: ->
      @sessions_finished.set @sessions_finished.get()+1

      @base.action.dialog "Session #{@currentSession()-1} finished!\nYou will now be logged out.",
          type: 'ok'
          callback: => @base.action.logout()

    abort: (reason) ->
      prompt = switch reason
        when 'toosoon'
          t = new Date(@nextSessionTime())
          "Please wait until\n#{t.toLocaleDateString()} at #{t.toLocaleTimeString()}\nto start session #{@currentSession()}."
        else
          throw ('Invalid abort reason')

      @base.action.dialog "#{prompt}\nYou will now be logged out.",
          type: 'ok'
          callback: => @base.action.logout()
