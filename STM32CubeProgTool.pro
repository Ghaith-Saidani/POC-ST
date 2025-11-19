QT += quick core

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    CubeProgrammerInterface.cpp \
    DisplayManager.cpp \
    OptionBytesModel.cpp \
    main.cpp

RESOURCES += qml.qrc \
    images.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

RC_ICONS = /images/Programmer.ico

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES +=

HEADERS += \
    CubeProgrammerInterface.h \
    OptionByteItem.h \
    OptionBytesModel.h \
    include/CubeProgrammer_API.h \
    include/DeviceDataStructure.h \
    include/DisplayManager.h


INCLUDEPATH += "include"
win32  {
     LIBS += -Llib/ -lCubeProgrammer_API
}

