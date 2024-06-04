import QtQuick 2.15

Text {
    id: textItem
    x: 654
    y: 112
    width: 630
    height: 169
    color: "#21a0ff"
    text: textProperty
    font.letterSpacing: 4
    font.pixelSize: 80
    horizontalAlignment: Text.AlignHCenter
    lineHeight: 1
    textFormat: Text.AutoText
    font.wordSpacing: 1
    font.weight: Font.DemiBold
    font.bold: false
    style: Text.Normal
    font.family: "FontAwesome"

    NumberAnimation {
        id: fadeInAnimation
        target: textItem
        properties: "opacity"
        duration: 5000
        to: 1
        from: 0
    }

    Component.onCompleted: {
        fadeInAnimation.start();
    }
}
