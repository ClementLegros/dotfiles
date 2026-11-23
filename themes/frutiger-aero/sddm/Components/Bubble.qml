// Une bulle de savon : un anneau clair, un gros reflet en haut à gauche, un
// petit en bas à droite. Deux reflets suffisent à faire lire la sphère ; un
// seul donne un disque.
import QtQuick

Item {
    id: bubble

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: Qt.rgba(1, 1, 1, 0.10)
        border.width: Math.max(1, width * 0.035)
        border.color: Qt.rgba(1, 1, 1, 0.55)
    }
    Rectangle {
        x: parent.width * 0.20; y: parent.height * 0.15
        width: parent.width * 0.28; height: width; radius: width / 2
        color: Qt.rgba(1, 1, 1, 0.85)
    }
    Rectangle {
        x: parent.width * 0.62; y: parent.height * 0.64
        width: parent.width * 0.15; height: width; radius: width / 2
        color: Qt.rgba(1, 1, 1, 0.40)
    }
}
