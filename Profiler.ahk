profiler(advance)
{
;#include E:\Projects\tf.ahk
;Aircraft profile***********************************
	
Iniread, LKCUPpath, Condor2LK.ini, LKCUPpath, LKCUPpath
Iniread, LKDEMpath, Condor2LK.ini, LKDEMpath, LKDEMpath
Iniread, LKLKMpath, Condor2LK.ini, LKLKMpath, LKLKMpath


IniRead, TaskDir, Condor2LK.ini, TaskDir, TaskDir
IniRead, PlaneType, %TaskDir%, Plane, Name
IniRead, LkDefaultAircraftDir, Condor2LK.ini, LkDefaultAircraftDir, LkDefaultAircraftDir

linenum := TF_Find(LkDefaultAircraftDir,"","", "SafteySpeed1")
TF_ReplaceLine("!"LkDefaultAircraftDir,linenum,linenum,"SafteySpeed1=")
IniRead, safetyspeed, C2LKPolars.txt, %PlaneType%, SafteySpeed1
TF_InsertSuffix("!"LkDefaultAircraftDir,linenum,linenum, safetyspeed)

linenum := TF_Find(LkDefaultAircraftDir,"","", "Handicap1")
TF_ReplaceLine("!"LkDefaultAircraftDir,linenum,linenum,"Handicap1=")
IniRead, Handicap, C2LKPolars.txt, %PlaneType%, Handicap1
TF_InsertSuffix("!"LkDefaultAircraftDir,linenum,linenum, Handicap)

linenum := TF_Find(LkDefaultAircraftDir,"","", "BallastSecsToEmpty1")
TF_ReplaceLine("!"LkDefaultAircraftDir,linenum,linenum,"BallastSecsToEmpty1=")
IniRead, BallastSecsToEmpty, C2LKPolars.txt, %PlaneType%, BallastSecsToEmpty1
TF_InsertSuffix("!"LkDefaultAircraftDir,linenum,linenum, BallastSecsToEmpty)

linenum := TF_Find(LkDefaultAircraftDir,"","", "AircraftType1")
TF_ReplaceLine("!"LkDefaultAircraftDir,linenum,linenum,"AircraftType1=")
TF_InsertSuffix("!"LkDefaultAircraftDir,linenum,linenum, """")
IniRead, AircraftType, C2LKPolars.txt, %PlaneType%, AircraftType1
TF_InsertSuffix("!"LkDefaultAircraftDir,linenum,linenum, AircraftType)
TF_InsertSuffix("!"LkDefaultAircraftDir,linenum,linenum, """")


;LK porfile**************************************


if advance = auto
	{
	advancen := 0
	}
	else
		if advance = manual
			{
			advancen := 1
			}
			else
				if advance = Arm
					{
					advancen := 2
					}
					else
						if advance = ArmStart
							{
							advancen := 3
							}
								else
									{
									advancen := 0
									}


IniRead, LKDefaultprfDir, Condor2LK.ini, LKDefaultprfDir, LKDefaultprfDir
linenum := TF_Find(LKDefaultprfDir,"","", "AutoAdvance=")
TF_ReplaceLine("!"LKDefaultprfDir,linenum,linenum,"AutoAdvance=")
TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, advancen)


IniRead, LKDefaultprfDir, Condor2LK.ini, LKDefaultprfDir, LKDefaultprfDir
linenum := TF_Find(LKDefaultprfDir,"","", "MapFile=")
TF_ReplaceLine("!"LKDefaultprfDir,linenum,linenum,"MapFile=")
TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, """")
IniRead, TaskDir, Condor2LK.ini, TaskDir, TaskDir
IniRead, Landscape, %TaskDir%, Task, Landscape
IniRead, LKM, C2LKlandscapes.txt, %landscape%, LKM, 0
if (LKM = 0) 
	{
	msgBox ERROR, no %Landscape% landscape in C2LKlandscapes.txt. Map will NOT be set!
	TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, """")
	}
	else
		{
		TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, LKLKMpath)
		;TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, "%LOCAL_PATH%\_Maps\C2LK\")
		TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, LKM)
		TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, """")
		}
		
linenum := TF_Find(LKDefaultprfDir,"","", "TerrainFile=")
TF_ReplaceLine("!"LKDefaultprfDir,linenum,linenum,"TerrainFile=")
TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, """")
IniRead, DEM, C2LKlandscapes.txt, %landscape%, DEM, 0
if (DEM = 0) 
	{
	msgBox ERROR, no %Landscape% landscape in C2LKlandscapes.txt. Terrain will NOT be set!
	TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, """")
	}
	else
		{
		TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, LKDEMpath)
		;TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, "%LOCAL_PATH%\_Maps\C2LK\")
		TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, DEM)
		TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, """")
		}



linenum := TF_Find(LKDefaultprfDir,"","", "AdditionalWPFile=")
TF_ReplaceLine("!"LKDefaultprfDir,linenum,linenum,"AdditionalWPFile=")
TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, """")
IniRead, CUP, C2LKlandscapes.txt, %landscape%, CUP, 0
if (CUP = 0)
	{
	TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, """")
	}
	else
	{
	TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, LKCUPpath)
	;TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, "%LOCAL_PATH%\_Waypoints\C2LK\")
	TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, CUP)
	TF_InsertSuffix("!"LKDefaultprfDir,linenum,linenum, """")
	}

;next - uglupotoodpornic - ostrzezenie ze nie ma scenerii
return
}





