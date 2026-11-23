// Une plaque de verre Aero. Recette identique à celle de waybar.css :
//   1. dégradé vertical avec une CASSURE nette vers 46 % — c'est cette arête,
//      et pas le flou, qui fait lire la surface comme du verre bombé ;
//   2. un liseré blanc sur l'arête haute = la lumière qui l'accroche ;
//   3. une ombre portée bleutée, jamais noire.
import QtQuick
import QtQuick.Effects

Item {
    id: plate

    property real cornerRadius: 18
    property real alphaTop: 0.88      // opacité de la moitié haute
    property real alphaBottom: 0.80   // opacité de la moitié basse
    property bool shine: true         // liseré de l'arête haute
    // Hauteur de la cassure, en fraction de la plaque. À placer dans un
    // interligne : une couture qui traverse un texte le rend illisible.
    property real breakAt: 0.45
    property color shadowTint: "#a3041e33"
    property real shadowSize: 0.85

    Rectangle {
        id: glass
        anchors.fill: parent
        radius: plate.cornerRadius
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.85)
        gradient: Gradient {
            GradientStop { position: 0.00; color: Qt.rgba(1.000, 1.000, 1.000, plate.alphaTop) }
            GradientStop { position: plate.breakAt;        color: Qt.rgba(0.914, 0.976, 1.000, plate.alphaTop * 0.94) }
            GradientStop { position: plate.breakAt + 0.01; color: Qt.rgba(0.671, 0.859, 0.965, plate.alphaBottom * 0.92) }
            GradientStop { position: 1.00; color: Qt.rgba(0.839, 0.949, 0.988, plate.alphaBottom) }
        }
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: plate.shadowTint
            shadowBlur: plate.shadowSize
            shadowVerticalOffset: 4
        }
    }

    Rectangle {
        visible: plate.shine
        anchors.horizontalCenter: parent.horizontalCenter
        y: 1
        width: Math.max(0, parent.width - plate.cornerRadius)
        height: 1
        color: Qt.rgba(1, 1, 1, 0.95)
    }
}
