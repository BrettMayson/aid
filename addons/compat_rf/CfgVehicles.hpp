class CfgVehicles {
    class Helicopter_Base_F;
    class UAV_RC40_Base_RF: Helicopter_Base_F {
        EGVAR(uav,mode) = "LOS";
        EGVAR(uav,power)[] = { 100, 200, 300 };
        EGVAR(uav,defaultPower) = 100;
        EGVAR(uav,freq)[] = { 2400, 5800 };
        EGVAR(uav,defaultFreq) = 2400;
    }; 
};
