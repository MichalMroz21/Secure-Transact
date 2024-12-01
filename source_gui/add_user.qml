import QtQuick
import QtQuick.Controls 6.8
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "small_gui_components"

Page {
    id: formPage
    property int maxInputWidth: 300

    background: Rectangle {
        color: colorPalette.background900
    }

    Component.onCompleted: {
        root.pageTitleText = "Add new user";
    }

    ColumnLayout {
        id: formContainer
        anchors.centerIn: parent
        spacing: 15
        width: Math.min(parent.width / 3, maxInputWidth)  // Set a maximum width for the form
        height: implicitHeight
        Layout.preferredHeight: 256

        Text {

            Layout.alignment: Qt.AlignHCenter
            text: "Connect to User"
            font.pixelSize: 20
            color: colorPalette.primary300
        }

        // IP Address Input
        MyTextFieldLabel {
            id: addressTextField
            upText: "IP Address"
            downText: user.port
            parentWidth: parent.width
            parentHeight: 50
        }

        // Port Input
        MyTextFieldLabel {
            id: portTextField
            upText: "Port"
            downText: user.port
            parentWidth: parent.width
            parentHeight: 50
        }

        // Buttons Row
        RowLayout {
            spacing: 20
            Layout.alignment: Qt.AlignHCenter

            // Accept Button
            Button {
                text: "Accept"
                font.pixelSize: 16
                width: 100
                height: 40
                background: Rectangle {
                    color: "green"
                    radius: 5
                }
                contentItem: Text {
                    text: "Accept"
                    color: "white"
                    font.pixelSize: 16
                    anchors.centerIn: parent
                }
                onClicked:{
                    if(addressTextField.text !== "" && portTextField.text !== ""){
                        user.send_invitation(addressTextField.text, portTextField.text);
                        //user.verify_peer_connection(addressTextField.text, portTextField.text);
                        stackView.push("chat_module.qml");
                    }
                }
            }

            // Cancel Button
            Button {
                text: "Cancel"
                font.pixelSize: 16
                width: 100
                height: 40
                background: Rectangle {
                    color: "red"
                    radius: 5
                }
                contentItem: Text {
                    text: "Cancel"
                    color: "white"
                    font.pixelSize: 16
                    anchors.centerIn: parent
                }
                onClicked: {
                    root.pageTitleText = "User profile";
                    stackView.pop();
                }
            }
        }
    }
}
