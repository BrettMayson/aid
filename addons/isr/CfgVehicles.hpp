class CfgVehicles {
    class Helicopter_Base_F;
    class UAV;

    // Darter
    class UAV_01_base_F: Helicopter_Base_F {
        GVAR(function) = QFUNC(vanilla);
    };

    // Falcon
    class UAV_03_base_F: Helicopter_Base_F {
        GVAR(function) = QFUNC(vanilla);
    };

    /// YABHON
    class UAV_02_base_F: UAV {
        GVAR(function) = QFUNC(vanilla);
    };

    // Sentinel
    class UAV_05_Base_F: UAV {
        GVAR(function) = QFUNC(vanilla);
    };
};
