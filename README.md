# TotallyLegit

###What?
An automated survey taker for assisting with SV2 testing

###Why?
Because manually taking long surveys prior to testing really sucks.

###How?
Scripts instruct automation framework to send mouse and keyboard events to survey UI.

###Internal Script Name:
SV2 Flex Survey Filler

###Author:
Daniel Lu (@dandydanny)

###Dependencies (or, suggested friends and environment):
* AutoIt 3
* Microsoft Windows 7 (32-bit), 1280x960 resolution, Windows Classic Theme
* Oracle VirtualBox
* Mozilla Firefox
* Tesseract 3 OCR library
* Modified Tesseract integration / include file

###Version History:
* 0.9 - Added ability to fill flights with covey & covey follow-on questions
* 0.8 - Added captcha OCR, added tagging for trackerId
* 0.7 - Added captcha to coordinate drag logic
* 0.6 - Added respondent data bank and coordinate look-up logic
* 0.5 - Added variable for governing transition wait time and mouse speed
* 0.4 - Added systray balloon tips to show script execution state
* 0.3 - Added image capture
* 0.2 - Replaced some hard-wired timers with color comparison for detecting slide change
* 0.1 - Born in a remote, dark test lab

###Setup Instructions:
Install VirtualBox
Grab a copy of Windows 7 IE 10 VM from [Modern.ie Tools page](http://dev.modern.ie/tools/vms/), decompress and import VM
Launch VM, install Mozilla Firefox
Install AutoIt 3
Install [Tesseract 3 OCR Engine](https://github.com/tesseract-ocr) binary for Windows
Copy Tesseract.au3 to C:\Program Files\AutoIt3\Beta\Include

###How to Run:
* Need to write this one out

###To Do:
* Fix issue where single digit captcha results in OCR output of 1
* Implement OCR result sanity check before survey submit
* Support for multi-covey flights
* Support for flights with multiple ads
* Server-client setup for firing off multiple nodes for simultaneous survey filling
* Logic for detecting premature survey rejections
* Logic for detecting idle warning dialog box
* Logic for determining location of inputs
* Basic shape recognition