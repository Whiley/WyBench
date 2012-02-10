define RGB as {int r, int g, int b}

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