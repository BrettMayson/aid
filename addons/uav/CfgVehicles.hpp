class CfgVehicles {
    class Helicopter_Base_F;
    class UAV;

    // Darter
    class UAV_01_base_F: Helicopter_Base_F {
        GVAR(mode) = "LOS";
        GVAR(power)[] = { 100, 200, 300, 400, 600, 800, 1200, 1800 };
        GVAR(defaultPower) = 100;
        GVAR(freq)[] = { 433, 915, 1200, 2400, 5800 };
        GVAR(defaultFreq) = 1200;
    };

    // Falcon
    class UAV_03_base_F: Helicopter_Base_F {
        GVAR(mode) = "SAT";
    };

    /// YABHON
    class UAV_02_base_F: UAV {
        GVAR(mode) = "SAT";
    };

    // Sentinel
    class UAV_05_Base_F: UAV {
        GVAR(mode) = "SAT";
    };
};
