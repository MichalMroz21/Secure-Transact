import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls 6.2
import QtQuick.Studio.Effects

ColumnLayout {
    id: registerForm
    spacing: 20 //spacing between items in layout
    width: 600

    InputBox {

        property string initialText: "Email"

        Image {
            id: mail
            x: 8
            y: 4
            width: 61
            height: 42
            source: "../asset_imports/mail.png"
            fillMode: Image.PreserveAspectFit
        }

        property bool showText: true
    }

    InputBox {

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

    InputBox {

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

    SubmitButton {}

    ClickableText {
        Layout.alignment: Qt.AlignHCenter
        id: textRegister
        property string pageName: "LoginPage.ui.qml"
        property var textSize: 26
        property string textColor: "#034efc"
        property string hoverColor: "#200299"
        property string textValue: "Already have an account? Click to Login"
    }

    Item {
        Layout.fillHeight: true
    }
}
