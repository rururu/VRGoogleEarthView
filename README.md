# Virtual Regatta Google Earth View

Realistic 3D look for the [Virtual Regatta](https://www.virtualregatta.com/en/offshore-game/).
Especially fine for shore views.

This progect uses [A Tool for Building Expert Systems CLIPS](https://www.clipsrules.net/), 
[Google Earth program](https://www.google.com/earth/about/versions/#earth-pro) and
Chrome browser with
[VR Dashboard plugin](https://chrome.google.com/webstore/search/VR%20Dashboard)

[![Watch the video](1.png)](https://www.youtube.com/watch?v=qwWi1miGMjE)
Click the screenshot to see a video!

## Prerequisites

You need to be installed on your machine:

1 Chrome browser.

2. [VR Dashboard](https://chromewebstore.google.com/search/VR%20Dashboard%20I.T.Y.C.)

3. Python3. For Windows please check the Microsoft App store or download the installer [here](https://www.python.org/downloads/windows/)
        The location of python.exe will be determined using PATH variable.
    For others platforms please follow the instructions for your OS or download the tarball [here](https://www.python.org/downloads/)


## Installation and usage

Download VRGoogleEarthView project from the Github using an OS command "git clone https://github.com/rururu/VRGoogleEarthView.git " or aa button "Code" on this page and unzip somewhere. Then:

1. Open "Virual Regatta" page in a browser.
2. Activate "VR Dashboard" plugin.
3. Enter into the race.
4. Allow a file run.sh (run.bat for Windows) to be executable (if needed).
5. Start VRGoogleEarthView program:

```shell
$ cd <..>/VRGoogleEarthView
$ ./run.sh       # Linux, MacOS
$ run.bat        # Windows (replace python.exe in this file in accordance with your python installation)
```
6. Start Google Earth program.
7. Open Google Earth View -> Sidebar (if needed).
8. Open cd <..>/VRGoogleEarthView/LinkToCamera.kml file.
9. Open cd <..>/VRGoogleEarthView/LinkToFleet.kml file and wait..

#### Note:

1. You may need to install some Python libraries during the first run! To do this:

```shell
$ pip install pyais
...
$ pip install pynmea2
...
$ pip install streamlit
...
```
2. Simplest way to install python is by installing Python IDE [Thonny](https://thonny.org/) and using use run_with_thonny.bat as template for run.bat.
## Video Lesson

[VR Shore View](https://www.youtube.com/watch?v=qwWi1miGMjE)

_More detailed version: [https://github.com/rururu/sail-pro](https://github.com/rururu/sail-pro)_

Copyright © 2024 Ruslan Sorokin

