;Script Name:		SV2 Flex Survey Filler
;Author: 			Daniel Lu
;Dependencies:		AutoIt 3
;					Windows 7, 1280x960 resolution, Windows Classic Theme
;					Mozilla Firefox
;Version History:	0.8 - 	Added captcha OCR, added tagging for trackerId
;					0.7 - 	Added captcha to coordinate drag logic
;					0.6 - 	Added respondent data bank and coordinate look-up logic
;					0.5 - 	Added variable for governing transition wait time and mouse speed
;					0.4 - 	Added systray balloon tips to show script execution state
;					0.3 - 	Added image capture
;					0.2 - 	Replaced some hard-wired timers with color
;							comparison for detecting slide change
;					0.1 - 	Initial release

#include <ScreenCapture.au3>
#include <Date.au3>
#include <Array.au3>
#include <Tesseract.au3>

;Globals hellz yeah
Global $snapDir = "snaps\"
Global $browserPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
Global $surveyUrl
Global $trackerId
Global $respondentNumber
Global $pixelColor
Global $pixelColor1
Global $pixelColor2
Global $keyStrokeDelay = 100
Global $sliderBlue = 4880534
Global $bgGrey = 8882055
Global $containerWhite = 16185078
Global $pureWhite = 16777215
Global $buttonYellow = 15585335
Global $sliderStart = 640
Global $sliderEnd = 850
Global $mouseSpeed = 2
Global $smallDelay = 100
Global $transitionDelay = 500

;Press ESC to terminate script
HotKeySet("{ESC}", "EscTerminate")

;Respondent data (2D array)
Local $respondentBank[8][6] = [[], _
		[1, "M", 1965, "HighIncome", "Caucasian", "NoChildren"], _
		[2, "F", 1966, "HighIncome", "Asian", "HasChildren"], _
		[3, "M", 1975, "MidIncome", "AfricanAmerican", "NoChildren"], _
		[4, "F", 1980, "MidIncome", "Hispanic", "HasChildren"], _
		[5, "M", 1983, "LowIncome", "Asian", "NoChildren"], _
		[6, "F", 1990, "LowIncome", "Other", "HasChildren"], _
		[7, "M", 1994, "LowIncome", "AfricanAmerican", "NoChildren"]]

;Get how many times necessary to take survey using all respondents
Local $maxRespondents = (UBound($respondentBank) - 1)

;Get survey URL and respondent number
$surveyUrl = InputBox("SV2 Flex Survey Helper", "Please enter survey URL (without trackerID):", _
		"http://sv2a-qacore.foodomain.com/service03/survey-app.html?t=wiqDPKO&p=pnt&trackerId=")

;Get token
;$token = StringRegExp($surveyUrl, "(?i)=([:alnum:]{7})")

;MsgBox(0,"Test", $token)

$respondentNumber = Number(InputBox("SV2 Flex Survey Helper", "...and which respondent demographic data to use? (0: all, 1-7: single)", "0"))

;0: all respondents
;1-7: single respondent
If $respondentNumber = 0 Then
	$loopStart = 1
	$loopEnd = 7
ElseIf $respondentNumber > 0 Then
	$loopStart = $respondentNumber
	$loopEnd = $respondentNumber
EndIf

