#include "..\script_component.hpp"

/**
 * Format marker metadata for hover tooltip display
 *
 * Args: _id
 *       _id: marker id
 * Returns: formatted text for display
 */

params ["_id"];

private _state = GVAR(markers) getOrDefault [_id, createHashMap];
if (count _state == 0) exitWith { "" };

private _text = _state getOrDefault ["text", ""];

// Created by and when
private _createdBy = _state getOrDefault ["createdBy", "Unknown"];
private _createdAt = _state getOrDefault ["createdAt", -1];
if (_createdAt != -1) then {
    _text = _text + format ["<br/><t size='0.9'>Created by: %1</t>", _createdBy];
    _text = _text + format ["<br/><t size='0.8'>at %1</t>", ([_createdAt] call FUNC(formatTime))];
} else {
    _text = _text + format ["<br/><t size='0.9'>Created by: %1</t>", _createdBy];
};

// Last edited by (if different from creator)
private _editedBy = _state getOrDefault ["editedBy", ""];
private _editedAt = _state getOrDefault ["editedAt", -1];
if (_editedBy != "") then {
    _text = _text + format ["<br/><t color='#FFD700' size='0.9'>Edited by: %1</t>", _editedBy];
    if (_editedAt != -1) then {
        _text = _text + format ["<br/><t color='#FFD700' size='0.8'>at %1</t>", ([_editedAt] call FUNC(formatTime))];
    };
};

// Last sync time
private _lastSync = _state getOrDefault ["lastSyncAt", -1];
if (_lastSync != -1) then {
    _text = _text + format ["<br/><t color='#90EE90' size='0.8'>Synced: %1</t>", ([_lastSync] call FUNC(formatTime))];
};

_text
