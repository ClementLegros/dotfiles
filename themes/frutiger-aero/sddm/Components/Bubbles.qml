// Champ de bulles montantes. Chaque bulle tire sa taille, sa colonne, sa durée
// et son délai de départ au hasard : sans le délai, elles montent en rang
// d'oignons et l'illusion tombe.
import QtQuick

Item {
    id: field
    property int count: 16

    Repeater {
        model: field.count

        delegate: Bubble {
            id: b
            required property int index

            readonly property real s: 10 + Math.random() * 48
            readonly property real baseX: Math.random() * Math.max(1, field.width - s)

            width: s
            height: s
            x: baseX
            y: field.height + s
            opacity: 0.20 + Math.random() * 0.40

            SequentialAnimation on y {
                loops: Animation.Infinite
                running: true
                PauseAnimation { duration: Math.random() * 14000 }
                NumberAnimation {
                    from: field.height + b.s
                    to: -b.s
                    duration: 15000 + Math.random() * 20000
                }
            }

            // Dérive latérale : la bulle ne monte jamais droit.
            SequentialAnimation on x {
                loops: Animation.Infinite
                running: true
                NumberAnimation {
                    to: b.baseX + 18; duration: 4000 + Math.random() * 4000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: b.baseX - 18; duration: 4000 + Math.random() * 4000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
