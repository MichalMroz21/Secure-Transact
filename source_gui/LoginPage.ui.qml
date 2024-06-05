import QtQuick
import QtQuick.Studio.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Extras 2.7
import Qt3D.Input 2.7

import QtQuick3D
import Quick3DAssets.Orbiter_Space_Shuttle_OV_103_Discovery_150k_4096
import Quick3DAssets.Coin
import Quick3DAssets.Tuomodesign_ethereum
import QtQuick.Layouts
import Quick3DAssets.Bitcoin
import Quick3DAssets.Uploads_files_993453_etherium

Rectangle {
    id: rectangle
    width: 1920
    height: 1080
    color: "white"
    radius: 0
    border.color: "#1e1e1e"
    border.width: 18

    RadialGradient {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "white"
            }
            GradientStop {
                id: gradient12
                position: 0.5
                color: "#c7c7c7"
            }
        }
    }

    SequentialAnimation {
        running: true
        loops: Animation.Infinity

        NumberAnimation {
            target: gradient12
            property: "position"
            from: 0.5
            to: 0.7
            duration: 5000
        }

        NumberAnimation {
            target: gradient12
            property: "position"
            from: 0.7
            to: 0.5
            duration: 5000
        }
    }

    RowLayout {
        id: rowLayout
        x: 0
        y: 48
        width: parent.width
        height: 333

        RowLayout {
            Layout.alignment: Qt.AlignCenter
            View3D {
                id: view3D
                y: -15
                width: 150
                height: 333
                environment: sceneEnvironment

                SceneEnvironment {
                    id: sceneEnvironment
                    antialiasingQuality: SceneEnvironment.High
                    antialiasingMode: SceneEnvironment.MSAA
                }

                Node {
                    id: scene
                    DirectionalLight {
                        id: directionalLight
                    }

                    PerspectiveCamera {
                        id: sceneCamera
                        x: -286.671
                        y: 27.51
                        z: 368.9527
                    }

                    Bitcoin {
                        id: bitcoin
                        x: -304.35
                        y: -402.641
                        scale.z: 200
                        scale.x: 200
                        scale.y: 200
                        z: -530.37915
                    }
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

            View3D {
                id: view3D2
                y: -15
                width: 200
                height: 333
                environment: sceneEnvironment2

                SceneEnvironment {
                    id: sceneEnvironment2
                    antialiasingQuality: SceneEnvironment.High
                    antialiasingMode: SceneEnvironment.MSAA
                }

                Node {
                    id: scene2
                    DirectionalLight {
                        id: directionalLight2
                    }

                    PerspectiveCamera {
                        id: sceneCamera2
                        x: -286.671
                        y: 27.51
                        z: 368.9527
                    }

                    Uploads_files_993453_etherium {
                        id: tuomodesign_ethereum
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
                }

                NumberAnimation {
                    target: tuomodesign_ethereum
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

    FadeInText {
        property string textProperty: "Login"
        id: appName
        y: 324
        anchors.left: parent.left
        anchors.right: parent.right
    }

    LoginForm {
        id: columnLayout
        anchors.horizontalCenter: parent.horizontalCenter
        height: 533
        width: 307
        y: 471
    }

    Item {
        id: __materialLibrary__
    }
}