;Main Loop Start -------------------------------------------------------------
For $currentRespondentNumber = $loopStart To $loopEnd
	;Select and return array for specified respondent
	$respondent = Call("RespondentSelect", $currentRespondentNumber, $respondentBank)

	TrayTip("Survey Helper", $respondent[0] & "," & $respondent[1] & "," & $respondent[2] & "," & $respondent[3] & "," & $respondent[4] & "," & $respondent[5], 10, 1)

	;Respondent vars --------------------------------------------------------
	Local $testTagging = ""
	Local $brandRecResponse = "Acura_follow"
	Local $trackerId = "100" & $currentRespondentNumber & $testTagging
	Local $intender = False
	Local $coveySingle = False
	Local $coveyMulti = False
	Local $coveyFollowOn = False
	Local $surveyUrlWithNumber = $surveyUrl & $trackerId
	Local $zipTag = 90000 + $trackerId
	Local $verbatimString = _ArrayToString($respondent, "") & $testTagging
	Local $brandRecString = $brandRecResponse & " " & $verbatimString & $trackerId

	;Init respondent coordinate and keystroke variables
	Local $genderX = 0
	Local $genderY = 0
	Local $birthYearX = 351
	Local $birthYearY = 364
	Local $birthYearDownStrokes = 0
	Local $incomeX = 0
	Local $incomeY = 0
	Local $ethnicityX = 351
	Local $ethnicityY = 550
	Local $ethnicityDownStrokes = 0
	Local $childrenX = 351
	Local $childrenY = 618
	Local $childrenDownStrokes = 0

	;Set respondent coordinate and keystroke variables
	$ethnicityDownStrokes = Call("EthnicityToKeystroke", $respondent[4])
	$childrenDownStrokes = Call("ChildrenToKeystroke", $respondent[5])

	Call("GenderToCoordinates", $respondent[1], $genderX, $genderY)
	Call("IncomeToCoordinates", $respondent[3], $incomeX, $incomeY)

	;Launch browser and start survey
	ShellExecute($browserPath, $surveyUrlWithNumber)

	;continue only if demo question page is shown
	;checking for grey background and off-white container
	While 1
		;MouseMove(300,710,10)
		$pixelColor1 = PixelGetColor(300, 710)
		Sleep(200)
		;MouseMove(430,710,10)
		$pixelColor2 = PixelGetColor(430, 710)
		If ($pixelColor1 = $bgGrey) And ($pixelColor2 = $containerWhite) Then
			ExitLoop
		EndIf
	WEnd

	Sleep($transitionDelay) ;allow for tranisition to complete

	;Demographic Questions Page

	;Display Sys  Balloon Tip
	TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "a1 - Demographic questions", 10, 1)

	;Gender
	MouseMove($genderX, $genderY, $mouseSpeed)
	Sleep($smallDelay)
	MouseClick("left", $genderX, $genderY, 2)
	MouseMove($birthYearX, $birthYearY, $mouseSpeed) ;move mouse into next position
	Sleep($smallDelay)

	;Birth year
	;MsgBox(0,"DEBUG: respondent[2]", $respondent[2])
	MouseClick("left", $birthYearX, $birthYearY, 1)

	$birthYearDownStrokes = Call("YearToKeystroke", $respondent[2])

	For $i = 1 To $birthYearDownStrokes
		Send("{DOWN}")
		Sleep($keyStrokeDelay)
	Next
	Send("{ENTER 1}")

	MouseMove($incomeX, $incomeY, $mouseSpeed) ;move mouse into next position
	Sleep($smallDelay)

	;Income level
	MouseClick("left", $incomeX, $incomeY)
	MouseMove($ethnicityX, $ethnicityY, $mouseSpeed) ;move mouse into next position
	Sleep($smallDelay)

	;Ethnicity
	MouseClick("left", $ethnicityX, $ethnicityY, 1)

	For $i = 1 To $ethnicityDownStrokes
		Send("{DOWN}")
		Sleep($keyStrokeDelay)
	Next
	Send("{ENTER 1}")

	MouseMove($childrenX, $childrenY, $mouseSpeed) ;move mouse into next position
	Sleep($smallDelay)

	;Children
	MouseClick("left", $childrenX, $childrenY, 1)
	For $i = 1 To $childrenDownStrokes
		Send("{DOWN}")
		Sleep($keyStrokeDelay)
	Next
	Send("{ENTER 1}")
	MouseMove(351, 684, $mouseSpeed) ;move mouse into next position
	Sleep($smallDelay)

	;Zip Code
	MouseClick("left", 351, 684, 1)
	Sleep($keyStrokeDelay)
	Send($zipTag)
	Sleep($smallDelay)

	MouseMove(894, 715, $mouseSpeed)

	;Demographic response screenshot
	_ScreenCapture_Capture($snapDir & $trackerId & "-a1.png")

	;Go on button
	MouseClick("left", 894, 715, 1)
	Sleep($transitionDelay)

	;Instructions Page---------------------------------

	;Display Systray Balloon Tip
	TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "a2 - Survey instructions", 10, 1)

	;Check if instruction page is ready by checking slider color = light blue
	MouseMove(610, 220, $mouseSpeed)

	While 1
		$pixelColor = PixelGetColor(610, 220)
		If $pixelColor = $sliderBlue Then
			ExitLoop
		EndIf
	WEnd

	;Instructions screenshot
	_ScreenCapture_Capture($snapDir & $trackerId & "-a2.png")

	;Next button
	MouseMove(894, 647, $mouseSpeed)
	Sleep($smallDelay)
	MouseClick("left", 894, 647, 1)
	MouseMove(680, 380, $mouseSpeed) ;move mouse to next position
	Sleep($transitionDelay)

	;Video Page-----------------------------------------

	;Wait for yellow play button to become visible
	$proced = False
	While 1
		$pixelColor = PixelGetColor(680, 380)
		If $pixelColor = $buttonYellow Then
			ExitLoop
		EndIf
	WEnd

	;Display Systray Balloon Tip
	TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "a3 - Video page", 15, 1)

	;Play button
	Sleep(1000) ;wait for video player transition
	MouseMove(628, 324, $mouseSpeed)
	MouseClick("left", 628, 324, 2)

	Sleep(2000)

	;Video page screenshot
	_ScreenCapture_Capture($snapDir & $trackerId & "-a3.png")


	;First set-----------------------------------------

	;Check if first set page is displayed by checking location
	;occupied by volume slider is no longer white
	MouseMove(850, 525, $mouseSpeed)

	While 1
		$pixelColor = PixelGetColor(850, 525)
		If $pixelColor <> $pureWhite Then
			ExitLoop
		EndIf
	WEnd

	;Enough delay to allow for page transition to complete
	Sleep($transitionDelay)

	;Display Systray Balloon Tip
	TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "a4 - Syndicate questions (first set)", 10, 1)

	MouseMove(640, 195, $mouseSpeed)
	MouseClickDrag("left", $sliderStart, 195, $sliderEnd, 195, $mouseSpeed)
	Sleep($smallDelay)
	MouseClickDrag("left", $sliderStart, 320, $sliderEnd, 320, $mouseSpeed)
	Sleep($smallDelay)
	MouseClickDrag("left", $sliderStart, 440, $sliderEnd, 440, $mouseSpeed)
	MouseMove(900, 525, $mouseSpeed)
	Sleep($smallDelay)

	;First set screenshot
	_ScreenCapture_Capture($snapDir & $trackerId & "-a4.png")

	;Next button
	MouseClick("left", 900, 525, 1)
	Sleep($transitionDelay)

	;Second set-----------------------------------------

	;Display Systray Balloon Tip
	TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "a5 - Syndicated questions (second set)", 10, 1)

	MouseMove(640, 195, $mouseSpeed)
	MouseClickDrag("left", $sliderStart, 195, $sliderEnd, 195, $mouseSpeed)
	Sleep($smallDelay)
	MouseClickDrag("left", $sliderStart, 320, $sliderEnd, 320, $mouseSpeed)
	Sleep($smallDelay)
	MouseClickDrag("left", $sliderStart, 440, $sliderEnd, 440, $mouseSpeed)
	MouseMove(900, 525, $mouseSpeed)
	Sleep($smallDelay)

	;Second set screenshot
	_ScreenCapture_Capture($snapDir & $trackerId & "-a5.png")

	;Next button
	MouseClick("left", 900, 525, 1)
	Sleep($transitionDelay)

	;Third set-----------------------------------------

	;Display Systray Balloon Tip
	TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "a6 - Syndicated questions (third set) + verbatim", 10, 1)

	MouseMove(640, 195, $mouseSpeed)
	MouseClickDrag("left", $sliderStart, 195, $sliderEnd, 195, $mouseSpeed)
	MouseMove(350, 300, $mouseSpeed) ;move mouse into next position
	Sleep($smallDelay)
	MouseClick("left", 350, 300, 1)
	Sleep($smallDelay)
	MouseMove(350, 540, $mouseSpeed) ;move mouse into next position
	MouseClick("left", 350, 540, 2)
	Sleep($keyStrokeDelay)
	Send($verbatimString)
	MouseMove(900, 600, $mouseSpeed)
	Sleep($smallDelay)

	;Third set screenshot
	_ScreenCapture_Capture($snapDir & $trackerId & "-a6.png")

	;Next button
	MouseClick("left", 900, 600, 1)
	MouseMove(351, 136, $mouseSpeed)
	Sleep($transitionDelay)

	;Personal Experience--------------------------------

	;Display Systray Balloon Tip
	TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "a7 - Persoal experience + brand recognition", 10, 1)

	MouseClick("left", 351, 136, 1)
	MouseMove(345, 335, $mouseSpeed) ;move mouse into next position
	Sleep($smallDelay)
	MouseClick("left", 345, 335, 2)
	Sleep($keyStrokeDelay)
	Send($brandRecString)
	MouseMove(900, 525, $mouseSpeed)
	Sleep($smallDelay)

	;Personal experience screenshot
	_ScreenCapture_Capture($snapDir & $trackerId & "-a7.png")

	;Next button
	MouseClick("left", 900, 525, 1)
	;MouseMove(351,153,$mouseSpeed)		;move mouse into next position
	Sleep($transitionDelay)


	;Intender-----------------------------------------
	If $intender = True Then
		;Display Systray Balloon Tip
		TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "i1 - Intender", 10, 1)

		MouseClick("left", 351, 153, 1)
		MouseMove(900, 525, $mouseSpeed)
		Sleep($smallDelay)

		;Intender screenshot
		_ScreenCapture_Capture($snapDir & $trackerId & "-i1.png")

		;Next button
		MouseClick("left", 900, 525, 1)
		Sleep($transitionDelay)
	EndIf

	;Covey Follow On -------------------------------
	If $coveyFollowOn = True Then

		;Check for text area readiness by checking for bright white in text area
		While 1
			$pixelColor = PixelGetColor(350, 165) ;white
			If ($pixelColor = $pureWhite) Then
				ExitLoop
			EndIf
		WEnd

		;Display Systray Balloon Tip
		TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "cf1 - Covey Follow-On", 10, 1)

		;Initial question
		MouseMove(350, 165, $mouseSpeed)
		Sleep($keyStrokeDelay)
		MouseDown("left")
		Sleep($keyStrokeDelay)
		MouseUp("left")
		Sleep($keyStrokeDelay)
		Send("My current car is older, but reliable. " & _DateTimeFormat(_NowCalc, 1))

		;Next
		MouseMove(900, 525, $mouseSpeed)
		Sleep($keyStrokeDelay)
		MouseDown("left")
		Sleep($keyStrokeDelay)
		MouseUp("left")

		Sleep($transitionDelay)

		;Follow-on question
		MouseMove(350, 165, $mouseSpeed)
		Sleep($keyStrokeDelay)
		MouseDown("left")
		Sleep($keyStrokeDelay)
		MouseUp("left")
		Sleep($keyStrokeDelay)
		Send("It is easy to maintain. " & _DateTimeFormat(_NowCalc, 1))

		;Next
		MouseMove(900, 650, $mouseSpeed)
		Sleep($keyStrokeDelay)
		MouseDown("left")
		Sleep($keyStrokeDelay)
		MouseUp("left")

		Sleep($transitionDelay)

	EndIf

	;Covey (single select) -----------------------------------------
	If $coveySingle = True Then
		;1st radio button
		MouseMove(352, 186, $mouseSpeed)
		Sleep($keyStrokeDelay)
		MouseDown("left")
		Sleep($keyStrokeDelay)
		MouseUp("left")
		Sleep($keyStrokeDelay)

		;Next
		MouseMove(900, 525, $mouseSpeed)
		Sleep($keyStrokeDelay)
		MouseDown("left")
		Sleep($keyStrokeDelay)
		MouseUp("left")
		Sleep($transitionDelay)
	EndIf

	;Covey (multi select) -----------------------------------------
	If $coveyMulti = True Then
		;3rd checkbox
		MouseMove(352, 197, $mouseSpeed)
		Sleep($keyStrokeDelay)
		MouseDown("left")
		Sleep($keyStrokeDelay)
		MouseUp("left")
		Sleep($keyStrokeDelay)

		;4th checkbox
		MouseMove(352, 227, $mouseSpeed)
		Sleep($keyStrokeDelay)
		MouseDown("left")
		Sleep($keyStrokeDelay)
		MouseUp("left")
		Sleep($keyStrokeDelay)

		;Next
		MouseMove(900, 525, $mouseSpeed)
		Sleep($keyStrokeDelay)
		MouseDown("left")
		Sleep($keyStrokeDelay)
		MouseUp("left")
		Sleep($transitionDelay)
	EndIf



	;Capcha Page -----------------------------------

	;Wait for captcha page to become ready
	;Check for blue handle color and whitespace in middle of page
	MouseMove(615, 345, $mouseSpeed)

	While 1
		$pixelColor1 = PixelGetColor(615, 250) ;white
		$pixelColor2 = PixelGetColor(615, 345) ;sliderBlue
		If ($pixelColor1 = $containerWhite) And ($pixelColor2 = $sliderBlue) Then
			ExitLoop
		EndIf
	WEnd


	;Display Systray Balloon Tip
	TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "c1 - Captcha", 10, 1)

	;OCR vars
	Local $ocrMaxRetries = 20
	Local $attempts = 0
	Local $screenX = 1280
	Local $screenY = 960
	;capture starting position
	Local $x1 = 560
	Local $y1 = 140
	Local $x2 = $screenX - 720 ;desired width
	Local $y2 = $screenY - 155 ;desired height
	;data to calculate number vs pixel ratio
	Local $captchaXoffset = 0 ;to be calculated
	Local $captchaNumber = 0 ;to be obtained from OCR
	Local $captchaXmin = 400 ;abs min x-position (1)
	Local $captchaXmax = 883 ;abs max x-position (100)
	Local $captchaToPixelRatio = ($captchaXmax - $captchaXmin) / 100
	;Handle start and end coordinates
	Local $captchaHandleX1 = 637
	Local $captchaHandleY1 = 340
	Local $captchaHandleX2 = 0 ;to be calculated
	Local $captchaHandleY2 = 340

	;Run OCR
	While 1
		CaptureToTIFF("", "", "", $snapDir & $trackerId & "-c1_source-" & $attempts & ".tif", 1, $x1, $y1, $x2, $y2)
		$captchaNumber = Number( _TesseractScreenCapture(0, "", 0, 2, $x1, $y1, $x2, $y2, 0))
		TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "c1 - OCR: " & $captchaNumber, 5, 1)
		$attempts = $attempts + 1
		;Sleep(2000)

		;MsgBox(0, "Debug: is it a number?", IsNumber($captchaNumber))

		;Retry OCR if we don't get an integer between 1 and 100
		If $attempts > $ocrMaxRetries Then
			MsgBox(0, "SV2 Survey Helper", "Exceeded OCR retry attempts. Press OK to terminate.")
			WinClose("AMx :: Survey2 :: App - Mozilla Firefox")
			Exit
		ElseIf ($captchaNumber > 0) Or ($captchaNumber < 101) Then
			TrayTip("SV2 Survey Helper [" & $currentRespondentNumber & " of " & $maxRespondents & "]", "c1 - OCR Success: " & $captchaNumber, 5, 1)
			ExitLoop
		EndIf
	WEnd
	;MsgBox(0,"DEBUG captchaNumber", $captchaNumber)

	;Calculate x-offset (from center origin)
	$captchaHandleX2 = $captchaHandleX1 + (($captchaNumber - 50) * $captchaToPixelRatio)

	;MsgBox(0,"Ratio, offset, captchaHandleX2", $captchaToPixelRatio & ", " & $captchaXoffset & ", " & $captchaHandleX2)
	MouseMove($captchaHandleX1, $captchaHandleY1, $mouseSpeed) ;move to slider handle origin
	Sleep($smallDelay)

	;If captcha is exactly 50, move handle to the left a bit (so number will show), then return.
	;Otherwise, move the handle normally
	If $captchaNumber = 50 Then
		MouseClickDrag("left", $captchaHandleX1, $captchaHandleY1, ($captchaHandleX2 - 10), $captchaHandleY2, $mouseSpeed)
		MouseClickDrag("left", ($captchaHandleX1 - 10), $captchaHandleY1, $captchaHandleX2, $captchaHandleY2, $mouseSpeed)
	Else
		MouseClickDrag("left", $captchaHandleX1, $captchaHandleY1, $captchaHandleX2, $captchaHandleY2, $mouseSpeed)
	EndIf

	MouseMove(895, 647, $mouseSpeed)
	;Captcha screenshot (after click drag)
	_ScreenCapture_Capture($snapDir & $trackerId & "-c1.png")
	Sleep(1000)

	;Next (submit), holding down mouse button longer
	MouseDown("Left")
	Sleep(500)
	MouseUp("Left")


	;Accept Page -----------------------------------
	;Check for accept / rejection page
	;where grey bg no longer exists
	MouseMove(1000, 200, $mouseSpeed)
	While 1
		$pixelColor = PixelGetColor(1000, 200)
		If ($pixelColor <> $bgGrey) Then
			ExitLoop
		EndIf
		Sleep(1000)
	WEnd

	;Display Systray Balloon Tip
	;Captcha screenshot
	_ScreenCapture_Capture($snapDir & $trackerId & "-end.png")

	Sleep(1000)
	;WinClose("AMx :: Survey2 :: App - Mozilla Firefox")
	Send("^W") ;send CTRL-W to close the browser
	Sleep(1000)


