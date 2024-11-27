import QtQuick 2.15
import QtQuick.Controls 6.8
import QtQuick.Layouts 1.15

//User (Peer) List Class Blueprint
Rectangle {
    //Class Properties (override if needed)
    property string list_color: "#ffffff"
    property string border_color: "#dddddd"
    property int border_radius: 10
    property int list_width: parent.width / 3
    property int list_height: parent.height
    property bool list_fill_width: true
    property bool list_fill_height: true

    property var customFunctions: new Array(1);

    // Create a ListModel for the users
    ListModel {
        id: userModel
    }

    function updateUserModel() {
        userModel.clear();

        // Iterate over peers array passed from Python
        for (let i = 0; i < user.peers.length; i++) {
            var isInGroup = false;
            var addr = user.peers[i].addr;
            var port = user.peers[i].port;

            for (let j = 0; j < user.group.length; j++) {
                if (addr === user.group[j].addr && port === user.group[j].port) {
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
    }

    Component.onCompleted: {
        updateUserModel();

        user.peersChanged.connect(updateUserModel);
        user.nicknameChanged.connect(updateUserModel);
    }

    Layout.fillWidth: list_fill_width  // Make it scale horizontally
    Layout.fillHeight: list_fill_height  // Make it scale vertically
    width: list_width
    height: list_height
    color: list_color
    border.color: border_color
    radius: border_radius

    // ListView to display user names and IP addresses
    ListView {
        id: friendListView
        width: parent.width
        height: parent.height
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
                    text: '<span style="color: black; ">' + model.nickname + ' </span><span style="color: gray; "><i>(' + model.addr + ":" + model.port + ')</i></span>'
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
                modal: true
                focus: true
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                property var myaddr: model.addr
                property var myport: model.port
                property var mynickname: model.nickname
                property var myPKString: model.PKString
                property var myisInGroup: model.isInGroup

                ColumnLayout {
                    Repeater {
                        model: customFunctions.length

                        Loader {
                            active: customFunctions[index].isVisible

                            sourceComponent: Button {
                                height: 40
                                text: customFunctions[index].text

                                onClicked: {
                                    if (typeof customFunctions[index].action === "function"){
                                        customFunctions[index].action(popup.myaddr, popup.myport,
                                            popup.mynickname, popup.myPKString, popup.myisInGroup);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
