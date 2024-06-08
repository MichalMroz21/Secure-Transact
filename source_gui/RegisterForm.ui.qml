import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls 6.2
import QtQuick.Studio.Effects

ColumnLayout {
    id: registerForm
    spacing: 20
    width: 400

    FadeInText {
        id: appName
        property string textProperty: "Register"
        property string text_color: "#21a0ff"
        property int text_y: 112
        property int text_width: 630
        property int text_height: 169
        property int text_letterSpacing: 4
        property int text_pixelSize: 80
        Layout.alignment: Qt.AlignHCenter
    }

    InputFormBox {
        property string initialText: "E-mail"
        property bool showText: true
        property string imageSource: "../asset_imports/mail.png"
    }

    InputFormBox {
        property string initialText: "Login"
        property bool showText: true
        property string imageSource: "../asset_imports/my-account-login-64.png"
    }

    InputFormBox {
        property string initialText: "Password"
        property bool showText: false
        property string imageSource: "../asset_imports/clipart683514.png"
    }

    SubmitFormButton {}

    ClickableText {
        id: textRegister
        property int textSize: 26
        property string pageName: "LoginForm.ui.qml"
        property string textColor: "#034efc"
        property string hoverColor: "#200299"
        property string textValue: "Already have an account?"
        Layout.alignment: Qt.AlignHCenter
    }

    Item {
        Layout.fillHeight: true
    }

    FadeInAnimation {
        target: registerForm
        duration: 2000
        to: 1.0
    }
}
