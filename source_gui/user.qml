import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"

Page {
    ListModel {
        id: inviteModel
    }
    function getDrawerEntrySize(width, height){
        return (width + height) * 0.02;
    }
    function updateInvitesModel() {
        inviteModel.clear();
        for (let i = 0; i < user.invites.length; i++) {
            if(user.invites[i].received === true){
                inviteModel.append({
                    host: user.invites[i].host,
                    port: user.invites[i].port
                });
            };
        }
    }
    Component.onCompleted: {

        updateInvitesModel();
        user.invitesChanged.connect(updateInvitesModel);

    }
    // Properties for customization
        property string list_color: "#ffffff"
        property string border_color: "#dddddd"
        property int border_radius: 10
        property int list_width: parent.width * 0.6
        property int list_height: parent.height
        property bool list_fill_width: true
        property bool list_fill_height: true

        property var customFunctions: [
            {
                text: "Akceptuj",
                action: function(host, port, index) {
                    user.accept_invitation(host, port);
                    inviteModel.remove(index);
                },
                isVisible: true
            },
            {
                text: "Odrzuć",
                action: function(host, port, index) {
                    user.reject_invitation(host, port);
                    inviteModel.remove(index);
                },
                isVisible: true
            }
        ]
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

            ColumnLayout{
                ToolBar {
                    contentHeight: 40
                    z: 1

                    background: Rectangle {
                        color: "transparent"
                    }

                    ToolButton {
                        text: "🔔"
                        font.pixelSize: getDrawerEntrySize(root.width, root.height);
                        onClicked: invitesDrawer.open();
                    }
                }

                // Drawer component to display invites
                    Drawer {
                        id: invitesDrawer
                        width: list_width
                        height: list_height
                        visible: false

                        background: Rectangle {
                            color: list_color
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10
                            anchors.margins: 10

                            Text {
                                text: "Zaproszenia do znajomych"
                                font.pixelSize: 18
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }

                            ListView {
                                id: inviteListView
                                width: parent.width
                                height: parent.height
                                model: inviteModel

                                delegate: Rectangle {
                                    width: parent.width
                                    height: 40
                                    id: inviteRectangle

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: invitePopup.open()
                                        hoverEnabled: true
                                        id: inviteMouseArea

                                        onEntered: {
                                            parent.color = "lightgray"
                                            inviteMouseArea.cursorShape = Qt.PointingHandCursor
                                        }
                                        onExited: {
                                            parent.color = "white"
                                            inviteMouseArea.cursorShape = Qt.ArrowCursor
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Od: " + model.host + ":" + model.port
                                            color: "#000"
                                            font.pixelSize: 14
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Popup {
                                        id: invitePopup
                                        width: parent.width
                                        modal: true
                                        focus: true
                                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                                        property string inviteHost: model.host
                                        property int invitePort: model.port
                                        property int inviteIndex: model.index

                                        ColumnLayout {
                                            spacing: 5
                                            anchors.margins: 10

                                            Repeater {
                                                model: customFunctions.length

                                                Loader {
                                                    active: customFunctions[index].isVisible

                                                    sourceComponent: Button {
                                                        height: 40
                                                        text: customFunctions[index].text

                                                        onClicked: {
                                                            if (typeof customFunctions[index].action === "function") {
                                                                customFunctions[index].action(invitePopup.inviteHost, invitePopup.invitePort, invitePopup.inviteIndex);
                                                            }
                                                            invitePopup.close();
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }


            }
        }
    }

}
