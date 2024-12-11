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

    property int list_width: parent.width - 2 * spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_huge, root.width, root.height, false)
    property int list_height: parent.height / 1.3

    property int border_radius: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_sm, root.width, root.height, false)
    property int widthPadding: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_sm, root.width, root.height, false)
    property int heightPadding: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_sm, root.width, root.height, true)

    property bool list_fill_width: true
    property bool list_fill_height: false

    property var customFunctions: new Array(0)

    property var userClicked: function(popupIndex, assigness, due_date, priority, status, comments, name, tags, mouseArea, popup) {
        popup.open();
    }

    property int currentIndex

    ListModel {
        dynamicRoles:true
        id: taskModel
    }

    function updateTaskModel(project) {
        taskModel.clear();

        var tasks = project.tasks;

        taskModel.append({
            assignee: "Assignee",
            due_date: "Due Date",
            priority: "Priority",
            status: "Status",
            name: "Name",
            tags: "Tags",
            first_element: true
        });

        for (let i = 0; i < tasks.length; i++) {
            let task = tasks[i];

            taskModel.append({
                assignee: task.assignee,
                due_date: task.due_date,
                priority: task.priority,
                status: task.status,
                name: task.name,
                tags: task.tags,
                first_element: false
            });
        }
    }

    function getProjectData() {
        return updateTaskModel(user.projects[taskList.currentIndex]);
    }


    Component.onCompleted: {
        user.check_project_index(taskList.currentIndex) ? getProjectData() : null;
        user.projectsChanged.connect(getProjectData);
    }

    Layout.fillWidth: list_fill_width
    Layout.fillHeight: list_fill_height

    implicitWidth: list_width
    implicitHeight: list_height

    anchors.centerIn: parent

    radius: border_radius
    color: settings.light_mode ? colorPalette.background50 : colorPalette.background900

    border.color: settings.light_mode ? colorPalette.primary700 : colorPalette.primary400

    Rectangle {
        id: separatorLine

        height: parent.height / 5
        width: parent.width

        color: parent.color
        border.color: parent.border.color

        MyButton {
            id: addNewTaskButton
            buttonText: "Add new task"

            widthHeightScale: 4

            anchors.right: parent.right
            anchors.rightMargin: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_xx_big, root.width, root.height, false)

            anchors.verticalCenter: separatorLine.verticalCenter

            onClickedFunction: function () {
                stackView.push("../add_task.qml", {projectIndex: taskList.currentIndex});
            }
        }

        z: 2 //yes, to be able to click
    }

    ListView {
        id: taskListView
        width: parent.width
        height: parent.height
        model: taskModel

        //HAS TO BE CONSTANT HERE
        property var taskHeight: spacingObjects.spacing_x_lg

        anchors.top: separatorLine.bottom

        delegate: Rectangle {
            width: taskListView.width - taskList.border.width * 2
            height: taskListView.taskHeight
            id: taskRectangle
            color: settings.light_mode ? colorPalette.background50 : colorPalette.background900

            anchors.horizontalCenter: parent.horizontalCenter

            CustomBorder {
                commonBorder: false
                lBorderwidth: taskList.border.width
                rBorderwidth: taskList.border.width
                tBorderwidth: model.first_element ? 0 : taskList.border.width
                bBorderwidth: taskList.border.width
                borderColor: taskList.border.color
            }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                height: taskListView.taskHeight
                width: parent.width * 0.9
                spacing: 0

                TaskElementInfo {
                    rect_width: parent.width / 6
                    rect_height: parent.height
                    img_source: "../../assets/project.png"
                    txt_color: (settings.light_mode ? colorPalette.primary600 : colorPalette.primary700)
                    txt: model.name
                    displayImg: model.first_element
                }

                TaskElementInfo {
                    rect_width: parent.width / 6
                    rect_height: parent.height
                    img_source: "../../assets/user2.png"
                    txt_color: (settings.light_mode ? colorPalette.primary600 : colorPalette.primary700)
                    txt: model.first_element ? model.assignee : model.assignee.host + ":" + model.assignee.port
                    displayImg: model.first_element
                }

                TaskElementInfo {
                    rect_width: parent.width / 6
                    rect_height: parent.height
                    img_source: "../../assets/calendar.png"
                    txt_color: (settings.light_mode ? colorPalette.primary600 : colorPalette.primary700)
                    txt: model.due_date
                    displayImg: model.first_element
                }

                TaskElementInfo {
                    rect_width: parent.width / 6
                    rect_height: parent.height
                    img_source: "../../assets/tag.png"
                    txt_color: (settings.light_mode ? colorPalette.primary600 : colorPalette.primary700)
                    txt: model.first_element ? model.tags : getTags(model.tags)
                    displayImg: model.first_element
                }

                TaskElementInfo {
                    rect_width: parent.width / 6
                    rect_height: parent.height
                    img_source: "../../assets/flag.png"
                    txt_color: (settings.light_mode ? colorPalette.primary600 : colorPalette.primary700)
                    txt: model.priority
                    displayImg: model.first_element
                }

                TaskElementInfo {
                    rect_width: parent.width / 6
                    rect_height: parent.height
                    img_source: "../../assets/clock.png"
                    txt_color: (settings.light_mode ? colorPalette.primary600 : colorPalette.primary700)
                    txt: model.status
                    displayImg: model.first_element
                }
            }
        }
    }

    function getTags(tags) {
        return tags.join(", ");
    }
}
