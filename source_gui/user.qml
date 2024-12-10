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
            Layout.preferredWidth: 1 / 2 * parent.width

            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, false)

            property bool isInEdit: false

            ClickableImage {
                sourceImg: "../../assets/edit.png"
                image_width: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, false)
                image_height: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, true)
                customFunction: function() {
                    parent.isInEdit = !parent.isInEdit
                }

                anchors.right: userText.left
                anchors.rightMargin: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_sm, root.width, root.height, false)
                anchors.top: userText.top
                anchors.topMargin: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, true)
            }

            Text {
                id: userText
                Layout.alignment: Qt.AlignHCenter
                text: user.nickname
                font.pixelSize: fontStyle.getFontSize(fontStyle.display_h1, root.width, root.height)
                color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
            }

            ClickableImage {
                sourceImg: "../../assets/clipboard.png"
                image_width:  spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, false)
                image_height:  spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, true)
                customFunction: function() {
                    console.log("Image clicked!")
                }

                anchors.left: userText.right
                anchors.leftMargin: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_sm, root.width, root.height, false)
                anchors.top: userText.top
                anchors.topMargin: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, true)
            }

            MyTextFieldLabel {
                id: usernameTextField
                upText: "Username"
                downText: user.nickname
                parentWidth: parent.width - spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, false)
                isEditable: parent.isInEdit
            }

            MyTextFieldLabel {
                id: addressTextField
                upText: "Address"
                downText: user.host
                parentWidth: parent.width - spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, false)
                isEditable: false
            }

            MyTextFieldLabel {
                id: portTextField
                upText: "Port"
                downText: user.port
                parentWidth: parent.width - spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, false)
                isEditable: false
            }

            MyButton {
                id: changeButton
                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                buttonText: "Save changes"
                visible: parent.isInEdit

                onClickedFunction: function () {
                    user.change_nickname(usernameTextField.downText);
                    user.host = addressTextField.downText;
                    user.port = portTextField.downText;
                }
            }

            Component.onCompleted: {
                function loadNickname(){
                    usernameTextField.downText = user.nickname;
                    userText.text = user.nickname;
                }

                user.nicknameChanged.connect(loadNickname);
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
                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                buttonText: "Add new user"

                onClickedFunction: function () {
                    stackView.push("add_user.qml");
                }
            }
        }
    }
}
