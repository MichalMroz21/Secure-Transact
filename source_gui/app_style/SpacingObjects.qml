import QtQuick 2.15

QtObject {
    readonly property int spacing_xx_sm: 4
    readonly property int spacing_x_sm: 8
    readonly property int spacing_sm: 12
    readonly property int spacing_md: 16
    readonly property int spacing_big: 20
    readonly property int spacing_x_big: 24
    readonly property int spacing_xx_big: 28
    readonly property int spacing_xxx_big: 32
    readonly property int spacing_lg: 40
    readonly property int spacing_x_lg: 48
    readonly property int spacing_xx_lg: 64
    readonly property int spacing_xxx_lg: 80
    readonly property int spacing_huge: 96
    readonly property int spacing_x_huge: 128
    readonly property int spacing_xx_huge: 160
    readonly property int spacing_xxx_huge: 192

    function getSpacing(width, height) {
        // Determine the smaller dimension (to handle portrait vs. landscape)
        let sizeBaseline = Math.min(width, height);

        // Spacing selection based on the size of the window
        if (sizeBaseline < 400) {
            return spacingObjects.spacing_xx_sm; // Very small screens (extra compact spacing)
        } else if (sizeBaseline >= 400 && sizeBaseline < 500) {
            return spacingObjects.spacing_x_sm; // Small mobile screens
        } else if (sizeBaseline >= 500 && sizeBaseline < 600) {
            return spacingObjects.spacing_sm; // Medium mobile screens
        } else if (sizeBaseline >= 600 && sizeBaseline < 700) {
            return spacingObjects.spacing_md; // Larger mobile screens
        } else if (sizeBaseline >= 700 && sizeBaseline < 800) {
            return spacingObjects.spacing_big; // Medium tablets
        } else if (sizeBaseline >= 800 && sizeBaseline < 900) {
            return spacingObjects.spacing_x_big; // Large tablets
        } else if (sizeBaseline >= 900 && sizeBaseline < 1000) {
            return spacingObjects.spacing_xx_big; // Small desktops
        } else if (sizeBaseline >= 1000 && sizeBaseline < 1100) {
            return spacingObjects.spacing_xxx_big; // Medium desktops
        } else if (sizeBaseline >= 1100 && sizeBaseline < 1200) {
            return spacingObjects.spacing_lg; // Larger desktops
        } else if (sizeBaseline >= 1200 && sizeBaseline < 1300) {
            return spacingObjects.spacing_x_lg; // Extra-large desktops
        } else if (sizeBaseline >= 1300 && sizeBaseline < 1400) {
            return spacingObjects.spacing_xx_lg; // Huge displays
        } else if (sizeBaseline >= 1400 && sizeBaseline < 1500) {
            return spacingObjects.spacing_xxx_lg; // Very large displays
        } else if (sizeBaseline >= 1500 && sizeBaseline < 1600) {
            return spacingObjects.spacing_huge; // Large ultra-wide displays
        } else if (sizeBaseline >= 1600 && sizeBaseline < 1700) {
            return spacingObjects.spacing_x_huge; // Extra-large ultra-wide displays
        } else if (sizeBaseline >= 1700) {
            return spacingObjects.spacing_xx_huge; // Extreme large screens (e.g., 4K+)
        }
    }
}
