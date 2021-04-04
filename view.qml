import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    id: root
    property int minewidth: 25
    property int sec: 0
    property int minesleft: 99
    property int cols: 30
    property int rows: 16
    width: frame.width + 100
    height: frame.height
    property var colorlist: ["white","blue", "#CC6666", "green", "#6666CC","#CC66CC","#66CCCC","#CCCC66", "#DAAA00"]

    Rectangle{
        id: frame
        anchors.left: parent.left
        anchors.top: parent.top
        border.width: 2
        width: minewidth * cols
        height: minewidth * rows
        Repeater {
            id: repeater
            anchors.fill: parent
            model: minesModel
            delegate: minedelegate
        }
        Component{
            id: minedelegate

            Rectangle{
                id: mine
                x: index % cols * root.minewidth + 1
                y: Math.floor(index / cols) * root.minewidth + 1
                width: root.minewidth
                height: root.minewidth
                border.width: 1
                border.color:"blue"

                property bool lbtnPressed: false
                property bool rbtnPressed: false

                Text{
                    id: marktext
                    anchors.centerIn: parent
                    font.pixelSize: 24
                    font.bold: true
                    color: "black"
                }
                state: minestate
                states: [
                    State {
                        name: "unopened"
                        PropertyChanges { target: mine; color: "darkgray"; }
                        PropertyChanges { target: marktext; text: mark; }
                    },
                    State {
                        name: "opened"
                        PropertyChanges { target: mine; color: "lightgray"; }
                        PropertyChanges { target: marktext; text:(minesaround === 0 ? "" : minesaround); color: root.colorlist[minesaround] }
                    },
                    State {
                        name: "bomb"
                        PropertyChanges { target: mine; color: "red"; border.color: "green";}
                        PropertyChanges { target: marktext; text:"*"; color:"blue"; font.pixelSize: 36;}
                    }
                ]
                MouseArea{
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onPressed: {
                        if (mouse.button === Qt.RightButton) rbtnPressed = true
                        if (mouse.button === Qt.LeftButton) lbtnPressed = true
                    }

                    onReleased: {
                        if(minesModel.getStatus() === 0) { timer.start() }
                        if ((minesModel.openedflag) && (lbtnPressed && rbtnPressed)) {
                                lbtnPressed = false
                                rbtnPressed = false
                                minesModel.open(index)
                        }
                        if (!minesModel.openedflag) {
                            if (mouse.button === Qt.LeftButton) {
                                lbtnPressed = false
                                minesModel.open(index)
                                //minedelegate.openSignal(index)
                            }
                            else if (mouse.button === Qt.RightButton) {
                                //minedelegate.markSignal(index)
                                minesModel.mark(index)
                                rbtnPressed = false
                            }
                        }
                        root.refresh()
                    }
                }
            }

        }
    }

    Column {
        anchors.top: parent.top
        anchors.left: frame.right
        anchors.bottom: parenf.bottom
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 40
        Button {
            id: startbtn
            x: 0
            width: 80
            text: "Start"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 20
            highlighted: true
            flat: false
            font.bold: true
            onClicked:{
                root.sec = 0
                minesleft = 99
                statustext.text = ""
                minesModel.newGame()
            }
        }
        Text{
            id: timetext
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 30
            font.bold: true
            text: root.sec
        }
        Text{
            id: mineslefttext
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 30
            font.bold: true
            text: root.minesleft
        }
        Text{
            id: statustext
            font.pixelSize: 24
            font.bold: true
            color: "red"
            wrapMode: Text.WrapAnywhere
            text: ""
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.sec += 1
        }
    }

    function refresh(){
        switch (minesModel.getStatus())
        {
            case 1:
                minesleft = 99 - minesModel.getmarkedCount()
                break
            case 2:
                timer.stop()
                statustext.text = "恭喜你\n成功了"
                break
            case 3:
                timer.stop()
                statustext.text = "很不幸\n你触雷了"
                break
        }
    }
}


