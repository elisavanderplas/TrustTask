### Trust task ###

This repository contains code for running the ‘Trust Task’ online. This experiment consists of a ‘main.js’ script which calls and writes three sub-tasks: (1) calibration phase, (2) the Confidence Task and (3) the Advice-Taking task. 

(1) Calibration phase (metaTask_prac.js) is a psychophysical experiment during which participants decide which of two boxes (draw_blankstimulus.js) contains a higher density of dots (draw_stimulus.js): the box on the left or the box on the right. The difference in number of dots between the left and right box (i.e. choice difficulty) is adjusted during the practice task (metaTask._prac.js) with a 2-up-1-down calibration (staircase2edit.js), which converges towards an approximate performance level of 71% for each participant. 

(2) Confidence Task (metaTask.m) is an adapted metacognition task from Marion Rouault (https://github.com/metacoglab/metacognition-task-online). Participants see their calibrated dot difference from the calibration phase, based on which they make a binary decision and are then asked to rate their confidence in their decision. This task is preceded by a practice phase (metaTask_prac.js). 

(3) Advice Taking task (changeOfMind.m); participants are shown their own replayed accuracy and confidence level as if they were derived from two other participants and can use this as ‘advice’ to revise their initial choice and confidence rating. Importantly, the trial-by-trial association between confidence and accuracy is manipulated for one of the two advisers (advdeviset.js). This task is preceded by a practice phase (changeOfMind_prac.js). 

### Dependencies ###

All sub-tasks make use of the jsPsych package version 4.3: 

De Leeuw, J. R. (2015). jsPsych: A JavaScript library for creating behavioural experiments in a web browser. Behavior research methods, 47(1), 1-12.

The experiment is presented to participants via the Gorilla experiment builder (www.gorilla.sc): 

Anwyl-Irvine, A.L., Massonié J., Flitton, A., Kirkham, N.Z., Evershed, J.K. (2019).
Gorilla in our midst: an online behavioural experiment builder.
Behavior Research Methods.
Doi: https://doi.org/10.3758/s13428-019-01237-x

Click on the following link in a Chrome or Mozilla Firefox browser to see the complete Trust Task as embedded in Gorilla: https://research.sc/participant/login/dynamic/52C75E27-E04D-466F-B86B-A8E2F2E74251

### Disclaimer ###

This code is being released with a permissive open-source license. You should feel free to use or adapt the utility code as long as you follow the terms of the license, which are enumerated below. 

Copyright (c) 2020, Elisa van der Plas
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.