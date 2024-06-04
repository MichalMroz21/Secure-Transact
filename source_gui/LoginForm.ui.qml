import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls 6.2
import QtQuick.Studio.Effects

ColumnLayout {
    id: columnLayout
    spacing: 20 //spacing between items in layout
    width: 600

    LoginBox {

        property string initialText: "Login"

        Image {
            id: icon
            x: 8
            y: 4
            width: 61
            height: 42
            source: "../asset_imports/my-account-login-64.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    LoginBox {

        property string initialText: "Password"

        Image {
            id: clipart683514
            x: 8
            y: 4
            width: 61
            height: 42
            source: "../asset_imports/clipart683514.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    LoginButton {}

    Item {
        Layout.fillHeight: true
    }
}
