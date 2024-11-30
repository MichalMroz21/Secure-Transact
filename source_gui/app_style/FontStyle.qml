import QtQuick 2.15
import QtQuick.Controls 2.5

QtObject {
    readonly property int       h1 : 32
    readonly property int       h2 : 24
    readonly property double    h3 : 18.72
    readonly property int       h4 : 16
    readonly property double    h5 : 13.28
    readonly property double    h6 : 10.72

    readonly property int content : 14

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
}
