import QtQuick
import QtQuick.Controls 6.8
import QtCharts 6.3
import QtQuick.Layouts 6.3

import "small_gui_components"

Page {
    id: formPage
    property int maxInputWidth: 300

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    ColumnLayout {
        id: formContainer
        anchors.centerIn: parent
        spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_big, root.width, root.height, true)
        width: Math.min(parent.width / 3, maxInputWidth)  // Set a maximum width for the form
        height: implicitHeight
        Layout.preferredHeight: 256

        Text {
            id: userText
            Layout.alignment: Qt.AlignHCenter
            text: "Connect to User"
            font.pixelSize: fontStyle.getFontSize(fontStyle.display_h1, root.width, root.height)
            color: settings.light_mode ? colorPalette.primary600 : colorPalette.primary300
        }

        // IP Address Input
        MyTextFieldLabel {
            id: addressTextField
            upText: "IP Address"
            parentWidth: parent.width
            parentHeight: 50
        }

        // Port Input
        MyTextFieldLabel {
            id: portTextField
            upText: "Port"
            parentWidth: parent.width
            parentHeight: 50
        }

        // Buttons Row
        RowLayout {
            spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_xxx_big, root.width, root.height, false)
            Layout.alignment: Qt.AlignHCenter

            // Accept Button
            MyButton {
                buttonText: "Accept"

                onClickedFunction: function () {
                    if(addressTextField.downText !== "" && portTextField.downText !== ""){
                        user.send_invitation(addressTextField.downText, portTextField.downText);
                        //user.verify_peer_connection(addressTextField.text, portTextField.text);
                        stackView.push("chat_module.qml");
                    }
                }
            }
        }
    }
}
