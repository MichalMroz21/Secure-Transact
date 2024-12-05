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

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        FriendList {
            id: friendList
            anchors.horizontalCenter: parent.horizontalCenter

            list_height: parent.height - addUserButton.height
            list_fill_width: false
            includeMyself: true
            userClicked: function(model, mouseArea, popup) {
                let index = selectedUsers.findIndex(u => u.host === model.host && u.port === model.port);

                if (index === -1) {
                    model.isSelected = true;
                    console.log(model.host + ":" + model.port);
                    selectedUsers.push(user.find_peer(model.host, model.port, true));
                    console.log(selectedUsers);
                    mouseArea.parent.color = "lightblue";

                }
                else {
                    selectedUsers.splice(index, 1);
                    model.isSelected = false;
                    mouseArea.parent.color = "white";
                }
            }
        }

        MyButton {
            id: addUserButton
            buttonHeight: 50  // Fixed height for the button
            buttonWidth: friendList.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom  // Position the button at the bottom of the parent
            text: "Continue"

            onClicked: {
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
