import QtQuick 2.4
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

Item {
    width: 980
    height: 500

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "Option bytes"
                font.pixelSize: 24
                font.bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "#D3D3D3"
        }

        ScrollView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Accordion {
                id: accordion
                Layout.fillWidth: true
                Layout.fillHeight: true
                anchors.margins: 10
                model: programmerInterface.optionBytesModel
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: "#D3D3D3"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Button {
                text: "Apply"
                width: 100
                height: 40
                font.pixelSize: 16
                background: Rectangle {
                    color: "#3AA8DB"
                    radius: 5
                    border.color: "#388E3C"
                    border.width: 1
                }
                onClicked: {

                }
            }
            Button {
                text: "Read"
                width: 100
                height: 40
                font.pixelSize: 16
                background: Rectangle {
                    color: "#3AA8DB"
                    radius: 5
                    border.color: "#1976D2"
                    border.width: 1
                }
                onClicked: {
                    programmerInterface.fetchOptionBytes();
                }
            }
        }
    }
}
