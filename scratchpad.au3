; Scratchpad
; Test you ideas here

#include <ScreenCapture.au3>
#include <Date.au3>
Global $tag = "Test"
Local $freq = 440
Local $duration = 100

HotKeySet("{ESC}", "EscTerminate")

;Beep(500, 100)
;Beep(1000, 100)
;Beep(1500, 200)
;Sleep(500)
Beep(1200, 200)
Beep(700, 400)
While 1
	Beep($freq, $duration)
	$freq = $freq + 1000
	If $freq > 15000 Then
		Break
	EndIf
WEnd
;TrayTip("SV2 Survey Helper", "a1 - Demographic questions", 10, 1)
;Sleep(500) ; Sleep to give tooltip time to display
;MsgBox(0, "Ahora", "The time is:" & _NowTime())
;Demographic response screenshot
;_ScreenCapture_Capture("snaps\" & $tag & "-" & _NowTime() & "0001.png")


Func EscTerminate()
	MsgBox(0, "Terminate", "Script terminated.")
	;WinClose("AMx :: Survey2 :: App - Mozilla Firefox")
    Exit
EndFunc   ;==>Terminate