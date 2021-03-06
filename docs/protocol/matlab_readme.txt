MWLearn pre-/posttest execution instructions:

1. Make sure to start by running "PrepMWL"

2. (Almost) all experiment parameters can be controlled by modifying the four subfunctions of MWL.Param. In particular, "numTrial" and "numPractice" (or, for the span tasks in the working memory battery, "trialsPerCond"), as well as the "time" structs (which control the timing of each stage of the task), are likely to be useful. Also, WMP.run (line ~180) controls which working memory battery tests are run.

3. To start the experiment, create an mwlt object:
	"mwlt = MWLearnTest"
The default debug level is 0 (experimental trial). This can be modified to 1 or 2 by specifying the optional argument "debug", e.g. "mwlt = MWLearnTest('debug', 2)"

4. Specify subject initials, birth date and other information. The last prompt, "Select session", refers to whether this is a pre- or a posttest. The default option should usually be correct. If it suggests "post" and this is the subject's first testing, the subject's initials could be conflicting with another subject's. 

5. To run each task once MWLearnTest returns, use the helper functions "RunCI", "RunAngle", "RunWM", and "RunAssemblage". These are methods of the mwlt object, so call them as "mwlt.RunCI", etc.

Note: each of these helper functions has an option called "lock", which defaults to true. This determines whether the program should wait at the end of the test for an unlock code to be entered on the input device before it returns control to the matlab prompt (meanwhile, the subject is instructed to alert the experimenter). This is useful in order to run several tasks in succession. For instance, in order to run the CI task and then the angle task, one would type:

				"mwlt.RunCI;mwlt.RunAngle;"

at the prompt. When CI finishes, the subject would alert the experimenter, he/she comes in the room and enters the code on the gamepad, and the angle instructions appear. The experimenter can then explain the next task.

To disable this behavior, set "lock" to false ("mwlt.RunCI('lock',false)"). Then each task should be started individually from the command line when the previous one is finished.

The gamepad unlock code is: left upper trigger + back + y.
The keyboard unlock code (in debug mode) is left + right.

5. When all tests are finished, type "mwlt.End" to end the experiment. All data is stored in the session .mat file in the mwlearn/data folder (ddMMMyyii.mat, where ii = subject initials), at PTBIFO.mwlt.

Modified 03-11-2014 by Ethan Blackwood
