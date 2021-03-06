SuperStrict


Rem
bbdoc:This module contains the stuff you need to make your BlitzMax program connect to GameJolt
about:This module has been designed to take advantage of the Threaded mode, but as some programs can turn out a bit allergic to Threaded mode, I did enter a possibility to use this API unthreaded, however this will slow down your game when updates on GameJolt are done.
End Rem
Module GameJolt.GJ

ModuleInfo "ModuleName: GAMEJOLT.GJ"
ModuleInfo "Title: GameJolt API module for BlitzMax"
ModuleInfo "Origially created by: Polan"
ModuleInfo "Converted into a module by: Jeroen P. Broks aka Tricky (Phantasar Productions)"
ModuleInfo "License:Use it as you see fit"
ModuleInfo "Module Initial Release: Jan 1st, 2013"


Rem
?Not threaded
Import brl.retro
Print "This module only works in threaded build"
?threaded
End Rem
?Threaded
Import brl.threads
?
Import brl.stream
Import brl.max2d
Import brl.retro


?Threaded
Print "Threaded version of GJ routines"
?Not Threaded
Print "Unthreaded version of GJ routines"
?


Include "inc/gjCall.bmx"
Include "inc/gjUserInfo.bmx"
Include "inc/gjUser.bmx"
Include "inc/gjResult.bmx"
Include "inc/gjTrophy.bmx"
Include "inc/gjScore.bmx"
Include "inc/gjTable.bmx"


Rem
bbdoc: When set true, it will dump some stuff received from GJ onto the screen. If not needed, keep it on False.
End Rem
Global GJDebug:Int

Rem
bbdoc:Used to setup some data for GameJolt
End Rem
Type GJ
	Global privatekey$,gameid%
	Rem
	bbdoc:Enter your Game ID and Private key here!
	about:This function should ALWAYS be called first before using any other feature of this module!<p>Example:<br><pre>GJ.Create("e987a0113e029a49fba4865da681ff50",9840) </pre>
	End Rem
	Function Create(privatekey$,gameid%)
		GJ.privatekey = privatekey
		GJ.gameid = gameid
		gjTable.Fetch()
	End Function

	Global users:TList = CreateList()
	
	Function Update()
		For Local u:gjUser = EachIn users
			u.Update()
		Next
	End Function

	Function MD5$(in$)
		Local h0% = $67452301, h1% = $EFCDAB89, h2% = $98BADCFE, h3% = $10325476
		Local r%[] = [7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,..
					5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,..
					4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,..
					6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21]
		Local k%[] = [$D76AA478, $E8C7B756, $242070DB, $C1BDCEEE, $F57C0FAF, $4787C62A,..
					$A8304613, $FD469501, $698098D8, $8B44F7AF, $FFFF5BB1, $895CD7BE,..
					$6B901122, $FD987193, $A679438E, $49B40821, $F61E2562, $C040B340,..
					$265E5A51, $E9B6C7AA, $D62F105D, $02441453, $D8A1E681, $E7D3FBC8,..
					$21E1CDE6, $C33707D6, $F4D50D87, $455A14ED, $A9E3E905, $FCEFA3F8,..
					$676F02D9, $8D2A4C8A, $FFFA3942, $8771F681, $6D9D6122, $FDE5380C,..
					$A4BEEA44, $4BDECFA9, $F6BB4B60, $BEBFBC70, $289B7EC6, $EAA127FA,..
					$D4EF3085, $04881D05, $D9D4D039, $E6DB99E5, $1FA27CF8, $C4AC5665,..
					$F4292244, $432AFF97, $AB9423A7, $FC93A039, $655B59C3, $8F0CCC92,..
					$FFEFF47D, $85845DD1, $6FA87E4F, $FE2CE6E0, $A3014314, $4E0811A1,..
					$F7537E82, $BD3AF235, $2AD7D2BB, $EB86D391]
		
		Local intCount% = (((in$.length + 8) Shr 6) + 1) Shl 4
		Local data%[intCount]
		For Local c%=0 Until in$.length
			data[c Shr 2] = data[c Shr 2] | ((in$[c] & $FF) Shl ((c & 3) Shl 3))
		Next
		data[in$.length Shr 2] = data[in$.length Shr 2] | ($80 Shl ((in$.length & 3) Shl 3)) 
		data[data.length - 2] = (Long(in$.length) * 8) & $FFFFFFFF
		data[data.length - 1] = (Long(in$.length) * 8) Shr 32
		For Local chunkStart%=0 Until intCount Step 16
			Local a% = h0, b% = h1, c% = h2, d% = h3
			For Local i%=0 To 15
				Local f% = d ~ (b & (c ~ d))
				Local t% = d
				
				d = c ; c = b
				b = Rol((a + f + k[i] + data[chunkStart + i]), r[i]) + b
				a = t
			Next
			For Local i%=16 To 31
				Local f% = c ~ (d & (b ~ c))
				Local t% = d
				
				d = c ; c = b
				b = Rol((a + f + k[i] + data[chunkStart + (((5 * i) + 1) & 15)]), r[i]) + b
				a = t
			Next
			For Local i%=32 To 47
				Local f% = b ~ c ~ d
				Local t% = d
				
				d = c ; c = b
				b = Rol((a + f + k[i] + data[chunkStart + (((3 * i) + 5) & 15)]), r[i]) + b
				a = t
			Next
			For Local i%=48 To 63
				Local f% = c ~ (b | ~d)
				Local t% = d
				
				d = c ; c = b
				b = Rol((a + f + k[i] + data[chunkStart + ((7 * i) & 15)]), r[i]) + b
				a = t
			Next
			h0 :+ a ; h1 :+ b
			h2 :+ c ; h3 :+ d
		Next
		Return (LEHex(h0) + LEHex(h1) + LEHex(h2) + LEHex(h3)).ToLower()  
	End Function
	Function Rol%(val%, shift%)
		Return (val Shl shift) | (val Shr (32 - shift))
	End Function
	Function Ror%(val%, shift%)
		Return (val Shr shift) | (val Shl (32 - shift))
	End Function
	Function LEHex$(val%)
		Local out$ = Hex(val)
		Return out$[6..8] + out$[4..6] + out$[2..4] + out$[0..2]
	End Function
End Type

