import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    function updateCheckbox() {
        autoConnectionCheckbox.checked = settings.auto_connection;
    }

    background: Rectangle {
        color: colorPalette.background900
    }

    Component.onCompleted: {
        root.pageTitleText = "Options";
        updateCheckbox();
        settings.autoConnectionChanged.connect(updateCheckbox);
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        CheckBox {
            id: autoConnectionCheckbox
            text: "<font color=\""+ colorPalette.primary400 +"\">Automatically accept friend invites</font>"
        }

        Button {
            text: "Save settings"
            onClicked: {
                settings.auto_connection = autoConnectionCheckbox.checked;
            }
        }
    }
}

