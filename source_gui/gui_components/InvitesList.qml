import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "../small_gui_components"
import "../app_style"

Item {
    id: invitesList

    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }
    SpacingObjects { id: spacingObjects }

    property color list_color: settings.light_mode ? colorPalette.background50 : colorPalette.background800
    property color title_color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300

    property int border_radius: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, false)

    property int list_width: parent.width * 0.6
    property int list_height: parent.height / 2 * 3

    property bool list_fill_width: true
    property bool list_fill_height: true

    property var customFunctions: new Array(0)

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

    ToolBar {
        id: invitesToolbar
        contentHeight: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_lg, root.width, root.height, true)
        z: 1

        background: Rectangle {
            color: "transparent"
        }

        ToolButton {
            text: "<font color=\""+ colorPalette.primary50 + "\">🔔</font>"
            font.pixelSize: getDrawerEntrySize(root.width, root.height);
            onClicked: invitesDrawer.open();
        }
    }

    // Drawer component to display invites
    Drawer {
        id: invitesDrawer
        width: list_width
        height: list_height
        visible: false
        edge: Qt.RightEdge

        background: Rectangle {
            color: list_color
        }

        ColumnLayout {
            id: column

            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width

            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, true)
            anchors.margins: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, true)

            property int drawerWidth: list_width
            property int drawerHeight: list_height

            Text {
                text: "<font color=\""+ invitesList.title_color +"\">Friend invites</font>"

                font.pixelSize: fontStyle.getFontSize(root.width, root.height)
                font.bold: true

                horizontalAlignment: Text.AlignHCenter

                Layout.alignment: Qt.AlignHCenter ^ Qt.AlignTop
            }

            ListView {
                id: inviteListView
                implicitWidth: list_width
                implicitHeight: list_height
                model: inviteModel

                property var inviteHeight: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_lg, root.width, root.height, true)

                delegate: Rectangle {
                    width: parent.width
                    height: inviteListView.inviteHeight
                    id: inviteRectangle
                    color: settings.light_mode ? colorPalette.background50 : colorPalette.background800

                    MouseArea {
                        id: inviteMouseArea
                        onClicked: invitePopup.open()
                        hoverEnabled: true

                        anchors.fill: parent

                        onEntered: {
                            parent.color = settings.light_mode ? colorPalette.background100 : colorPalette.background700
                            inviteMouseArea.cursorShape = Qt.PointingHandCursor
                        }

                        onExited: {
                            parent.color = settings.light_mode ? colorPalette.background50 : colorPalette.background800
                            inviteMouseArea.cursorShape = Qt.ArrowCursor
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "<font color=\""+ (settings.light_mode ? colorPalette.primary700 : colorPalette.primary400) +"\">From: </font><font color=\""+ (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) +"\">" + model.host + ":" + model.port + " </font>"
                            color: "#000"
                            font.pixelSize: fontStyle.getFontSize(root.width, root.height)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Popup {
                        id: invitePopup
                        width: parent.width
                        modal: true
                        focus: true
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                        background: Rectangle{
                            color: settings.light_mode ? colorPalette.background50 : colorPalette.background800
                        }

                        property string inviteHost: model.host

                        property int invitePort: model.port
                        property int inviteIndex: model.index

                        ColumnLayout {
                            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_xx_sm, root.width, root.height, true)
                            anchors.margins: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, true)

                            Repeater {
                                model: customFunctions.length

                                Loader {
                                    active: customFunctions[index].isVisible

                                    sourceComponent: MyButton {
                                        text: customFunctions[index].text
                                        buttonHeight: inviteListView.inviteHeight
                                        buttonWidth: invitePopup.width

                                        onClicked: {
                                            if (typeof customFunctions[index].action === "function") {
                                                customFunctions[index].action(invitePopup.inviteHost, invitePopup.invitePort,
                                                    invitePopup.inviteIndex, inviteModel);
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
    }
}
