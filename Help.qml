import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    width: parent.width
    height: parent.height

    Rectangle {
        color: "lightgray"
        border.color: "black"
        border.width: 1
        radius: 5
        Layout.fillWidth: true
        Layout.fillHeight: true

        Text {
            text: "Help Content"
            font.pixelSize: 20
            anchors.centerIn: parent
        }
    }
}
