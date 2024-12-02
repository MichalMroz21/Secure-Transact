import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"
import "small_gui_components"

Page {
    property int currentIndex
    property var selectedUsers: new Array(0)
    property var onReturn

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background50 : colorPalette.background900
    }

    Component.onCompleted: {
        root.pageTitleText = "Add users to the project";
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
            userClicked: function(model, mouseArea, popup) {
                let index = selectedUsers.findIndex(u => u.host === model.host && u.port === model.port);

                if (index === -1) {
                    model.isSelected = true;
                    selectedUsers.push(user.find_peer(model.host, model.port));
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
            backgroundColor: "green"
            text: "Add to project"

            onClicked: {
                if (onReturn) {
                    onReturn(selectedUsers);
                }
                stackView.pop();
            }
        }
    }
}
