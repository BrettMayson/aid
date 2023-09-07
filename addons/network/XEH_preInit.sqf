#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

GVAR(peers) = createHashMap; // All the peer objects

// Used by tickRadioSignal
GVAR(allRadios) = [];
GVAR(radios) = [];
GVAR(peerRadios) = createHashMap;
GVAR(playerRadios) = createHashMap;

// Used by tickDiscovery
GVAR(searchObjects) = [];
GVAR(scanningObjects) = createHashMap;
GVAR(peerObjects) = createHashMap;

ADDON = true;
