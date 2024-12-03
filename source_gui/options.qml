import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import QtQuick 2.15
import QtQuick.Controls 2.15

import "small_gui_components"

Page {
    id: optionsPage
    function updateCheckbox() {
        autoConnectionCheckbox.isToggled = settings.auto_connection;
        lightModeCheckbox.isToggled = settings.light_mode;
    }
    function changeColor() {
        optionsPage.background.color = settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    Component.onCompleted: {
        updateCheckbox();
        settings.lightModeChanged.connect(changeColor);
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: spacingObjects.preserveSpacingProportion(spacingObjects.spacing_big, root.width, root.height, true)

        MyCheckButton{
            id: autoConnectionCheckbox
            text: "Automatically accept friend invites"
        }

        MyCheckButton{
            id: lightModeCheckbox
            text: "Turn light mode"
        }

        MyButton{
            text: "Save settings"
            buttonWidth: 200
            onClicked: {
                settings.auto_connection = autoConnectionCheckbox.isToggled;
                settings.light_mode = lightModeCheckbox.isToggled;
                updateCheckbox()
            }
        }


    }
}

