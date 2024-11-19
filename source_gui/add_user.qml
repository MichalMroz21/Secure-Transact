import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

Page {
    id: formPage
    property int maxInputWidth: 300

    ColumnLayout {
        id: formContainer
        anchors.centerIn: parent
        spacing: 15
        width: Math.min(parent.width / 3, maxInputWidth)  // Set a maximum width for the form
        height: implicitHeight

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Connect to User"
            font.pixelSize: 20
            color: "black"
        }

        // IP Address Input
        TextField {
            id: ipAddressField
            placeholderText: "IP Address"
            font.pixelSize: 16
            height: 40
            Layout.fillWidth: true
            Layout.maximumWidth: maxInputWidth  // Set a maximum width for the input
            background: Rectangle {
                color: "#ffffff"
                border.color: "#ccc"
                radius: 5
            }
        }

        // Port Input
        TextField {
            id: portField
            placeholderText: "Port"
            font.pixelSize: 16
            height: 40
            Layout.fillWidth: true
            Layout.maximumWidth: maxInputWidth  // Set a maximum width for the input
            background: Rectangle {
                color: "#ffffff"
                border.color: "#ccc"
                radius: 5
            }
        }

        // Public Key Input
        TextField {
            id: pkField
            placeholderText: "Public Key"
            font.pixelSize: 16
            height: 40
            Layout.fillWidth: true
            Layout.maximumWidth: maxInputWidth  // Set a maximum width for the input
            background: Rectangle {
                color: "#ffffff"
                border.color: "#ccc"
                radius: 5
            }
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
                    if(ipAddressField.text !== "" && portField.text !== ""){
                        main_node.peer(ipAddressField.text, portField.text, pkField.text);
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
                    stackView.pop();
                }
            }
        }
    }
}
