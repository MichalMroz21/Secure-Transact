import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt3D.Core 2.0
import Qt3D.Render 2.0
import Qt3D.Extras 2.7
import Qt3D.Input 2.7
import QtQuick3D

import "small_gui_components"
import "../assets/Bitcoin"

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
            Layout.leftMargin: root.width * 8/165 + 384/11 //Yes.
            //explaination: for original resolution width (600) it was best to have spacingObjects.spacing_Xx_lg = 64 margin and for full hd width (1920) spacingObjects.spacing_x_huge = 128

            Layout.preferredHeight: -1
            Layout.preferredWidth: parent.width / 2 - Layout.leftMargin

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            spacing: spacingObjects.spacing_sm

            Text {
                id: bigText
                text: "Secure\nTransactions\nwith Blockchain\nPrecision."
                font.pixelSize: fontStyle.getFontSize(root.width, root.height) * 3
                color: colorPalette.primary300
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                lineHeight: 1
                wrapMode: Text.WordWrap
                Layout.preferredWidth: parent.width
            }

            Text {
                id: smallerText
                text: "Experience unparalleled security and transparency with our blockchain-powered application, designed to protect Your transactions with cutting-edge technlology."
                font.pixelSize: fontStyle.getFontSize(root.width, root.height)
                color: colorPalette.primary200
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                wrapMode: Text.WordWrap
                Layout.preferredWidth: parent.width
            }

            MyButton {
                text: "Enter"
                //buttonWidth: 125
                //buttonHeight: 40
                buttonWidth: 250
                buttonHeight: 80
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

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
