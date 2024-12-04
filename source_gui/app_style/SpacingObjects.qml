import QtQuick 2.15

QtObject {
    readonly property int spacing_xxxx_sm: 1
    readonly property int spacing_xxx_sm: 2
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
    readonly property int spacing_xxxx_huge: 384
    readonly property int spacing_xxxxx_huge: 768

    readonly property var base_x: 1280.0
    readonly property var base_y: 720.0

    //axis boolean - 0 is X, 1 is Y
    function preserveSpacingProportion(spacing, width, height, axis) {
        if(!axis) return width / base_x * spacing;
        else return height / base_y * spacing;
    }
}
