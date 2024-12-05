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
        width: Math.min(parent.width / 3, maxInputWidth)  // Set a maximum width for the form
        height: implicitHeight
        //Layout.preferredHeight: 256

        Text {

            Layout.alignment: Qt.AlignHCenter
            text: "Connect to User"
            font.pixelSize: fontStyle.getFontSize(root.width, root.height)
            color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
        }
        // Assignee Input
        MyTextFieldLabel {
            id: nameTextField
            upText: "Name"
            parentWidth: parent.width
        }
        // Assignee Input
        MyTextFieldLabel {
            id: assigneeTextField
            upText: "Assignee"
            parentWidth: parent.width
            enabled: false
        }
        MyButton{
            text: "Select assignee"
            buttonWidth: parent.width
            onClicked: {
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
        // Priority Input
        MyTextFieldLabel {
            id: priorityTextField
            upText: "Priority"
            parentWidth: parent.width
        }
        // Due Date Input
        MyTextFieldLabel {
            id: dueDateTextField
            upText: "Due Date"
            parentWidth: parent.width
        }
        // Tags Input
        MyTextFieldLabel {
            id: tagsTextField
            upText: "Tags"
            parentWidth: parent.width
        }

        // Buttons Row
        RowLayout {
            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_big, root.width, root.height, false)
            Layout.alignment: Qt.AlignHCenter

            // Accept Button
            MyButton {
                text: "Accept"

                onClicked:{
                    if(nameTextField.downText !== "" && assigneeTextField.downText !== "" && priorityTextField.downText !== "" && dueDateTextField.downText !== "" && tagsTextField.downText !== ""){
                        user.create_a_new_task(formPage.projectIndex, formPage.assignee, nameTextField.downText, priorityTextField.downText, dueDateTextField.downText, tagsTextField.downText);
                        stackView.pop();
                    }
                }
            }
        }
    }
}
