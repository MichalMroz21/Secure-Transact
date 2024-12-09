import QtQuick
import QtQuick.Controls 6.8
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "small_gui_components"
import "app_style"

Page {
    id: formPage

    property int maxInputWidth: 300
    property var usersInProject: new Array(0)
    property int index: 0

    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }
    SpacingObjects { id: spacingObjects }

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    width: root.width
    height: root.height

    ColumnLayout {
        id: formContainer
        spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_lg, root.width, root.height, true)
        implicitWidth: parent.width / 2
        implicitHeight: parent.height

        anchors.centerIn: parent

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "<font color=\""+ (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) +"\">New project info</font>"
            font.pixelSize: fontStyle.getFontSize(fontStyle.display_h3, root.width, root.height)
            color: "black"
        }

        MyTextFieldLabel{
            Layout.alignment: Qt.AlignHCenter
            id: projectNameField
            upText: "Project name"
            parentWidth: parent.width - spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, false)
        }

        // Buttons Row
        RowLayout {
            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_big, root.width, root.height, false)
            Layout.alignment: Qt.AlignHCenter

            MyButton {
                Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                buttonText: "Create project"

                onClickedFunction: function () {
                    if(projectNameField.text !== ""){
                        user.add_new_project_from_FE(projectNameField.downText, usersInProject);
                        stackView.push("chat_module.qml");
                    }
                }
            }
        }
    }
}
