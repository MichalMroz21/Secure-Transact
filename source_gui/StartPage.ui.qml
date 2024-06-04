import QtQuick
import QtQuick.Studio.Effects
import Qt5Compat.GraphicalEffects
import QtQuick.Effects

Rectangle {
    id: rectangle
    width: 1920
    height: 1080
    color: "white"
    radius: 0
    border.color: "#1e1e1e"
    border.width: 18

    AnimatedTitle {
        id: animatedText
        y: 70
        anchors.left: parent.left
        anchors.right: parent.right
    }

    FadeInText {
        property string textProperty: "Login"
        id: appName
        y: 324
        anchors.left: parent.left
        anchors.right: parent.right
    }

    LoginForm {
        id: columnLayout
        anchors.horizontalCenter: parent.horizontalCenter
        height: 533
        width: 307
        y: 471
    }
}
