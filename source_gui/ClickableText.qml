import QtQuick 2.15

Text {
    id: textClickable
    text: textValue
    color: mouseArea.containsMouse ? hoverColor : textColor
    font.pixelSize: textSize

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            currentForm = pageName;
        }

        hoverEnabled: true
    }
}
