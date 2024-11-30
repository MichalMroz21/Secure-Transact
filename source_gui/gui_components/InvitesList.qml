import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "../small_gui_components"

Item {
    id: invitesList

    property string list_color: "#ffffff"
    property string border_color: "#dddddd"
    property int border_radius: 10
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
        contentHeight: 40
        z: 1

        background: Rectangle {
            color: "transparent"
        }

        ToolButton {
            text: "🔔"
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
            spacing: 10
            anchors.margins: 10

            property int drawerWidth: list_width
            property int drawerHeight: list_height

            Text {
                text: "Friend invites"
                font.pixelSize: 18
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter ^ Qt.AlignTop
            }

            ListView {
                id: inviteListView
                implicitWidth: list_width
                implicitHeight: list_height
                model: inviteModel

                delegate: Rectangle {
                    width: parent.width
                    height: 40
                    id: inviteRectangle

                    MouseArea {
                        anchors.fill: parent
                        onClicked: invitePopup.open()
                        hoverEnabled: true
                        id: inviteMouseArea

                        onEntered: {
                            parent.color = "lightgray"
                            inviteMouseArea.cursorShape = Qt.PointingHandCursor
                        }
                        onExited: {
                            parent.color = "white"
                            inviteMouseArea.cursorShape = Qt.ArrowCursor
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "Od: " + model.host + ":" + model.port
                            color: "#000"
                            font.pixelSize: 14
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

                        property string inviteHost: model.host
                        property int invitePort: model.port
                        property int inviteIndex: model.index

                        ColumnLayout {
                            spacing: 5
                            anchors.margins: 10

                            Repeater {
                                model: customFunctions.length

                                Loader {
                                    active: customFunctions[index].isVisible

                                    sourceComponent: MyButton {
                                        text: customFunctions[index].text
                                        buttonHeight: 40
                                        buttonWidth: invitePopup.width

                                        backgroundColor: "green"

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
