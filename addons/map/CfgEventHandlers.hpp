class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preStart));
    };
};
class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_FILE(XEH_preInit));
    };
};
class Extended_PostInit_EventHandlers {
    class ADDON {
        clientInit = QUOTE(call COMPILE_FILE(XEH_postInitClient));
    };
};
class Extended_DisplayLoad_EventHandlers {
    class RscDiary {
        ADDON = QUOTE(([ARR_2((_this select 0),(_this select 0) displayCtrl ID_DIARY_MAP)]) call (uiNamespace getVariable 'DFUNC(initDisplayDiary)'););
    };
};
