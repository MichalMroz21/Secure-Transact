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

    property string list_color: settings.light_mode ? colorPalette.background50 : colorPalette.background900

    property int list_width: parent.width / 3
    property int list_height: parent.height / 2 * 3

    property bool list_fill_width: true
    property bool list_fill_height: true

    property int border_radius: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, false)
    property int widthPadding: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_sm, root.width, root.height, false)
    property int heightPadding: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_sm, root.width, root.height, true)

    property var customFunctions: new Array(0);

    property bool includeMyself: false

    property var userClicked: function(model, mouseArea, popup) {
        popup.open();
    }

    // Create a ListModel for the users
    ListModel {
        id: userModel
    }

    function updateUserModel() {
        userModel.clear();

        if(includeMyself) {
            userModel.append({
                nickname: user.nickname,
                host: user.host,
                port: user.port,
                active: user.active,
                isInGroup: true,
                isSelected: false,
                activeColor: colorPalette.primary500
            });
        }

        // Iterate over peers array passed from Python
        for (let i = 0; i < user.peers.length; i++) {
            var activeColor = user.peers[i].active > 0 ? colorPalette.primary500 : colorPalette.destructive400
            var colorString = activeColor.toString();

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
                activeColor: colorString
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

    radius: border_radius
    color: settings.light_mode ? colorPalette.background50 : colorPalette.background900

    border.color: settings.light_mode ? colorPalette.primary700 : colorPalette.primary400

    // ListView to display user names and IP addresses
    ListView {
        id: friendListView
        width: parent.width - widthPadding
        height: parent.height - heightPadding
        model: userModel

        anchors.centerIn: parent

        // Fixed height for each user item
        property var userHeight: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_lg, root.width, root.height, true)

        delegate: Rectangle {
            width: parent.width  // Set width explicitly for user list items
            height: friendListView.userHeight
            id: userRectangle
            color: settings.light_mode ? colorPalette.background50 : colorPalette.background900

            MouseArea {
                id: mousearea

                onClicked: userClicked(model, mousearea, popup)
                hoverEnabled: true

                anchors.fill: parent

                onEntered: {
                    model.isSelected === false ? parent.color = (settings.light_mode ? colorPalette.background100 : colorPalette.background700) : null;
                    mousearea.cursorShape = Qt.PointingHandCursor;
                }
                onExited: {
                    model.isSelected === false ? parent.color = (settings.light_mode ? colorPalette.background50 : colorPalette.background900) : null;
                    mousearea.cursorShape = Qt.ArrowCursor
                }

                // Use a single Text element to concatenate the name and IP address
                Text {
                    anchors.centerIn: parent
                    font.pixelSize: fontStyle.getFontSize(fontStyle.display_h3, root.width, root.height)
                    text: '<span style="color: ' + model.activeColor + '; ">' + '▮ ' + ' </span><span style="color: ' + (settings.light_mode ? colorPalette.background600 : colorPalette.primary300) + '; ">' + model.nickname + ' </span>'
                    color: "#000"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    textFormat: Text.RichText
                }
            }

            Popup {
                id: popup
                width: parent.width
                padding: 0
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                background: Rectangle{
                    color: "transparent"
                }

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
                                buttonText: customFunctions[index].text
                                buttonHeight: friendListView.userHeight
                                buttonWidth: popup.width

                                onClickedFunction: function () {
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
