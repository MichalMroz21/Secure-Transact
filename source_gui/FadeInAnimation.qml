import QtQuick 2.15

Item {
    id: fadeInAnimation

    property Item target: null
    property int duration: 1000
    property real to: 1.0
    property real from: 0.0

    onTargetChanged: {
        if (target !== null){
            animation.running = true
        }
    }

    NumberAnimation {
        id: animation
        target: fadeInAnimation.target
        property: "opacity"
        duration: fadeInAnimation.duration
        to: fadeInAnimation.to
        from: fadeInAnimation.from
    }
}
