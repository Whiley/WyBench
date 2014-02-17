// This is based on a modelling problem found in "Modeling in Event-B:
// System and Software Engineering" by By Jean-Raymond Abrial

type nat is (int x) where x >= 0

constant maxCarsOnIsland is 10

type State is {
	nat carsOnMl,  // number of cars on Main Land
	nat carsOnIl,  // number of cars on Island
	nat carsOnBr   // number of cars on Bridge
} where (carsOnBr + carsOnIl) < maxCarsOnIsland

// A car leaves the island and enters the bridge.
function carLeavesIsland(State st) => State
// For a car to leave the island, there must have been a car on the
// island.
requires st.carsOnIl > 0:
	//
	st.carsOnIl = st.carsOnIl - 1
	st.carsOnBr = st.carsOnBr + 1
	return st

// A car, either heading towards the island or towards the 
// main land, leaves the bridge.
function carLeavesBridge(State st, bool toIsland) => State
// For a car to leave the bridge, there must have been a car on the
// bridge.
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
function carEntersBridge(State st, bool toIsland) => State
// We need cars on island for one to leave island
requires toIsland || st.carsOnIl > 0
// We need cars on the mainland for one to leave mainland
requires !toIsland || st.carsOnMl > 0
// To allow a car onto the bridge heading towards the island, there must 
// be at least one free space available.
requires !toIsland || (st.carsOnBr + st.carsOnIl + 1) < maxCarsOnIsland: 
	//
	st.carsOnBr = st.carsOnBr + 1
	if toIsland:
		st.carsOnMl = st.carsOnMl - 1
	else:
		st.carsOnIl = st.carsOnIl - 1
	return st
