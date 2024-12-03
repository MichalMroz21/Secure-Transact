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

            spacing: spacingObjects.spacing_sm

            Text {
                textFormat: Text.RichText
                id: bigText
                text: "Secure\n" +
                          "<span style='color:" + colorPalette.primary500 + ";'>Transactions</span>\n" +
                          "with " +
                          "<span style='color:" + colorPalette.primary500 + ";'>Blockchain</span>\n" +
                          "Precision."
                font.pixelSize: fontStyle.getFontSize(root.width, root.height) * 3
                color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                lineHeight: 1
                wrapMode: Text.WordWrap
                Layout.preferredWidth: parent.width
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
                text: "Enter"
                //width: 600
                //buttonWidth: 125
                //buttonHeight: 40

                //width: 1920
                //buttonWidth: 250
                //buttonHeight: 80

                //Expressions below are combinations of both settings above

                buttonWidth: root.width * 25/264 + 750/11
                buttonHeight: root.height / 15 + 40 / 3

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
