import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"

Page {
    Rectangle {
        width: parent.width / 1.5
        height: parent.height / 1.5
        color: "#f0f0f0"
        radius: 10
        anchors.centerIn: parent

        RowLayout {
            anchors.fill: parent

            ColumnLayout {
                id: formContainer
                Layout.fillWidth: true  // Make it scale horizontally
                Layout.fillHeight: true  // Make it scale vertically
                Layout.minimumWidth: parent.width * 1 / 2

                RowLayout{
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        id: ipAddress
                        text: "IP Address: "
                        font.pixelSize: 20
                        color: "black"
                    }
                    TextField {
                        text: user.host
                        font.pixelSize: 20
                        color: "black"
                    }
                }
                RowLayout{
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        id: portAddress
                        text: "Port: "
                        font.pixelSize: 20
                        color: "black"
                    }
                    TextField {
                        text: user.port
                        font.pixelSize: 20
                        color: "black"
                    }
                }
            }

            ColumnLayout {
                FriendList {
                    id: friendList
                    list_height: parent.height - addUserButton.height
                    list_width: parent.width / 2

                    Layout.maximumWidth: 300

                    customFunctions: [
                        {
                            text: "Delete from friends",
                            action: function(model, mousearea, popup) {
                                user.removeFromPeers(model.host, model.port);
                                user.removeFromGroup(model.host, model.port);
                            },
                            isVisible: true
                        }
                    ]
                }

                // Add New User Button
                Rectangle {
                    id: addUserButton
                    width: friendList.width
                    Layout.alignment: Qt.AlignBottom
                    //anchors.horizontalCenter: parent.horizontalCenter
                    //anchors.bottom: parent.bottom  // Position the button at the bottom of the parent

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
    }
}
