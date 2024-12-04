import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"
import "small_gui_components"
import "app_style"

Page {
    id: projectDetailsPage

    SpacingObjects { id: spacingObjects }

    property int currentIndex

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    RowLayout {
        Layout.preferredHeight: -1
        Layout.preferredWidth: -1

        implicitWidth: parent.width * 2 / 3
        implicitHeight: parent.height * 1 / 6

        anchors.centerIn: parent

        spacing: 0

        ColumnLayout{
            implicitWidth: parent.width / 2
            implicitHeight: parent.height
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Text{
                id: projectNameText
                text: "<font color=\""+ (settings.light_mode ? colorPalette.primary600 : colorPalette.primary300) +"\">" + projectDetailsPage.projectName +"</font>"
            }
        }
        ColumnLayout{
            implicitWidth: parent.width / 4
            implicitHeight: parent.height
            MyButton{
                id: addNewTaskButton
                text: "Add a new task"
                onClicked: {
                    stackView.push("add_task.qml", {projectIndex: projectDetailsPage.currentIndex});
                }
            }
        }
        ColumnLayout{
            implicitWidth: parent.width / 4
            implicitHeight: parent.height
            MyButton{
                buttonWidth: 20
                buttonHeight: 20
                id: placeHolderButton
                text: "⁝"
                onClicked: {
                    console.log("Here will be an another silly button. Hurray :D")
                }
            }
        }

    }
    RowLayout {
        Layout.preferredHeight: -1
        Layout.preferredWidth: -1
        implicitWidth: parent.width * 2 / 3
        implicitHeight: parent.height * 5 / 6
        anchors.centerIn: parent

        spacing: 0

    }
}
