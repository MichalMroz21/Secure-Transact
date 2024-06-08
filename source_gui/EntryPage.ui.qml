import QtQuick
import QtQuick.Studio.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Extras 2.7
import Qt3D.Input 2.7

import QtQuick3D
import QtQuick.Layouts
import Quick3DAssets.Bitcoin
import Quick3DAssets.Etherium

Rectangle {
    id: entryPage
    width: 1920
    height: 1080
    color: "white"
    radius: 0
    border.color: "#1e1e1e"
    border.width: 18

    property string currentForm: "LoginForm.ui.qml"

    RadialGradient {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "white"
            }
            GradientStop {
                id: gradientBg
                position: 0.5
                color: "#c7c7c7"
            }
        }
    }

    SequentialAnimation {
        running: true
        loops: Animation.Infinite

        NumberAnimation {
            target: gradientBg
            property: "position"
            from: 0.5
            to: 0.7
            duration: 5000
        }

        NumberAnimation {
            target: gradientBg
            property: "position"
            from: 0.7
            to: 0.5
            duration: 5000
        }
    }

    RowLayout {
        id: rowLayout
        width: parent.width

        RowLayout {
            Layout.alignment: Qt.AlignCenter

            ThreeDObject {
                y: -75
                width: 150
                height: 333
                Bitcoin {
                    id: bitcoin
                    x: -304.35
                    y: -402.641
                    scale.z: 200
                    scale.x: 200
                    scale.y: 200
                    z: -530.37915
                }

                NumberAnimation {
                    target: bitcoin
                    property: "eulerRotation.y"
                    loops: Animation.Infinite
                    running: true
                    from: 360
                    to: 0
                    duration: 10000
                }
            }

            AnimatedTitle {
                id: animatedText
                y: 70
            }

            ThreeDObject {
                y: -75
                width: 200
                height: 333
                Etherium {
                    id: ethereum
                    x: -309.619
                    y: -162.217
                    eulerRotation.z: 0.00001
                    eulerRotation.y: -0
                    eulerRotation.x: -19.74361
                    scale.z: 45
                    scale.x: 45
                    scale.y: 45
                    z: -473.4837
                }

                NumberAnimation {
                    target: ethereum
                    property: "eulerRotation.y"
                    loops: Animation.Infinite
                    running: true
                    from: 0
                    to: 360
                    duration: 10000
                }
            }
        }
    }

    Loader {
        anchors.centerIn: parent
        source: currentForm
    }

    Item {
        id: __materialLibrary__
    }
}
