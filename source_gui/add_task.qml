import QtQuick
import QtQuick.Controls 6.8
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "small_gui_components"

Page {
    id: formPage
    property int maxInputWidth: 300
    property int projectIndex: 0

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

        // IP Address Input
        MyTextFieldLabel {
            id: addressTextField
            upText: "Assignee IP Address"
            parentWidth: parent.width
            //parentHeight: 50
        }

        // Port Input
        MyTextFieldLabel {
            id: portTextField
            upText: "Assignee Port"
            parentWidth: parent.width
            //parentHeight: 50
        }
        // Port Input
        MyTextFieldLabel {
            id: priorityTextField
            upText: "Priority"
            parentWidth: parent.width
            //parentHeight: 50
        }
        // Port Input
        MyTextFieldLabel {
            id: dueDateTextField
            upText: " Due Date"
            parentWidth: parent.width
            //parentHeight: 50
        }
        // Port Input
        MyTextFieldLabel {
            id: tagsTextField
            upText: "Tags"
            parentWidth: parent.width
            //parentHeight: 50
        }

        // Buttons Row
        RowLayout {
            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_big, root.width, root.height, false)
            Layout.alignment: Qt.AlignHCenter

            // Accept Button
            MyButton {
                text: "Accept"

                onClicked:{
                    if(addressTextField.downText !== "" && portTextField.downText !== "" && priorityTextField.downText !== "" && dueDateTextField.downText !== "" && tagsTextField.downText !== ""){
                        //na razie tylko samo tworzenie zadania, potem uzupelnie o parametry
                        user.create_a_new_task(formPage.projectIndex, addressTextField.downText, portTextField.downText, priorityTextField.downText, dueDateTextField.downText, tagsTextField.downText);
                        stackView.pop();
                    }
                }
            }
        }
    }
}
