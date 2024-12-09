import QtQuick
import QtQuick.Controls 6.8
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "small_gui_components"

Page {
    id: formPage

    property int maxInputWidth: 300
    property int projectIndex: 0

    property QtObject assignee

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    ColumnLayout {
        id: formContainer
        anchors.centerIn: parent
        spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_md, root.width, root.height, true)
        width: Math.min(parent.width / 3, maxInputWidth)
        height: implicitHeight

        scale: Math.min(root.width / formContainer.width, root.height / formContainer.height) / 1.2

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Add new task"
            font.pixelSize: fontStyle.getFontSize(fontStyle.display_large, root.width, root.height)
            color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
        }

        MyTextFieldLabel {
            id: nameTextField
            upText: "Name"
            parentWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
        }

        MyTextFieldLabel {
            id: assigneeTextField
            upText: "Assignee"
            parentWidth: parent.width

            Layout.alignment: Qt.AlignHCenter

            runOnClick: true

            customFunctionClick: function () {
                stackView.push("select_users.qml", {
                    currentIndex: formPage.projectIndex,
                    selectOnlyOne: true,
                    onReturn: function (returnedUser) {
                        formPage.assignee = returnedUser;
                        console.log("Returned user:", returnedUser);
                        assigneeTextField.downText = returnedUser.nickname;
                    }
                });
            }
        }

        MyTextFieldLabel {
            id: priorityTextField
            upText: "Priority"
            parentWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
        }

        MyTextFieldLabel {
            id: dueDateTextField
            upText: "Due Date (YYYY-MM-DD)"
            parentWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
        }

        MyTextFieldLabel {
            id: tagsTextField
            upText: "Tags"
            parentWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
        }

        MyButton {
            buttonText: "Add Task"
            buttonWidth: parent.width

            Layout.alignment: Qt.AlignHCenter

            anchors.top: tagsTextField.bottom
            anchors.topMargin: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_xxx_big, root.width, root.height, true)

            onClickedFunction: function () {
                if(nameTextField.downText !== "" && assigneeTextField.downText !== "" && priorityTextField.downText !== "" && dueDateTextField.downText !== "" && tagsTextField.downText !== ""){
                    user.create_a_new_task(formPage.projectIndex, formPage.assignee, nameTextField.downText, priorityTextField.downText, dueDateTextField.downText, tagsTextField.downText);
                    stackView.push("project_details.qml");
                }
            }
        }
    }
}
