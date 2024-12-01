import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 1.15

import "../small_gui_components"
import "../app_style"

//User (Peer) List Class Blueprint
Rectangle {

    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }
    SpacingObjects { id: spacingObjects }

    //Class Properties (override if needed)
    property string list_color: colorPalette.primary300
    property string border_color: "#dddddd"
    property int border_radius: 10
    property int list_width: parent.width / 3
    property int list_height: parent.height / 2 * 3
    property bool list_fill_width: true
    property bool list_fill_height: true

    property var customFunctions: new Array(0)

    property var userClicked: function(name, tasks, users, mouseArea, popup) {
        popup.open();
    }

    ListModel {
        id: projectModel
    }

    function updateProjectModel() {
        projectModel.clear();

        var projects = user.projects;

        for (let i = 0; i < projects.length; i++) {
            projectModel.append({
                name: projects[i].name,
                //tasks: projects[i].tasks,
                //users: projects[i].users,
                index: i
            });
        }
    }

    Component.onCompleted: {
        updateProjectModel();
        user.projectsChanged.connect(updateProjectModel);
    }

    Layout.fillWidth: list_fill_width
    Layout.fillHeight: list_fill_height
    implicitWidth: list_width
    implicitHeight: list_height
    color: colorPalette.background800
    border.color: colorPalette.primary400
    radius: border_radius

    ListView {
        id: projectListView
        width: parent.width
        height: parent.height
        model: projectModel

        delegate: Rectangle {
            width: parent.width
            height: 40
            id: projectRectangle
            color: colorPalette.background800

            MouseArea {
                anchors.fill: parent
                onClicked: userClicked(model.name, model.tasks, model.users, mousearea, popup)
                hoverEnabled: true
                id: mousearea

                onEntered: {
                    parent.color = colorPalette.background700
                    mousearea.cursorShape = Qt.PointingHandCursor
                }
                onExited: {
                    parent.color = colorPalette.background800
                    mousearea.cursorShape = Qt.ArrowCursor
                }

                Text {
                    anchors.centerIn: parent                 
                    text: '<span style="color: ' + colorPalette.primary300 + '; ">' + model.name + '</span>'
                    color: "#000"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    textFormat: Text.RichText
                }
            }

            Popup {
                id: popup
                width: parent.width
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                property var projectModel: model

                padding: 0

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
                                        customFunctions[index].action(popup.projectModel);
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
