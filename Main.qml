import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import vegaconfig

ApplicationWindow {
    id: win
    width: 1080
    height: 760
    minimumWidth: 920
    minimumHeight: 640
    visible: true
    title: store.dirty ? "Vega 配置修改器 *" : "Vega 配置修改器"
    font.family: "Microsoft YaHei UI"
    font.pixelSize: 13

    property bool allowClose: false
    property string pending: ""

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

    ConfigStore {
        id: store
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
            Layout.preferredWidth: 132
        }
        TextField {
            id: input
            Layout.fillWidth: true
            selectByMouse: true
            validator: IntValidator {
                bottom: minValue
                top: maxValue
            }
            inputMethodHints: Qt.ImhDigitsOnly
            onTextEdited: win.noteEdit()
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
            Layout.preferredWidth: 132
        }
        TextField {
            id: input
            Layout.fillWidth: true
            selectByMouse: true
            echoMode: parent.echoMode
            onTextEdited: win.noteEdit()
        }
        CheckBox {
            visible: echoMode === TextInput.Password
            text: "显示"
            onToggled: input.echoMode = checked ? TextInput.Normal : TextInput.Password
        }
    }

    function noteEdit() {
        store.markDirty()
    }

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
        signedLabel.text = "签名: " + String(store.value("signed") ?? "")
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

    Dialog {
        id: discardDialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        modal: true
        title: "未保存的修改"
        standardButtons: Dialog.Save | Dialog.Discard | Dialog.Cancel
        padding: 16
        Label {
            text: "当前配置已修改。保存后再继续？"
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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "打开"
                onClicked: requestAction("open")
            }
            Button {
                text: "保存"
                onClicked: pushAndSave()
            }
            Button {
                text: "另存为"
                onClicked: doSaveAs()
            }
            Button {
                text: "恢复默认"
                onClicked: requestAction("reset")
            }
            Item { Layout.fillWidth: true }
            Label {
                text: signedLabel.text
                color: "#666666"
            }
        }

        TextField {
            id: pathField
            Layout.fillWidth: true
            readOnly: true
            text: store.filePath
            selectByMouse: true
            placeholderText: "尚未选择 config.json"
        }

        TabBar {
            id: tabs
            Layout.fillWidth: true
            TabButton { text: "基础" }
            TabButton { text: "登录" }
            TabButton { text: "验证码" }
            TabButton { text: "自动模式" }
            TabButton { text: "装备与 BUFF" }
        }

        StackLayout {
            currentIndex: tabs.currentIndex
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollView {
                id: basePage
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ColumnLayout {
                    width: basePage.availableWidth
                    spacing: 10
                    GroupBox {
                        title: "机器绑定"
                        Layout.fillWidth: true
                        TextRow {
                            id: identifierField
                            label: "机器编号"
                        }
                    }
                    GroupBox {
                        title: "基础设置"
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 2
                            columnSpacing: 18
                            rowSpacing: 8
                            width: parent.width
                            IntField {
                                id: stopUsersField
                                label: "停止角色数"
                                maxValue: 999
                            }
                            IntField {
                                id: timeoutField
                                label: "副本超时(秒)"
                                minValue: 1
                                maxValue: 86400
                            }
                            CheckBox {
                                id: shutdownBox
                                text: "刷完关机"
                                onClicked: win.noteEdit()
                            }
                            CheckBox {
                                id: backpackBox
                                text: "整理背包"
                                onClicked: win.noteEdit()
                            }
                            CheckBox {
                                id: neoEquipBox
                                text: "穿戴会员装备"
                                Layout.columnSpan: 2
                                onClicked: win.noteEdit()
                            }
                        }
                    }
                    GroupBox {
                        title: "运行状态"
                        Layout.fillWidth: true
                        ColumnLayout {
                            width: parent.width
                            Label {
                                text: "角色序号和切换时间由 Vega 运行时写入。0 表示从第一个角色开始。"
                                color: "#666666"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                            GridLayout {
                                columns: 2
                                columnSpacing: 18
                                rowSpacing: 8
                                Layout.fillWidth: true
                                IntField {
                                    id: roleIndexField
                                    label: "当前角色序号"
                                    maxValue: 999
                                }
                                IntField {
                                    id: switchTimeField
                                    label: "切换角色时间"
                                    maxValue: 2147483647
                                }
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
                    spacing: 10
                    GroupBox {
                        title: "自动登录"
                        Layout.fillWidth: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 8
                            RowLayout {
                                Layout.fillWidth: true
                                Label { text: "登录方式"; Layout.preferredWidth: 132 }
                                ComboBox {
                                    id: loginCombo
                                    model: win.loginModel
                                    Layout.fillWidth: true
                                    onActivated: win.noteEdit()
                                }
                            }
                            TextRow { id: accountField; label: "游戏账号" }
                            TextRow { id: passwordField; label: "游戏密码"; echoMode: TextInput.Password }
                            TextRow { id: otpField; label: "OTP秘钥"; echoMode: TextInput.Password }
                            RowLayout {
                                Layout.fillWidth: true
                                Label { text: "游戏目录"; Layout.preferredWidth: 132 }
                                TextField {
                                    id: launcherField
                                    Layout.fillWidth: true
                                    selectByMouse: true
                                    placeholderText: "NeopleLauncher.exe"
                                    onTextEdited: win.noteEdit()
                                }
                                Button {
                                    text: "浏览"
                                    onClicked: {
                                        const path = store.pickLauncher()
                                        if (path) {
                                            launcherField.text = path
                                            win.noteEdit()
                                        }
                                    }
                                }
                                Button {
                                    text: "读注册表"
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
                    GroupBox {
                        title: "邮箱"
                        Layout.fillWidth: true
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
                    GroupBox {
                        title: "会员登录"
                        Layout.fillWidth: true
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
                    GroupBox {
                        title: "验证码处理"
                        Layout.fillWidth: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 8
                            RowLayout {
                                Layout.fillWidth: true
                                Label { text: "识别平台"; Layout.preferredWidth: 132 }
                                ComboBox {
                                    id: platformCombo
                                    model: win.platformModel
                                    Layout.preferredWidth: 220
                                    onActivated: win.noteEdit()
                                }
                                Label { text: "验证操作"; Layout.leftMargin: 12 }
                                ComboBox {
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
                    spacing: 10
                    GroupBox {
                        title: "模式开关"
                        Layout.fillWidth: true
                        RowLayout {
                            CheckBox { id: doomBox; text: "最终调律"; onClicked: win.noteEdit() }
                            CheckBox { id: doomProBox; text: "调律边界"; onClicked: win.noteEdit() }
                            CheckBox { id: uplevelBox; text: "自动升级"; onClicked: win.noteEdit() }
                            CheckBox { id: clean1Box; text: "搬砖地图1"; onClicked: win.noteEdit() }
                            CheckBox { id: clean2Box; text: "搬砖地图2"; onClicked: win.noteEdit() }
                        }
                    }
                    GroupBox {
                        title: "最终调律 / 调律边界"
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 2
                            columnSpacing: 18
                            rowSpacing: 8
                            width: parent.width
                            IntField {
                                id: doomOracleField
                                label: "最终调律深渊票"
                                minValue: 49
                                maxValue: 999999
                            }
                            IntField {
                                id: doomProOracleField
                                label: "调律边界深渊票"
                                minValue: 750
                                maxValue: 999999
                            }
                            IntField {
                                id: weightField
                                label: "砝码数量"
                                minValue: 3
                                maxValue: 9999
                            }
                        }
                    }
                    GroupBox {
                        title: "自动升级"
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 2
                            columnSpacing: 18
                            rowSpacing: 8
                            width: parent.width
                            IntField { id: upMinField; label: "最低等级"; minValue: 1; maxValue: store.maxLevel }
                            IntField { id: upMaxField; label: "最高等级"; minValue: 1; maxValue: store.maxLevel }
                        }
                    }
                    GroupBox {
                        title: "搬砖地图1"
                        Layout.fillWidth: true
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
                                Label { text: "地图"; Layout.preferredWidth: 132 }
                                ComboBox { id: c1Map; model: win.dungeonModel; textRole: "name"; Layout.fillWidth: true; onActivated: win.noteEdit() }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Label { text: "难度"; Layout.preferredWidth: 132 }
                                ComboBox { id: c1Difficulty; model: win.difficultyModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                            }
                        }
                    }
                    GroupBox {
                        title: "搬砖地图2"
                        Layout.fillWidth: true
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
                                Label { text: "地图"; Layout.preferredWidth: 132 }
                                ComboBox { id: c2Map; model: win.dungeonModel; textRole: "name"; Layout.fillWidth: true; onActivated: win.noteEdit() }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Label { text: "难度"; Layout.preferredWidth: 132 }
                                ComboBox { id: c2Difficulty; model: win.difficultyModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
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
                    spacing: 10
                    GroupBox {
                        title: "装备处理"
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 3
                            columnSpacing: 18
                            rowSpacing: 8
                            width: parent.width
                            ColumnLayout {
                                Label { text: "紫装" }
                                ComboBox { id: rareCombo; model: win.equipModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                            }
                            ColumnLayout {
                                Label { text: "粉装" }
                                ComboBox { id: uniqueCombo; model: win.equipModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                            }
                            ColumnLayout {
                                Label { text: "史诗" }
                                ComboBox { id: epicCombo; model: win.equipModel; Layout.fillWidth: true; onActivated: win.noteEdit() }
                            }
                        }
                    }
                    GroupBox {
                        title: "自定义 BUFF"
                        Layout.fillWidth: true
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

        Label {
            id: signedLabel
            visible: false
        }

        Label {
            Layout.fillWidth: true
            text: store.status
            color: store.statusError ? "#b00020" : "#1b5e20"
            elide: Text.ElideRight
        }
    }
}
