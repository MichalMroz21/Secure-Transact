import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 1.15

import "../small_gui_components"
import "../app_style"

//User (Peer) List Class Blueprint
Rectangle {
    //Class Properties (override if needed)
    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }
    SpacingObjects { id: spacingObjects }

    property string list_color: settings.light_mode ? colorPalette.background50 : colorPalette.background800
    property string border_color: "#dddddd"
    property int border_radius: 10
    property int list_width: parent.width / 3
    property int list_height: parent.height / 2 * 3
    property bool list_fill_width: true
    property bool list_fill_height: true
    property string active_color: "#00FF00"
    property int widthPadding: 6
    property int heightPadding: 6

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
            var activeColor = user.peers[i].active > 0 ? colorPalette.primary500 : colorPalette.destructive400
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
    implicitWidth: list_width
    implicitHeight: list_height
    color: settings.light_mode ? colorPalette.background50 : colorPalette.background800
    border.color: settings.light_mode ? colorPalette.primary700 : colorPalette.primary400
    radius: border_radius

    // ListView to display user names and IP addresses
    ListView {

        id: friendListView
        width: parent.width - widthPadding
        height: parent.height - heightPadding
        anchors.centerIn: parent
        model: userModel

        delegate: Rectangle {
            width: parent.width  // Set width explicitly for user list items
            height: 40  // Fixed height for each user item
            id: userRectangle
            color: settings.light_mode ? colorPalette.background50 : colorPalette.background800

            MouseArea {
                id: mousearea
                anchors.fill: parent
                onClicked: userClicked(model, mousearea, popup)
                hoverEnabled: true

                onEntered: {
                    model.isSelected === false ? parent.color = (settings.light_mode ? colorPalette.background100 : colorPalette.background700) : null;
                    mousearea.cursorShape = Qt.PointingHandCursor;
                }
                onExited: {
                    model.isSelected === false ? parent.color = (settings.light_mode ? colorPalette.background50 : colorPalette.background800) : null;
                    mousearea.cursorShape = Qt.ArrowCursor
                }

                // Use a single Text element to concatenate the name and IP address
                Text {
                    anchors.centerIn: parent  // Center the text within the parent
                    text: '<span style="color: ' + model.activeColor + '; ">' + '▮ ' + ' </span><span style="color: ' + (settings.light_mode ? colorPalette.background600 : colorPalette.primary300) + '; ">' + model.nickname + ' </span>'
                    //<span style="color: gray; "><i>(' + model.host + ":" + model.port + ')</i></span>
                    color: "#000"
                    font.pixelSize: fontStyle.getFontSize(root.width, root.height)
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

                background: Rectangle{
                    color: "transparent"
                }

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
