import QtQuick
import QtQuick.Controls 2.0
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "gui_components"

Page {
    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        ProjectList {
            id: projectList
            anchors.horizontalCenter: parent.horizontalCenter

            customFunctions: [
                {
                    text: "Add user to project",
                    action: function (name, tasks, users, index) {
                        stackView.push("add_to_project.qml", {currentIndex: index});
                    },
                    isVisible: true
                }
            ]
        }
    }
}
