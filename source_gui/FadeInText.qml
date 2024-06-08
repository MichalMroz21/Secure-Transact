import QtQuick 2.15

Text {
    id: textItem
    y: text_y
    width: text_width
    height: text_height
    color: text_color
    font.letterSpacing: text_letterSpacing
    font.pixelSize: text_pixelSize
    horizontalAlignment: Text.AlignHCenter
    lineHeight: 1
    textFormat: Text.AutoText
    font.wordSpacing: 1
    font.weight: Font.DemiBold
    font.bold: false
    style: Text.Normal
    font.family: "FontAwesome"
    text: textProperty
}
