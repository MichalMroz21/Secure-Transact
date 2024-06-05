import QtQuick 2.15

Text {
    id: textClickable
    text: textValue
    color: mouseArea.containsMouse ? hoverColor : textColor
    font.pixelSize: textSize

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        onClicked: stackView.push(pageName)
        hoverEnabled: true
    }

    NumberAnimation {
        id: fadeInAnimation
        target: textClickable
        properties: "opacity"
        duration: 5000
        to: 1
        from: 0
    }

    Component.onCompleted: {
        fadeInAnimation.start();
    }
}
