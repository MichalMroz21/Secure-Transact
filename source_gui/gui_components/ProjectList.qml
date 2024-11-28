import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 1.15

//1. Wyjebać Peery, ma byc tylko User
//Historie friendów, projektów itd
//polaczenie page user.qml + friends.qml, zeby bylo kontentu wiecej na jednej stronie
//Dodanie w options.qml ostrzezenia, ze jak ktos nas dodaje to ze chcemy zaakceptowac
//Dodanie wizualii bycia online (znaczek online (zielony, szary))
//Zrobienie listy tasków obok listy Projektów w planning_module.qml

//User (Peer) List Class Blueprint
Rectangle {
    //Class Properties (override if needed)
    property string list_color: "#ffffff"
    property string border_color: "#dddddd"
    property int border_radius: 10
    property int list_width: parent.width / 3
    property int list_height: parent.height
    property bool list_fill_width: true
    property bool list_fill_height: true

    property var customFunctions: new Array(0);
    property var userClicked: function(name, tasks, users, mouseArea, popup) {
        popup.open();
    }

    // Create a ListModel for the users
    ListModel {
        id: projectModel
    }

    function updateProjectModel() {
        projectModel.clear();

        var projects = user.projects;

        // Iterate over peers array passed from Python
        for (let i = 0; i < projects.length; i++) {
            projectModel.append({
                name: projects[i].name,
                tasks: projects[i].tasks,
                users: projects[i].users,
                index: i
            });
        }
    }

    Component.onCompleted: {
        updateProjectModel();
        user.projectsChanged.connect(updateProjectModel);
    }

    Layout.fillWidth: list_fill_width  // Make it scale horizontally
    Layout.fillHeight: list_fill_height  // Make it scale vertically
    width: list_width
    height: list_height
    color: list_color
    border.color: border_color
    radius: border_radius

    // ListView to display user names and IP addresses
    ListView {
        id: projectListView
        width: parent.width
        height: parent.height
        model: projectModel

        delegate: Rectangle {
            width: parent.width  // Set width explicitly for user list items
            height: 40  // Fixed height for each user item
            id: userRectangle

            MouseArea {
                anchors.fill: parent
                onClicked: userClicked(model.name, model.tasks, model.users, mousearea, popup)
                hoverEnabled: true
                id: mousearea

                onEntered: {
                    parent.color = "lightgray"
                    mousearea.cursorShape = Qt.PointingHandCursor
                }
                onExited: {
                    parent.color = "white"
                    mousearea.cursorShape = Qt.ArrowCursor
                }

                // Use a single Text element to concatenate the name and IP address
                Text {
                    anchors.centerIn: parent  // Center the text within the parent
                    text: '<span style="color: black; ">' + model.name + '</span>'
                    color: "#000"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter  // Center horizontally
                    verticalAlignment: Text.AlignVCenter  // Center vertically
                    textFormat: Text.RichText  // Enable HTML formatting
                }
            }

            Popup {
                id: popup
                width: parent.width
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                property var myname: model.name
                property var mytasks: model.tasks
                property var myusers: model.users
                property var myindex: model.index

                ColumnLayout {
                    Repeater {
                        model: customFunctions.length

                        Loader {
                            active: customFunctions[index].isVisible

                            sourceComponent: Button {
                                height: 40
                                text: customFunctions[index].text

                                onClicked: {
                                    if (typeof customFunctions[index].action === "function"){
                                        customFunctions[index].action(popup.myname, popup.mytasks, popup.myusers, popup.myindex);
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
