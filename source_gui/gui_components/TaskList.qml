import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 1.15

import "../small_gui_components"
import "../app_style"

//Task List Class Blueprint
Rectangle {
    id: taskList

    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }
    SpacingObjects { id: spacingObjects }

    //Class Properties (override if needed)
    property color list_color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300

    property int list_width: parent.width / 3
    property int list_height: parent.height / 2 * 3

    property int border_radius: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, false)
    property int widthPadding: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_sm, root.width, root.height, false)
    property int heightPadding: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_sm, root.width, root.height, true)

    property bool list_fill_width: true
    property bool list_fill_height: true

    property var customFunctions: new Array(0)

    property var userClicked: function(name, tasks, users, mouseArea, popup) {
        popup.open();
    }

    property int currentIndex

    ListModel {
        id: taskModel
    }

    function updateTaskModel(project) {
        taskModel.clear();

        var tasks = project.tasks;

        for (let i = 0; i < tasks.length; i++) {
            let task = tasks[i];

            taskModel.append({
                assignees = task.assignees,
                due_date = task.due_date,
                priority = task.priority,
                status = task.status,
                comments = task.comments,
                name = task.name,
                tags = task.tags
            });
        }
    }

    function getProjectData(index) {
        return user.get_project(index);
    }

    Component.onCompleted: {
        updateTaskModel(getProjectData(taskList.currentIndex));
    }

    Layout.fillWidth: list_fill_width
    Layout.fillHeight: list_fill_height

    implicitWidth: list_width
    implicitHeight: list_height

    radius: border_radius
    color: settings.light_mode ? colorPalette.background50 : colorPalette.background800

    border.color: settings.light_mode ? colorPalette.primary700 : colorPalette.primary400

    ListView {
        id: taskListView
        width: parent.width - widthPadding
        height: parent.height - heightPadding
        model: taskModel

        anchors.centerIn: parent

        property var taskHeight: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_lg, root.width, root.height, true)

        delegate: Rectangle {
            width: parent.width
            height: taskListView.taskHeight
            id: taskRectangle
            color: settings.light_mode ? colorPalette.background50 : colorPalette.background800

            MouseArea {
                onClicked: userClicked(model.name, model.tasks, model.users, mousearea, popup)
                hoverEnabled: true
                id: mousearea

                anchors.fill: parent

                onEntered: {
                    parent.color = settings.light_mode ? colorPalette.background100 : colorPalette.background700
                    mousearea.cursorShape = Qt.PointingHandCursor
                }

                onExited: {
                    parent.color = settings.light_mode ? colorPalette.background50 : colorPalette.background800
                    mousearea.cursorShape = Qt.ArrowCursor
                }

                RowLayout {
                    width: parent.width
                    anchors.centerIn: parent
                    spacing: 0

                    ColumnLayout {
                        Layout.alignment: Qt.AlignLeft
                        Layout.minimumWidth: parent.width / 2
                        Layout.maximumWidth: parent.width / 2

                        Text {
                            Layout.alignment: Qt.AlignLeft
                            id: projectName
                            text: '<span style="color: ' + (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) + '; ">' + model.name + '</span>'
                            font.pixelSize: fontStyle.getFontSize(root.width, root.height)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            textFormat: Text.RichText
                        }
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.minimumWidth: parent.width / 4
                        Layout.maximumWidth: parent.width / 4

                        Text {
                            Layout.alignment: Qt.AlignRight
                            id: usersNumberName
                            text: '<span style="color: ' + (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) + '; ">' + model.usersNumber + '</span>'
                            textFormat: Text.RichText
                        }
                    }

                    ColumnLayout {
                        Layout.minimumWidth: parent.width / 4
                        Layout.maximumWidth: parent.width / 4

                        Text {
                            Layout.alignment: Qt.AlignRight
                            id: tasksNumberName
                            text: '<span style="color: ' + (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) + '; ">' + model.inProgressTasksNumber + "/" + model.totalTasksNumber + '</span>'
                            textFormat: Text.RichText
                        }
                    }
                }
            }

            Popup {
                id: popup
                width: parent.width
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                padding: 0

                property var projectModel: model

                background: Rectangle{
                    color: "transparent"
                }

                ColumnLayout {
                    Repeater {
                        model: customFunctions.length

                        Loader {
                            active: customFunctions[index].isVisible

                            sourceComponent: MyButton {
                                text: customFunctions[index].text
                                buttonHeight: projectListView.projectHeight
                                buttonWidth: popup.width

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
