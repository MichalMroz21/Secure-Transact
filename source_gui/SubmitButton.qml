import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls 6.2
import QtQuick.Studio.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Rectangle {
    id: rectangle
    width: 200
    height: 60
    radius: 10
    layer.enabled: true
    Layout.fillWidth: true

    gradient: Gradient {
        GradientStop {
            position: 0.07456
            color: "#21a0ff"
        }

        GradientStop {
            position: 1
            color: "#035da0"
        }

        orientation: Gradient.Horizontal
    }

    Text {
       text: "Submit"
       color: "white"
       horizontalAlignment: Text.AlignHCenter
       verticalAlignment: Text.AlignVCenter
       font.pointSize: 23
       anchors.fill: parent
   }

    Button {
        id: button
        anchors.fill: parent
        opacity: 0
    }

    Component.onCompleted: {
        fadeInAnimation.start();
    }

    NumberAnimation {
        id: fadeInAnimation
        target: rectangle
        properties: "opacity"
        duration: 5000
        to: 1
        from: 0
    }
}
