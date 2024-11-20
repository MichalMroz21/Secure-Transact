import QtQuick
import QtQuick.Controls 6.3
import QtCharts 6.3
import QtQuick.Layouts 6.3

Page {
    ColumnLayout {
        property int maxInputWidth: 300
        id: formContainer
        anchors.centerIn: parent
        spacing: 15
        width: Math.min(parent.width / 3, maxInputWidth)  // Set a maximum width for the form
        height: implicitHeight
            RowLayout{
                Text {
                id: ipAddress
                    Layout.alignment: Qt.AlignHCenter
                    text: "IP Address: "
                    font.pixelSize: 20
                    color: "black"
                }
                TextField {
                    text: user.host
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 20
                    color: "black"
                }
            }
            RowLayout{
                Text {
                id: portAddress
                    Layout.alignment: Qt.AlignHCenter
                    text: "Port: "
                    font.pixelSize: 20
                    color: "black"
                }
                TextField {
                    text: user.port
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 20
                    color: "black"
                }
            }
            RowLayout{
                Text {
                    id: pkText
                    Layout.alignment: Qt.AlignHCenter
                    text: "Public Key: "
                    font.pixelSize: 20
                    color: "black"
                }
                TextField {
                    text: pk
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 20
                    color: "black"
                }
            }
    }
}
