import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "../app_style"

Item {
    id: clickableImage

    // Custom properties
    property var customFunction: null
    property string sourceImg: ""
    property alias image_width: image.width
    property alias image_height: image.height

    width: image_width
    height: image_height

    Image {
        id: image
        source: sourceImg
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectFit
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (customFunction) {
                customFunction()
            }
        }
        cursorShape: Qt.PointingHandCursor
    }
}
