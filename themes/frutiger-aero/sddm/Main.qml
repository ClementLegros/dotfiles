// ─── SDDM — Frutiger Aero ────────────────────────────────────────────────────
// Écran de connexion assorti au reste du thème (waybar.css, hyprlock.conf).
// Le greeter n'a pas de compositeur derrière lui : le flou du fond d'écran est
// donc fait ici, par QtQuick.Effects, et pas par Hyprland.
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Effects
import "Components"

Item {
    id: root
    width: Screen.width
    height: Screen.height

    // ── Palette (identique à waybar.css / hyprlock.conf du thème) ──
    readonly property color ink:   "#06355c"
    readonly property color inkdim:"#3d7ba6"
    readonly property color ocean: "#0b4c8c"
    readonly property color foam:  "#d6f2fb"
    readonly property color lime:  "#7cc93a"
    readonly property color sun:   "#f0a500"
    readonly property color coral: "#e8442f"

    property string errorText: ""

    // ── Utilisateurs ──
    // Instantiator plutôt qu'une ListView cachée : une vue sans hauteur
    // n'instancie aucun délégué, et `currentItem` resterait null.
    property int userIndex: userModel.lastIndex
    readonly property var currentUser: users.objectAt(userIndex)
    readonly property string userName: currentUser ? currentUser.name : userModel.lastUser
    readonly property string userLabel: currentUser
        ? (currentUser.realName.length > 0 ? currentUser.realName : currentUser.name)
        : userModel.lastUser

    Instantiator {
        id: users
        model: userModel
        delegate: QtObject {
            required property string name
            required property string realName
            required property string icon
        }
    }

    // ── Fond ──
    Rectangle {   // repli si l'image manque : un ciel, pas un écran noir
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#5ec2ee" }
            GradientStop { position: 0.6; color: "#a9e0f7" }
            GradientStop { position: 1.0; color: "#d6f2fb" }
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.Background
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: true
        mipmap: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        visible: wallpaper.status === Image.Ready
        blurEnabled: true
        blur: 1.0
        blurMax: parseInt(config.BlurRadius) || 42
        // Comme hyprlock : on ÉCLAIRCIT. Le verre Aero est une vitre embuée
        // devant une piscine, pas une vitre teintée.
        brightness: parseFloat(config.Brightness) || 0.06
        saturation: parseFloat(config.Saturation) || 0.18
    }

    // Voile de lumière en haut de l'écran.
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: parent.height * 0.45
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.30) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
        }
    }

    Bubbles {
        anchors.fill: parent
        count: parseInt(config.BubbleCount) || 0
    }

    // ── Horloge ──
    Clock {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.11
        visible: config.ClockEnabled === "true"
        localeName: config.Locale || "fr_FR"
    }

    // ── Carte de connexion ──
    Item {
        id: card
        width: 460
        // Hauteur fixe : elle sert de référence à la position de la cassure du
        // verre (voir breakAt plus bas), qui doit tomber entre l'avatar et le nom.
        height: 300
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 0
        y: root.height * 0.50

        GlassPlate {
            anchors.fill: parent
            cornerRadius: 26
            alphaTop: 0.82
            alphaBottom: 0.74
            shadowSize: 1.0
            breakAt: 0.44
        }

        Column {
            id: column
            anchors.centerIn: parent
            width: parent.width
            spacing: 14

            // Avatar : la photo du compte si l'utilisateur en a posé une,
            // sinon une bille de verre avec l'initiale — plus dans le ton que
            // l'avatar générique gris de SDDM.
            Item {
                width: 96; height: 96
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    id: disc
                    anchors.fill: parent
                    radius: width / 2
                    border.width: 2
                    border.color: Qt.rgba(1, 1, 1, 0.9)
                    gradient: Gradient {
                        GradientStop { position: 0.00; color: "#8fd6f7" }
                        GradientStop { position: 0.49; color: "#4fb3e8" }
                        GradientStop { position: 0.50; color: "#1e88e5" }
                        GradientStop { position: 1.00; color: "#57b0ea" }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: face.status !== Image.Ready
                    text: root.userLabel.length > 0 ? root.userLabel.charAt(0).toUpperCase() : "?"
                    color: "#ffffff"
                    font.family: "Inter"
                    font.pixelSize: 44
                    font.weight: Font.DemiBold
                }

                Image {
                    id: face
                    anchors.fill: parent
                    // Chemin utilisé quand l'utilisateur a réellement choisi un
                    // avatar (KDE/GNOME) ; sinon status = Error et on garde la bille.
                    source: "file:///var/lib/AccountsService/icons/" + root.userName
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                }
                Rectangle {
                    id: faceMask
                    anchors.fill: parent
                    radius: width / 2
                    color: "black"
                    visible: false
                    layer.enabled: true
                }
                MultiEffect {
                    anchors.fill: parent
                    source: face
                    visible: face.status === Image.Ready
                    maskEnabled: true
                    maskSource: faceMask
                }

                // Reflet du verre par-dessus, dans les deux cas.
                Rectangle {
                    x: parent.width * 0.16; y: parent.height * 0.08
                    width: parent.width * 0.68; height: parent.height * 0.36
                    radius: height / 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.75) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.03) }
                    }
                }
            }

            // Nom, encadré de flèches s'il y a plusieurs comptes.
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: userModel.count > 1
                    text: "‹"
                    color: root.inkdim
                    font.pixelSize: 26
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.userIndex = (root.userIndex - 1 + userModel.count) % userModel.count
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.userLabel
                    color: root.ink
                    font.family: "Inter"
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                    // Le reflet du texte « gravé dans le verre » : une ombre
                    // blanche d'1px vers le bas, comme dans waybar.css.
                    style: Text.Raised
                    styleColor: Qt.rgba(1, 1, 1, 0.8)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: userModel.count > 1
                    text: "›"
                    color: root.inkdim
                    font.pixelSize: 26
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.userIndex = (root.userIndex + 1) % userModel.count
                    }
                }
            }

            // ── Champ de saisie ── même dessin que hyprlock : pilule bleue,
            // liseré blanc, texte blanc.
            Item {
                id: pill
                width: 330
                height: 54
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Qt.rgba(0.043, 0.298, 0.549, password.activeFocus ? 0.66 : 0.52)
                    border.width: 2
                    border.color: Qt.rgba(1, 1, 1, password.activeFocus ? 0.95 : 0.75)
                    Behavior on color { ColorAnimation { duration: 160 } }
                }

                TextField {
                    id: password
                    anchors.fill: parent
                    leftPadding: 24
                    rightPadding: 58
                    focus: true
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    passwordMaskDelay: parseInt(config.PasswordShowLastLetter) || 0
                    selectByMouse: true
                    selectionColor: Qt.rgba(1, 1, 1, 0.35)
                    color: "#ffffff"
                    placeholderText: "Mot de passe…"
                    placeholderTextColor: Qt.rgba(0.839, 0.949, 0.988, 0.75)
                    font.family: "Inter"
                    font.pixelSize: 16
                    verticalAlignment: TextInput.AlignVCenter
                    background: Item {}
                    onAccepted: root.attemptLogin()
                    onTextChanged: root.errorText = ""
                }

                AeroBead {
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 42; height: 42
                    tint: root.lime
                    icon.source: Qt.resolvedUrl("icons/arrow.svg")
                    onClicked: root.attemptLogin()
                }
            }

            // Messages : erreur de login, ou verrouillage majuscule.
            Item {
                width: parent.width
                height: 18
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    visible: root.errorText.length > 0
                    text: root.errorText
                    color: root.coral
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.errorText.length === 0 && keyboard.capsLock
                    text: "⇪  Verrouillage majuscule activé"
                    color: "#b07400"
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                }
            }
        }

        // Secousse à l'échec : plus lisible qu'un simple message, l'œil est
        // sur le champ, pas sous la carte.
        SequentialAnimation {
            id: shake
            loops: 2
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to:  12; duration: 55 }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: -12; duration: 55 }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to:   0; duration: 55 }
        }
    }

    // ── Barre du bas ──
    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 30
        spacing: 12

        AeroBead {
            tint: root.coral
            visible: sddm.canPowerOff
            icon.source: Qt.resolvedUrl("icons/power.svg")
            ToolTip.visible: hovered; ToolTip.text: "Éteindre"
            onClicked: sddm.powerOff()
        }
        AeroBead {
            tint: root.sun
            visible: sddm.canReboot
            icon.source: Qt.resolvedUrl("icons/reboot.svg")
            ToolTip.visible: hovered; ToolTip.text: "Redémarrer"
            onClicked: sddm.reboot()
        }
        AeroBead {
            tint: "#1e88e5"
            visible: sddm.canSuspend
            icon.source: Qt.resolvedUrl("icons/sleep.svg")
            ToolTip.visible: hovered; ToolTip.text: "Veille"
            onClicked: sddm.suspend()
        }
    }

    SessionPicker {
        id: sessionPicker
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 30
    }

    // ── Connexion ──
    function attemptLogin() {
        if (root.userName.length === 0)
            return
        root.errorText = ""
        sddm.login(root.userName, password.text, sessionPicker.index)
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.errorText = "Mot de passe incorrect"
            password.text = ""
            password.forceActiveFocus()
            shake.restart()
        }

        function onLoginSucceeded() {
            fadeOut.start()
        }

        function onInformationMessage(message) {
            root.errorText = message
        }
    }

    NumberAnimation {
        id: fadeOut
        target: root
        property: "opacity"
        to: 0
        duration: 350
        easing.type: Easing.OutCubic
    }

    Component.onCompleted: password.forceActiveFocus()
}
