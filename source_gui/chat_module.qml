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

    // Create a ListModel for the users (placeholders for now)
    ListModel {
        id: userModel
        ListElement { name: "User 1"; ip: "192.168.1.1" }
        ListElement { name: "User 2"; ip: "192.168.1.2" }
        ListElement { name: "User 3"; ip: "192.168.1.3" }
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
                            text: model.text
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
                                messageModel.append({"text": inputField.text});
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
                    width: parent.width
                    height: parent.height
                    model: userModel

                    delegate: Item {
                        width: parent.width  // Set width explicitly for user list items
                        height: 40  // Fixed height for each user item

                        // Use a single Text element to concatenate the name and IP address
                        Text {
                            anchors.centerIn: parent  // Center the text within the parent
                            text: '<font color="black">' + model.name + ' </font><font color="gray"><i>(' + model.ip + ')</i></font>'
                            color: "#000"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter  // Center horizontally
                            verticalAlignment: Text.AlignVCenter  // Center vertically
                            textFormat: Text.RichText  // Enable HTML formatting
                        }
                    }
                }
            }
        }
    }
}
