import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"
import "small_gui_components"

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

    Rectangle {
        width: parent.width / 1.5
        height: parent.height / 1.5
        color: "#f0f0f0"
        radius: 10
        anchors.centerIn: parent

        RowLayout {
            id: rowLayout
            anchors.fill: parent
            spacing: 10

            ColumnLayout {
                id: formContainer
                Layout.fillWidth: true  // Make it scale horizontally
                Layout.fillHeight: true  // Make it scale vertically
                Layout.preferredWidth: 1 / 2

                RowLayout{
                    Layout.alignment: Qt.AlignHCenter
                    Layout.minimumWidth: parent.width * 1 / 2

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
                    Layout.minimumWidth: parent.width * 1 / 2

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
                Layout.fillWidth: true  // Make it scale horizontally
                Layout.fillHeight: true  // Make it scale vertically
                Layout.preferredWidth: 1 / 2


                FriendList {
                    id: friendList
                    list_height: parent.height - addUserButton.height
                    list_width: Math.min(parent.width, 400)

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

                MyButton {
                    id: addUserButton
                    buttonHeight: 50  // Fixed height for the button
                    buttonWidth: friendList.width
                    Layout.alignment: Qt.AlignBottom
                    backgroundColor: "green"
                    text: "Add new user"

                    onClicked: {
                        stackView.push("add_user.qml");
                    }
                }
            }
        }
    }
}
