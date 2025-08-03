class CfgVehicles {
    class Helicopter_Base_F;
    class UAV_RC40_Base_RF: Helicopter_Base_F {
        GVAR(mode) = "LOS";
        GVAR(power)[] = { 100, 200, 300 };
        GVAR(defaultPower) = 100;
        GVAR(freq)[] = { 2400, 5800 };
        GVAR(defaultFreq) = 2400;
    }; 
};
