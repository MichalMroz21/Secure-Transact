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
            //explaination: for original resolution width (600) it was best to have spacingObjects.spacing_Xx_lg = 64 margin and for full hd width (1920) spacingObjects.spacing_x_huge = 128

            Layout.preferredHeight: -1
            Layout.preferredWidth: parent.width / 2 - Layout.leftMargin

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_big, root.width, root.height, true)

            Text {
                textFormat: Text.RichText
                id: bigText
                text: "Secure<br><span style='color:" + colorPalette.primary500 + ";'>Transactions<br></span>with <span style='color:" + colorPalette.primary500 + ";'>Blockchain</span><br>Precision."
                font.pixelSize: fontStyle.getFontSize(root.width, root.height) * 3
                color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.preferredWidth: parent.width
                lineHeight: 1
                wrapMode: Text.WordWrap
            }

            Text {
                id: smallerText
                text: "Experience unparalleled security and\ntransparency with our blockchain-powered\napplication, designed to protect Your\ntransactions with cutting-edge technlology."
                font.pixelSize: fontStyle.getFontSize(root.width, root.height)
                color: settings.light_mode ? colorPalette.accent700 : colorPalette.accent500
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                wrapMode: Text.WordWrap
                Layout.preferredWidth: parent.width
            }

            MyButton {
                text: "Enter the App"

                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                onClicked: {
                    stackView.push("user.qml")
                }
            }
        }

        ColumnLayout {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignCenter // Aligns the entire ColumnLayout to the center

            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_x_big, root.width, root.height, true)

            View3D {
                id: view3D
                Layout.alignment: Qt.AlignHCenter // Centers the View3D horizontally within the ColumnLayout
                anchors.fill: parent // Make View3D fill its parent to track size changes dynamically
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
                        z: 500 // Adjust this as needed to control the camera's distance from the object
                    }

                    Bitcoin {
                        id: bitcoin

                        // Center dynamically based on scale
                        x: -scale.x * 0.5 // Adjust this multiplier to fine-tune centering
                        y: -scale.y * 2 // Adjust this multiplier to fine-tune centering
                        z: -scale.z * 1 // Adjust for depth if needed

                        property var scaleFactor: Math.sqrt(Math.min(root.width, root.height)) * 5

                        // Dynamically adjust the scale based on View3D's width and height
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
