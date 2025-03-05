#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

GVAR(peers) = []; // All the peer radios

// Used by tickRadioSignal
GVAR(allRadios) = [];
GVAR(outerIndex) = 0;
GVAR(innerIndex) = 0;

// Used by tickDiscovery
GVAR(searchObjects) = [];
GVAR(scanningObjects) = createHashMap;
GVAR(peerObjects) = createHashMap;

// Used by radioData
GVAR(radioData) = createHashMap;

ADDON = true;
