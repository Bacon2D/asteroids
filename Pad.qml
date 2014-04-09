import QtQuick 2.0

Item {
    height: width
    opacity: 0.1

    signal fire

    property bool isUpPressed: false
    property bool isDownPressed: false
    property bool isLeftPressed: false
    property bool isRightPressed: false
    property bool isFirePressed: firedArea.pressed

    Column {
        anchors.fill: parent

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height/3
            width: parent.width/3
            Image {
                fillMode: Image.PreserveAspectFit
                width: parent.width
                source: "images/pad-up.png"
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        isUpPressed = true;
                    }
                    onReleased: {
                        isUpPressed = false;
                    }

                }
            }
        }
        Row {
            height: parent.height/3
            width: parent.width
            Image {
                fillMode: Image.PreserveAspectFit
                width: parent.width/3
                source: "images/pad-left.png"
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        isLeftPressed = true;
                    }
                    onReleased: {
                        isLeftPressed = false;
                    }
                }
            }
            Image {
                fillMode: Image.PreserveAspectFit
                width: parent.width/3
                source: "images/pad-center.png"
                MouseArea {
                    id: firedArea
                    anchors.fill: parent
                    onPressed: {
                        isFirePressed = true;
                        fire();
                    }
                    onReleased: {
                        isFirePressed = false;
                    }
                }
            }
            Image {
                fillMode: Image.PreserveAspectFit
                width: parent.width/3
                source: "images/pad-right.png"
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        isRightPressed = true;
                    }
                    onReleased: {
                        isRightPressed = false;
                    }
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height/3
            width: parent.width/3
            Image {
                fillMode: Image.PreserveAspectFit
                width: parent.width
                source: "images/pad-down.png"
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        isDownPressed = true;
                    }
                    onReleased: {
                        isDownPressed = false;
                    }
                }
            }
        }

    }
}
