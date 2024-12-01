import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "small_gui_components"

Page {
    id: mainPage

    background: Rectangle {
        color: colorPalette.background900
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
            Rectangle {
                Layout.preferredHeight: 150
                Layout.preferredWidth: 150
                Layout.alignment: Qt.AlignRight

                color: colorPalette.primary100
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
