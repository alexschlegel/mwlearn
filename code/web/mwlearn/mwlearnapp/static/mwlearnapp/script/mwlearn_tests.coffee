window.mwl = new MWLearn
  practice_minutes: 1

fTestNaturalDirection = ->
  fTest = (a) -> "#{a}: #{naturalDirection(a)}"
  alert fTest(a) for a in [0,90,180,270,-90,45,-45,360]

fTestStimulus = ->
  el = mwl.show.Rectangle()
  el.attr "x", -100

fTestCompoundStimulus = ->
  x = mwl.show.Rectangle
    x: -100
  y = mwl.show.Circle
    x: 100

  z = mwl.show.CompoundStimulus [x,y],
    background: "red"
    element_mousedown: (el,x,y) -> alert getClass(el)

  z.attr "y", 100
  z.attr "height", 300

  alert '1'
  z.show(false)
  alert '2'
  z.show(true)

fTestConstruct = ->
  R = 20; C = 30
  W = 600
  for i in [0..R-1]
    for j in [0..C-1]
      d = 1*( (i*C + j)/(R*C-1) )
      x = mwl.show.ConstructFigure d,
        width: W/R
        height: W/R
        x: -W/2*(C/R) + j*W/(R-1)
        y: -W/2 + i*W/(R-1)
        #rot: 45
        color: mwl.game.construct.difficultyColor(d,0,1)
        #mousedown: (e,x,y,z) -> alert "#{x}, #{y}, #{z}"

fTestConstructPrompt = ->
  figure = mwl.show.ConstructFigure 0.2,
    color: 'red'
    width: 200
    height: 200
    t: 0

  prompt = mwl.show.ConstructPrompt figure

fTestAssemblage = ->
  a = mwl.show.Assemblage
    color: mwl.color.pick()
  x = a.addPart "square"
  y = a.addPart "triangle", x, 1, 2
  a.rotate 2

fTestShowRotate = ->
  x = []
  x.push mwl.paper.path "m209.22 266.46c55.502-5.477 87.385-85.259 51.793-121.34 22.375 41.625 5.438 100.83-38.474 109.5-1.022-2.923-3.947-3.946-7.4-4.44 9.019-10.715 26.66-12.804 34.036-25.157 26.808-47.027-8.602-104.45-63.631-85.827 21.526 0.989 44.034 1.137 57.712 16.277 18.684 20.685 11.906 64.544-19.238 69.55 6.952-10.895 21.057-28.459 11.842-45.873-10.403 15.743-24.035 28.256-42.914 35.514-8.445 15.729-17.856 30.489-42.917 29.598 23.163-16.531 11.351-63.241-5.918-81.388 21.278 5.49 54.63 15.904 50.312 47.353 14.759-25.13-21.125-34.034-31.076-48.833 6.235-3.138 14.563-4.183 20.718-7.4-11.291-6.114-21.626 8.638-29.595 5.919 5.103-11.668 19.047-14.492 29.595-20.717-14.6-1.271-26.769 12.683-36.995 20.717-4.484-3.119-6.6-0.941-11.839-4.439 11.025-23.122 43.302-38.342 79.908-34.035 20.766 2.443 34.918 15.242 45.874 22.197-9.026-21.661-61.965-35.96-91.746-19.237 3.143-6.163 16.193-11.934 23.679-13.319 70.341-13.009 127.15 52.403 85.827 115.43-13.84 21.11-40.05 36.67-69.54 39.95zm19.24-94.71c-7.853-12.228-28.632-23.575-42.915-16.278 18.94 0.8 31.72 7.75 42.92 16.28z"
  x.push mwl.paper.path "m123.39 321.21c1.154 3.282 7.157-4.883 10.357 0-2.117 4.297-8.617 4.206-10.357 8.879 3.325 3.58 11.907 1.903 13.318 7.399-20.301 0.56-37.697-5.705-54.753-4.439 4.695-4.219 13.376-8.861 20.719-5.92-1.113-7.273-17.899 1.126-17.759-7.4 31.926 1.84 39.442-20.733 48.833-41.432-10.967-18.673-35.973-31.053-42.914-48.833 19.776 13.357 69.258 15.92 62.151 47.352-1.656 7.334-12.773 12.365-17.758 20.719-5.19 8.68-4.95 17.19-11.84 23.67z"
  x.push mwl.paper.path "m71.6 19.331c7.545 10.479 22.856 25.286 25.155 45.874-2.691 16.295-19.691 23.568-19.236 38.475 0.631 20.665 30.334 29.657 45.874 41.434 19.09 18.662 40.326 48.39 35.516 81.39-3.372 7.479-8.856 12.846-14.799 17.756-8.17 0.771-13.95-0.849-20.717-1.481-37.664-23.345-71.886-42.227-108.03-68.068-5.659-35.07 19.823-58.61 51.8-41.43-5.66-13.444-59.563-12.094-51.793 22.196-34.866-23.792-2.715-64.691 20.718-82.868 15.422-11.971 40.807-22.103 26.637-48.842 3.344 10.982 0.393 33.998-13.32 36.995 2.399-7.852 9.037-16.322 1.48-22.198-6.504 9.772-11.183 21.372-23.676 25.157-6.572-6.448 0.301-16.912-2.961-22.197-9.015-3.474-14.473 0.219-23.676 1.48-1.723-6.594 7.27-14.119 14.797-16.277-12.251-26.099 28.868-30.932 47.356-23.678-5.663 5.84-11.47 17.226-20.718 14.799 3.739 4.894-4.688 13.283 4.439 13.317-7.77-5.601 6.605-10.423 5.919-16.277 9.333-2.383 13.774 7.869 19.238 4.44zm-42.914 11.837c-0.029-7.4 4.767-5.569 10.358-4.439-0.944-11.915-20.232-2.262-10.358 4.439zm68.069 121.34c-3.178-9.663-10.763-22.756-20.716-20.717 9.75 4.07 13.856 13.77 20.716 20.72zm25.155 5.92c-1.125-4.363-6.898-11.758-10.358-8.879 4.37 2.05 5.99 6.84 10.36 8.88zm-38.472 28.12c7.962 10.883 27.729 17.515 38.475 20.716-7.52-9.65-30.536-22.78-38.472-20.72zm4.439 20.71c11.678 4.892 27.188 20.752 36.995 17.756-7.63-13.087-24.175-17.26-38.475-23.675-0.109 2.58 0.334 4.6 1.482 5.92z"

  el.attr("fill", 'red') for el in x

