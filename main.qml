import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import Qt.labs.platform 1.1

ApplicationWindow {
    visible: true
    width: 1560
    height: 1024
    title: qsTr("STM32CubeProgrammer")
    Material.theme: Material.Light

    property int currentIndex: 0
    property bool isConnected: false

    Component.onCompleted: {
        updateMainContent(0);
        programmerInterface.fetchSerialNumbers();
    }

    function updateMainContent(index) {
        currentIndex = index;
        if (index === 0) {
            contentLoader.source = "qrc:/MemoryFileEditing.qml"
        } else if (index === 1) {
            contentLoader.source = "qrc:/ErasingProgramming.qml"
        } else if (index === 2) {
            contentLoader.source = "qrc:/OptionBytes.qml"
        } else if (index === 3) {
            contentLoader.source = "qrc:/Help.qml"
        }
    }


    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 10

            ScrollView {
                width: 250
                Layout.fillHeight: true
                Layout.preferredWidth: 250
                anchors.margins: 10

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Button {
                        text: "Memory and File Editing"
                        font.pixelSize: 16
                        Layout.fillWidth: true
                        background: Rectangle {
                            color: currentIndex === 0 ? "#3AA8DB" : "#7289DA"
                            border.color: "black"
                            border.width: 1
                            radius: 5
                        }
                        onClicked: updateMainContent(0)
                    }
                    Button {
                        text: "Erasing and Programming"
                        font.pixelSize: 16
                        Layout.fillWidth: true
                        background: Rectangle {
                            color: currentIndex === 1 ? "#3AA8DB" : "#7289DA"
                            border.color: "black"
                            border.width: 1
                            radius: 5
                        }
                        onClicked: updateMainContent(1)
                    }
                    Button {
                        text: "Option bytes"
                        font.pixelSize: 16
                        Layout.fillWidth: true
                        background: Rectangle {
                            color: currentIndex === 2 ? "#3AA8DB" : "#7289DA"
                            border.color: "black"
                            border.width: 1
                            radius: 5
                        }
                        onClicked: {
                            programmerInterface.setSerialNumber(serialNumberComboBox.currentText);
                            programmerInterface.setPort(portComboBox.currentText);
                            programmerInterface.setFrequency(parseInt(frequencyComboBox.currentText));
                            programmerInterface.setMode(modeComboBox.currentText);
                            programmerInterface.setAccessPort(accessPortComboBox.currentIndex);
                            programmerInterface.setResetMode(resetModeComboBox.currentText);
                            programmerInterface.setSpeed(speedComboBox.currentText);
                            programmerInterface.setShared(sharedComboBox.currentText);
                            programmerInterface.connectToDevice();
                            isConnected = true;
                            programmerInterface.fetchOptionBytes();
                            updateMainContent(2)
                        }
                    }
                    Button {
                        text: "Help"
                        font.pixelSize: 16
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignBottom
                        background: Rectangle {
                            color: currentIndex === 3 ? "#3AA8DB" : "#7289DA"
                            border.color: "black"
                            border.width: 1
                            radius: 5
                        }
                        onClicked: updateMainContent(3)
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10
                anchors.margins: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#F5F5F5"
                    border.color: "black"
                    border.width: 1
                    radius: 5

                    Loader {
                        id: contentLoader
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        anchors.horizontalCenter: parent.horizontal
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 10
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 240
                    color: "#F5F5F5"
                    border.color: "black"
                    border.width: 1
                    radius: 5

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        RowLayout {
                            spacing: 10
                            Text {
                                text: "Verbosity level"
                                font.pixelSize: 16
                            }

                            RadioButton {
                                id: verbosityLevel1
                                text: "1"
                                checked: true
                                onClicked: verbosityLevel = 1
                            }
                            RadioButton {
                                id: verbosityLevel2
                                text: "2"
                                onClicked: verbosityLevel = 2
                            }
                            RadioButton {
                                id: verbosityLevel3
                                text: "3"
                                onClicked: verbosityLevel = 3
                            }
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            TextArea {
                                id: logArea
                                width: parent.width
                                height: parent.height
                                readOnly: true
                                text: "Log Area"
                                font.pixelSize: 16
                            }
                        }

                        ProgressBar {
                            id: progressBar
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: 50
                            indeterminate: true
                        }
                        Rectangle {
                            id: statusIndicator
                            Layout.fillWidth: true
                            height: 20
                            color: "transparent"
                            border.color: "black"
                            border.width: 1
                            radius: 5
                        }

                        Connections {
                            target: programmerInterface
                            function onConnectionStatusChanged(status) {
                                isConnected = status;
                                progressBar.indeterminate = false
                                if (status) {
                                    progressBar.value = 100
                                    statusIndicator.color = "#BACB16"
                                } else {
                                    progressBar.value = 0
                                    statusIndicator.color = "#AE0158"
                                }
                            }

                            function onLogMessage(message) {
                                if (logArea.text === "Log Area") {
                                    logArea.text = ""
                                }
                                logArea.text += message + "\n"
                            }
                            function onSerialNumbersUpdated(serialNumbers) {
                                serialNumberComboBox.model = serialNumbers;
                            }
                            function onFrequenciesUpdated(frequencies) {
                                frequencyComboBox.model = frequencies;
                            }
                            function onConfigChanged() {
                                targetVoltageText.text = programmerInterface.targetVoltage;
                                firmwareVersionText.text = programmerInterface.firmwareVersion;
                            }
                            function onPortChanged() {
                            }
                        }

                    }
                }
            }

            ScrollView {
                width: 250
                Layout.fillHeight: true
                Layout.preferredWidth: 250
                anchors.margins: 10

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    RowLayout {
                        width: parent.width
                        spacing: 10

                        ComboBox {
                            width: 150
                            displayText: "ST-LINK"
                            model: ["ST-LINK", "J-Link / Flasher", "UART", "USB"]
                            Layout.preferredHeight: 29
                        }

                        Button {
                            text: isConnected ? "Disconnect" : "Connect"
                            Layout.preferredHeight: 40
                            background: Rectangle {
                                color: "#BACB16"
                                radius: 5
                                border.color: "black"
                                border.width: 1
                            }
                            onClicked: {
                                if (isConnected) {
                                    programmerInterface.disconnectFromDevice()
                                    isConnected = false;

                                } else {
                                    programmerInterface.setSerialNumber(serialNumberComboBox.currentText);
                                    programmerInterface.setPort(portComboBox.currentText);
                                    programmerInterface.setFrequency(parseInt(frequencyComboBox.currentText));
                                    programmerInterface.setMode(modeComboBox.currentText);
                                    programmerInterface.setAccessPort(accessPortComboBox.currentIndex);
                                    programmerInterface.setResetMode(resetModeComboBox.currentText);
                                    programmerInterface.setSpeed(speedComboBox.currentText);
                                    programmerInterface.setShared(sharedComboBox.currentText);
                                    programmerInterface.connectToDevice();
                                    isConnected = true;
                                }
                            }
                        }
                    }

                    ScrollView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        ColumnLayout {
                            width: 250
                            spacing: 10

                            Rectangle {
                                width: parent.width
                                height: 504
                                color: "#03234B"
                                border.color: "black"
                                border.width: 1
                                radius: 5

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10

                                    Text {
                                        color:"white"
                                        text: "ST-LINK configuration"
                                        font.bold: true
                                    }

                                    RowLayout {
                                        spacing: 6
                                        Layout.alignment: Qt.AlignVCenter

                                        Label {
                                            color: "white"
                                            text: "Serial number"
                                            font.pixelSize: 10
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        RowLayout {
                                            spacing: 0
                                            Layout.alignment: Qt.AlignVCenter

                                            Button {
                                                width: serialNumberComboBox.height
                                                height: serialNumberComboBox.height
                                                background: Rectangle {
                                                    width: serialNumberComboBox.height
                                                    height: serialNumberComboBox.height
                                                    radius: 5
                                                    color: "white"
                                                    border.color: "black"
                                                    border.width: 1
                                                }
                                                enabled: !isConnected
                                                onClicked: {
                                                    programmerInterface.refreshData();
                                                }
                                                Layout.alignment: Qt.AlignVCenter

                                                Image {
                                                    source: "qrc:/images/refresh2.png"
                                                    width: parent.width * 0.6
                                                    height: parent.height * 0.6
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            ComboBox {
                                                id: serialNumberComboBox
                                                width: 200
                                                model: []
                                                Layout.preferredHeight: 29
                                                enabled: !isConnected
                                                background: Rectangle {
                                                    color: "white"
                                                    radius: 5
                                                    border.color: "black"
                                                    border.width: 1
                                                    Material.elevation: 2
                                                }
                                                padding: 10

                                                contentItem: Text {
                                                    text: serialNumberComboBox.displayText
                                                    width: 50
                                                    font.pixelSize: 10
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 72
                                        Label {
                                            color:"white"
                                            text: "Port"
                                            font.pixelSize: 10
                                        }
                                        ComboBox {
                                            id: portComboBox
                                            width: 150
                                            model: ["SWD", "JTAG"]
                                            Layout.preferredHeight: 29
                                            enabled: !isConnected
                                            background: Rectangle {
                                                color: "white"
                                                radius: 5
                                                border.color: "black"
                                                border.width: 1
                                                Material.elevation: 2
                                            }
                                            padding: 10

                                            contentItem: Text {
                                                text: portComboBox.displayText
                                                font.pixelSize: 10
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onCurrentTextChanged: {
                                                programmerInterface.setPort(currentText);
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 19
                                        Label {
                                            color:"white"
                                            text: "Frequency (kHz)"
                                            font.pixelSize: 10
                                        }
                                        ComboBox {
                                            id: frequencyComboBox
                                            width: 150
                                            model: []
                                            Layout.preferredHeight: 29
                                            enabled: !isConnected
                                            background: Rectangle {
                                                color: "white"
                                                radius: 5
                                                border.color: "black"
                                                border.width: 1
                                                Material.elevation: 2
                                            }
                                            padding: 10

                                            contentItem: Text {
                                                text: frequencyComboBox.displayText
                                                font.pixelSize: 10
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 64
                                        Label {
                                            color:"white"
                                            text: "Mode"
                                            font.pixelSize: 10
                                        }
                                        ComboBox {
                                            id: modeComboBox
                                            width: 150
                                            model: ["Normal", "Hot plug", "Under reset", "Power down", "hwRstPulse"]
                                            Layout.preferredHeight: 29
                                            enabled: !isConnected
                                            background: Rectangle {
                                                color: "white"
                                                radius: 5
                                                border.color: "black"
                                                border.width: 1
                                                Material.elevation: 2
                                            }
                                            padding: 10

                                            contentItem: Text {
                                                text: modeComboBox.displayText
                                                font.pixelSize: 10
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 39
                                        Label {
                                            color:"white"
                                            text: "Access port"
                                            font.pixelSize: 10
                                        }
                                        ComboBox {
                                            id: accessPortComboBox
                                            width: 150
                                            model: ["0"]
                                            Layout.preferredHeight: 29
                                            enabled: !isConnected
                                            background: Rectangle {
                                                color: "white"
                                                radius: 5
                                                border.color: "black"
                                                border.width: 1
                                                Material.elevation: 2
                                            }
                                            padding: 10

                                            contentItem: Text {
                                                text: accessPortComboBox.displayText
                                                font.pixelSize: 10
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 37
                                        Label {
                                            color:"white"
                                            text: "Reset mode"
                                            font.pixelSize: 10
                                        }
                                        ComboBox {
                                            id: resetModeComboBox
                                            width: 200
                                            model: ["Software reset", "Hardware reset", "Core reset"]
                                            Layout.preferredHeight: 29
                                            font.pixelSize: 9
                                            enabled: !isConnected
                                            background: Rectangle {
                                                color: "white"
                                                radius: 5
                                                border.color: "black"
                                                border.width: 1
                                                Material.elevation: 2
                                            }
                                            padding: 10

                                            contentItem: Text {
                                                text: resetModeComboBox.displayText
                                                font.pixelSize: 10
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 62
                                        Label {
                                            color:"white"
                                            text: "Speed"
                                            font.pixelSize: 10
                                        }
                                        ComboBox {
                                            id: speedComboBox
                                            width: 150
                                            model: ["Reliable", "Fast"]
                                            Layout.preferredHeight: 29
                                            enabled: !isConnected
                                            background: Rectangle {
                                                color: "white"
                                                radius: 5
                                                border.color: "black"
                                                border.width: 1
                                                Material.elevation: 2
                                            }
                                            padding: 10

                                            contentItem: Text {
                                                text: speedComboBox.displayText
                                                font.pixelSize: 10
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }

                                    RowLayout {
                                        spacing: 59
                                        Label {
                                            color:"white"
                                            text: "Shared"
                                            font.pixelSize: 10
                                        }
                                        ComboBox {
                                            id: sharedComboBox
                                            width: 150
                                            model: ["Disabled", "Enabled"]
                                            Layout.preferredHeight: 29
                                            enabled: !isConnected
                                            background: Rectangle {
                                                color: "white"
                                                radius: 5
                                                border.color: "black"
                                                border.width: 1
                                                Material.elevation: 2
                                            }
                                            padding: 10

                                            contentItem: Text {
                                                text: sharedComboBox.displayText
                                                font.pixelSize: 10
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }

                                    Row {
                                        spacing: 0
                                        CheckBox {
                                            id: debugCheckBox
                                            enabled: !isConnected
                                            indicator: Rectangle {
                                                width: 10
                                                height: 10
                                                border.color: "white"
                                                color: "transparent"
                                                Rectangle {
                                                    anchors.fill: parent
                                                    color: debugCheckBox.checked ? "white" : "transparent"
                                                }
                                            }
                                        }
                                        Text {
                                            text: "Debug in Low Power mode"
                                            color: "white"
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    RowLayout {
                                        Label {
                                            color:"white"
                                            text: "Target voltage"
                                        }
                                        Text {
                                            color:"white"
                                            id: targetVoltageText
                                            text: programmerInterface.targetVoltage
                                        }
                                    }

                                    RowLayout {
                                        spacing: 5
                                        Label {
                                            color:"white"
                                            text: "Firmware version"
                                        }
                                        Text {
                                            color:"white"
                                            id: firmwareVersionText
                                            text: programmerInterface.firmwareVersion
                                        }
                                    }

                                    Button {
                                        background: Rectangle {
                                            color: "#3AA8DB"
                                            radius: 5
                                            border.color: "black"
                                            border.width: 1
                                            Material.elevation: 2
                                        }
                                        enabled: !isConnected

                                        contentItem: Text {
                                            text: "Firmware upgrade"
                                            color: "white"
                                            font.pixelSize: 10
                                            anchors.centerIn: parent
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 220
                                color: "#03234B"
                                border.color: "black"
                                border.width: 1
                                radius: 5

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 10
                                    anchors.margins: 10

                                    Text {
                                        color:"white"
                                        text: "Target Information"
                                        font.bold: true
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            color:"white"
                                            text: "Board"
                                            font.pixelSize: 10
                                            width: 150
                                        }

                                        Text {
                                            color:"white"
                                            text: programmerInterface.board
                                            font.pixelSize: 10
                                            width: 150
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            color:"white"
                                            text: "Device"
                                            font.pixelSize: 10
                                            width: 150
                                        }

                                        Text {
                                            color:"white"
                                            text: programmerInterface.device
                                            font.pixelSize: 10
                                            width: 150
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            color:"white"
                                            text: "Type"
                                            font.pixelSize: 10
                                            width: 150
                                        }

                                        Text {
                                            color:"white"
                                            text: programmerInterface.type
                                            font.pixelSize: 10
                                            width: 150
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            color:"white"
                                            text: "Device ID"
                                            font.pixelSize: 10
                                            width: 150
                                        }

                                        Text {
                                            color:"white"
                                            text: programmerInterface.deviceId
                                            font.pixelSize: 10
                                            width: 150
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            color:"white"
                                            text: "Revision ID"
                                            font.pixelSize: 10
                                            width: 150
                                        }

                                        Text {
                                            color:"white"
                                            text: programmerInterface.revisionId
                                            font.pixelSize: 10
                                            width: 150
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            color:"white"
                                            text: "Flash Size"
                                            font.pixelSize: 10
                                            width: 150
                                        }

                                        Text {
                                            color:"white"
                                            text: programmerInterface.flashSize
                                            font.pixelSize: 10
                                            width: 150
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            color:"white"
                                            text: "CPU"
                                            font.pixelSize: 10
                                            width: 150
                                        }

                                        Text {
                                            color:"white"
                                            text: programmerInterface.cpu
                                            font.pixelSize: 10
                                            width: 150
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 10

                                        Text {
                                            color:"white"
                                            text: "Bootloader Version"
                                            font.pixelSize: 10
                                            width: 150
                                        }

                                        Text {
                                            color:"white"
                                            text: programmerInterface.bootloaderVersion
                                            font.pixelSize: 10
                                            width: 150
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
