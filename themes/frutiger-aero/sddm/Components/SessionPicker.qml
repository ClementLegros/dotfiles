// Sélecteur de session : une pastille de verre qui ouvre la liste vers le haut
// (elle est ancrée en bas de l'écran).
import QtQuick
import QtQuick.Controls

Item {
    id: picker

    property int index: sessionModel.lastIndex
    readonly property string currentName: {
        var o = sessions.objectAt(index)
        return o ? o.name : ""
    }

    implicitWidth: pill.width
    implicitHeight: 38

    Instantiator {
        id: sessions
        model: sessionModel
        delegate: QtObject { required property string name }
    }

    GlassPlate {
        id: pill
        anchors.verticalCenter: parent.verticalCenter
        width: label.implicitWidth + chevron.width + 34
        height: parent.implicitHeight
        cornerRadius: height / 2
        alphaTop: 0.80
        alphaBottom: 0.72
    }

    Row {
        id: row
        anchors.centerIn: pill
        spacing: 8

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: picker.currentName
            color: "#06355c"
            font.family: "Inter"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering
        }
        Text {
            id: chevron
            anchors.verticalCenter: parent.verticalCenter
            text: popup.visible ? "▴" : "▾"
            color: "#3d7ba6"
            font.pixelSize: 13
        }
    }

    MouseArea {
        anchors.fill: pill
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.visible ? popup.close() : popup.open()
    }

    Popup {
        id: popup
        width: Math.max(pill.width, 220)
        x: pill.width - width
        y: -height - 10
        padding: 6

        background: GlassPlate {
            cornerRadius: 16
            alphaTop: 0.92
            alphaBottom: 0.88
        }

        contentItem: ListView {
            implicitHeight: Math.min(contentHeight, 240)
            model: sessionModel
            currentIndex: picker.index
            clip: true
            spacing: 2

            delegate: ItemDelegate {
                id: entry
                required property int index
                required property string name

                width: ListView.view.width
                height: 34

                contentItem: Text {
                    text: entry.name
                    color: "#06355c"
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: entry.index === picker.index ? Font.DemiBold : Font.Normal
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 10
                    renderType: Text.NativeRendering
                }

                background: Rectangle {
                    radius: 10
                    color: entry.index === picker.index ? Qt.rgba(0.30, 0.76, 0.97, 0.45)
                         : entry.hovered                ? Qt.rgba(1, 1, 1, 0.60)
                                                        : "transparent"
                }

                onClicked: {
                    picker.index = entry.index
                    popup.close()
                }
            }
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 160; easing.type: Easing.OutCubic }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 120 }
        }
    }
}
