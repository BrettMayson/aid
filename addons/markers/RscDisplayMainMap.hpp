class RscStructuredText;
class RscControlsGroupNoScrollbars;

class RscDisplayMainMap {
    class controls {
        class GVAR(markerHover): RscControlsGroupNoScrollbars {
            idc = IDC_MARKER_HOVER;
            show = 0;
            w = 0.35;
            h = 0.2;
            class controls {
                class Info: RscStructuredText {
                    idc = IDC_MARKER_HOVER_INFO;
                    x = 0;
                    y = 0;
                    w = 0.35;
                    h = 0.2;
                    colorBackground[] = {0.05,0.05,0.05,0.8};
                };
            };
        };
    };
};
