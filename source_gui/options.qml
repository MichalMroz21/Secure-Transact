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

    Component.onCompleted: {
        updateCheckbox();
        settings.autoConnectionChanged.connect(updateCheckbox);
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        CheckBox {
            id: autoConnectionCheckbox
            text: "Automatycznie akceptuj prośby o połączenie się z użytkownikiem"
        }

        Button {
            text: "Zapisz ustawienia"
            onClicked: {
                settings.auto_connection = autoConnectionCheckbox.checked;
            }
        }
    }
}

