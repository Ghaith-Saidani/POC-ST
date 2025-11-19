import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import Qt.labs.platform 1.1
import Qt.labs.qmlmodels 1.0

Item {
    Material.theme: Material.Light

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 10
        anchors.margins: 20

        TabBar {
            Layout.fillWidth: true
            spacing: 20

            TabButton {
                text: "Device Memory"
                font.pixelSize: 18
                background: Rectangle {
                    color: "#3AA8DB"
                    radius: 5
                    border.color: "black"
                    border.width: 1
                }
                padding: 10
            }
        }

        Rectangle {
            width: parent.width
            height: 2
            color: "transparent"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            anchors.margins: 5

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#3AA8DB"
                border.color: "black"
                border.width: 1
                radius: 5

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 15
                    anchors.margins: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        Label {
                            text: "Address: "
                            font.pixelSize: 16
                        }

                        TextField {
                            id: addressField
                            width: 200
                            font.pixelSize: 16
                            text: "0x08000000"
                            background: Rectangle {
                                color: "white"
                                radius: 5
                                border.color: "black"
                                border.width: 1
                                Material.elevation: 2
                            }
                            padding: 10
                            validator: RegularExpressionValidator {
                                regularExpression: /^0x[0-9A-Fa-f]{0,8}$/
                            }
                        }

                        Label {
                            text: "Size: "
                            font.pixelSize: 16
                        }

                        TextField {
                            id: sizeField
                            width: 200
                            font.pixelSize: 16
                            text: "0x400"
                            background: Rectangle {
                                color: "white"
                                radius: 5
                                border.color: "black"
                                border.width: 1
                                Material.elevation: 2
                            }
                            padding: 10
                        }

                        Label {
                            text: "Data Width: "
                            font.pixelSize: 16
                        }

                        ComboBox {
                            id: dataWidthComboBox
                            width: 150
                            model: ["8-bit", "16-bit", "32-bit"]
                            currentIndex: 2
                            Layout.preferredHeight: 29
                            font.pixelSize: 16
                            background: Rectangle {
                                color: "white"
                                radius: 5
                                border.color: "black"
                                border.width: 1
                                Material.elevation: 2
                            }
                            padding: 10

                            contentItem: Text {
                                text: dataWidthComboBox.displayText
                                font.pixelSize: 16
                                verticalAlignment: Text.AlignVCenter
                            }

                            onCurrentIndexChanged: {
                                connectToDeviceAndFetchData();
                                updateLoaderSourceComponent();
                            }

                        }

                        Button {
                            text: "Read"
                            font.pixelSize: 16
                            background: Rectangle {
                                color: "#3AA8DB"
                                radius: 5
                                border.color: "black"
                                border.width: 1
                                Material.elevation: 2
                            }
                            padding: 10
                            hoverEnabled: true
                            onClicked: {
                                connectToDeviceAndFetchData();
                            }
                        }
                    }

                    Loader {
                        id: contentLoader
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: isConnected ? (dataWidthComboBox.currentIndex === 0 ? eightBitComponent :
                                                                                               dataWidthComboBox.currentIndex === 1 ? sixteenBitComponent : thirtyTwoBitComponent)
                                                     : noDataComponent
                    }
                }
            }
        }
    }

    function parseValue(value) {
        if (value.startsWith("0x")) {
            return parseInt(value, 16);
        } else {
            return parseInt(value, 10);
        }
    }

    function connectToDeviceAndFetchData() {
        if (isConnected) {
            disconnectDevice();
        }

        let sizeValue = parseValue(sizeField.text);
        let addressValue = parseValue(addressField.text);


        programmerInterface.setSerialNumber(serialNumberComboBox.currentText);
        programmerInterface.setPort(portComboBox.currentText);
        programmerInterface.setFrequency(parseInt(frequencyComboBox.currentText));
        programmerInterface.setMode(modeComboBox.currentText);
        programmerInterface.setAccessPort(accessPortComboBox.currentIndex);
        programmerInterface.setResetMode(resetModeComboBox.currentText);
        programmerInterface.setSpeed(speedComboBox.currentText);
        programmerInterface.setShared(sharedComboBox.currentText);
        programmerInterface.connectToDevice();

        programmerInterface.fetchMemoryData(addressValue, sizeValue, dataWidthComboBox.currentText);
        updateLoaderSourceComponent();
    }

    function disconnectDevice() {
        programmerInterface.disconnectFromDevice();
        isConnected = false;
        updateLoaderSourceComponent();
    }

    function updateLoaderSourceComponent() {
        contentLoader.sourceComponent = isConnected ? (dataWidthComboBox.currentIndex === 0 ? eightBitComponent :
                                                                                              dataWidthComboBox.currentIndex === 1 ? sixteenBitComponent : thirtyTwoBitComponent)
                                                    : noDataComponent;
    }


    Component {
        id: noDataComponent

        Rectangle {
            visible: !isConnected
            width: 960
            height: 350
            color: "#F0F0F0"
            border.color: "black"
            border.width: 0.5

            Text {
                anchors.centerIn: parent
                text: "No data to display"
                font.pixelSize: 16
                color: "black"
            }
        }
    }

    Component {
        id: eightBitComponent

        ColumnLayout {
            visible: isConnected
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridLayout {
                columns: 18
                rowSpacing: 1
                columnSpacing: 1
                width: 1000

                Rectangle {
                    width: 160
                    height: 40
                    color: "#1E3A5F"
                    border.color: "black"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Address"
                        color: "white"
                        font.pixelSize: 16
                    }
                }

                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "0"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "1"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "2"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "3"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "4"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "5"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "6"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "7"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "8"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "9"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "A"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "B"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "C"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "D"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "E"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 41; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "F"; color: "white"; font.pixelSize: 16 } }

                Rectangle {
                    width: 160
                    height: 40
                    color: "#1E3A5F"
                    border.color: "black"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "ASCII"
                        color: "white"
                        font.pixelSize: 16
                    }
                }
            }

            ListView {
                id: memoryListView8Bit
                width: 1000
                height: 350
                model: programmerInterface.memoryData
                clip: true

                delegate: GridLayout {
                    columns: 18
                    rowSpacing: 1
                    columnSpacing: 1

                    Rectangle {
                        width: 160
                        height: 40
                        color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"
                        border.color: "black"
                        border.width: 0.5

                        Text {
                            anchors.centerIn: parent
                            text: modelData.address
                            font.pixelSize: 16
                            padding: 5
                        }
                    }

                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.zero8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.one8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.two8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.three8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.four8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.five8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.six8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.seven8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.eight8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.nine8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.a8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.b8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.c8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.d8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.e8; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 41; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.f8; font.pixelSize: 16; padding: 5 } }

                    Rectangle {
                        width: 160
                        height: 40
                        color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"
                        border.color: "black"
                        border.width: 0.5

                        Text {
                            anchors.centerIn: parent
                            text: modelData.ascii
                            font.pixelSize: 16
                            padding: 5
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    width: 10
                    background: Rectangle {
                        color: "#E0E0E0"
                    }
                }

                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    height: 10
                    background: Rectangle {
                        color: "#E0E0E0"
                    }
                }
            }
        }
    }

    Component {
        id: sixteenBitComponent

        ColumnLayout {
            visible: isConnected
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridLayout {
                columns: 10
                rowSpacing: 1
                columnSpacing: 1
                width: 1000

                Rectangle {
                    width: 160
                    height: 40
                    color: "#1E3A5F"
                    border.color: "black"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Address"
                        color: "white"
                        font.pixelSize: 16
                    }
                }

                Rectangle { width: 82; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "0"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 82; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "2"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 82; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "4"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 82; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "6"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 82; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "8"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 82; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "A"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 82; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "C"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 82; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "E"; color: "white"; font.pixelSize: 16 } }

                Rectangle {
                    width: 160
                    height: 40
                    color: "#1E3A5F"
                    border.color: "black"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "ASCII"
                        color: "white"
                        font.pixelSize: 16
                    }
                }
            }

            ListView {
                id: memoryListView16Bit
                width: 1000
                height: 350
                model: programmerInterface.memoryData
                clip: true

                delegate: GridLayout {
                    columns: 10
                    rowSpacing: 1
                    columnSpacing: 1

                    Rectangle {
                        width: 160
                        height: 40
                        color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"
                        border.color: "black"
                        border.width: 0.5

                        Text {
                            anchors.centerIn: parent
                            text: modelData.address
                            font.pixelSize: 16
                            padding: 5
                        }
                    }

                    Rectangle { width: 82; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.zero16; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 82; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.two16; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 82; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.four16; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 82; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.six16; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 82; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.eight16; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 82; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.a16; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 82; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.c16; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 82; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.e16; font.pixelSize: 16; padding: 5 } }

                    Rectangle {
                        width: 160
                        height: 40
                        color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"
                        border.color: "black"
                        border.width: 0.5

                        Text {
                            anchors.centerIn: parent
                            text: modelData.ascii
                            font.pixelSize: 16
                            padding: 5
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    width: 10
                    background: Rectangle {
                        color: "#E0E0E0"
                    }
                }

                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    height: 10
                    background: Rectangle {
                        color: "#E0E0E0"
                    }
                }
            }
        }
    }

    Component {
        id: thirtyTwoBitComponent

        ColumnLayout {
            visible: isConnected
            Layout.fillWidth: true
            Layout.fillHeight: true

            GridLayout {
                columns: 7
                rowSpacing: 1
                columnSpacing: 1
                width: 1000

                Rectangle {
                    width: 160
                    height: 40
                    color: "#1E3A5F"
                    border.color: "black"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Address"
                        color: "white"
                        font.pixelSize: 16
                    }
                }

                Rectangle { width: 165; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "0"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 165; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "4"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 165; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "8"; color: "white"; font.pixelSize: 16 } }
                Rectangle { width: 165; height: 40; color: "#1E3A5F"; border.color: "black"; border.width: 1; Text { anchors.centerIn: parent; text: "C"; color: "white"; font.pixelSize: 16 } }

                Rectangle {
                    width: 160
                    height: 40
                    color: "#1E3A5F"
                    border.color: "black"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "ASCII"
                        color: "white"
                        font.pixelSize: 16
                    }
                }
            }

            ListView {
                id: memoryListView32Bit
                width: 1000
                height: 350
                model: programmerInterface.memoryData
                clip: true

                delegate: GridLayout {
                    columns: 7
                    rowSpacing: 1
                    columnSpacing: 1

                    Rectangle {
                        width: 160
                        height: 40
                        color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"
                        border.color: "black"
                        border.width: 0.5

                        Text {
                            anchors.centerIn: parent
                            text: modelData.address
                            font.pixelSize: 16
                            padding: 5
                        }
                    }

                    Rectangle { width: 165; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.zero32; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 165; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.four32; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 165; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.eight32; font.pixelSize: 16; padding: 5 } }
                    Rectangle { width: 165; height: 40; color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"; border.color: "black"; border.width: 0.5; Text { anchors.centerIn: parent; text: modelData.c32; font.pixelSize: 16; padding: 5 } }

                    Rectangle {
                        width: 160
                        height: 40
                        color: index % 2 === 0 ? "#F0F0F0" : "#E0E0E0"
                        border.color: "black"
                        border.width: 0.5

                        Text {
                            anchors.centerIn: parent
                            text: modelData.ascii
                            font.pixelSize: 16
                            padding: 5
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    width: 10
                    background: Rectangle {
                        color: "#E0E0E0"
                    }
                }

                ScrollBar.horizontal: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                    height: 10
                    background: Rectangle {
                        color: "#E0E0E0"
                    }
                }
            }
        }
    }
}
