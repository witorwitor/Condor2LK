#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include %A_ScriptDir%\Profiler.ahk

atan2(a,b) 
{   
; 4-quadrant atan
   Return dllcall("msvcrt\atan2","Double",b, "Double",a, "CDECL Double")
}


;Radiospeed := 1

;***********INI Reading procedure********************
IniRead, CondorDir, Condor2LK.ini, CondorDir, CondorDir
IniRead, TaskDir, Condor2LK.ini, TaskDir, TaskDir
IniRead, LKTaskDir, Condor2LK.ini, LKTaskDir, LKTaskDir
IniRead, LKPenzoneDir, Condor2LK.ini, LKPenaltyzoneDir, LKPenzoneDir
IniRead, LKPolarDir, Condor2LK.ini, LKPolarDir, LKPolarDir
IniRead, SceneryName, %TaskDir%, Task, Landscape



;*****************GUI*****************************************************

Menu, tray, Icon , 01.ico, 1, 1
Gui, Font, S14 CDefault, Verdana
Gui, Add, Text, x24 y13 w110 h30 , Task type:
Gui, Add, Radio, gRadiospeed vRadiospeed Checked1 x24 y63 w100 h30 , Speed
Gui, Add, Radio, gRadioAAT  x134 y63 w100 h30 , AAT
Gui, Add, Text, x210 y13 w110 h30 , Advance:
Gui, Add, DropDownList, vAdvance Choose1 x300 y10 w100, Auto|Manual|Arm|ArmStart
Gui, Add, Edit, Hidden1 vAATtime x234 y63 w100 h30 ,
Gui, Add, Button,  x24 y113 w370 h120 , Convert
Gui, Add, Text, Hidden1 x344 y70 w40 h30 , min.
Gui, Show, x557 y353 h256 w418 , Condor2LK_v1.2 ; New GUI Window
Return

RadioAAT:
	GuiControl, Show, AATtime
	GuiControl, Show, min.
Return

Radiospeed:
	GuiControl, hide, AATtime
	GuiControl, hide, min.
Return

