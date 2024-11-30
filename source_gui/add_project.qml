import QtQuick
import QtQuick.Controls 6.8
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "small_gui_components"

Page {
    id: formPage
    property int maxInputWidth: 300
    property var usersInProject: new Array(0)
    property int index: 0

    Component.onCompleted: {
        root.pageTitleText = "Create a new project";
    }

    ColumnLayout {
        id: formContainer
        anchors.centerIn: parent
        spacing: 15
        width: Math.min(parent.width / 3, maxInputWidth)  // Set a maximum width for the form
        height: implicitHeight

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "New project info"
            font.pixelSize: 20
            color: "black"
        }

        // Project name Input
        TextField {
            id: projectNameField
            placeholderText: "Project name"
            font.pixelSize: 16
            height: 40
            Layout.fillWidth: true
            Layout.maximumWidth: maxInputWidth  // Set a maximum width for the input
            background: Rectangle {
                color: "#ffffff"
                border.color: "#ccc"
                radius: 5
            }
        }
        RowLayout{
            Text{
                id: usersText
                text: "Users: "
                font.pixelSize: 16
                height: 40
                Layout.fillWidth: true
                Layout.maximumWidth: maxInputWidth  // Set a maximum width for the input
            }
            MyButton {
                id: addUserButton
                buttonHeight: 50  // Fixed height for the button
                buttonWidth: 100
                Layout.alignment: Qt.AlignBottom
                backgroundColor: "green"
                text: "Add new user"

                onClicked: {
                    index = user.projects.length
                    stackView.push("add_to_project.qml", {
                                       currentIndex: index,
                                       onReturn: function(returnedUsers) {
                                           root.pageTitleText = "Create a new project";
                                            usersInProject = returnedUsers;
                                            console.log("Returned users:", returnedUsers);
                                        }
                                   });
                }
            }

        }

        // Buttons Row
        RowLayout {
            spacing: 20
            Layout.alignment: Qt.AlignHCenter

            // Accept Button
            Button {
                text: "Accept"
                font.pixelSize: 16
                width: 100
                height: 40
                background: Rectangle {
                    color: "green"
                    radius: 5
                }
                contentItem: Text {
                    text: "Accept"
                    color: "white"
                    font.pixelSize: 16
                    anchors.centerIn: parent
                }
                onClicked:{
                    if(projectNameField.text !== ""){
                        user.add_new_project_from_FE(projectNameField.text, usersInProject);
                        stackView.push("chat_module.qml");
                    }
                }
            }

            // Cancel Button
            Button {
                text: "Cancel"
                font.pixelSize: 16
                width: 100
                height: 40
                background: Rectangle {
                    color: "red"
                    radius: 5
                }
                contentItem: Text {
                    text: "Cancel"
                    color: "white"
                    font.pixelSize: 16
                    anchors.centerIn: parent
                }
                onClicked: {
                    root.pageTitleText = "Planning";
                    stackView.pop();
                }
            }
        }
    }
}
