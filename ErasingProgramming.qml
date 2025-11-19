import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import Qt.labs.platform 1.1
import QtQml 2.15

Item {
    width: parent.width
    height: parent.height

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            text: "Erasing & Programming"
            font.bold: true
            font.pixelSize: 24
            color: "#2E3A46"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "#D3D3D3"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: filePathInput
                placeholderText: "File path"
                font.pixelSize: 16
                readOnly: true
                width: 400
                background: Rectangle {
                    color: "#F5F5F5"
                    radius: 5
                    border.color: "#D3D3D3"
                    border.width: 1
                }
                padding: 10
                onTextChanged: {
                    startProgrammingButton.enabled = checkConditions();
                }
            }

            Button {
                text: "Browse"
                onClicked: {
                    fileDialogErasing.open()
                }
                font.pixelSize: 16
                background: Rectangle {
                    color: "#3AA8DB"
                    radius: 5
                    border.color: "#3A506B"
                    border.width: 1
                }
                padding: 10
            }

            FileDialog {
                id: fileDialogErasing
                nameFilters: ["Firmware files (*.bin *.binary *.BINARY *.hex *.HEX *.srec *.SREC *.s19 *.S19 *.elf *.ELF *.out *.OUT *.axf *.AXF *.tsv *.TSV *.BIN)"]
                onAccepted: {
                    console.log("Selected file: " + fileDialogErasing.file)

                    const filePath = fileDialogErasing.file.toString().replace("file:///", "");
                    filePathInput.text = filePath
                    const fileExtension = filePath.slice(filePath.lastIndexOf('.'));

                    const binaryFileTypes = [".bin", ".binary", ".BINARY"];
                    if (binaryFileTypes.includes(fileExtension)) {
                        startAddressInput.enabled = true;
                        startAddressInput.text = "0x08000000";
                    } else {
                        startAddressInput.enabled = false;
                        startAddressInput.text = "";
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "Start Address"
                font.pixelSize: 16
            }

            TextField {
                id: startAddressInput
                enabled: false
                font.pixelSize: 16
                background: Rectangle {
                    color: "#F5F5F5"
                    radius: 5
                    border.color: "#D3D3D3"
                    border.width: 1
                }
                padding: 10
                validator: RegularExpressionValidator {
                    regularExpression: /^0x[0-9A-Fa-f]{0,8}$/
                }
                onTextChanged: {
                    startProgrammingButton.enabled = checkConditions();
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            RowLayout {
                CheckBox {
                    id: skipFlash
                    text: "Skip flash erase before programming"
                    font.pixelSize: 16
                }
            }

            RowLayout {
                CheckBox {
                    id: verifyProgramming
                    text: "Verify programming"
                    font.pixelSize: 16
                }
            }

            RowLayout {
                CheckBox {
                    id: fullFlashMemory
                    text: "Full flash memory checksum"
                    font.pixelSize: 16
                }
            }

            RowLayout {
                CheckBox {
                    id: runAfterProgramming
                    text: "Run after programming"
                    font.pixelSize: 16
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "#D3D3D3"
        }

        Button {
            id: startProgrammingButton
            text: "Start Programming"

            enabled: true
            onClicked: {
                /*
                if (!isConnected) {
                    alertText.text = "Device is not connected.";
                    alertDialog.open();
                } else*/ if (filePathInput.text === "") {
                    alertText.text = "Please specify a valid file path.";
                    alertDialog.open();
                } else {
                    const filePath = filePathInput.text.toString().replace("file:///", "");
                    const fileExtension = filePath.slice(filePath.lastIndexOf('.'));
                    const binaryFileTypes = [".bin", ".binary", ".BINARY", ".BIN"];
                    if (binaryFileTypes.includes(fileExtension) && !startAddressInput.text.match(/^0x[0-9A-Fa-f]{1,8}$/)) {
                        alertText.text = "Please specify a valid start address for the binary file.";
                        alertDialog.open();
                    } else {
                        programmerInterface.programDevice(filePath, startAddressInput.text, skipFlash.checked, verifyProgramming.checked, fullFlashMemory.checked, runAfterProgramming.checked);
                    }
                }
            }
            font.pixelSize: 16
            background: Rectangle {
                color: currentIndex === 0 ? "#BACB16" : "#3AA8DB"
                radius: 5
                border.color: "#3A506B"
                border.width: 1
            }
            padding: 10
        }
    }

    Popup {
        id: alertDialog
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        width: 300
        height: 150
        background: Rectangle {
            color: "white"
            radius: 10
            border.color: "#3A506B"
            border.width: 1
        }
        anchors.centerIn: parent

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "Alert"
                font.bold: true
                font.pixelSize: 20
                color: "#2E3A46"
            }

            Text {
                id: alertText
                wrapMode: Text.WordWrap
                font.pixelSize: 16
                color: "#2E3A46"
            }

            Button {
                text: "OK"
                onClicked: {
                    alertDialog.close();
                }
                font.pixelSize: 16
                background: Rectangle {
                    color: "#4A90E2"
                    radius: 5
                    border.color: "#3A506B"
                    border.width: 1
                }
                padding: 10
            }
        }
    }

    function checkConditions() {
        /*
        if (!isConnected) {
            return false;
        }
        */
        if (filePathInput.text === "") {
            return false;
        }
        const filePath = filePathInput.text.toString().replace("file:///", "");
        const fileExtension = filePath.slice(filePath.lastIndexOf('.'));
        const binaryFileTypes = [".bin", ".binary", ".BINARY"];
        if (binaryFileTypes.includes(fileExtension) && !startAddressInput.text.match(/^0x[0-9A-Fa-f]{1,8}$/)) {
            return false;
        }
        return true;
    }
}
