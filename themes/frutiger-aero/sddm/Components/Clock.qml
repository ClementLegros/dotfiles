// Horloge : heure en gros, date en dessous. Le format de date passe par
// Qt.locale() plutôt que par la locale du système, car le greeter tourne
// sous l'utilisateur `sddm`, dont l'environnement est nu (LANG=C).
import QtQuick

Column {
    id: clock
    property string localeName: "fr_FR"
    spacing: 2

    readonly property var loc: Qt.locale(localeName)
    property date now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.now = new Date()
    }

    ShadedText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: clock.now.toLocaleTimeString(clock.loc, "HH:mm")
        font.family: "Inter"
        font.pixelSize: 92
        font.weight: Font.DemiBold
        font.letterSpacing: -2
    }

    ShadedText {
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#e8f7fe"
        text: {
            var d = clock.now.toLocaleDateString(clock.loc, "dddd d MMMM")
            return d.charAt(0).toUpperCase() + d.slice(1)
        }
        font.family: "Inter"
        font.pixelSize: 20
        font.weight: Font.Medium
    }
}
