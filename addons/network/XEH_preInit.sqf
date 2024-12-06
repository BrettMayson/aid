#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

GVAR(peers) = []; // All the peer radios

// Used by tickRadioSignal
GVAR(allRadios) = [];
GVAR(outerRadios) = [];
GVAR(innerRadios) = [];

// Used by tickDiscovery
GVAR(searchObjects) = [];
GVAR(scanningObjects) = createHashMap;
GVAR(peerObjects) = createHashMap;

ADDON = true;
