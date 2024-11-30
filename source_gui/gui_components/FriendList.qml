import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 1.15

import "../small_gui_components"

//User (Peer) List Class Blueprint
Rectangle {
    //Class Properties (override if needed)
    property string list_color: "#ffffff"
    property string border_color: "#dddddd"
    property int border_radius: 10
    property int list_width: parent.width / 3
    property int list_height: parent.height / 2 * 3
    property bool list_fill_width: true
    property bool list_fill_height: true
    property string active_color: "#00FF00"

    property var customFunctions: new Array(0);

    property var userClicked: function(model, mouseArea, popup) {
        popup.open();
    }

    // Create a ListModel for the users
    ListModel {
        id: userModel
    }

    function updateUserModel() {
        userModel.clear();

        // Iterate over peers array passed from Python
        for (let i = 0; i < user.peers.length; i++) {
            var activeColor = user.peers[i].active > 0 ? "#00FF00" : "#FF0000"
            var isInGroup = false;
            var isSelected = false;
            var host = user.peers[i].host;
            var port = user.peers[i].port;

            for (let j = 0; j < user.group.length; j++) {
                if (host === user.group[j].host && port === user.group[j].port) {
                    isInGroup = true;
                    break;
                }
            }

            userModel.append({
                nickname: user.peers[i].nickname,
                host: host,
                port: port,
                active: user.peers[i].active,
                isInGroup: isInGroup,
                isSelected: isSelected,
                activeColor: activeColor
            });
        }
    }

    Component.onCompleted: {
        updateUserModel();

        user.peersChanged.connect(updateUserModel);
        user.nicknameChanged.connect(updateUserModel);
        user.activeChanged.connect(updateUserModel);
    }

    Layout.fillWidth: list_fill_width  // Make it scale horizontally
    Layout.fillHeight: list_fill_height  // Make it scale vertically
    width: list_width
    height: list_height
    color: list_color
    border.color: border_color
    radius: border_radius

    // ListView to display user names and IP addresses
    ListView {
        id: friendListView
        width: parent.width
        height: parent.height
        model: userModel

        delegate: Rectangle {
            width: parent.width  // Set width explicitly for user list items
            height: 40  // Fixed height for each user item
            id: userRectangle

            MouseArea {
                id: mousearea
                anchors.fill: parent
                onClicked: userClicked(model, mousearea, popup)
                hoverEnabled: true

                onEntered: {
                    model.isSelected === false ? parent.color = "lightgray" : null;
                    mousearea.cursorShape = Qt.PointingHandCursor;
                }
                onExited: {
                    model.isSelected === false ? parent.color = "white" : null;
                    mousearea.cursorShape = Qt.ArrowCursor
                }

                // Use a single Text element to concatenate the name and IP address
                Text {
                    anchors.centerIn: parent  // Center the text within the parent
                    text: '<span style="color: ' + model.activeColor + '; ">' + '▮ ' + ' </span><span style="color: black; ">' + model.nickname + ' </span><span style="color: gray; "><i>(' + model.host + ":" + model.port + ')</i></span>'
                    color: "#000"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter  // Center horizontally
                    verticalAlignment: Text.AlignVCenter  // Center vertically
                    textFormat: Text.RichText  // Enable HTML formatting
                }
            }

            Popup {
                id: popup
                width: parent.width
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                padding: 0

                property var myModel: model
                property var myMouseArea: mousearea
                property var myPopup: popup
                property var myhost: model.host
                property var myport: model.port
                property var mynickname: model.nickname
                property var myisInGroup: model.isInGroup
                property var myActive: model.active

                ColumnLayout {

                    Repeater {
                        model: customFunctions.length

                        Loader {
                            active: customFunctions[index].isVisible

                            sourceComponent: MyButton {
                                text: customFunctions[index].text
                                buttonHeight: 40
                                buttonWidth: popup.width

                                backgroundColor: "green"

                                onClicked: {
                                    if (typeof customFunctions[index].action === "function") {
                                        customFunctions[index].action(popup.myModel, popup.mouseArea, popup.myPopup);
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
