import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"

Page {
    property int currentIndex
    property var selectedUsers: new Array(0)

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        FriendList {
            id: friendList
            anchors.horizontalCenter: parent.horizontalCenter

            list_height: parent.height - addProjectButton.height
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

        // Add New User Button
        Rectangle {
            id: addProjectButton
            width: friendList.width

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom  // Position the button at the bottom of the parent

            height: 50  // Fixed height for the button
            color: "green"

            MouseArea {
                id: addButton
                anchors.fill: parent
                onClicked: {
                    console.log(selectedUsers);
                    for(let i = 0; i < selectedUsers.length; i++) {
                        console.log(selectedUsers[i]);
                        user.projects[currentIndex].add_user(selectedUsers[i]);
                    }
                    stackView.pop();
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
                    text: "Add to project"
                    color: "white"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
