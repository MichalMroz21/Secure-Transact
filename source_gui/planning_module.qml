import QtQuick
import QtQuick.Controls 2.0
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"
import "small_gui_components"

Page {
    property var usersInProject: new Array(0)

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    RowLayout {
        Layout.preferredHeight: -1
        Layout.preferredWidth: -1
        implicitWidth: parent.width * 2 / 3
        implicitHeight: parent.height * 2 / 3
        anchors.centerIn: parent

        spacing: 0

        ColumnLayout {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.5

            MyButton {
                id: addUserButton
                buttonHeight: 50  // Fixed height for the button
                buttonWidth: 150
                Layout.alignment: Qt.AlignHCenter ^ Qt.AlignVCenter
                text: "Create a new project"

                onClicked: {
                    stackView.push("add_project.qml");
                }
            }
        }

        ColumnLayout{
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width * 0.5
            ProjectList {
                id: projectList
                list_width: parent.width * 2 / 3
                list_fill_width: false
                Layout.alignment: Qt.AlignHCenter


                customFunctions: [
                    {
                        text: "Add user to project",
                        action: function (projectModel) {
                            stackView.push("add_to_project.qml", {
                                       currentIndex: projectModel.index,
                                       onReturn: function(returnedUsers) {
                                            usersInProject = returnedUsers;
                                            console.log("Returned users:", returnedUsers);
                                           user.update_project_users(projectModel.index, returnedUsers);
                                        }
                                   });

                        },
                        isVisible: true
                    }
                ]
            }
        }
    }

}
