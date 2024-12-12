import QtQuick 2.15
import QtQuick.Controls 2.5

QtObject {
    readonly property int display_large: 52
    readonly property int display_small: 44
    readonly property int display_h1: 30
    readonly property int display_h2: 28
    readonly property int display_h3: 26
    readonly property int display_h4: 24
    readonly property int display_h5: 22
    readonly property int display_h6: 20
    readonly property int mobile_h1: 18
    readonly property int mobile_h2: 16
    readonly property int mobile_h3: 14
    readonly property int mobile_h4: 12
    readonly property int mobile_h5: 10
    readonly property int mobile_h6: 8
    readonly property int paragraph_large: 18
    readonly property int paragraph_medium: 16
    readonly property int paragraph_small: 14
    readonly property int paragraph_xsmall: 12
    readonly property int label_large: 16
    readonly property int label_medium: 14
    readonly property int label_small: 12
    readonly property int label_xsmall: 10
    readonly property var getLatoBlack: fontLatoBlack
    readonly property var getLatoBlackItalic: fontLatoBlackItalic
    readonly property var getLatoBold: fontLatoBold
    readonly property var getLatoBoldItalic: fontLatoBoldItalic
    readonly property var getLatoItalic: contentLatoItalic
    readonly property var getLatoLight: contentLatoLight
    readonly property var getLatoLightItalic: contentLatoLightItalic
    readonly property var getLatoRegular: contentLatoRegular
    readonly property var getLatoThin: contentLatoThin
    readonly property var getLatoThinItalic: contentLatoThinItalic

    readonly property var fontLatoBlack: FontLoader {
        source: "../../assets/fonts/Lato-Black.ttf"
    }
    readonly property var fontLatoBlackItalic: FontLoader {
        source: "../../assets/fonts/Lato-BlackItalic.ttf"
    }
    readonly property var fontLatoBold: FontLoader {
        source: "../../assets/fonts/Lato-Bold.ttf"
    }
    readonly property var fontLatoBoldItalic: FontLoader {
        source: "../../assets/fonts/Lato-BoldItalic.ttf"
    }
    readonly property var contentLatoItalic: FontLoader {
        source: "../../assets/fonts/Lato-Italic.ttf"
    }
    readonly property var contentLatoLight: FontLoader {
        source: "../../assets/fonts/Lato-Light.ttf"
    }
    readonly property var contentLatoLightItalic: FontLoader {
        source: "../../assets/fonts/Lato-LightItalic.ttf"
    }
    readonly property var contentLatoRegular: FontLoader {
        source: "../../assets/fonts/Lato-Regular.ttf"
    }
    readonly property var contentLatoThin: FontLoader {
        source: "../../assets/fonts/Lato-Thin.ttf"
    }
    readonly property var contentLatoThinItalic: FontLoader {
        source: "../../assets/fonts/Lato-ThinItalic.ttf"
    }

    readonly property var base_x: 1280.0
    readonly property var base_y: 720.0

    function getFontSize(baseFontSize, width, height) {
        var scaleX = width / base_x;
        var scaleY = height / base_y;

        var scale = (scaleX + scaleY) / 2;

        return baseFontSize * scale;
    }
}
