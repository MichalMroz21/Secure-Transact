import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 1.15

// Page component that you want to push into StackView
Page {
    id: chatPage
    width: parent.width
    height: parent.height

    // Create a ListModel to hold the messages
    ListModel {
        id: messageModel
    }

    Component.onCompleted: {
        // Clear the model to ensure no hardcoded elements are present
        userModel.clear();
        messageModel.clear();

        // Iterate over peers array passed from Python
        for (let i = 0; i < user.peers.length; i++) {
            var isInGroup = false;
            var addr = user.peers[i].addr;
            var port = user.peers[i].port;

            for(let j = 0; j < user.group.length; j++){
                if(addr === user.group[j].addr && port === user.group[j].port){
                    isInGroup = true;
                    break;
                }
            }

            userModel.append({
                nickname: user.peers[i].nickname,
                addr: addr,
                port: port,
                PKString: user.peers[i].PKString,
                isInGroup: isInGroup
            });
        }

        let messages = user.get_conversation();

        for(let i = 0; i < messages.length; i++){
            messageModel.append({
                messageText: messages[i]
            });
        }
        user.messagesChanged.connect(function(newMessage) {
            if (newMessage !== ""){
                messageModel.append({
                    messageText: newMessage
                });
            };
        });
    }

    // Create a ListModel for the users
    ListModel {
        id: userModel
    }

    // Rectangle for the main chat container, where chat and user list will be side by side
    Rectangle {
        width: parent.width / 1.5  // Make the entire container 1.5 times smaller
        height: parent.height / 1.5  // Make the entire container 1.5 times smaller
        color: "#f0f0f0"  // Light gray background color for the main window
        radius: 10
        anchors.centerIn: parent  // Center the chat container

        // RowLayout for arranging chat and user list side by side
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
                        width: ListView.view.width  // Use ListView.view.width instead of parent.width
                        height: implicitHeight + 20  // Increased space between each message (padding)

                        Text {
                            width: parent.width  // Ensure the Text item takes full width of its parent
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
                    color: "#ffffff"  // White background for the input area
                    border.color: "#ccc"
                    anchors.bottom: parent.bottom

                    // TextField for entering new messages
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
                                //messageModel.append({"text": inputField.text});
                                // Clear the input field
                                inputField.text = "";
                            }
                        }
                    }
                }
            }

            // User List (right side)
            Rectangle {
                Layout.fillWidth: true  // Make it scale horizontally
                Layout.fillHeight: true  // Make it scale vertically
                width: parent.width / 3  // 1/3 for user list (1x space)
                height: parent.height
                color: "#ffffff"
                border.color: "#ddd"
                radius: 10

                // ListView to display user names and IP addresses
                ListView {
                    id: userListView
                    width: parent.width
                    height: parent.height - addButton.height  // Adjust height to leave space for the Add button
                    model: userModel

                    delegate: Rectangle {
                        width: parent.width  // Set width explicitly for user list items
                        height: 40  // Fixed height for each user item
                        id: userRectangle

                        MouseArea {
                            anchors.fill: parent
                            onClicked: popup.open()
                            hoverEnabled: true
                            id: mousearea

                            onEntered: {
                                parent.color = "lightgray"
                                mousearea.cursorShape = Qt.PointingHandCursor
                            }
                            onExited: {
                                parent.color = "white"
                                mousearea.cursorShape = Qt.ArrowCursor
                            }

                            // Use a single Text element to concatenate the name and IP address
                            Text {
                                anchors.centerIn: parent  // Center the text within the parent
                                text: '<font color="black">' + model.nickname + ' </font><font color="gray"><i>(' + model.addr + ":" + model.port + ')</i></font>'
                                color: "#000"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter  // Center horizontally
                                verticalAlignment: Text.AlignVCenter  // Center vertically
                                textFormat: Text.RichText  // Enable HTML formatting
                            }
                        }

                        Popup {
                            id: popup
                            width: parent.width

                            ColumnLayout {
                                Button {
                                    height: userRectangle.height / 2
                                    text: model.isInGroup ? "Remove from group" : "Add to group"

                                    onClicked:{
                                        if(model.isInGroup == true){
                                            user.removeFromGroup(model.addr, model.port);
                                        }
                                        else{
                                            user.addToGroup(model.addr, model.port);
                                        }
                                        stackView.push("chat_module.qml");
                                    }
                                }

                                Button {
                                    height: userRectangle.height / 2
                                    text: "Get public key"
                                    onClicked: {
                                        textEdit.text = model.PKString;
                                        textEdit.selectAll();
                                        textEdit.copy();
                                    }
                                }

                                TextEdit{
                                    id: textEdit
                                    visible: false
                                }

                                Button {
                                    height: userRectangle.height / 2
                                    text: "Delete from list"

                                    onClicked:{
                                        user.removeFromPeers(model.addr, model.port);
                                        user.removeFromGroup(model.addr, model.port);
                                        stackView.push("chat_module.qml");
                                    }
                                }
                            }
                        }
                    }
                }

                // Add New User Button
                Rectangle {
                    id: addUserButton
                    width: parent.width
                    height: 50  // Fixed height for the button
                    color: "green"
                    anchors.bottom: parent.bottom  // Position the button at the bottom of the parent

                    MouseArea {
                        id: addButton
                        anchors.fill: parent
                        onClicked: {
                            stackView.push("add_user.qml");
                        }
                        hoverEnabled: true

                        onEntered: {
                            parent.color = "darkgreen";  // Change color on hover
                        }
                        onExited: {
                            parent.color = "green";
                        }

                        Text {
                            id: addUserButtonText
                            anchors.centerIn: parent
                            text: "Add new user"
                            color: "white"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
