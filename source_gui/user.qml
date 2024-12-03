import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"
import "small_gui_components"
import "app_style"

Page {
    SpacingObjects { id: spacingObjects }

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

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
        root.pageTitleText = "User profile";
        updateInvitesModel();
        user.invitesChanged.connect(updateInvitesModel);
    }

        RowLayout {
            Layout.preferredHeight: -1
            Layout.preferredWidth: -1
            implicitWidth: parent.width * 2 / 3
            implicitHeight: parent.height * 2 / 3
            anchors.centerIn: parent

            spacing: 0

            ColumnLayout {
                id: formContainer
                Layout.fillWidth: false  // Make it scale horizontally
                Layout.fillHeight: false  // Make it scale vertically
                Layout.preferredWidth: 1 / 2 * parent.width
                Layout.preferredHeight: 256
                Layout.alignment: Qt.AlignTop ^ Qt.AlignHCenter
                spacing: 0

                MyTextFieldLabel {
                    id: usernameTextField
                    upText: "Username"
                    downText: user.nickname
                    parentWidth: parent.width - spacingObjects.spacing_x_big
                }

                MyTextFieldLabel {
                    id: addressTextField
                    upText: "Address"
                    downText: user.host
                    parentWidth: parent.width - spacingObjects.spacing_x_big
                }

                MyTextFieldLabel {
                    id: portTextField
                    upText: "Port"
                    downText: user.port
                    parentWidth: parent.width - spacingObjects.spacing_x_big
                }
            }

            ColumnLayout {
                Layout.fillWidth: true  // Make it scale horizontally
                Layout.fillHeight: true  // Make it scale vertically
                Layout.preferredWidth: 1 / 2 * parent.width
                Layout.preferredHeight: parent.height

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
                    buttonWidth: Math.min(parent.width, 400)
                    Layout.alignment: Qt.AlignBottom
                    text: "Add new user"

                    onClicked: {
                        stackView.push("add_user.qml");
                    }
                }

            }

    }
}
