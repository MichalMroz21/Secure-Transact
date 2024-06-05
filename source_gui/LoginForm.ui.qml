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

        property bool showText: true
    }

    LoginBox {

        property bool showText: false
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

    ClickableText {
        Layout.alignment: Qt.AlignHCenter
        id: textRegister
        property string pageName: "Register.qml"
        property var textSize: 26
        property string textColor: "#034efc"
        property string hoverColor: "#200299"
        property string textValue: "New? Click to Register"
    }

    ClickableText {
        Layout.alignment: Qt.AlignHCenter
        id: textForgot
        property string pageName: "PasswordForgot.qml"
        property string textColor: "#034efc"
        property string hoverColor: "#200299"
        property var textSize: 26
        property string textValue: "Forgot Password?"
    }

    Item {
        Layout.fillHeight: true
    }
}
