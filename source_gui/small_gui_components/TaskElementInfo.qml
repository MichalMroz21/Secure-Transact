import QtQuick 2.15
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import Qt5Compat.GraphicalEffects

import "../app_style"

Rectangle {
    id: taskElementInfo

    property int rect_width
    property int rect_height
    property string img_source
    property color txt_color
    property string txt

    property bool displayImg: true

    color: "transparent"

    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }

    width: rect_width
    height: rect_height

    Row {
        anchors.centerIn: parent
        spacing: parent.width * 0.02

        Image {
            visible: displayImg
            source: taskElementInfo.img_source
            fillMode: Image.PreserveAspectFit
            smooth: true

            width: parent.parent.width / 5
            height: parent.parent.width / 5
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: '<span style="color: ' + taskElementInfo.txt_color + '; ">' + taskElementInfo.txt + '</span>'
            textFormat: Text.RichText
            font.pixelSize: fontStyle.getFontSize(fontStyle.mobile_h1, root.width, root.height)
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
