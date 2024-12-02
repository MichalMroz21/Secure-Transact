import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Extras 2.7
import Qt3D.Input 2.7

import "small_gui_components"

Page {
    id: mainPage

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background50 : colorPalette.background900
    }

    Component.onCompleted: {
        root.pageTitleText = "Welcome";
    }

    RowLayout {
        anchors.fill: parent
        Layout.preferredHeight: root.height
        Layout.preferredWidth: root.width

        ColumnLayout {
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width / 2 - spacingObjects.spacing_xx_lg
                    Layout.leftMargin: spacingObjects.spacing_x_lg
                    Layout.alignment: Qt.AlignLeft

                    spacing: spacingObjects.spacing_sm

                    Text {
                        id: bigText
                        text: "Secure\nTransactions\nwith Blockchain\nPrecision."
                        font.pixelSize: fontStyle.getFontSize(root.width, root.height) * 3
                        color: colorPalette.primary300
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.topMargin: 50
                        lineHeight: 1
                        wrapMode: Text.WordWrap
                        Layout.preferredWidth: parent.width
                    }

                    Text {
                        id: smallerText
                        text: "Experience unparalleled security and transparency with our blockchain-powered application, designed to protect Your transactions with cutting-edge technlology."
                        font.pixelSize: fontStyle.getFontSize(root.width, root.height)
                        color: colorPalette.primary200
                        anchors.left: parent.left
                        anchors.top: bigText.bottom
                        anchors.topMargin: 12
                        wrapMode: Text.WordWrap
                        Layout.preferredWidth: parent.width
                    }

                    MyButton {
                        text: "Enter"
                        anchors.left: parent.left
                        anchors.top: smallerText.bottom
                        anchors.topMargin: 12
                        buttonWidth: 125

                        onClicked: {
                            stackView.push("user.qml")
                        }
                    }
                }

        ColumnLayout{
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignRight

            spacing: spacingObjects.spacing_x_big

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
        }
    }
}
