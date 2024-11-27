import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"

Page {
    Rectangle{
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
                    action: function(addr, port, nickname, PKString, isInGroup) {
                        user.removeFromPeers(addr, port);
                        user.removeFromGroup(addr, port);
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
}
