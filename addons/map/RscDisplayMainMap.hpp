class RscText;
class RscStructuredText;
class RscPicture;
class RscFrame;
class RscControlsGroupNoScrollbars;
class ctrlStatic;

class RscDisplayMainMap {
    class controls {
        class GVAR(peer): RscControlsGroupNoScrollbars {
            idc = IDC_PEER;
            show = 0;
            w = PEER_WIDTH;
            h = 0.14;
            class controls {
                class Name: RscText {
                    idc = IDC_PEER_NAME;
                    x = 0;
                    y = 0;
                    w = PEER_WIDTH;
                    h = 0.04;
                    colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21])","(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"};
                    text = "";
                };
            
                class Info: RscStructuredText {
                    idc = IDC_PEER_INFO;
                    x = 0;
                    y = 0.04;
                    w = PEER_WIDTH;
                    h = 0.5;
                    colorBackground[] = {0.05,0.05,0.05,0.75};
                };
            };
        };
    };
};
