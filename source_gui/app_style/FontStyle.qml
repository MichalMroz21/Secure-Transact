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

        function getFontSize(width, height) {
            // Determine the smaller dimension (to handle portrait vs. landscape)
            let sizeBaseline = Math.min(width, height);

            // Font size selection based on the size of the window
            if (sizeBaseline < 400) {
                return mobile_h6; // For very small screens
            } else if (sizeBaseline >= 400 && sizeBaseline < 500) {
                return mobile_h5; // Small mobile screens
            } else if (sizeBaseline >= 500 && sizeBaseline < 600) {
                return mobile_h4; // Medium mobile screens
            } else if (sizeBaseline >= 600 && sizeBaseline < 700) {
                return mobile_h3; // Larger mobile screens
            } else if (sizeBaseline >= 700 && sizeBaseline < 800) {
                return mobile_h2; // Medium tablets
            } else if (sizeBaseline >= 800 && sizeBaseline < 900) {
                return mobile_h1; // Large tablets
            } else if (sizeBaseline >= 900 && sizeBaseline < 1000) {
                return display_h6; // Small desktops
            } else if (sizeBaseline >= 1000 && sizeBaseline < 1100) {
                return display_h5; // Medium desktops
            } else if (sizeBaseline >= 1100 && sizeBaseline < 1200) {
                return display_h4; // Larger desktops
            } else if (sizeBaseline >= 1200 && sizeBaseline < 1300) {
                return display_h3; // Extra-large desktops
            } else if (sizeBaseline >= 1300 && sizeBaseline < 1400) {
                return display_h2; // Huge displays
            } else if (sizeBaseline >= 1400 && sizeBaseline < 1500) {
                return display_h1; // Very large displays
            } else if (sizeBaseline >= 1500 && sizeBaseline < 1600) {
                return display_small; // Large ultra-wide displays
            } else if (sizeBaseline >= 1600 && sizeBaseline < 1700) {
                return display_large; // Extra-large ultra-wide displays
            } else if (sizeBaseline >= 1700) {
                return display_large; // Extreme large screens (e.g., 4K+)
            }

            // Now considering paragraph and label sizes:
            // Small devices or small windows should use the paragraph and label small sizes
            if (sizeBaseline < 600) {
                return paragraph_xsmall; // Smallest text
            } else if (sizeBaseline >= 600 && sizeBaseline < 800) {
                return paragraph_small; // Small paragraphs and labels
            } else if (sizeBaseline >= 800 && sizeBaseline < 1000) {
                return paragraph_medium; // Medium paragraph size
            } else if (sizeBaseline >= 1000 && sizeBaseline < 1200) {
                return label_xsmall; // Small labels
            } else if (sizeBaseline >= 1200 && sizeBaseline < 1400) {
                return label_small; // Small labels for larger screens
            } else if (sizeBaseline >= 1400 && sizeBaseline < 1600) {
                return label_medium; // Larger labels for even larger screens
            } else {
                return label_large; // For very large screens or extreme cases
            }
        }
}