ButtonConvert:
{
;profiler()
Gui, Submit  ; Save the input from the user to each control's associated variable. 

profiler(Advance)
;**********************If Speed task**********************************
If Radiospeed = 1
{
FileDelete, %LKTaskDir%
;**********************First line and task type - Speed******************
FileAppend, <?xml version="1.0" encoding="UTF-8"?> `n, %LKTaskDir%, UTF-8
FileAppend, <lk-task type="Default"> `n, %LKTaskDir%, UTF-8
;***********************Task advance option************************************
FileAppend, %A_Tab% <options auto-advance="%Advance%"> `n, %LKTaskDir%, UTF-8
;***********************Read Start and Finish type data form Condor task file*****
IniRead, StartType, %TaskDir%, Task, TPSectorType1
IniRead, StartAngle, %TaskDir%, Task, TPAngle1
IniRead, StartRadius, %TaskDir%, Task, TPRadius1
IniRead, Count, %TaskDir%, Task, Count
Count := Count - 1
IniRead, FinishType, %TaskDir%, Task, TPSectorType%Count%
IniRead, FinishAngle, %TaskDir%, Task, TPAngle%Count%
IniRead, FinishRadius, %TaskDir%, Task, TPRadius%Count%
;****************Set Start and Finish type and Radius****************

	If (StartType = 0) and (StartAngle = 180)
		FileAppend, %A_Tab% %A_Tab% <start type="line" radius="%StartRadius%.000000"/> `n, %LKTaskDir%, UTF-8
		else 
			If (StartAngle = 90)
				FileAppend, %A_Tab% %A_Tab% <start type="sector" radius="%StartRadius%.000000"/> `n, %LKTaskDir%, UTF-8
				else
					If (StartAngle = 360)
					FileAppend, %A_Tab% %A_Tab% <start type="circle" radius="%StartRadius%.000000"/> `n, %LKTaskDir%, UTF-8
					else
					{
					FileAppend, %A_Tab% %A_Tab% <start type="line" radius="%StartRadius%.000000"/> `n, %LKTaskDir%, UTF-8	
					MsgBox  Unsupported Start type sector. Line sector will be used
					}

	If (FinishType = 0) and (FinishAngle = 180)
			FileAppend, %A_Tab% %A_Tab% <finish type="line" radius="%FinishRadius%.000000"/> `n, %LKTaskDir%, UTF-8
			else 
				If (FinishAngle = 90)
					FileAppend, %A_Tab% %A_Tab% <finish type="sector" radius="%FinishRadius%.000000"/> `n, %LKTaskDir%, UTF-8
					else
						If (FinishAngle = 360)
						FileAppend, %A_Tab% %A_Tab% <finish type="circle" radius="%FinishRadius%.000000"/> `n, %LKTaskDir%, UTF-8
						else
						{
						FileAppend, %A_Tab% %A_Tab% <finish type="line" radius="%FinishRadius%.000000"/> `n, %LKTaskDir%, UTF-8	
						MsgBox  Unsupported Finish type sector. Line sector will be used
						}
						
;*******************Check if window type TP's used in condor task************* used 
a := 2 ; temp variable for the loop
b := 0 ; If b = 0 no windows used. If b = 1 windows used in Condor task.

;*************Loop to determine b**************
While a < count
		{
		IniRead, TpType, %TaskDir%, Task, TPSectorType%a%
		a:=a + 1
		If TpType <> 0 
			{
			a := count + 1
			b := 1
			MsgBox  Unsupported Tp type. 500m cylinders will be used.
			}
		}

c := 0 ; If c = 0 all tp angles are the same. If c = 1 Tp angles not all the same FAI tp's should be used.
a := 3 ; temp variable for the loop

;***********Loop to determine c************************
IniRead, Tp1Angle, %TaskDir%, Task, TPAngle2
While a < count
		{
		IniRead, TpAngle, %TaskDir%, Task, TPAngle%a%
		a:=a + 1
		If Tp1Angle <> %TpAngle% 
			{
			a := count + 1
			c := 1
			MsgBox Mixed Tp angles not alowed. FAI sectors will be used.
			}
		}

r := 0 ; If r = 0 all tp radii are the same. If r = 1 Tp radii not all the same radii of the first tp should be used.
a := 3 ; temp variable for the loop
;***********Loop to determine r************************
IniRead, Tp1Radius, %TaskDir%, Task, TpRadius2

While a < count
		{
		IniRead, TpRadius, %TaskDir%, Task, TpRadius%a%
		a:=a + 1
		If Tp1Radius <> %TpRadius% 
			{
			a := count + 1
			r := 1
			MsgBox  Mixed Tp radii not alowed. %Tp1Radius% m radii will be used.
			}
		}



;******adding sector type line to the lkt file***********

if b = 1 
	FileAppend, %A_Tab% %A_Tab% <sector type="circle" Radius="500.000000"/> `n, %LKTaskDir%, UTF-8
	else
		if c = 1 
			FileAppend, %A_Tab% %A_Tab% <sector type="sector" Radius="500.000000"/> `n, %LKTaskDir%, UTF-8
		else
			if Tp1Angle = 360
				FileAppend, %A_Tab% %A_Tab% <sector type="circle" Radius="%Tp1Radius%.000000"/> `n, %LKTaskDir%, UTF-8
			else
				If Tp1Angle = 90
					FileAppend, %A_Tab% %A_Tab% <sector type="sector" Radius="%Tp1Radius%.000000"/> `n, %LKTaskDir%, UTF-8
				else
				{
				FileAppend, %A_Tab% %A_Tab% <sector type="sector" Radius="%Tp1Radius%.000000"/> `n, %LKTaskDir%, UTF-8
					if (count > 2)
					{
					MsgBox  Sector angle not alowed. FAI sectors with %Tp1Radius% m radii will be used.
					}
				}

FileAppend, %A_Tab% %A_Tab% <rules> `n, %LKTaskDir%, UTF-8
IniRead, TPWidth, %TaskDir%, Task, TPWidth%Count%
IniRead, TPPosZ, %TaskDir%, Task, TPPosZ%Count%
if (TPWidth > TPPosZ)
	{
	FinishHeight := TPWidth - TPPosZ 
	}
	else
	{
	FinishHeight := 0
	}		
FileAppend, %A_Tab% %A_Tab% %A_Tab% <finish fai-height="false" min-height="%FinishHeight%000"/> `n, %LKTaskDir%, UTF-8
IniRead, StartHeight, %TaskDir%, Task, TPHeight1
FileAppend, %A_Tab% %A_Tab% %A_Tab% <start max-height="%StartHeight%000" max-height-margin="0" max-speed="138889" max-speed-margin="0" height-ref="ASL"/> `n, %LKTaskDir%, UTF-8
FileAppend, %A_Tab% %A_Tab% </rules> `n, %LKTaskDir%, UTF-8
FileAppend, %A_Tab% </options> `n, %LKTaskDir%, UTF-8

;******************task points writing procedure**************************
FileAppend, %A_Tab% <taskpoints> `n, %LKTaskDir%, UTF-8
id := 1 
while id <= count 
	{
	IniRead, TPName, %TaskDir%, Task, TPName%id%
	LKidx := id - 1
	if (LKidx = 0)
		{
		FileAppend, %A_Tab% %A_Tab% <point idx="%LKidx%" name="S:%TPName%"/> `n, %LKTaskDir%, UTF-8
		id :=id + 1
		}
		else
			if (LKidx = count-1)
			{
			FileAppend, %A_Tab% %A_Tab% <point idx="%LKidx%" name="F:%TPName%"/> `n, %LKTaskDir%, UTF-8
			id :=id + 1
			}
			else
			{
			FileAppend, %A_Tab% %A_Tab% <point idx="%LKidx%" name="%LKidx%:%TPName%"/> `n, %LKTaskDir%, UTF-8
			id :=id + 1
			}
	}
FileAppend, %A_Tab% </taskpoints> `n, %LKTaskDir%, UTF-8

;******************waypoints writing procedure*****************************************************
FileAppend, %A_Tab% <waypoints> `n, %LKTaskDir%, UTF-8

dllName = %condorDir%\NaviCon.dll
trnPath = %condorDir%\Landscapes\%SceneryName%\%SceneryName%.trn
hModule := DllCall("LoadLibrary", Str, dllName)
DllCall("NaviCon\NaviConInit", Str, trnPath)

id := 1
while id <= count
	{
	IniRead, TPName, %TaskDir%, Task, TPName%id%
	IniRead, TPPosX, %TaskDir%, Task, TPPosX%id%
	IniRead, TPPosY, %TaskDir%, Task, TPPosY%id%
	IniRead, TPPosZ, %TaskDir%, Task, TPPosZ%id%
	Longitude := DllCall("NaviCon\XYToLon", Float, TPPosX, Float, TPPosY, Float)
	Latitude := DllCall("NaviCon\XYToLat", Float, TPPosX, Float, TPPosY, Float)
	If (id = 1)
		{
		FileAppend, %A_Tab% %A_Tab% <point name="S:%TPName%" latitude="%Latitude%" longitude="%Longitude%" altitude="%TPPosZ%.000000" flags="5"  format="2" style="1"/> `n, %LKTaskDir%, UTF-8
		id := id + 1	
		}
		else
			if (id = count)
				{
				FileAppend, %A_Tab% %A_Tab% <point name="F:%TPName%" latitude="%Latitude%" longitude="%Longitude%" altitude="%TPPosZ%.000000" flags="5"  format="2" style="1"/> `n, %LKTaskDir%, UTF-8
				id := id + 1
				}
				else
				{
				pn := id - 1
				FileAppend, %A_Tab% %A_Tab% <point name="%pn%:%TPName%" latitude="%Latitude%" longitude="%Longitude%" altitude="%TPPosZ%.000000" flags="5"  format="2" style="1"/> `n, %LKTaskDir%, UTF-8
				id := id + 1
				}
	}
DllCall("FreeLibrary", "UInt", hModule)  ; To conserve memory, the DLL may be unloaded after using it.
FileAppend, %A_Tab% </waypoints> `n, %LKTaskDir%, UTF-8
FileAppend, </lk-task>, %LKTaskDir%, UTF-8
;ExitApp
}
else

;***************************If AAT task***********************************	
{	
FileDelete, %LKTaskDir%

;**********************First line and task type - AAT******************
FileAppend, <?xml version="1.0" encoding="UTF-8"?> `n, %LKTaskDir%, UTF-8
FileAppend, <lk-task type="AAT"> `n , %LKTaskDir%, UTF-8

;***********************Task advance option************************************
FileAppend, %A_Tab% <options auto-advance="%Advance%" length="%AATtime%.000000">`n, %LKTaskDir%, UTF-8

;****************************Rules********************************
FileAppend, %A_Tab% %A_Tab% <rules> `n, %LKTaskDir%, UTF-8
IniRead, Count, %TaskDir%, Task, Count
Count := Count - 1
IniRead, FinishHeight, %TaskDir%, Task, TPWidth%Count%

FileAppend, %A_Tab% %A_Tab% %A_Tab% <finish fai-height="false" min-height="%FinishHeight%000"/> `n, %LKTaskDir%, UTF-8
IniRead, StartHeight, %TaskDir%, Task, TPHeight1
FileAppend, %A_Tab% %A_Tab% %A_Tab% <start max-height="%StartHeight%000" max-height-margin="0" max-speed="138889" max-speed-margin="0" height-ref="ASL"/> `n, %LKTaskDir%, UTF-8
FileAppend, %A_Tab% %A_Tab% </rules> `n, %LKTaskDir%, UTF-8
FileAppend, %A_Tab% </options> `n, %LKTaskDir%, UTF-8

;*******************task points - AAT********************************
FileAppend, %A_Tab% <taskpoints> `n, %LKTaskDir%, UTF-8
IniRead, Tp1Angle, %TaskDir%, Task, TPAngle1
IniRead, Tp1Radius, %TaskDir%, Task, TpRadius1
IniRead, TPName, %TaskDir%, Task, TPName1
IniRead, StartType, %TaskDir%, Task, TPSectorType1

If (Tp1Angle = 90) and (StartType = 0)
	FileAppend, %A_Tab% %A_Tab% <point idx="0" name="S:%TPName%" type="sector" radius="%Tp1Radius%.000000" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8
	else
		If (Tp1Angle = 180) and (StartType = 0)
			FileAppend, %A_Tab% %A_Tab% <point idx="0" name="S:%TPName%" type="line" radius="%Tp1Radius%.000000" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8
		else
			If (Tp1Angle = 360) and (StartType = 0)
				FileAppend, %A_Tab% %A_Tab% <point idx="0" name="S:%TPName%" type="circle" radius="%Tp1Radius%.000000" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8
			else
			{
			MsgBox Unsuported start sector angle. Line start will be used.
			FileAppend, %A_Tab% %A_Tab% <point idx="0" name="S:%TPName%" type="line" radius="%Tp1Radius%.000000" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8
			}
a := 2
while a < count
	{
	IniRead, TpAngle, %TaskDir%, Task, TPAngle%a%
	IniRead, TpRadius, %TaskDir%, Task, TpRadius%a%
	IniRead, TPName, %TaskDir%, Task, TPName%a%
		if TpAngle = 360
		{
		idx := a-1
		FileAppend, %A_Tab% %A_Tab% <point idx="%idx%" name="%idx%:%TPName%" type="circle" radius="%TpRadius%.000000" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8
		a := a + 1
		}
		else
		{
		dllName = %condorDir%\NaviCon.dll
		trnPath = %condorDir%\Landscapes\%SceneryName%\%SceneryName%.trn
		hModule := DllCall("LoadLibrary", Str, dllName)
		DllCall("NaviCon\NaviConInit", Str, trnPath)
		np := a-1
		nn := a+1
		
		IniRead, TPPosXp, %TaskDir%, Task, TPPosX%np%
		IniRead, TPPosYp, %TaskDir%, Task, TPPosY%np%
		IniRead, TPPosXn, %TaskDir%, Task, TPPosX%nn%
		IniRead, TPPosYn, %TaskDir%, Task, TPPosY%nn%
		IniRead, TPPosX, %TaskDir%, Task, TPPosX%a%
		IniRead, TPPosY, %TaskDir%, Task, TPPosY%a%
	
		Lonr := (DllCall("NaviCon\XYToLon", Float, TPPosX, Float, TPPosY, Float))*(3.141592653589793/180)
		Latr := (DllCall("NaviCon\XYToLat", Float, TPPosX, Float, TPPosY, Float))*(3.141592653589793/180)
		lonpr := (DllCall("NaviCon\XYToLon", Float, TPPosXp, Float, TPPosYp, Float))*(3.141592653589793/180)
		Latpr := (DllCall("NaviCon\XYToLat", Float, TPPosXp, Float, TPPosYp, Float))*(3.141592653589793/180)
		lonnr := (DllCall("NaviCon\XYToLon", Float, TPPosXn, Float, TPPosYn, Float))*(3.141592653589793/180)
		Latnr := (DllCall("NaviCon\XYToLat", Float, TPPosXn, Float, TPPosYn, Float))*(3.141592653589793/180)
		
		fp := sin(Lonpr-Lonr)*cos(Latpr)
		sp := cos(Latr)*sin(Latpr)-sin(Latr)*cos(Latpr)*cos(Lonpr-Lonr)
		bp := (Mod((atan2(sp,fp) *(180/3.141592653589793)+360),360))* 3.141592653589793/180
		
		fn := sin(Lonnr-Lonr)*cos(Latnr)
		sn := cos(Latr)*sin(Latnr)-sin(Latr)*cos(Latnr)*cos(Lonnr-Lonr)
		bn := (Mod((atan2(sn,fn) *(180/3.141592653589793)+360),360))* 3.141592653589793/180
		
		x3 :=cos(bp)+cos(bn)
		y3 :=sin(bp)+sin(bn)
		b:= Mod((atan2(x3,y3) *(180/3.141592653589793)+360),360)
		
		;**********oposite bearing************************
		
		bb:=Mod(b+180,360)
		IniRead, TpAngle, %TaskDir%, Task, TPAngle%a%
		ss:= Mod((bb - (TpAngle/2) + 360),360)
		sf:= Mod((bb + (TpAngle/2) + 360),360)
		
		idx := a-1
		FileAppend, %A_Tab% %A_Tab% <point idx="%idx%" name="%idx%:%TPName%" type="sector" radius="%TpRadius%.000000" start-radial="%ss%" end-radial="%sf%" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8
		a := a + 1
		}
	}

idx := a-1		
IniRead, TPName, %TaskDir%, Task, TPName%count%
IniRead, FinishType, %TaskDir%, Task, TPSectorType%Count%
IniRead, FinishAngle, %TaskDir%, Task, TPAngle%Count%
IniRead, FinishRadius, %TaskDir%, Task, TPRadius%Count%		

If (FinishType = 0) and (FinishAngle = 180)
			FileAppend, %A_Tab% %A_Tab% <point idx="%idx%" name="F:%TPName%" type="line" radius="%FinishRadius%.000000" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8
			else 
				If (FinishAngle = 90)
					FileAppend, %A_Tab% %A_Tab% <point idx="%idx%" name="F:%TPName%" type="sector" radius="%FinishRadius%.000000" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8
				else
						If (FinishAngle = 360)
						FileAppend, %A_Tab% %A_Tab% <point idx="%idx%" name="F:%TPName%" type="circle" radius="%FinishRadius%.000000" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8
						else
						{
						FileAppend, %A_Tab% %A_Tab% <point idx="%idx%" name="F:%TPName%" type="line" radius="%FinishRadius%.000000" lock="false" offset-radius="0.000000" offset-radial="0.000000"/> `n, %LKTaskDir%, UTF-8	
						MsgBox  Unsupported Finish type sector. Line sector will be used
						}		
FileAppend, %A_Tab% </taskpoints> `n, %LKTaskDir%, UTF-8
FileAppend, %A_Tab% <waypoints> `n, %LKTaskDir%, UTF-8

dllName = %condorDir%\NaviCon.dll
trnPath = %condorDir%\Landscapes\%SceneryName%\%SceneryName%.trn
hModule := DllCall("LoadLibrary", Str, dllName)
DllCall("NaviCon\NaviConInit", Str, trnPath)

id := 1
while id <= count
	{
	IniRead, TPName, %TaskDir%, Task, TPName%id%
	IniRead, TPPosX, %TaskDir%, Task, TPPosX%id%
	IniRead, TPPosY, %TaskDir%, Task, TPPosY%id%
	IniRead, TPPosZ, %TaskDir%, Task, TPPosZ%id%
	Longitude := DllCall("NaviCon\XYToLon", Float, TPPosX, Float, TPPosY, Float)
	Latitude := DllCall("NaviCon\XYToLat", Float, TPPosX, Float, TPPosY, Float)
	if (id = 1)
	{
	FileAppend, %A_Tab% %A_Tab% <point name="S:%TPName%" latitude="%Latitude%" longitude="%Longitude%" altitude="%TPPosZ%.000000" flags="5"  format="2" style="1"/> `n, %LKTaskDir%, UTF-8
	id := id + 1	
	}
	else
		if (id = count)
		{
		FileAppend, %A_Tab% %A_Tab% <point name="F:%TPName%" latitude="%Latitude%" longitude="%Longitude%" altitude="%TPPosZ%.000000" flags="5"  format="2" style="1"/> `n, %LKTaskDir%, UTF-8
	id := id + 1	
		}
		else
		{
			pn := id - 1
		FileAppend, %A_Tab% %A_Tab% <point name="%pn%:%TPName%" latitude="%Latitude%" longitude="%Longitude%" altitude="%TPPosZ%.000000" flags="5"  format="2" style="1"/> `n, %LKTaskDir%, UTF-8
		id := id + 1
		}
	}
DllCall("FreeLibrary", "UInt", hModule)  ; To conserve memory, the DLL may be unloaded after using it.
FileAppend, %A_Tab% </waypoints> `n, %LKTaskDir%, UTF-8
FileAppend, </lk-task>, %LKTaskDir%, UTF-8
}
IniRead, pzcount, %TaskDir%, Task, PZCount
if (pzcount > 0)
	{
	FileDelete, %LKPenzoneDir%
	FileAppend, **C2lk penalty zones** `n, %LKPenzoneDir%
	
	hModule := DllCall("LoadLibrary", Str, dllName)
	DllCall("NaviCon\NaviConInit", Str, trnPath)
	
	
	a := 0
	
	idx := pzcount - 1
	while (a <= idx)
		{
		IniRead, PZBase, %TaskDir%, Task, PZBase%a%
		IniRead, PZtop, %TaskDir%, Task, PZTop%a%
		FileAppend, AC P`n, %LKPenzoneDir%
		FileAppend, AN Penalty Zone %a%`n, %LKPenzoneDir%
		FileAppend, AH %PZtop%m AMSL`n, %LKPenzoneDir%
		FileAppend, AL %PZBase%m AMSL`n, %LKPenzoneDir%
		b := 0
			while (b < 4)
			{
			IniRead, PZPosX, %TaskDir%, Task, PZPos%b%X%a%
			IniRead, PZPosY, %TaskDir%, Task, PZPos%b%Y%a%
			Lon := DllCall("NaviCon\XYToLon", Float, PZPosX, Float, PZPosY, Float)
			Lat := DllCall("NaviCon\XYToLat", Float, PZPosX, Float, PZPosY, Float)
			;MsgBox %Lon% %Lat%
			if (lat>=0)
				{	
				Dla := floor(lat)
				Mla := floor(mod(lat*60,60))
				Sla := round(mod(lat*3600,60))
				FileAppend, DP %Dla%:%Mla%:%Sla% N , %LKPenzoneDir%
				}
				else
					{
					Dla := abs(ceil(lat))
					Mla := abs(ceil(mod(lat*60,60)))
					Sla := round(abs(mod(lat*3600,60)))
					FileAppend, DP %Dla%:%Mla%:%Sla% S , %LKPenzoneDir%
					}
			if (lon>=0)
				{	
				Dlo := floor(lon)
				Mlo := floor(mod(lon*60,60))
				Slo := round(mod(lon*3600,60))
				FileAppend, %Dlo%:%Mlo%:%Slo% E`n, %LKPenzoneDir%
				}
				else
					{
					Dlo := abs(ceil(lon))
					Mlo := abs(ceil(mod(lon*60,60)))
					Slo := round(abs(mod(lon*3600,60)))
					FileAppend, %Dlo%:%Mlo%:%Slo% W`n, %LKPenzoneDir%
					}
			b := b + 1 
			}
		a := a + 1
		}
	}
else
	{
	FileDelete, %LKPenzoneDir%
	FileAppend, **C2lk penalty zones** `n, %LKPenzoneDir%
	FileAppend, **No penalty zones** `n, %LKPenzoneDir%
	}
DllCall("FreeLibrary", "UInt", hModule)  ; To conserve memory, the DLL may be unloaded after using it.
IniRead, PlaneType, %TaskDir%, Plane, Name
FileDelete, %LKPolarDir%
FileAppend, * Condor polar for: %PlaneType% `n, %LKPolarDir%
FileAppend, * MassDryGross[kg]`, MaxWaterBallast[liters]`, Speed1[km/h]`, Sink1[m/s]`, Speed2`, Sink2`, Speed3`, Sink3`, WingArea[m2] `n, %LKPolarDir%
;msgbox %PlaneType%
IniRead, PolarString, C2LKPolars.txt, %PlaneType%, polar
FileAppend, %Polarstring% `n, %LKPolarDir%


;profiler()
;run Profiler.exe


ExitApp
}



GuiClose:
ExitApp





