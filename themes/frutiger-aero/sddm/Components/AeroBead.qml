// Le bouton-bille : une pastille de verre teintée, plus claire en haut,
// avec un reflet en demi-lune. C'est le bouton « Aqua/Aero » canonique.
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: bead

    property color tint: "#1e88e5"

    implicitWidth: 44
    implicitHeight: 44
    hoverEnabled: true
    display: AbstractButton.IconOnly

    icon.width: 19
    icon.height: 19
    icon.color: "#ffffff"

    scale: down ? 0.94 : (hovered ? 1.08 : 1.0)
    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

    background: Item {
        Rectangle {
            id: shell
            anchors.fill: parent
            radius: width / 2
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.9)
            gradient: Gradient {
                GradientStop { position: 0.00; color: Qt.lighter(bead.tint, 1.65) }
                GradientStop { position: 0.49; color: Qt.lighter(bead.tint, 1.15) }
                GradientStop { position: 0.50; color: bead.tint }
                GradientStop { position: 1.00; color: Qt.lighter(bead.tint, 1.30) }
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#8c041e33"
                shadowBlur: 0.7
                shadowVerticalOffset: 3
            }
        }
        // Le reflet : une demi-lune blanche qui ne couvre que le haut.
        Rectangle {
            x: parent.width * 0.15
            y: parent.height * 0.09
            width: parent.width * 0.70
            height: parent.height * 0.42
            radius: height / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.90) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.05) }
            }
        }
        // Halo au survol.
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 8
            height: parent.height + 8
            radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: Qt.rgba(1, 1, 1, 0.75)
            opacity: bead.hovered ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }
}
