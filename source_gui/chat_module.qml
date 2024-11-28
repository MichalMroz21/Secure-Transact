import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 1.15

import "gui_components"

Page {
    id: chatPage
    width: parent.width
    height: parent.height

    // Create a ListModel to hold the messages
    ListModel {
        id: messageModel
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

    // Rectangle for the main chat container
    Rectangle {
        width: parent.width / 1.5
        height: parent.height / 1.5
        color: "#f0f0f0"
        radius: 10
        anchors.centerIn: parent

        RowLayout {
            anchors.fill: parent

            // Chat Window (left side)
            Rectangle {
                Layout.fillWidth: true  // Make it scale horizontally
                Layout.fillHeight: true  // Make it scale vertically
                width: parent.width * 2 / 3  // 2/3 for chat window (2x space)
                height: parent.height
                color: "#f0f0f0"
                border.color: "#ddd"
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
                    color: "#ffffff"
                    border.color: "#ccc"
                    anchors.bottom: parent.bottom

                    TextField {
                        id: inputField
                        width: parent.width - 20
                        height: parent.height - 10
                        anchors.centerIn: parent
                        padding: 5
                        placeholderText: "Type a message..."

                        background: Rectangle {
                            border.width: 0
                            border.color: "transparent"
                        }

                        // When the user presses Enter, append the message to the ListView
                        onAccepted: {
                            if (inputField.text.trim() !== "") {
                                // Append new message to the model
                                user.send_mes(inputField.text);
                                // Clear the input field
                                inputField.text = "";
                            }
                        }
                    }
                }
            }

            FriendList{
                customFunctions: [
                     {
                         text: "Add to group",
                         action: function(addr, port, nickname, PKString, isInGroup, popup) {
                             user.addToGroup(addr, port);
                         },
                         isVisible: true
                     },
                    {
                        text: "Remove from group",
                        action: function (addr, port, nickname, PKString, isInGroup, popup) {
                            user.removeFromGroup(addr, port);
                        },
                        isVisible: true
                    }
                ]
            }
        }
    }
}
