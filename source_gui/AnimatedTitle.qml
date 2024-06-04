import QtQuick
import QtQuick.Studio.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Text {
    color: "green"
    horizontalAlignment: Text.AlignHCenter
    font.pointSize: 86
    id: animatedText
    text: "SecureTransact"

    LinearGradient {
        anchors.fill: animatedText
        source: animatedText
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                id: gradient1
                position: 0.0
                color: "green"
            }
            GradientStop {
                id: gradient2
                position: 0
                color: "lightgreen"
            }
            GradientStop {
                id: gradient3
                position: 0.1
                color: "green"
            }
        }
    }

    ParallelAnimation {
        running: true
        loops: Animation.Infinite
        NumberAnimation {
            target: gradient1
            property: "position"
            from: -0.1
            to: 1.0
            duration: 5000
        }
        NumberAnimation {
            target: gradient2
            property: "position"
            from: 0
            to: 1.0
            duration: 5000
        }
        NumberAnimation {
            target: gradient3
            property: "position"
            from: 0.1
            to: 1.0
            duration: 5000
        }
    }
}
