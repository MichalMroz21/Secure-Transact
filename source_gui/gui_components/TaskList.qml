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

    property var userClicked: function(popupIndex, assigness, due_date, priority, status, comments, name, tags, mouseArea, popup) {
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

            RowLayout {
                width: parent.width
                spacing: 0

                anchors.centerIn: parent

                ColumnLayout {
                    Layout.alignment: Qt.AlignLeft

                    Layout.minimumWidth: parent.width / 2
                    Layout.maximumWidth: parent.width / 2

                    Text {
                        Layout.alignment: Qt.AlignLeft

                        id: projectName
                        text: '<span style="color: ' + (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) + '; ">' + model.name + '</span>'
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        textFormat: Text.RichText

                        font.pixelSize: fontStyle.getFontSize(root.width, root.height)
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignLeft

                    Layout.minimumWidth: parent.width / 2
                    Layout.maximumWidth: parent.width / 2

                    Text {
                        Layout.alignment: Qt.AlignLeft
                        id: projectName
                        text: '<span style="color: ' + (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) + '; ">' + model.assignee.nickname + '</span>'
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        textFormat: Text.RichText

                        font.pixelSize: fontStyle.getFontSize(root.width, root.height)
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter

                    Layout.minimumWidth: parent.width / 4
                    Layout.maximumWidth: parent.width / 4

                    Text {
                        Layout.alignment: Qt.AlignRight
                        id: usersNumberName
                        text: '<span style="color: ' + (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) + '; ">' + model.due_date + '</span>'
                        textFormat: Text.RichText
                    }
                }

                ColumnLayout {
                    Layout.minimumWidth: parent.width / 4
                    Layout.maximumWidth: parent.width / 4

                    Text {
                        Layout.alignment: Qt.AlignRight
                        id: tasksNumberName
                        text: '<span style="color: ' + (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) + '; ">' + model.tags[0] + '</span>'
                        textFormat: Text.RichText
                    }
                }

                ColumnLayout {
                    Layout.minimumWidth: parent.width / 4
                    Layout.maximumWidth: parent.width / 4

                    Text {
                        Layout.alignment: Qt.AlignRight
                        id: tasksNumberName
                        text: '<span style="color: ' + (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) + '; ">' + model.priority + '</span>'
                        textFormat: Text.RichText
                    }
                }

                ColumnLayout {
                    Layout.minimumWidth: parent.width / 4
                    Layout.maximumWidth: parent.width / 4

                    Text {
                        Layout.alignment: Qt.AlignRight
                        id: tasksNumberName
                        text: '<span style="color: ' + (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) + '; ">' + model.status + '</span>'
                        textFormat: Text.RichText
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
