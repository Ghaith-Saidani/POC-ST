#ifndef CUBEPROGRAMMERINTERFACE_H
#define CUBEPROGRAMMERINTERFACE_H

#include <QObject>
#include <QVariantList>
#include "CubeProgrammer_API.h"
#include <QDateTime>
#include "OptionBytesModel.h"
#include <QMap>

class CubeProgrammerInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(OptionBytesModel* optionBytesModel READ optionBytesModel NOTIFY optionBytesModelChanged)
    Q_PROPERTY(QString board READ board NOTIFY targetInformationChanged)
    Q_PROPERTY(QString device READ device NOTIFY targetInformationChanged)
    Q_PROPERTY(QString type READ type NOTIFY targetInformationChanged)
    Q_PROPERTY(QString deviceId READ deviceId NOTIFY targetInformationChanged)
    Q_PROPERTY(QString revisionId READ revisionId NOTIFY targetInformationChanged)
    Q_PROPERTY(QString flashSize READ flashSize NOTIFY targetInformationChanged)
    Q_PROPERTY(QString cpu READ cpu NOTIFY targetInformationChanged)
    Q_PROPERTY(QString bootloaderVersion READ bootloaderVersion NOTIFY targetInformationChanged)
    Q_PROPERTY(QString targetVoltage READ targetVoltage NOTIFY configChanged)
    Q_PROPERTY(QString firmwareVersion READ firmwareVersion NOTIFY configChanged)
    Q_PROPERTY(QVariantList memoryData READ memoryData NOTIFY memoryDataChanged)

public:
    explicit CubeProgrammerInterface(QObject *parent = nullptr);
    ~CubeProgrammerInterface();

    Q_INVOKABLE void connectToDevice();
    Q_INVOKABLE void disconnectFromDevice();
    Q_INVOKABLE void fetchMemoryData(int address, int size, const QString &dataWidth);
    Q_INVOKABLE void fetchSerialNumbers();
    Q_INVOKABLE void refreshData();
    Q_INVOKABLE void programDevice(const QString &filePath, QString startAddress, bool skipErase, bool verify, bool fullChecksum, bool runAfter);
    Q_INVOKABLE void fetchOptionBytes();


    Q_INVOKABLE void setSerialNumber(const QString &serialNumber);
    Q_INVOKABLE void setPort(const QString &port);
    Q_INVOKABLE void setFrequency(int frequency);
    Q_INVOKABLE void setMode(const QString &mode);
    Q_INVOKABLE void setAccessPort(int accessPort);
    Q_INVOKABLE void setResetMode(const QString &resetMode);
    Q_INVOKABLE void setSpeed(const QString &speed);
    Q_INVOKABLE void setShared(const QString &shared);

    QString board() const { return m_board; }
    QString device() const { return m_device; }
    QString type() const { return m_type; }
    QString deviceId() const { return m_deviceId; }
    QString revisionId() const { return m_revisionId; }
    QString flashSize() const { return m_flashSize; }
    QString cpu() const { return m_cpu; }
    QString bootloaderVersion() const { return m_bootloaderVersion; }
    QString targetVoltage() const { return m_voltage; }
    QString firmwareVersion() const { return m_firmware; }
    QVariantList memoryData() const { return m_memoryData; }
    OptionBytesModel* optionBytesModel() const { return m_optionBytesModel; }

signals:
    void connectionStatusChanged(bool status);
    void logMessage(const QString &message);
    void configChanged();
    void targetInformationChanged();
    void memoryDataChanged();
    void serialNumbersUpdated(QStringList serialNumbers);
    void frequenciesUpdated(QStringList frequencies);
    void portChanged(const QString &port);
    void optionBytesModelChanged();
    void groupedOptionBytesUpdated(const QVariantList& groupedOptionBytes);



private:
    struct OptionByteData {
        QString label;
        QList<OptionByteItem> items;
    };

    struct MemoryEntry {
        QString address;
        QString zero32, four32, eight32, c32;
        QString zero16, two16, four16, six16, eight16, a16, c16, e16;
        QString zero8, one8, two8, three8, four8, five8, six8, seven8, eight8, nine8, a8, b8, c8, d8, e8, f8;
        QString ascii;
    };

    QString m_board, m_device, m_type, m_deviceId, m_revisionId, m_flashSize, m_cpu, m_bootloaderVersion, m_voltage, m_firmware;
    QVariantList m_memoryData;
    QString m_serialNumber, m_port, m_mode, m_resetMode, m_speed, m_shared;
    int m_frequency, m_accessPort;

    OptionBytesModel* m_optionBytesModel;

    void updateMemoryData(int startAddress, const QString &dataWidth, const QByteArray &data);
    MemoryEntry format32BitMemoryData(unsigned char *data, int index, int remaining, int startAddress);
    MemoryEntry format16BitMemoryData(unsigned char *data, int index, int remaining, int startAddress);
    MemoryEntry format8BitMemoryData(unsigned char *data, int index, int remaining, int startAddress);
    QString formatLogMessage(const QString &message) {
        return QDateTime::currentDateTime().toString("hh:mm:ss") + " : " + message + "\n";
    }

    void processAndSendOptionBytes(const QList<OptionByteItem>& optionByteItems);
};

#endif // CUBEPROGRAMMERINTERFACE_H