Next
;Main Loop End -------------------------------------------------------------

MsgBox(0, "SV2 Survey Helper", "Survey fill complete")

;Helper functions ----------------------------------------------------------


Func EscTerminate()
	MsgBox(0, "Terminate", "Script terminated. Press OK to close the opened browser window.")
	WinClose("AMx :: Survey2 :: App - Mozilla Firefox")
	Sleep($smallDelay)
	Send("{SPACE}")
	Exit
EndFunc   ;==>EscTerminate


; Converts birth year to # of keystroke necessary to select it in the dropdown
Func YearToKeystroke($birthYear)
	Local $maxYear = 2014
	Local $offset = 1 ;how many keystroke to enable keyboard navigation
	Local $keyStrokes = $maxYear - $birthYear + $offset
	Return $keyStrokes
EndFunc   ;==>YearToKeystroke

; Converts ethnicity to # of keystroke necessary to select it in the dropdown
Func EthnicityToKeystroke($ethnicity)
	Local $keyStrokes = 0
	Switch $ethnicity
		Case $ethnicity = "Caucasian"
			$keyStrokes = 1
		Case $ethnicity = "Hispanic"
			$keyStrokes = 2
		Case $ethnicity = "AfricanAmerican"
			$keyStrokes = 3
		Case $ethnicity = "Asian"
			$keyStrokes = 4
		Case $ethnicity = "Other"
			$keyStrokes = 5
	EndSwitch
	Return $keyStrokes
