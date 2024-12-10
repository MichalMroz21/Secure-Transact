import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"
import "small_gui_components"

Page {
    id: selectUsersPage

    property int currentIndex
    property var selectedUsers: new Array(0)
    property var onReturn
    property bool selectOnlyOne: false
    property bool includeOwner: true

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    ColumnLayout {
        id: formContainer
        width: parent.width
        height: parent.height

        scale: Math.min(root.width / formContainer.width, root.height / formContainer.height) / 1.2

        anchors.centerIn: parent

        FriendList {
            id: friendList
            list_height: parent.height - addUserButton.height
            list_fill_width: false
            includeMyself: selectUsersPage.includeOwner

            anchors.horizontalCenter: parent.horizontalCenter

            userClicked: function(model, mouseArea, popup) {
                let index = selectedUsers.findIndex(u => u.host === model.host && u.port === model.port);

                if (index === -1) {
                    model.isSelected = true;
                    console.log(model.host + ":" + model.port);
                    selectedUsers.push(user.find_peer(model.host, model.port, true));
                    console.log(selectedUsers);
                    mouseArea.parent.color = colorPalette.primary400;
                    mouseArea.parent.opacity = 0.5;

                }
                else {
                    selectedUsers.splice(index, 1);
                    model.isSelected = false;
                    mouseArea.parent.color = (settings.light_mode ? colorPalette.background50 : colorPalette.background900);
                    mouseArea.parent.opacity = 1;
                }
            }
        }

        MyButton {
            id: addUserButton

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom  // Position the button at the bottom of the parent

            buttonText: "Continue"

            onClickedFunction: function () {
                if (onReturn) {
                    if (!selectUsersPage.selectOnlyOne) {
                        onReturn(selectedUsers);
                    }
                    else{
                        onReturn(selectedUsers[0]);
                    }
                }
                stackView.pop();
            }
        }
    }
}
