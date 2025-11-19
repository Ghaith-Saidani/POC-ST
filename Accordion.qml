import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Column {
    width: parent.width
    height: parent.height

    property alias model: columnRepeater.model

    Repeater {
        id: columnRepeater
        model: programmerInterface.optionBytesModel
        delegate: Item {
            id: itemDelegate
            width: parent.width
            height: childrenRect.height
            property bool expanded: false

            Column {
                width: parent.width

                Rectangle {
                    id: header
                    width: parent.width
                    height: 30
                    color: "#3AA8DB"
                    border.color: "white"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: itemDelegate.expanded = !itemDelegate.expanded
                    }

                    Image {
                        id: carot
                        anchors {
                            left: parent.left
                            margins: 5
                        }
                        sourceSize.width: 16
                        sourceSize.height: 16
                        source: 'images/triangle.png'
                        transform: Rotation {
                            origin.x: 5
                            origin.y: 10
                            angle: itemDelegate.expanded ? 90 : 0
                            Behavior on angle { NumberAnimation { duration: 150 } }
                        }
                    }

                    Text {
                        anchors {
                            left: carot.right
                            margins: 5
                        }
                        font.pointSize: 12
                        color: 'white'
                        text: model.label
                    }
                }

                ListView {
                    id: subentryColumn
                    width: parent.width
                    height: childrenRect.height * opacity
                    visible: opacity > 0
                    opacity: itemDelegate.expanded ? 1 : 0
                    model: details
                    delegate: GridLayout {
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 80

                        Text {
                            text: modelData.name
                            Layout.alignment: Qt.AlignLeft
                        }

                        Item {
                            width: 100
                            height: 30

                            Loader {
                                id: controlLoader
                                anchors.fill: parent
                                sourceComponent: {
                                    if (modelData.display === "CHECKBOX") {
                                        checkboxComponent
                                    } else if (modelData.display === "COMBOBOX") {
                                        comboboxComponent
                                    } else if (modelData.display === "TEXTFIELDS") {
                                        textfieldsComponent
                                    } else {
                                        textfieldComponent
                                    }
                                }
                            }

                            Component {
                                id: checkboxComponent
                                CheckBox {
                                    checked: modelData.value === "1"
                                }
                            }

                            Component {
                                id: comboboxComponent
                                ComboBox {
                                    id: comboBox
                                    model: modelData.values
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 100
                                }
                            }

                            Component {
                                id: textfieldsComponent
                                RowLayout {
                                    spacing: 10
                                    Layout.fillWidth: true

                                    TextField {
                                        id: textField1
                                        placeholderText: "Value"
                                        text: "0x"+ modelData.value
                                        Layout.preferredWidth: 70
                                    }

                                    TextField {
                                        id: textField2
                                        placeholderText: "Address"
                                        text: "0x0"
                                        Layout.preferredWidth: 100
                                    }

                                    Component.onCompleted: {
                                        textField1.textChanged.connect(onTextField1Changed);
                                        textField2.textChanged.connect(onTextField2Changed);
                                    }

                                    function onTextField1Changed(newValue) {
                                        if (newValue.startsWith("0x") && newValue.length > 2) {
                                            let newInt = parseInt(newValue, 16);
                                            let value = newInt * modelData.multiplier + modelData.offset;
                                            let hexValue = value.toString(16).toUpperCase();
                                            textField2.text = "0x" + hexValue.padStart(8, '0');
                                        }
                                    }

                                    function onTextField2Changed(newValue) {
                                        if (newValue.startsWith("0x") && newValue.length > 2) {
                                            let newInt = parseInt(newValue, 16);
                                            let value = (newInt - modelData.offset) / modelData.multiplier;
                                            if (value < 0) {
                                                textField1.text = "0x0";
                                            } else {
                                                textField1.text = "0x" + value.toString(16).toUpperCase();
                                            }
                                        }
                                    }
                                }
                            }

                            Component {
                                id: textfieldComponent
                                TextField {
                                    id: textField
                                    Layout.fillWidth: true
                                    text: "0x0"

                                    onTextChanged: {
                                        textField.text = textField.text.replace(/[^0-9a-fA-Fx]/g, "");

                                        if (textField.text.startsWith("0x") && textField.text.length > 2) {
                                            let value = parseInt(textField.text, 16);

                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            text: modelData.description
                            Layout.alignment: Qt.AlignRight
                            wrapMode: Text.WordWrap
                            Layout.preferredWidth: 200
                        }
                    }
                    interactive: false
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
            }
        }
    }
}
