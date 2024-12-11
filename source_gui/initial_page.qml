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
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    RowLayout {
        anchors.fill: parent
        Layout.preferredHeight: root.height
        Layout.preferredWidth: root.width

        ColumnLayout {
            Layout.leftMargin: root.width * 8/165 + 384/11 //Yes.
            //explaination: for original resolution width (600) it was best to have spacingObjects.spacing_Xx_lg = 56 margin and for full hd width (1920) spacingObjects.spacing_x_huge = 128

            Layout.preferredHeight: -1
            Layout.preferredWidth: parent.width / 2 - Layout.leftMargin

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_big, root.width, root.height, true)

            Text {
                textFormat: Text.RichText
                id: bigText
                text: "Secure<br><span style='color:" + colorPalette.primary500 + ";'>Transactions<br></span>with <span style='color:" + colorPalette.primary500 + ";'>Blockchain</span><br>Precision."
                font.pixelSize: fontStyle.getFontSize(fontStyle.display_large, root.width, root.height)
                color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.preferredWidth: parent.width
                lineHeight: 1
                wrapMode: Text.WordWrap
            }

            Text {
                id: smallerText
                text: "Experience unparalleled security and\ntransparency with our blockchain-powered\napplication, designed to protect Your\ntransactions with cutting-edge technlology."
                font.pixelSize: fontStyle.getFontSize(fontStyle.display_h6, root.width, root.height)
                color: settings.light_mode ? colorPalette.accent700 : colorPalette.accent500
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                wrapMode: Text.WordWrap
                Layout.preferredWidth: parent.width
            }

            MyButton {
                buttonText: "Enter the App"

                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                onClickedFunction: function () {
                    stackView.push("user.qml")
                }
            }
        }

        ColumnLayout {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignCenter

            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, true)

            View3D {
                id: view3D
                Layout.alignment: Qt.AlignHCenter
                anchors.fill: parent
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
                        x: 0
                        y: 0
                        z: 500
                    }

                    Bitcoin {
                        id: bitcoin

                        x: -scale.x * 0.5
                        y: -scale.y * 2
                        z: -scale.z * 1

                        property var scaleFactor: Math.sqrt(Math.min(root.width, root.height)) * 5

                        scale: Qt.vector3d(scaleFactor, scaleFactor, scaleFactor)
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