fTestScaling = ->
  x = mwl.show.Square
  a = mwl.game.assemblage.create 10, 4
  a.show(true)
  a.scale(0.1)
  x.attr "height", a.attr("height")

fTestRemove = ->
  x = mwl.show.Circle()
  alert '1'
  x.remove()
  alert '2'
  x = mwl.show.Circle {x:-100}
  y = mwl.show.Square {x:100}
  z = mwl.show.CompoundStimulus [x,y]
  alert '3'
  z.remove()
  alert '4;'

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
    -> document.title = 'press the "a" key!'
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
  exec = mwl.exec.Sequence 'test_sequence', f, n, {
    cleanup: cleanup
    callback: -> document.title = 'done!'
  }
  mwl.queue.add "blah", -> alert 'hi'

fTestChoice = ->
  x = mwl.show.Circle
    x: -150
  y = mwl.show.Square
    color: 'red'
    x: 0
  z = mwl.show.Circle
    x: 150
  c = mwl.show.Choice [x, y, z],
    callback: (ch, idx) -> document.title = "choice: #{idx}"
    choice_include: [0,2]
    timeout: 3000

fTestShowTest = ->
  x = mwl.show.Circle
    x: -150
  y = mwl.show.Square
    color: 'red'
    x: 0
  z = mwl.show.Circle
    x: 150
  c = mwl.show.Test [x, y, z],
    callback: (tst, idx) -> alert(idx)
    choice_include: [0,2]

fTestShowSequence = ->
  stim = [
    [
      ['Text', 'Click the red circle!']
      ['Circle', {color: 'red', y: -100}]
    ]
    (s, idx) -> ['Text', "This is step #{idx}"]
    [
      ['Text', 'green circle!']
      ['Circle', {color: 'green', y: -100}]
    ]
    [
      ['Text', 'multiple circles!']
      ['Circle', {color: 'blue', x:-100, y:-100}]
      ['Circle', {color: 'red', x:100, y:-100}]
    ]
    [
      ['Circle', {color: 'blue', r: 100, y: -100}]
      ['Text', 'is this text properly centering itself, and what is the nature of the universe?']
    ]
    [
      ['Circle', {color: 'red'}]
      ['Circle', {color: 'green'}]
      ['Circle', {color: 'blue'}]
    ]
    [
      ['Text', 'finished']
    ]
  ]
  next = [
    ['mouse', {button: 'left'}]
    1000
    1000
    ['choice', {callback: (el, idx) -> document.title = el}]
    1000
    ['test', {callback: (el, idx) -> document.title = el}]
    1000
  ]

  shw = mwl.exec.Show 'test_show_sequence', stim, next, {
    callback: -> document.title = 'done!'
  }

fTestConstructTrial = ->
  mwl.game.construct.trial({d:df}) for df in [0..1] by 0.1

fTestAssemblageTrial = ->
  ###for i in [0..100]
    document.title = i
    a = mwl.game.assemblage.create 5, 4
    instruct = mwl.game.assemblage.instruct a
    t = mwl.game.assemblage.test a, 4###

  mwl.game.assemblage.trial({steps:n}) for n in [1..100]

#mwl.queue.add "testnaturaldirection", fTestNaturalDirection
#mwl.queue.add "teststimulus", fTestStimulus
#mwl.queue.add "testcompoundstimulus", fTestCompoundStimulus
#mwl.queue.add "testconstruct", fTestConstruct
#mwl.queue.add "testconstructprompt", fTestConstructPrompt
#mwl.queue.add "testassemblage", fTestAssemblage
#****mwl.queue.add "testshowrotate", fTestShowRotate
#***mwl.queue.add "testscaling", fTestScaling
#mwl.queue.add "testremove", fTestRemove
#mwl.queue.add "testinput", fTestInput
#mwl.queue.add "testexec", fTestExecuteSequence
#mwl.queue.add "testchoice", fTestChoice
#mwl.queue.add "testshowtest", fTestShowTest
#mwl.queue.add "testshowsequence", fTestShowSequence
mwl.queue.add "testconstructtrial", fTestConstructTrial
#mwl.queue.add "testassemblagetrial", fTestAssemblageTrial