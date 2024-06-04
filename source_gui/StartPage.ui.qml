import QtQuick 2.15

Rectangle {
    id: rectangle
    width: 1920
    height: 1080
    color: "white"
    radius: 0
    border.color: "#1e1e1e"
    border.width: 18

    AnimatedMainText {
        id: appNameMain
        x: 655
        y: 185
    }

    FadeInText {
        property string textProperty: "Login"
        id: appName
        x: 655
        y: 324
    }

    LoginForm {
        id: columnLayout
        height: 533
        width: 307
        x: 816
        y: 441
    }
}
