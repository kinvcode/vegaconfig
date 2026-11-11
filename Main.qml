import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import vegaconfig

ApplicationWindow {
    id: win
    width: 1120
    height: 780
    minimumWidth: 980
    minimumHeight: 680
    visible: true
    title: store.dirty ? "Vega 配置修改器 *" : "Vega 配置修改器"
    color: Qt.rgba(shellRgb.r, shellRgb.g, shellRgb.b, cornerAlpha)
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.WindowMinimizeButtonHint
    font.family: "Microsoft YaHei UI"
    font.pixelSize: 13

    property bool allowClose: false
    property string pending: ""
    property int navIndex: 0
    property bool pointerInside: false
    readonly property color shellRgb: "#07101c"
    readonly property real shellRestAlpha: 0xD8 / 255
    property real shellAlpha: pointerInside ? 1 : shellRestAlpha
    property real cornerAlpha: pointerInside ? 1 : 0

    Behavior on shellAlpha { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    Behavior on cornerAlpha { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    readonly property var dungeonModel: [
        { "code": 100002965, "name": "海伯伦的预言" },
        { "code": 100005064, "name": "千海天" },
        { "code": 100005062, "name": "生命巡礼" },
        { "code": 100005063, "name": "光辉巡礼" }
    ]
    readonly property var loginModel: ["手动登录", "协议登录"]
    readonly property var platformModel: ["超级鹰", "自训练"]
    readonly property var actionModel: ["不识别退出游戏", "识别后继续运行", "识别后退出游戏", "识别后关机", "识别后重启"]
    readonly property var equipModel: ["出售", "分解"]
    readonly property var difficultyModel: ["普通", "冒险", "勇士", "王者", "噩梦"]
    readonly property var navModel: [
        { "name": "基础", "hint": "机器与运行", "accent": "#3ee0ff" },
        { "name": "登录", "hint": "账号与目录", "accent": "#b388ff" },
        { "name": "验证码", "hint": "识别平台", "accent": "#ffb020" },
        { "name": "自动", "hint": "刷图策略", "accent": "#3dffb0" },
        { "name": "装备", "hint": "BUFF 数值", "accent": "#ff4fd8" }
    ]
    readonly property color pageAccent: navModel[navIndex].accent

    ConfigStore { id: store }

    component NeonButton: Button {
        id: btn
        property color accent: "#3ee0ff"
        property bool primary: false
        implicitHeight: 34
        leftPadding: 14
        rightPadding: 14
        font.pixelSize: 13
        hoverEnabled: true
        contentItem: Text {
            text: btn.text
            color: btn.primary ? "#061018" : (btn.down ? "#ffffff" : btn.accent)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font: btn.font
        }
        background: Rectangle {
            radius: 9
            color: {
                if (btn.primary)
                    return btn.down ? Qt.darker(btn.accent, 1.15) : (btn.hovered ? Qt.lighter(btn.accent, 1.12) : btn.accent)
                return btn.hovered ? Qt.rgba(btn.accent.r, btn.accent.g, btn.accent.b, 0.22) : Qt.rgba(btn.accent.r, btn.accent.g, btn.accent.b, 0.08)
            }
            border.color: btn.accent
            border.width: 1
        }
    }

    component NeonCheck: CheckBox {
        id: box
        property color accent: "#3ee0ff"
        indicator: Rectangle {
            implicitWidth: 18
            implicitHeight: 18
            radius: 5
            y: box.height / 2 - height / 2
            color: box.checked ? Qt.rgba(box.accent.r, box.accent.g, box.accent.b, 0.22) : "#0c1428aa"
            border.color: box.checked ? box.accent : "#ffffff33"
            border.width: 1
            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 8
                radius: 2
                color: box.accent
                visible: box.checked
            }
        }
        contentItem: Text {
            text: box.text
            color: box.checked ? "#f4f8ff" : "#b7c7e2"
            font: box.font
            leftPadding: box.indicator.width + box.spacing
            verticalAlignment: Text.AlignVCenter
        }
    }

    component GlassCombo: ComboBox {
        id: combo
        implicitHeight: 34
        leftPadding: 12
        rightPadding: 28
        font.pixelSize: 13
        hoverEnabled: true
        contentItem: Text {
            text: combo.displayText
            color: "#eef6ff"
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            leftPadding: 12
            font: combo.font
        }
        indicator: Text {
            x: combo.width - width - 10
            y: combo.topPadding + (combo.availableHeight - height) / 2
            text: "▾"
            color: win.pageAccent
            font.pixelSize: 11
        }
        background: Rectangle {
            radius: 8
            color: combo.hovered || combo.popup.visible ? "#1a2744e6" : "#101828d0"
            border.color: combo.visualFocus || combo.popup.visible ? win.pageAccent : "#ffffff28"
            border.width: 1
        }
        delegate: ItemDelegate {
            width: combo.width
            height: 32
            highlighted: combo.highlightedIndex === index
            contentItem: Text {
                text: combo.textAt(index)
                color: highlighted ? "#071018" : "#e7f2ff"
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
                font.pixelSize: 13
            }
            background: Rectangle {
                radius: 6
                color: highlighted ? win.pageAccent : "transparent"
            }
        }
        popup: Popup {
            y: combo.height + 6
            width: combo.width
            implicitHeight: Math.min(contentItem.implicitHeight + 8, 240)
            padding: 4
            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: combo.popup.visible ? combo.delegateModel : null
                currentIndex: combo.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator { }
            }
            background: Rectangle {
                radius: 10
                color: "#10182ef5"
                border.color: Qt.rgba(win.pageAccent.r, win.pageAccent.g, win.pageAccent.b, 0.7)
                border.width: 1
            }
        }
    }

    component IntField: RowLayout {
        property string label
        property alias text: input.text
        property alias editor: input
        property int minValue: 0
        property int maxValue: 99999999
        Layout.fillWidth: true
        Label {
            text: label
            color: "#9eb4d6"
            Layout.preferredWidth: 132
        }
        TextField {
            id: input
            Layout.fillWidth: true
            implicitHeight: 34
            selectByMouse: true
            color: "#f3f8ff"
            placeholderTextColor: "#6d82a8"
            font.pixelSize: 13
            validator: IntValidator {
                bottom: minValue
                top: maxValue
            }
            inputMethodHints: Qt.ImhDigitsOnly
            onTextEdited: win.noteEdit()
            background: Rectangle {
                radius: 8
                color: input.activeFocus ? "#182844ee" : "#101828cc"
                border.color: input.activeFocus ? win.pageAccent : "#ffffff26"
                border.width: 1
            }
        }
    }

    component TextRow: RowLayout {
        property string label
        property alias text: input.text
        property alias editor: input
        property int echoMode: TextInput.Normal
        Layout.fillWidth: true
        Label {
            text: label
            color: "#9eb4d6"
            Layout.preferredWidth: 132
        }
        TextField {
            id: input
            Layout.fillWidth: true
            implicitHeight: 34
            selectByMouse: true
            color: "#f3f8ff"
            placeholderTextColor: "#6d82a8"
            font.pixelSize: 13
            echoMode: parent.echoMode
            onTextEdited: win.noteEdit()
            background: Rectangle {
                radius: 8
                color: input.activeFocus ? "#182844ee" : "#101828cc"
                border.color: input.activeFocus ? win.pageAccent : "#ffffff26"
                border.width: 1
            }
        }
        NeonCheck {
            visible: echoMode === TextInput.Password
            text: "显示"
            accent: "#b388ff"
            onToggled: input.echoMode = checked ? TextInput.Normal : TextInput.Password
        }
    }

    component GlassCard: GroupBox {
        id: card
        property color accent: "#3ee0ff"
        Layout.fillWidth: true
        topPadding: 36
        leftPadding: 16
        rightPadding: 16
        bottomPadding: 14
        label: Text {
            x: 16
            y: 10
            text: card.title
            color: card.accent
            font.bold: true
            font.pixelSize: 13
        }
        background: Rectangle {
            y: 4
            width: parent.width
            height: parent.height - 4
            radius: 16
            color: "#10192cc4"
            border.width: 1
            border.color: Qt.rgba(card.accent.r, card.accent.g, card.accent.b, 0.55)
            Rectangle {
                width: 3
                height: parent.height - 22
                radius: 2
                anchors.left: parent.left
                anchors.leftMargin: 1
                anchors.verticalCenter: parent.verticalCenter
                color: card.accent
            }
        }
    }

    function noteEdit() { store.markDirty() }

    function mustInt(editor, label) {
        if (editor.text.trim() === "" || !editor.acceptableInput) {
            store.setStatus(label + " 填写无效", true)
            editor.forceActiveFocus()
            return NaN
        }
        return parseInt(editor.text, 10)
    }

    function selectIndex(combo, value, maxIndex) {
        let index = Number(value)
        if (!isFinite(index) || index < 0 || index > maxIndex)
            index = 0
        combo.currentIndex = index
    }

    function selectMap(combo, code) {
        const mapCode = Number(code)
        if (!mapCode) {
            combo.currentIndex = 0
            return
        }
        for (let i = 0; i < dungeonModel.length; ++i) {
            if (dungeonModel[i].code === mapCode) {
                combo.currentIndex = i
                return
            }
        }
        combo.currentIndex = -1
    }

    function mapCode(combo, keyPath) {
        if (combo.currentIndex < 0)
            return store.value(keyPath)
        return dungeonModel[combo.currentIndex].code
    }

    function pull() {
        identifierField.text = String(store.value("BindMachine/Identifier") ?? "")
        stopUsersField.text = String(store.value("BaseSet/stop_users"))
        timeoutField.text = String(store.value("BaseSet/dungeon_timeout"))
        shutdownBox.checked = !!store.value("BaseSet/shutdown_after_finishing")
        backpackBox.checked = !!store.value("BaseSet/clean_backpack")
        neoEquipBox.checked = !!store.value("BaseSet/neo_wear_equipment")
        roleIndexField.text = String(store.value("BaseSet/play_role_index"))
        switchTimeField.text = String(store.value("Timestamp/switch_role_time"))

        selectIndex(loginCombo, store.value("GameLogin/login_type"), 1)
        accountField.text = String(store.value("GameLogin/game_account") ?? "")
        passwordField.text = String(store.value("GameLogin/game_password") ?? "")
        otpField.text = String(store.value("GameLogin/OTP_SECRET") ?? "")
        launcherField.text = String(store.value("GameLogin/neoplelauncher_path") ?? "")
        emailField.text = String(store.value("GameLogin/email_account") ?? "")
        emailPasswordField.text = String(store.value("GameLogin/email_password") ?? "")
        helpEmailField.text = String(store.value("GameLogin/help_email_account") ?? "")
        helpEmailPasswordField.text = String(store.value("GameLogin/help_email_password") ?? "")
        vipNameField.text = String(store.value("VIPLogin/ms_name") ?? "")
        vipPasswordField.text = String(store.value("VIPLogin/ms_password") ?? "")
        qqField.text = String(store.value("VIPLogin/qq") ?? "")

        selectIndex(platformCombo, store.value("CAPTCHA/verify_platform"), 1)
        selectIndex(actionCombo, store.value("CAPTCHA/verify_action"), 4)
        cjyAccountField.text = String(store.value("CAPTCHA/cjy_account") ?? "")
        cjyPasswordField.text = String(store.value("CAPTCHA/cjy_password") ?? "")

        doomBox.checked = !!store.value("AutoModeSwitch/doom")
        doomProBox.checked = !!store.value("AutoModeSwitch/doom_pro")
        uplevelBox.checked = !!store.value("AutoModeSwitch/uplevel")
        clean1Box.checked = !!store.value("AutoModeSwitch/cleandungeon")
        clean2Box.checked = !!store.value("AutoModeSwitch/cleandungeon2")
        doomOracleField.text = String(store.value("AutoModeDoom/oracle_num"))
        doomProOracleField.text = String(store.value("AutoModeDoomPro/oracle_num"))
        weightField.text = String(store.value("AutoModeDoomPro/weight_num"))
        upMinField.text = String(store.value("AutoModeUpLevel/min_level"))
        upMaxField.text = String(store.value("AutoModeUpLevel/max_level"))
        c1MinLevel.text = String(store.value("AutoModeCleanDungeon/min_level"))
        c1MaxLevel.text = String(store.value("AutoModeCleanDungeon/max_level"))
        c1MinFame.text = String(store.value("AutoModeCleanDungeon/min_fame"))
        c1MaxFame.text = String(store.value("AutoModeCleanDungeon/max_fame"))
        selectMap(c1Map, store.value("AutoModeCleanDungeon/dungeon_map"))
        selectIndex(c1Difficulty, store.value("AutoModeCleanDungeon/dungeon_difficulty"), 4)
        c2MinLevel.text = String(store.value("AutoModeCleanDungeon2/min_level"))
        c2MaxLevel.text = String(store.value("AutoModeCleanDungeon2/max_level"))
        c2MinFame.text = String(store.value("AutoModeCleanDungeon2/min_fame"))
        c2MaxFame.text = String(store.value("AutoModeCleanDungeon2/max_fame"))
        selectMap(c2Map, store.value("AutoModeCleanDungeon2/dungeon_map"))
        selectIndex(c2Difficulty, store.value("AutoModeCleanDungeon2/dungeon_difficulty"), 4)

        selectIndex(rareCombo, store.value("ProcessingEquip/rare"), 1)
        selectIndex(uniqueCombo, store.value("ProcessingEquip/unique"), 1)
        selectIndex(epicCombo, store.value("ProcessingEquip/epic"), 1)
        damageField.text = String(store.value("CustomBUFF/overall_damage"))
        hpField.text = String(store.value("CustomBUFF/max_hp"))
        mpField.text = String(store.value("CustomBUFF/max_mp"))
        attackField.text = String(store.value("CustomBUFF/attack_speed"))
        castField.text = String(store.value("CustomBUFF/casting_speed"))
        moveField.text = String(store.value("CustomBUFF/movement_speed"))
        signedLabel.text = "SIG " + String(store.value("signed") ?? "")
    }

    function push() {
        const numbers = [
            [stopUsersField.editor, "停止角色数"],
            [timeoutField.editor, "副本超时"],
            [roleIndexField.editor, "当前角色序号"],
            [switchTimeField.editor, "切换角色时间"],
            [doomOracleField.editor, "最终调律深渊票"],
            [doomProOracleField.editor, "调律边界深渊票"],
            [weightField.editor, "砝码数量"],
            [upMinField.editor, "自动升级最低等级"],
            [upMaxField.editor, "自动升级最高等级"],
            [c1MinLevel.editor, "搬砖地图1最低等级"],
            [c1MaxLevel.editor, "搬砖地图1最高等级"],
            [c1MinFame.editor, "搬砖地图1最低名望"],
            [c1MaxFame.editor, "搬砖地图1最高名望"],
            [c2MinLevel.editor, "搬砖地图2最低等级"],
            [c2MaxLevel.editor, "搬砖地图2最高等级"],
            [c2MinFame.editor, "搬砖地图2最低名望"],
            [c2MaxFame.editor, "搬砖地图2最高名望"],
            [damageField.editor, "总伤害"],
            [hpField.editor, "最大生命"],
            [mpField.editor, "最大魔法"],
            [attackField.editor, "攻击速度"],
            [castField.editor, "施放速度"],
            [moveField.editor, "移动速度"]
        ]
        const parsed = []
        for (let i = 0; i < numbers.length; ++i) {
            const n = mustInt(numbers[i][0], numbers[i][1])
            if (isNaN(n))
                return false
            parsed.push(n)
        }

        store.setValue("BindMachine/Identifier", identifierField.text)
        store.setValue("BaseSet/stop_users", parsed[0])
        store.setValue("BaseSet/dungeon_timeout", parsed[1])
        store.setValue("BaseSet/shutdown_after_finishing", shutdownBox.checked)
        store.setValue("BaseSet/clean_backpack", backpackBox.checked)
        store.setValue("BaseSet/neo_wear_equipment", neoEquipBox.checked)
        store.setValue("BaseSet/play_role_index", parsed[2])
        store.setValue("Timestamp/switch_role_time", parsed[3])

        store.setValue("GameLogin/login_type", loginCombo.currentIndex)
        store.setValue("GameLogin/game_account", accountField.text)
        store.setValue("GameLogin/game_password", passwordField.text)
        store.setValue("GameLogin/OTP_SECRET", otpField.text)
        store.setValue("GameLogin/neoplelauncher_path", launcherField.text)
        store.setValue("GameLogin/email_account", emailField.text)
        store.setValue("GameLogin/email_password", emailPasswordField.text)
        store.setValue("GameLogin/help_email_account", helpEmailField.text)
        store.setValue("GameLogin/help_email_password", helpEmailPasswordField.text)
        store.setValue("VIPLogin/ms_name", vipNameField.text)
        store.setValue("VIPLogin/ms_password", vipPasswordField.text)
        store.setValue("VIPLogin/qq", qqField.text)

        store.setValue("CAPTCHA/verify_platform", platformCombo.currentIndex)
        store.setValue("CAPTCHA/verify_action", actionCombo.currentIndex)
        store.setValue("CAPTCHA/cjy_account", cjyAccountField.text)
        store.setValue("CAPTCHA/cjy_password", cjyPasswordField.text)

        store.setValue("AutoModeSwitch/doom", doomBox.checked)
        store.setValue("AutoModeSwitch/doom_pro", doomProBox.checked)
        store.setValue("AutoModeSwitch/uplevel", uplevelBox.checked)
        store.setValue("AutoModeSwitch/cleandungeon", clean1Box.checked)
        store.setValue("AutoModeSwitch/cleandungeon2", clean2Box.checked)
        store.setValue("AutoModeDoom/oracle_num", parsed[4])
        store.setValue("AutoModeDoomPro/oracle_num", parsed[5])
        store.setValue("AutoModeDoomPro/weight_num", parsed[6])
        store.setValue("AutoModeUpLevel/min_level", parsed[7])
        store.setValue("AutoModeUpLevel/max_level", parsed[8])
        store.setValue("AutoModeCleanDungeon/min_level", parsed[9])
        store.setValue("AutoModeCleanDungeon/max_level", parsed[10])
        store.setValue("AutoModeCleanDungeon/min_fame", parsed[11])
        store.setValue("AutoModeCleanDungeon/max_fame", parsed[12])
        store.setValue("AutoModeCleanDungeon/dungeon_map", mapCode(c1Map, "AutoModeCleanDungeon/dungeon_map"))
        store.setValue("AutoModeCleanDungeon/dungeon_difficulty", c1Difficulty.currentIndex)
        store.setValue("AutoModeCleanDungeon2/min_level", parsed[13])
        store.setValue("AutoModeCleanDungeon2/max_level", parsed[14])
        store.setValue("AutoModeCleanDungeon2/min_fame", parsed[15])
        store.setValue("AutoModeCleanDungeon2/max_fame", parsed[16])
        store.setValue("AutoModeCleanDungeon2/dungeon_map", mapCode(c2Map, "AutoModeCleanDungeon2/dungeon_map"))
        store.setValue("AutoModeCleanDungeon2/dungeon_difficulty", c2Difficulty.currentIndex)

        store.setValue("ProcessingEquip/rare", rareCombo.currentIndex)
        store.setValue("ProcessingEquip/unique", uniqueCombo.currentIndex)
        store.setValue("ProcessingEquip/epic", epicCombo.currentIndex)
        store.setValue("CustomBUFF/overall_damage", parsed[17])
        store.setValue("CustomBUFF/max_hp", parsed[18])
        store.setValue("CustomBUFF/max_mp", parsed[19])
        store.setValue("CustomBUFF/attack_speed", parsed[20])
        store.setValue("CustomBUFF/casting_speed", parsed[21])
        store.setValue("CustomBUFF/movement_speed", parsed[22])
        return true
    }

    function pushAndSave() {
        if (!push())
            return false
        return store.save()
    }

    function doOpen() {
        const path = store.pickConfigOpen()
        if (path)
            store.load(path)
    }

    function doSaveAs() {
        const path = store.pickConfigSave()
        if (!path)
            return
        if (!push())
            return
        store.saveAs(path)
    }

    function runPending(action) {
        if (action === "open")
            doOpen()
        else if (action === "reset")
            store.resetDefaults()
        else if (action === "close")
            win.close()
    }

    function requestAction(action) {
        if (store.dirty && action !== "save") {
            pending = action
            discardDialog.open()
            return
        }
        runPending(action)
    }

    Connections {
        target: store
        function onLoaded() { pull() }
    }

    Component.onCompleted: store.loadStartup()

    Shortcut {
        sequences: [StandardKey.Save]
        onActivated: pushAndSave()
    }
    Shortcut {
        sequences: [StandardKey.Open]
        onActivated: requestAction("open")
    }

    onClosing: function(close) {
        if (allowClose || !store.dirty)
            return
        close.accepted = false
        requestAction("close")
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: 18
            color: Qt.rgba(win.shellRgb.r, win.shellRgb.g, win.shellRgb.b, win.shellAlpha)
            border.color: "#ffffff18"
            border.width: 1
        }
        Rectangle {
            width: 460
            height: 460
            radius: 230
            x: -120
            y: -160
            color: "#1aa7ff"
            opacity: 0.28
        }
        Rectangle {
            width: 380
            height: 380
            radius: 190
            x: parent.width - 220
            y: 40
            color: "#b14bff"
            opacity: 0.22
        }
        Rectangle {
            width: 320
            height: 320
            radius: 160
            x: parent.width * 0.35
            y: parent.height - 180
            color: "#18e0a0"
            opacity: 0.16
        }
        Rectangle {
            width: 220
            height: 220
            radius: 110
            x: parent.width * 0.55
            y: -40
            color: "#ff4f9a"
            opacity: 0.16
        }
        Canvas {
            id: grid
            anchors.fill: parent
            opacity: 0.18
            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "#8fd8ff"
                ctx.lineWidth = 1
                ctx.beginPath()
                for (let x = 0; x <= width; x += 42) {
                    ctx.moveTo(x, 0)
                    ctx.lineTo(x, height)
                }
                for (let y = 0; y <= height; y += 42) {
                    ctx.moveTo(0, y)
                    ctx.lineTo(width, y)
                }
                ctx.stroke()
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Component.onCompleted: requestPaint()
        }
    }

    Dialog {
        id: discardDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        modal: true
        title: "未保存的修改"
        padding: 18
        standardButtons: Dialog.NoButton
        Overlay.modal: Rectangle { color: "#050910b0" }
        background: Rectangle {
            radius: 16
            color: "#10182ef2"
            border.color: "#3ee0ff"
            border.width: 1
        }
        header: Label {
            text: "未保存的修改"
            color: "#3ee0ff"
            font.bold: true
            font.pixelSize: 15
            leftPadding: 18
            topPadding: 14
        }
        contentItem: Label {
            text: "当前配置已修改。保存后再继续？"
            color: "#d5e4ff"
            wrapMode: Text.WordWrap
        }
        footer: RowLayout {
            spacing: 8
            NeonButton {
                text: "保存"
                primary: true
                accent: "#3ee0ff"
                onClicked: discardDialog.accept()
            }
            NeonButton {
                text: "不保存"
                accent: "#ffb020"
                onClicked: {
                    const action = pending
                    pending = ""
                    discardDialog.close()
                    if (action === "close")
                        allowClose = true
                    runPending(action)
                }
            }
            NeonButton {
                text: "取消"
                accent: "#ff5d8a"
                onClicked: discardDialog.reject()
            }
            Item { Layout.fillWidth: true }
        }
        onAccepted: {
            const action = pending
            pending = ""
            if (pushAndSave()) {
                if (action === "close")
                    allowClose = true
                runPending(action)
            }
        }
        onDiscarded: {
            const action = pending
            pending = ""
            if (action === "close")
                allowClose = true
            runPending(action)
        }
        onRejected: pending = ""
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 188
            Layout.fillHeight: true
            radius: 16
            color: "#0c1428b8"
            border.color: "#ffffff22"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        color: "#3ee0ff"
                        Text {
                            anchors.centerIn: parent
                            text: "V"
                            color: "#061018"
                            font.bold: true
                            font.pixelSize: 16
                        }
                    }
                    ColumnLayout {
                        spacing: 0
                        Label {
                            text: "VEGA"
                            color: "#f4f8ff"
                            font.bold: true
                            font.pixelSize: 16
                            font.letterSpacing: 2
                        }
                        Label {
                            text: "CONFIG"
                            color: "#7f93b5"
                            font.pixelSize: 10
                            font.letterSpacing: 3
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 2
                    radius: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#3ee0ff" }
                        GradientStop { position: 0.5; color: "#b388ff" }
                        GradientStop { position: 1.0; color: "#ff4fd8" }
                    }
                }

                Repeater {
                    model: win.navModel.length
                    delegate: Rectangle {
                        required property int index
                        readonly property var item: win.navModel[index]
                        readonly property color tint: item.accent
                        Layout.fillWidth: true
                        implicitHeight: 52
                        radius: 12
                        color: win.navIndex === index ? Qt.rgba(tint.r, tint.g, tint.b, 0.22) : (hover.hovered ? "#ffffff12" : "transparent")
                        border.color: win.navIndex === index ? tint : "transparent"
                        border.width: 1
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 10
                            Rectangle {
                                width: 4
                                height: 28
                                radius: 2
                                anchors.verticalCenter: parent.verticalCenter
                                color: tint
                                opacity: win.navIndex === index ? 1 : 0.35
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1
                                Text {
                                    text: item.name
                                    color: win.navIndex === index ? "#ffffff" : "#d5e2f7"
                                    font.pixelSize: 14
                                    font.bold: win.navIndex === index
                                }
                                Text {
                                    text: item.hint
                                    color: "#89a0c4"
                                    font.pixelSize: 11
                                }
                            }
                        }
                        HoverHandler { id: hover }
                        TapHandler { onTapped: win.navIndex = index }
                    }
                }

                Item { Layout.fillHeight: true }

                Label {
                    text: store.dirty ? "有未保存修改" : "配置已同步"
                    color: store.dirty ? "#ffb020" : "#3dffb0"
                    font.pixelSize: 12
                }
                Label {
                    id: signedLabel
                    visible: true
                    text: "SIG"
                    color: "#6f84a8"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Label {
                    text: win.navModel[win.navIndex].name
                    color: win.pageAccent
                    font.pixelSize: 22
                    font.bold: true
                }
                Label {
                    text: win.navModel[win.navIndex].hint
                    color: "#8ea3c6"
                    font.pixelSize: 12
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    MouseArea {
                        anchors.fill: parent
                        onPressed: win.startSystemMove()
                    }
                }
                NeonButton { text: "打开"; accent: "#3ee0ff"; onClicked: requestAction("open") }
                NeonButton { text: "保存"; accent: "#3dffb0"; primary: true; onClicked: pushAndSave() }
                NeonButton { text: "另存为"; accent: "#b388ff"; onClicked: doSaveAs() }
                NeonButton { text: "恢复默认"; accent: "#ffb020"; onClicked: requestAction("reset") }
                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 8
                    color: minHover.hovered ? "#ffffff18" : "transparent"
                    Text { anchors.centerIn: parent; text: "—"; color: "#d5e4ff" }
                    HoverHandler { id: minHover }
                    TapHandler { onTapped: win.showMinimized() }
                }
                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 8
                    color: maxHover.hovered ? "#ffffff18" : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: win.visibility === Window.Maximized ? "❐" : "□"
                        color: "#d5e4ff"
                    }
                    HoverHandler { id: maxHover }
                    TapHandler {
                        onTapped: win.visibility === Window.Maximized ? win.showNormal() : win.showMaximized()
                    }
                }
                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 8
                    color: closeHover.hovered ? "#ff4d6a" : "transparent"
                    Text { anchors.centerIn: parent; text: "×"; color: "#ffe8ee"; font.pixelSize: 16 }
                    HoverHandler { id: closeHover }
                    TapHandler { onTapped: win.close() }
                }
            }

            TextField {
                id: pathField
                Layout.fillWidth: true
                readOnly: true
                text: store.filePath
                selectByMouse: true
                color: "#d5e6ff"
                placeholderText: "尚未选择 config.json"
                placeholderTextColor: "#6d82a8"
                background: Rectangle {
                    radius: 10
                    color: "#101828aa"
                    border.color: "#ffffff22"
                    border.width: 1
                }
            }

            StackLayout {
                currentIndex: win.navIndex
                Layout.fillWidth: true
                Layout.fillHeight: true

                ScrollView {
                    id: basePage
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: basePage.availableWidth
                        spacing: 12
                        GlassCard {
                            title: "机器绑定"
                            accent: "#3ee0ff"
                            ColumnLayout {
                                width: parent.width
                                TextRow { id: identifierField; label: "机器编号" }
                            }
                        }
                        GlassCard {
                            title: "基础设置"
                            accent: "#b388ff"
                            GridLayout {
                                columns: 2
                                columnSpacing: 18
                                rowSpacing: 8
                                width: parent.width
                                IntField { id: stopUsersField; label: "停止角色数"; maxValue: 999 }
                                IntField { id: timeoutField; label: "副本超时(秒)"; minValue: 1; maxValue: 86400 }
                                NeonCheck { id: shutdownBox; text: "刷完关机"; accent: "#ff5d8a"; onClicked: win.noteEdit() }
                                NeonCheck { id: backpackBox; text: "整理背包"; accent: "#3dffb0"; onClicked: win.noteEdit() }
                                NeonCheck { id: neoEquipBox; text: "穿戴会员装备"; accent: "#ffb020"; Layout.columnSpan: 2; onClicked: win.noteEdit() }
                            }
                        }
                        GlassCard {
                            title: "运行状态"
                            accent: "#ffb020"
                            ColumnLayout {
                                width: parent.width
                                Label {
                                    text: "角色序号和切换时间由 Vega 运行时写入。0 表示从第一个角色开始。"
                                    color: "#8ea3c6"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                                GridLayout {
                                    columns: 2
                                    columnSpacing: 18
                                    rowSpacing: 8
                                    Layout.fillWidth: true
                                    IntField { id: roleIndexField; label: "当前角色序号"; maxValue: 999 }
                                    IntField { id: switchTimeField; label: "切换角色时间"; maxValue: 2147483647 }
                                }
                            }
                        }
                    }
                }

                ScrollView {
                    id: loginPage
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: loginPage.availableWidth
                        spacing: 12
                        GlassCard {
                            title: "自动登录"
                            accent: "#3ee0ff"
                            ColumnLayout {
                                width: parent.width
                                spacing: 8
                                RowLayout {
                                    Layout.fillWidth: true
                                    Label { text: "登录方式"; color: "#9eb4d6"; Layout.preferredWidth: 132 }
                                    GlassCombo { id: loginCombo; model: win.loginModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                                }
                                TextRow { id: accountField; label: "游戏账号" }
                                TextRow { id: passwordField; label: "游戏密码"; echoMode: TextInput.Password }
                                TextRow { id: otpField; label: "OTP秘钥"; echoMode: TextInput.Password }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Label { text: "游戏目录"; color: "#9eb4d6"; Layout.preferredWidth: 132 }
                                    TextField {
                                        id: launcherField
                                        Layout.fillWidth: true
                                        implicitHeight: 34
                                        selectByMouse: true
                                        color: "#f3f8ff"
                                        placeholderText: "NeopleLauncher.exe"
                                        placeholderTextColor: "#6d82a8"
                                        onTextEdited: win.noteEdit()
                                        background: Rectangle {
                                            radius: 8
                                            color: launcherField.activeFocus ? "#182844ee" : "#101828cc"
                                            border.color: launcherField.activeFocus ? win.pageAccent : "#ffffff26"
                                            border.width: 1
                                        }
                                    }
                                    NeonButton {
                                        text: "浏览"
                                        accent: "#3ee0ff"
                                        onClicked: {
                                            const path = store.pickLauncher()
                                            if (path) {
                                                launcherField.text = path
                                                win.noteEdit()
                                            }
                                        }
                                    }
                                    NeonButton {
                                        text: "读注册表"
                                        accent: "#b388ff"
                                        onClicked: {
                                            const path = store.launcherFromRegistry()
                                            if (path) {
                                                launcherField.text = path
                                                win.noteEdit()
                                            } else {
                                                store.setStatus("注册表中没有找到游戏目录", true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        GlassCard {
                            title: "邮箱"
                            accent: "#ff4fd8"
                            GridLayout {
                                columns: 2
                                columnSpacing: 18
                                rowSpacing: 8
                                width: parent.width
                                TextRow { id: emailField; label: "邮箱账号" }
                                TextRow { id: emailPasswordField; label: "邮箱密码"; echoMode: TextInput.Password }
                                TextRow { id: helpEmailField; label: "辅助邮箱账号" }
                                TextRow { id: helpEmailPasswordField; label: "辅助邮箱密码"; echoMode: TextInput.Password }
                            }
                        }
                        GlassCard {
                            title: "会员登录"
                            accent: "#ffb020"
                            GridLayout {
                                columns: 2
                                columnSpacing: 18
                                rowSpacing: 8
                                width: parent.width
                                TextRow { id: vipNameField; label: "会员账号" }
                                TextRow { id: vipPasswordField; label: "会员密码"; echoMode: TextInput.Password }
                                TextRow { id: qqField; label: "QQ"; Layout.columnSpan: 2 }
                            }
                        }
                    }
                }

                ScrollView {
                    id: captchaPage
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: captchaPage.availableWidth
                        GlassCard {
                            title: "验证码处理"
                            accent: "#ffb020"
                            ColumnLayout {
                                width: parent.width
                                spacing: 8
                                RowLayout {
                                    Layout.fillWidth: true
                                    Label { text: "识别平台"; color: "#9eb4d6"; Layout.preferredWidth: 132 }
                                    GlassCombo {
                                        id: platformCombo
                                        model: win.platformModel
                                        Layout.preferredWidth: 220
                                        onActivated: win.noteEdit()
                                    }
                                    Label { text: "验证操作"; color: "#9eb4d6"; Layout.leftMargin: 12 }
                                    GlassCombo {
                                        id: actionCombo
                                        model: win.actionModel
                                        Layout.fillWidth: true
                                        onActivated: win.noteEdit()
                                    }
                                }
                                TextRow { id: cjyAccountField; label: "API账号" }
                                TextRow { id: cjyPasswordField; label: "API密码"; echoMode: TextInput.Password }
                            }
                        }
                    }
                }

                ScrollView {
                    id: autoPage
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: autoPage.availableWidth
                        spacing: 12
                        GlassCard {
                            title: "模式开关"
                            accent: "#3dffb0"
                            RowLayout {
                                NeonCheck { id: doomBox; text: "最终调律"; accent: "#3ee0ff"; onClicked: win.noteEdit() }
                                NeonCheck { id: doomProBox; text: "调律边界"; accent: "#b388ff"; onClicked: win.noteEdit() }
                                NeonCheck { id: uplevelBox; text: "自动升级"; accent: "#ffb020"; onClicked: win.noteEdit() }
                                NeonCheck { id: clean1Box; text: "搬砖地图1"; accent: "#3dffb0"; onClicked: win.noteEdit() }
                                NeonCheck { id: clean2Box; text: "搬砖地图2"; accent: "#ff4fd8"; onClicked: win.noteEdit() }
                            }
                        }
                        GlassCard {
                            title: "最终调律 / 调律边界"
                            accent: "#3ee0ff"
                            GridLayout {
                                columns: 2
                                columnSpacing: 18
                                rowSpacing: 8
                                width: parent.width
                                IntField { id: doomOracleField; label: "最终调律深渊票"; minValue: 49; maxValue: 999999 }
                                IntField { id: doomProOracleField; label: "调律边界深渊票"; minValue: 750; maxValue: 999999 }
                                IntField { id: weightField; label: "砝码数量"; minValue: 3; maxValue: 9999 }
                            }
                        }
                        GlassCard {
                            title: "自动升级"
                            accent: "#ffb020"
                            GridLayout {
                                columns: 2
                                columnSpacing: 18
                                rowSpacing: 8
                                width: parent.width
                                IntField { id: upMinField; label: "最低等级"; minValue: 1; maxValue: store.maxLevel }
                                IntField { id: upMaxField; label: "最高等级"; minValue: 1; maxValue: store.maxLevel }
                            }
                        }
                        GlassCard {
                            title: "搬砖地图1"
                            accent: "#3dffb0"
                            GridLayout {
                                columns: 2
                                columnSpacing: 18
                                rowSpacing: 8
                                width: parent.width
                                IntField { id: c1MinLevel; label: "最低等级"; minValue: 1; maxValue: store.maxLevel }
                                IntField { id: c1MaxLevel; label: "最高等级"; minValue: 1; maxValue: store.maxLevel }
                                IntField { id: c1MinFame; label: "最低名望"; minValue: 1; maxValue: 999999 }
                                IntField { id: c1MaxFame; label: "最高名望"; minValue: 1; maxValue: 999999 }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Label { text: "地图"; color: "#9eb4d6"; Layout.preferredWidth: 132 }
                                    GlassCombo { id: c1Map; model: win.dungeonModel; textRole: "name"; Layout.fillWidth: true; onActivated: win.noteEdit() }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Label { text: "难度"; color: "#9eb4d6"; Layout.preferredWidth: 132 }
                                    GlassCombo { id: c1Difficulty; model: win.difficultyModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                                }
                            }
                        }
                        GlassCard {
                            title: "搬砖地图2"
                            accent: "#ff4fd8"
                            GridLayout {
                                columns: 2
                                columnSpacing: 18
                                rowSpacing: 8
                                width: parent.width
                                IntField { id: c2MinLevel; label: "最低等级"; minValue: 1; maxValue: store.maxLevel }
                                IntField { id: c2MaxLevel; label: "最高等级"; minValue: 1; maxValue: store.maxLevel }
                                IntField { id: c2MinFame; label: "最低名望"; minValue: 1; maxValue: 999999 }
                                IntField { id: c2MaxFame; label: "最高名望"; minValue: 1; maxValue: 999999 }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Label { text: "地图"; color: "#9eb4d6"; Layout.preferredWidth: 132 }
                                    GlassCombo { id: c2Map; model: win.dungeonModel; textRole: "name"; Layout.fillWidth: true; onActivated: win.noteEdit() }
                                }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Label { text: "难度"; color: "#9eb4d6"; Layout.preferredWidth: 132 }
                                    GlassCombo { id: c2Difficulty; model: win.difficultyModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                                }
                            }
                        }
                    }
                }

                ScrollView {
                    id: buffPage
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ColumnLayout {
                        width: buffPage.availableWidth
                        spacing: 12
                        GlassCard {
                            title: "装备处理"
                            accent: "#b388ff"
                            GridLayout {
                                columns: 3
                                columnSpacing: 18
                                rowSpacing: 8
                                width: parent.width
                                ColumnLayout {
                                    Label { text: "紫装"; color: "#c084fc" }
                                    GlassCombo { id: rareCombo; model: win.equipModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                                }
                                ColumnLayout {
                                    Label { text: "粉装"; color: "#ff4fd8" }
                                    GlassCombo { id: uniqueCombo; model: win.equipModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                                }
                                ColumnLayout {
                                    Label { text: "史诗"; color: "#ffb020" }
                                    GlassCombo { id: epicCombo; model: win.equipModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                                }
                            }
                        }
                        GlassCard {
                            title: "自定义 BUFF"
                            accent: "#ff4fd8"
                            GridLayout {
                                columns: 2
                                columnSpacing: 18
                                rowSpacing: 8
                                width: parent.width
                                IntField { id: damageField; label: "总伤害"; minValue: 0; maxValue: 99999999 }
                                IntField { id: hpField; label: "最大生命"; minValue: 0; maxValue: 99999999 }
                                IntField { id: mpField; label: "最大魔法"; minValue: 0; maxValue: 999999 }
                                IntField { id: attackField; label: "攻击速度"; minValue: 0; maxValue: 9999 }
                                IntField { id: castField; label: "施放速度"; minValue: 0; maxValue: 9999 }
                                IntField { id: moveField; label: "移动速度"; minValue: 0; maxValue: 9999 }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 28
                radius: 8
                color: store.statusError ? "#3a1020aa" : "#0d241ccc"
                border.color: store.statusError ? "#ff5d8a" : "#3dffb088"
                border.width: 1
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: store.statusError ? "#ff5d8a" : "#3dffb0"
                    }
                    Label {
                        Layout.fillWidth: true
                        text: store.status
                        color: store.statusError ? "#ffd0dc" : "#d9ffe9"
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    MouseArea {
        z: 20
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 6
        cursorShape: Qt.SizeHorCursor
        onPressed: win.startSystemResize(Qt.LeftEdge)
    }
    MouseArea {
        z: 20
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 6
        cursorShape: Qt.SizeHorCursor
        onPressed: win.startSystemResize(Qt.RightEdge)
    }
    MouseArea {
        z: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 6
        cursorShape: Qt.SizeVerCursor
        onPressed: win.startSystemResize(Qt.TopEdge)
    }
    MouseArea {
        z: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 6
        cursorShape: Qt.SizeVerCursor
        onPressed: win.startSystemResize(Qt.BottomEdge)
    }
}
