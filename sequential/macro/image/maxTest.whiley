import * from whiley.lang.*

void ::test(int i, int pad):
	data = List.reverse(Int.toUnsignedBytes(i))
	for j in |data|..pad:
		data = [00000000b] + data 
	debug "Final Data: " + data + "\n"

void ::main(System.Console sys):
	val = 10
	x = Util.padSignedInt(val, 4)
	ret = Util.getSignedInt(x)
	sys.out.println("Init: " + val + " Adjusted: " + ret)
	val = 60
	x = Util.padSignedInt(val, 4)
	ret = Util.getSignedInt(x)
	sys.out.println("Init: " + val + " Adjusted: " + ret)
	val = 159
	x = Util.padSignedInt(val, 4)
	ret = Util.getSignedInt(x)
	sys.out.println("Init: " + val + " Adjusted: " + ret)
	val = 150
	x = Util.padSignedInt(val, 4)
	ret = Util.getSignedInt(x)
	sys.out.println("Init: " + val + " Adjusted: " + ret)
	val = 320
	x = Util.padSignedInt(val, 4)
	ret = Util.getSignedInt(x)
	sys.out.println("Init: " + val + " Adjusted: " + ret)
	val = 260
	x = Util.padSignedInt(val, 4)
	ret = Util.getSignedInt(x)
	sys.out.println("Init: " + val + " Adjusted: " + ret)