EndFunc   ;==>EthnicityToKeystroke

; Converts children status year to # of keystroke necessary to select it in the dropdown
Func ChildrenToKeystroke($children)
	Local $keyStrokes = 0
	If $children = "HasChildren" Then
		$keyStrokes = 1
	ElseIf $children = "NoChildren" Then
		$keyStrokes = 2
	EndIf
	Return $keyStrokes
EndFunc   ;==>ChildrenToKeystroke

;Return array for specified respondent
Func RespondentSelect($respondentNumber, ByRef $respondentBank)
	Local $respondent[6]
	Local $temp


	;Workaround for inability of array[$i] from 2D array
	For $i = 0 To 5
		$temp = $respondentBank[$respondentNumber][$i]
		$respondent[$i] = $temp
	Next
	Return $respondent
EndFunc   ;==>RespondentSelect

;Assign coordinates to specified gender
Func GenderToCoordinates($gender, ByRef $genderX, ByRef $genderY)
	Switch $gender
		Case $gender = "M"
			$genderX = 351
			$genderY = 269
		Case $gender = "F"
			$genderX = 351
			$genderY = 294
	EndSwitch
EndFunc   ;==>GenderToCoordinates

;Assign coordinates to specified income
Func IncomeToCoordinates($income, ByRef $incomeX, ByRef $incomeY)
	Switch $income
		Case $income = "LowIncome"
			$incomeX = 351
			$incomeY = 430
		Case $income = "MidIncome"
			$incomeX = 351
			$incomeY = 455
		Case $income = "HighIncome"
			$incomeX = 351
			$incomeY = 480
	EndSwitch
EndFunc   ;==>IncomeToCoordinates
