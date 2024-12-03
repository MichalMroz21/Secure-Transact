import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts 2.15
import Qt5Compat.GraphicalEffects

import "gui_components"
import "app_style"
import "small_gui_components"

ApplicationWindow {
    width: 600
    height: 400
    visible: true
    id: root
    title: qsTr("Secure Transact")

    ColorPalette { id: colorPalette }
    FontStyle { id: fontStyle }
    SpacingObjects { id: spacingObjects }

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    property alias pageTitleText: pageTitle.text

    StackView {
       id: stackView
       initialItem: "initial_page.qml"
       anchors.fill: parent
    }

    ToolBar {
        id: menuToolbar
        contentHeight: 40
        z: 1

        background: Rectangle {
            color: "transparent"
        }

        ToolButton {
            id: menuToolbarText
            text: "<font color=\""+ (settings.light_mode ? colorPalette.primary900 : colorPalette.primary500) + "\">☰</font>"
            font.pixelSize: getDrawerEntrySize(root.width, root.height);
            onClicked: drawer.open();
        }
    }

    Text{
        id: pageTitle
        anchors.left: menuToolbar.right
        anchors.leftMargin: root.width * 1 / 6 - menuToolbar.width
        anchors.top: menuToolbar.top
        anchors.topMargin: menuToolbar.height / 4
        font.pixelSize: getDrawerEntrySize(root.width, root.height);
        font.family: fontStyle.getLatoRegular.name
        font.pointSize: 9
        color: settings.light_mode ? colorPalette.primary700 : colorPalette.primary400
        text: "Test"
    }

    RotationAnimator {
        id: rotationAnimator
        from: 0;
        to: 360;
        duration: 1000
        loops: Animation.Infinite
    }

    ScaleAnimator {
        id: scaleAnimator
        from: 1
        to: 1.15
        duration: 450
    }

    InvitesList {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: menuToolbar.contentHeight * 1.2 + getDrawerEntrySize(root.width, root.height)
        customFunctions: [
            {
                text: "Accept",
                action: function(host, port, index, model) {
                    user.accept_invitation(host, port);
                    //model.remove(index);
                },
                isVisible: true
            },
            {
                text: "Reject",
                action: function(host, port, index, model) {
                    user.reject_invitation(host, port);
                    //model.remove(index);
                },
                isVisible: true
            }
        ]
    }

    Drawer {
        id: drawer
        width: parent.width * 0.15
        height: parent.height
        background: Rectangle {
            color: settings.light_mode ? colorPalette.background100 : colorPalette.background800
        }

        ListView {
            id: listView
            anchors.fill: parent
            model:
                ListModel {
                    ListElement {}
                    ListElement {}
                    ListElement {}
                    ListElement { text: "Options"; }
                }

            delegate: Item {

                width: parent.width
                height: width * 0.5

                Rectangle {

                    id: rect_butt

                    width: parent.width
                    height: parent.height

                    y: isOptions(model.text) ? listView.height - height * listView.model.count : Number.NaN;

                    color: getColor(model.index)

                    layer.enabled: false

                    layer.effect: DropShadow {
                        transparentBorder: true
                        color: getShadowColor(model.index)
                        samples: 40
                    }

                    Image {
                        id: menuImage
                        source: getImagePath(model.index)
                        fillMode: Image.PreserveAspectFit

                        anchors.leftMargin: parent.width * 0.1
                        anchors.rightMargin: parent.width * 0.1
                        anchors.topMargin: parent.height * 0.1
                        anchors.bottomMargin: parent.height * 0.1

                        anchors.fill: parent
                        smooth: true
                    }

                    Text {
                        anchors.centerIn: parent
                        text: model.text
                        font.pixelSize: fontStyle.getFontSize(parent.width, parent.height);
                        opacity: 0
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true

                        onEntered: {
                            rect_butt.layer.enabled = true;
                            handleAnimation(model.index, menuImage, true)
                        }

                        onExited: {
                            rect_butt.layer.enabled = false;
                            handleAnimation(model.index, menuImage, false)
                        }

                        onClicked: {
                            handleAnimation(model.index, menuImage, false)
                            switchPage(model.index);
                            drawer.close();
                        }
                    }
                }

            }
        }
    }

    function isOptions(text){
        return text === "Options";
    }

    function handleAnimation(index, image, turnOn){
        switch(index){
            case 0:
            case 1:
            case 2: {
                scaleAnimator.target = image;
                scaleAnimator.running = turnOn;
                if(turnOn === false) image.scale = 1;
                break;
            }
            case 3: {
                rotationAnimator.target = image;
                rotationAnimator.running = turnOn;
                break;
            }
        }
    }

    function getImagePath(index){
        switch (index) {
            case 0: return "../assets/user.png";
            case 1: return "../assets/chat.png";
            case 2: return "../assets/planner.png";
            case 3: return "../assets/options.png";
        }
    }

    function getColor(index) {
        switch (index) {
            case 0: return "lightgray";
            case 1: return "lightblue";
            case 2: return "lightgreen";
            case 3: return "orangered";
            default: return "lightgray";
        }
    }

    function getShadowColor(index) {
        switch (index) {
            case 0: return "gray"
            case 1: return "blue";
            case 2: return "green";
            case 3: return "orange";
            default: return "lightgray";
        }
    }

    function switchPage(index) {
        var pageSelected;

        switch (index) {
            case 0: pageSelected = "user.qml"; break;
            case 1: pageSelected = "chat_module.qml"; break;
            case 2: pageSelected = "planning_module.qml"; break;
            case 3: pageSelected = "options.qml"; break;
        }

        stackView.push(pageSelected);
    }

    function getDrawerEntrySize(width, height){
        return (width + height) * 0.02;
    }
}
