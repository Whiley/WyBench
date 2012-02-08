import * from whiley.lang.*

define RGB as {int r, int g, int b}

define RGBA as {int r, int g, int b, int a}



public int BMPDepth([[RGB]] array):
	return getBitDepth(array, [1, 4, 8, 16, 24, 32])

public int mathMax(int a, int b):
	if a > b:
		return a
	else:
		return b

public int mathMin(int a, int b):
	if a < b:
		return a
	else:
		return b


public real realMax(real a, real b):
	if a > b:
		return a
	else:
		return b

public real realMin(real a, real b):
	if a < b:
		return a
	else:
		return b



public int getBitDepth([[RGB]] array, [int] potential):
	numColors = getDistinctColors(array)
	debug "Number of Distinct Colours: " + numColors + "\n"
	for i in potential:
		if intPower(2, i) >= numColors:
			return i
	return -1

int getDistinctColors([[RGB]] array):
	table = {}
	for i in 0..|array|:
		for j in 0..|array[0]|:
			rgb = array[i][j]
			table = table + {rgb}
	return |table|
public int intPower(int base, int power):
	i = 1
	value = base
	while i < power:
		value = value * base
		i = i + 1
	return value

public string stringTrim(string s):
	firstEnd = 0
	lastEnd = |s|
	for i in 0..|s|:
		if s[i] != ' ':
			firstEnd = i
			break
	i = |s|
	
	while i >= 0:
		if s[i-1] != ' ':
			lastEnd = i
			break
		i= i - 1
	return s[firstEnd..lastEnd]

public string stringReverse(string s):
	str = ""
	for ch in s:
		str = ch + str
	return str
	
public [byte] padUnsignedInt(int i, int padLength):
	data = Int.toUnsignedBytes(i)
	
	for j in |data|..padLength:
		data = data + [00000000b]
	return data
	
//public [byte] padSignedInt(int i, int padLength):
//	data = Int.toUnsignedBytes(i)
//	//Need to Flip the Array
//	data = reverseBits(data)
	//debug "Data: " + data + "\n"
//	for j in |data|..padLength:
//		data = data + [00000000b]
//	return data

public [byte] padSignedInt(int i, int padLength):
	data = [Int.toSignedByte(i)]
//debug "Data: " + data + "\n"
	for j in |data|..padLength:
		data = data + [00000000b]
//debug "Final Data: " + data + "\n"

	return data
	
[byte] reverseBits([byte] dat):
	//dat = List.reverse(dat) //Flip the List
	list = []
	for element in dat:
		list = list + [flipByte(element)]
	return list
	
byte flipByte(byte b):
	byt = 00000000b
	s = Byte.toString(b)
	if s[0] == '1':
		byt = byt | 00000001b
	if s[1] == '1':
		byt = byt | 00000010b
	if s[2] == '1':
		byt = byt | 00000100b
	if s[3] == '1':
		byt = byt | 00001000b
	if s[4] == '1':
		byt = byt | 00010000b
	if s[5] == '1':
		byt = byt | 00100000b
	if s[6] == '1':
		byt = byt | 01000000b
	if s[7] == '1':
		byt = byt | 10000000b
	
	return byt
	
	
	
public int getSignedInt([byte] bytes):
	
	val = 0
	mod = 1
	debug "Bytes: " + bytes + "\n"
	for b in bytes:
		str = Byte.toString(b)
		str = str[0..8]
		for ch in str:
			if ch == '1':
				val = val + mod
			mod = mod * 2
		debug "Value: " + val + "\n"
	return val

public [byte] stringToByte(string s):
	ret = []
	for ch in s:
		ret = ret + Int.toUnsignedBytes((int)ch)
	return ret

public (byte,int) ::toUnsignedInt(byte b, int shifts):
	r = 0
	base = intPower(2, shifts-1)
	shifted = 0
	while b != 0b && shifted < shifts:
		if (b & 10000000b) == 10000000b:
			r = r + base
		b = b << 1
		shifted = shifted + 1
		base = base / 2 
	return (b, r)

public int toSignedInt([byte] bytes):
	value = 0
	return Byte.toUnsignedInt(List.reverse(bytes))

public string toUpperCase(string s):
	str = ""
	for ch in s:
		if Char.isLowerCase(ch):
			val = (int)ch
			val = val - 32
			ch = (char)val
		str = str + ch
	return str

public string toLowerCase(string s):
	str = ""
	for ch in s:
		if Char.isUpperCase(ch):
			val = (int)ch
			val = val + 32
			ch = (char)val
		str = str + ch
	return str


public bool equalsIgnoreCase(string first, string second):
	return toLowerCase(first) == toLowerCase(second)

public int indexOf([any] list, any obj):
	
	for i in 0..|list|:
		if list[i] == obj:
			return i
	return -1


public int charToInt(string s):
	try:
		return Int.parse(s)
	catch(SyntaxError e):
		skip
	return -1


public int charToInt(char s):
	try:	
		s = "" + s
		return Int.parse(s)
	catch(SyntaxError e):
		skip
	return -1

public [string] stringSplit(string s, char c):
	array = []
	str = ""
	for ch in s:
		if ch == c:
			array = array + [str]
			str = ""
		else:
			str = str + ch
	
	array = array + [str]
	return array

