// Texte blanc + ombre portée bleu nuit. Sur un fond d'écran clair — et un
// ciel Aero l'est toujours — du blanc sans ombre est illisible. Même parti
// pris que hyprlock.conf du thème.
import QtQuick
import QtQuick.Effects

Text {
    color: "#ffffff"
    renderType: Text.NativeRendering
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#99041e33"
        shadowBlur: 0.7
        shadowVerticalOffset: 2
    }
}
