// This is based on a modelling problem found in "Modeling
// in Event-B: System and Software Engineering" by 
// By Jean-Raymond Abrial

define nat as int where $ >= 0

define maxCarsOnIsland as 10

define State as {
	nat carsOnMl,  // number of cars on Main Land
	nat carsOnIl,  // number of cars on Island
	nat carsOnBr   // number of cars on Bridge
} where (carsOnBr + carsOnIl) < maxCarsOnIsland

// A car leaves the island and enters the bridge.
State carLeavesIsland(State st) 
requires st.carsOnIl > 0:
	//
	st.carsOnIl = st.carsOnIl - 1
	st.carsOnBr = st.carsOnBr + 1
	return st

// A car, either heading towards the island or towards the 
// main land, leaves the bridge.
State carLeavesBridge(State st, bool toIsland) 
requires st.carsOnBr > 0:
	//
	st.carsOnBr = st.carsOnBr - 1
	if toIsland:
		st.carsOnIl = st.carsOnIl + 1
	else:
		st.carsOnMl = st.carsOnMl + 1
	return st

// A car, either heading towards the island or towards the 
// main land, enters the bridge.
State carEntersBridge(State st, bool toIsland)
requires (st.carsOnBr + st.carsOnIl + 1) < maxCarsOnIsland:
	//
	st.carsOnBr = st.carsOnBr + 1
	st.carsOnIl = st.carsOnIl - 1
	return st

	



