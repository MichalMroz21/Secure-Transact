import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 1.15

import "gui_components"
import "small_gui_components"
import "app_style"


Page {
    id: chatPage
    width: parent.width
    height: parent.height

    // Create a ListModel to hold the messages
    ListModel {
        id: messageModel
    }

    background: Rectangle {
        color: settings.light_mode ? colorPalette.background100 : colorPalette.background900
    }

    Component.onCompleted: {
        function loadChat(){
            var messages = user.prepare_conversation_history();

            messageModel.clear();

            for(let i = 0; i < messages.length; i++){
                messageModel.append({
                   messageText: messages[i]
                });
            }
        }

        function appendToChat(newMessage){
            if (newMessage !== ""){
                messageModel.append({
                    messageText: newMessage
                });
            }
        }

        loadChat();

        user.groupChanged.connect(loadChat);
        user.messagesAppend.connect(appendToChat);
    }


        RowLayout {
            width: parent.width / 1.5
            height: parent.height / 1.5
            anchors.centerIn: parent

            ColumnLayout{
                Layout.preferredWidth: parent.width * 2 / 3
                Layout.preferredHeight: parent.height
                // Chat Window (left side)
                Rectangle {
                Layout.fillWidth: true  // Make it scale horizontally
                Layout.fillHeight: true  // Make it scale vertically
                width: parent.width  // 2/3 for chat window (2x space)
                height: parent.height
                color: settings.light_mode ? colorPalette.background50 : colorPalette.background800
                border.color: settings.light_mode ? colorPalette.accent700 : colorPalette.accent400
                radius: 10

                // Scrollable ListView to display messages
                ListView {
                    width: parent.width
                    height: parent.height - inputArea.height  // Leave space for the input area
                    model: messageModel
                    clip: true
                    anchors.top: parent.top
                    anchors.bottom: inputArea.top
                    anchors.left: parent.left
                    anchors.right: parent.right


                    // Enable automatic scrolling when new messages are added
                    onContentYChanged: {
                        if (contentY + height >= contentHeight) {
                            positionViewAtEnd(); // Scroll to the end if new messages are added
                        }
                    }

                    delegate: Item {
                        width: ListView.view.width
                        height: implicitHeight + 20

                        Text {
                            width: parent.width
                            text: model.messageText
                            color: "#000"
                            font.pixelSize: 16
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 10
                        }
                    }
                }

                // The area where messages are typed and submitted
                Rectangle {
                    id: inputArea
                    width: parent.width
                    height: 50
                    color: settings.light_mode ? colorPalette.background50 : colorPalette.background800
                    border.color: settings.light_mode ? colorPalette.accent700 : colorPalette.accent400
                    anchors.bottom: parent.bottom

                    MyTextFieldLabel{
                        id: inputField
                        parentWidth: parent.width - 20
                        parentHeight: parent.height - 10
                        anchors.centerIn: parent
                        placeholder: "Type a message..."
                        placeholderColor: settings.light_mode ? colorPalette.accent700 : colorPalette.accent400
                        borderWidth: 0
                        textColor: settings.light_mode ? colorPalette.accent700 : colorPalette.accent400
                        visibleUpText: false
                        onAccepted: {
                            if (inputField.downText.trim() !== "") {
                                user.send_mes(inputField.downText);
                                inputField.downText = "";
                            }
                        }
                    }
                }
            }
            }

            ColumnLayout{
                Layout.preferredWidth: parent.width * 1 / 3
                Layout.preferredHeight: parent.height
                FriendList{

                    customFunctions: [
                         {
                             text: "Add to group",
                             action: function(model, mouseArea, popup) {
                                 user.add_to_group(model.host, model.port);
                             },
                             isVisible: true
                         },
                        {
                            text: "Remove from group",
                            action: function (model, mouseArea, popup) {
                                user.remove_from_group(model.host, model.port);
                            },
                            isVisible: true
                        }
                    ]
                }
            }
        }

}
