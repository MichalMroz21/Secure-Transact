import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"

Page {
    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        FriendList {
            id: friendList
            anchors.horizontalCenter: parent.horizontalCenter

            list_height: parent.height - addUserButton.height
            customFunctions: [
                {
                    text: "Delete from friends",
                    action: function(host, port, nickname, public_key, isInGroup) {
                        user.removeFromPeers(host, port);
                        user.removeFromGroup(host, port);
                    },
                    isVisible: true
                }
            ]
        }

        // Add New User Button
        Rectangle {
            id: addUserButton
            width: friendList.width

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom  // Position the button at the bottom of the parent

            height: 50  // Fixed height for the button
            color: "green"

            MouseArea {
                id: addButton
                anchors.fill: parent
                onClicked: {
                    stackView.push("add_user.qml");
                }
                hoverEnabled: true

                onEntered: {
                    parent.color = "darkgreen";  // Change color on hover
                }
                onExited: {
                    parent.color = "green";
                }

                Text {
                    id: addUserButtonText
                    anchors.centerIn: parent
                    text: "Add new user"
                    color: "white"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    ColumnLayout {
        property int maxInputWidth: 300
        id: formContainer
        anchors.centerIn: parent
        spacing: 15
        width: Math.min(parent.width / 3, maxInputWidth)  // Set a maximum width for the form
        height: implicitHeight
            RowLayout{
                Text {
                id: ipAddress
                    Layout.alignment: Qt.AlignHCenter
                    text: "IP Address: "
                    font.pixelSize: 20
                    color: "black"
                }
                TextField {
                    text: user.host
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 20
                    color: "black"
                }
            }
            RowLayout{
                Text {
                id: portAddress
                    Layout.alignment: Qt.AlignHCenter
                    text: "Port: "
                    font.pixelSize: 20
                    color: "black"
                }
                TextField {
                    text: user.port
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 20
                    color: "black"
                }
            }
    }
}
