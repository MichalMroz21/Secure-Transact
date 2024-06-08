import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: inputBox
    width: 400
    height: 64
    color: "lightgray"
    radius: 5
    border.color: "transparent"

    Row {
        anchors.fill: parent
        anchors.margins: 0

        Rectangle {
            width: inputBox.height * 1.5
            height: inputBox.height
            color: "#3a333333"
            border.color: "transparent"
            radius: 5
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.centerIn: parent
                source: imageSource
                width: parent.height * 0.8
                height: parent.height * 0.8
                fillMode: Image.PreserveAspectFit
            }
        }

        TextField {
            id: textField
            property string fieldColor: "#21a0ff"
            width: inputBox.width - (inputBox.height * 1.5)
            height: inputBox.height
            cursorVisible: true
            selectByMouse: true
            maximumLength: 20
            placeholderText: initialText
            placeholderTextColor: textField.activeFocus ? fieldColor : "gray"
            selectionColor: fieldColor
            echoMode: showText ? TextField.Normal : TextField.Password
            font.pixelSize: 20
            color: "black"
            background: null
            anchors.verticalCenter: parent.verticalCenter
            padding: {
                left: inputBox.height * 1.5 - textField.leftPadding
            }
        }
    }
}
