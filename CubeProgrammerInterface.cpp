#include "CubeProgrammerInterface.h"
#include <QDebug>
#include <QFileInfo>
#include <locale>
#include <codecvt>

CubeProgrammerInterface::CubeProgrammerInterface(QObject *parent)
    : QObject(parent),
    m_optionBytesModel(new OptionBytesModel(this))
{
    m_board = "-";
    m_device = "-";
    m_type = "-";
    m_deviceId = "-";
    m_revisionId = "-";
    m_flashSize = "-";
    m_cpu = "-";
    m_bootloaderVersion = "-";
    m_firmware= "-";
    m_voltage= "-";
    m_memoryData.clear();
    m_memoryData.append(QVariantMap{{"address", "No data to display"}, {"zero32", ""}, {"four32", ""}, {"eight32", ""}, {"c32", ""}, {"ascii", ""}});

    fetchSerialNumbers();
}

void CubeProgrammerInterface::fetchSerialNumbers() {
    debugConnectParameters *stLinkList;
    int getStlinkListNb = getStLinkList(&stLinkList, 0);

    if (getStlinkListNb > 0) {
        QStringList serialNumbers;
        QStringList frequencies;

        for (int i = 0; i < getStlinkListNb; i++) {
            serialNumbers.append(stLinkList[i].serialNumber);
            if (m_port == "SWD") {
                for (unsigned int j = 0; j < stLinkList[i].freq.swdFreqNumber; j++) {
                    frequencies.append(QString::number(stLinkList[i].freq.swdFreq[j]));
                }
            } else if (m_port == "JTAG") {
                for (unsigned int j = 0; j < stLinkList[i].freq.jtagFreqNumber; j++) {
                    frequencies.append(QString::number(stLinkList[i].freq.jtagFreq[j]));
                }
            }
        }
        emit serialNumbersUpdated(serialNumbers);
        emit frequenciesUpdated(frequencies);
    } else {
        QStringList serialNumbers;
        QStringList frequencies={""};
        serialNumbers.append("No ST-LINK detected");
        emit serialNumbersUpdated(serialNumbers);
        emit frequenciesUpdated(frequencies);
    }
}

void CubeProgrammerInterface::refreshData() {
    debugConnectParameters *stLinkList;
    int getStLinkListNb = getStLinkList(&stLinkList, 0);

    if (getStLinkListNb > 0) {
        QStringList serialNumbers;
        QStringList frequencies;

        for (int i = 0; i < getStLinkListNb; i++) {
            serialNumbers.append(stLinkList[i].serialNumber);

            if (m_port == "SWD") {
                for (unsigned int j = 0; j < stLinkList[i].freq.swdFreqNumber; j++) {
                    frequencies.append(QString::number(stLinkList[i].freq.swdFreq[j]));
                }
            } else if (m_port == "JTAG") {
                for (unsigned int j = 0; j < stLinkList[i].freq.jtagFreqNumber; j++) {
                    frequencies.append(QString::number(stLinkList[i].freq.jtagFreq[j]));
                }
            }
        }

        emit serialNumbersUpdated(serialNumbers);
        emit frequenciesUpdated(frequencies);

        m_voltage = QString::fromUtf8(stLinkList[0].targetVoltage);
        m_firmware = QString::fromUtf8(stLinkList[0].firmwareVersion);
        emit configChanged();
    } else {
        QStringList serialNumbers;
        QStringList frequencies={""};
        serialNumbers.append("No ST-LINK detected");
        m_firmware= "-";
        m_voltage= "-";
        emit serialNumbersUpdated(serialNumbers);
        emit frequenciesUpdated(frequencies);
        emit configChanged();
    }
}

CubeProgrammerInterface::~CubeProgrammerInterface()
{
}

void CubeProgrammerInterface::setSerialNumber(const QString &serialNumber) {
    m_serialNumber = serialNumber;
}


void CubeProgrammerInterface::setPort(const QString &port) {
    if (m_port != port) {
        m_port = port;
        emit portChanged(m_port);
        fetchSerialNumbers();
    }
}

void CubeProgrammerInterface::setFrequency(int frequency) {
    m_frequency = frequency;
}

void CubeProgrammerInterface::setMode(const QString &mode) {
    m_mode = mode;
}

void CubeProgrammerInterface::setAccessPort(int accessPort) {
    m_accessPort = accessPort;
}

void CubeProgrammerInterface::setResetMode(const QString &resetMode) {
    m_resetMode = resetMode;
}

void CubeProgrammerInterface::setSpeed(const QString &speed) {
    m_speed = speed;
}

void CubeProgrammerInterface::setShared(const QString &shared) {
    m_shared = shared;
}

void CubeProgrammerInterface::connectToDevice()
{
    debugConnectParameters *stLinkList;
    debugConnectParameters debugParameters;
    generalInf* genInfo;

    int getStlinkListNb = getStLinkList(&stLinkList, 0);

    if (getStlinkListNb == 0)
    {
        emit logMessage(formatLogMessage("No STLINK available"));
        qDebug() << "\nST-LINK numb %d :\n" << getStlinkListNb;
    }
    else {
        QString log;
        log += "\n-------- Connected ST-LINK Probes List --------\n";
        for (int i = 0; i < getStlinkListNb; i++)
        {
            log += formatLogMessage(QString("ST-LINK Probe %1 :").arg(i));
            log += formatLogMessage(QString("   ST-LINK SN   : %1").arg(stLinkList[i].serialNumber));
            m_voltage = QString::fromUtf8(stLinkList[i].targetVoltage);
            m_firmware = QString::fromUtf8(stLinkList[i].firmwareVersion);
            emit configChanged();
        }
        log += formatLogMessage("-----------------------------------------------");
        log += formatLogMessage("Connection successful.");
        emit logMessage(log);
    }

    debugParameters = stLinkList[0];
    strncpy(debugParameters.serialNumber, m_serialNumber.toStdString().c_str(), sizeof(debugParameters.serialNumber) - 1);
    debugParameters.dbgPort = (m_port == "SWD") ? SWD : JTAG;
    debugParameters.frequency = m_frequency;
    debugParameters.connectionMode = (m_mode == "Normal") ? NORMAL_MODE :
                                         (m_mode == "Hot plug") ? HOTPLUG_MODE :
                                         (m_mode == "Under reset") ? UNDER_RESET_MODE :
                                         (m_mode == "Power down") ? POWER_DOWN_MODE :
                                         PRE_RESET_MODE;
    debugParameters.accessPort = m_accessPort;
    debugParameters.resetMode = (m_resetMode == "Software reset") ? SOFTWARE_RESET :
                                    (m_resetMode == "Hardware reset") ? HARDWARE_RESET :
                                    CORE_RESET;
    debugParameters.shared = (m_shared == "Enabled") ? 1 : 0;

    /* Target connect */
    int connectStlinkFlag = connectStLink(debugParameters);
    emit logMessage(formatLogMessage(QString("connectStlinkFlag: %1").arg(connectStlinkFlag)));
    if (connectStlinkFlag != 0) {
        emit logMessage(formatLogMessage("Establishing connection with the device failed."));
        emit connectionStatusChanged(false);
        disconnect();
    }
    else {
        emit connectionStatusChanged(true);
        emit logMessage(formatLogMessage("--- Device Connected ---"));
        /* Display device information */
        genInfo = getDeviceGeneralInf();
        m_board = QString::fromUtf8(genInfo->board);
        m_device = QString::fromUtf8(genInfo->name);
        m_type = QString::fromUtf8(genInfo->type);
        m_deviceId = "0x" + QString::number(genInfo->deviceId, 16).toUpper();
        m_revisionId = QString::fromUtf8(genInfo->revisionId);
        double flashSizeKB = static_cast<double>(genInfo->flashSize) / 1024.0;
        m_flashSize = QString::number(flashSizeKB, 'f', 0) + " MB";
        m_cpu = QString::fromUtf8(genInfo->cpu);
        m_bootloaderVersion = "0x" + QString::number(genInfo->bootloaderVersion, 16).toUpper();
        emit targetInformationChanged();

        emit logMessage(formatLogMessage(QString("ST-LINK SN   : %1").arg(debugParameters.serialNumber)));
        emit logMessage(formatLogMessage(QString("ST-LINK FW   : %1").arg(m_firmware)));
        emit logMessage(formatLogMessage(QString("Board        : %1").arg(m_board)));
        emit logMessage(formatLogMessage(QString("Voltage      : %1V").arg(m_voltage)));
        emit logMessage(formatLogMessage(QString("SWD freq     : %1 KHz").arg(debugParameters.frequency)));
        emit logMessage(formatLogMessage(QString("Connect mode : %1").arg(m_mode)));
        emit logMessage(formatLogMessage(QString("Reset mode   : %1").arg(m_resetMode)));
        emit logMessage(formatLogMessage(QString("Device ID    : %1").arg(m_deviceId)));
        emit logMessage(formatLogMessage(QString("Revision ID  : %1").arg(m_revisionId)));
        emit logMessage(formatLogMessage(QString("Size  : %1").arg(genInfo->flashSize)));
    }

    fetchMemoryData(0x08000000, 0x400, "32-bit");
}

void CubeProgrammerInterface::disconnectFromDevice()
{
    emit logMessage(formatLogMessage("Disconnected from device."));
    emit connectionStatusChanged(false);
    disconnect();
    m_board = "-";
    m_device = "-";
    m_type = "-";
    m_deviceId = "-";
    m_revisionId = "-";
    m_flashSize = "-";
    m_cpu = "-";
    m_bootloaderVersion = "-";
    m_firmware= "-";
    m_voltage= "-";
    m_memoryData.clear();
    m_memoryData.append(QVariantMap{{"address", "No data to display"}, {"zero32", ""}, {"four32", ""}, {"eight32", ""}, {"c32", ""}, {"ascii", ""}});
    emit targetInformationChanged();
    emit configChanged();
    emit memoryDataChanged();
}

void CubeProgrammerInterface::fetchMemoryData(int address, int size, const QString &dataWidth)
{
    QByteArray data;
    for (int i = 0; i < size; ++i) {
        data.append(static_cast<char>(i));
    }

    updateMemoryData(address, dataWidth, data);
}

void CubeProgrammerInterface::updateMemoryData(int startAddress, const QString &dataWidth, const QByteArray &data)
{
    m_memoryData.clear();

    unsigned char* dataStruct = reinterpret_cast<unsigned char*>(const_cast<char*>(data.data()));
    int size = data.size();

    int readMemoryFlag = readMemory(startAddress, &dataStruct, size);
    if (readMemoryFlag != 0) {
        disconnect();
    }

    int index=0;
    while (index < size)
    {
        int remaining = size - index;
        MemoryEntry entry32 = format32BitMemoryData(dataStruct, index, remaining, startAddress);
        MemoryEntry entry16 = format16BitMemoryData(dataStruct, index, remaining, startAddress);
        MemoryEntry entry8 = format8BitMemoryData(dataStruct, index, remaining, startAddress);

        QVariantMap entryMap;
        entryMap["address"] = entry32.address;
        // 32-bit
        entryMap["zero32"] = entry32.zero32;
        entryMap["four32"] = entry32.four32;
        entryMap["eight32"] = entry32.eight32;
        entryMap["c32"] = entry32.c32;
        // 16-bit
        entryMap["zero16"] = entry16.zero16;
        entryMap["two16"] = entry16.two16;
        entryMap["four16"] = entry16.four16;
        entryMap["six16"] = entry16.six16;
        entryMap["eight16"] = entry16.eight16;
        entryMap["a16"] = entry16.a16;
        entryMap["c16"] = entry16.c16;
        entryMap["e16"] = entry16.e16;
        // 8-bit
        entryMap["zero8"] = entry8.zero8;
        entryMap["one8"] = entry8.one8;
        entryMap["two8"] = entry8.two8;
        entryMap["three8"] = entry8.three8;
        entryMap["four8"] = entry8.four8;
        entryMap["five8"] = entry8.five8;
        entryMap["six8"] = entry8.six8;
        entryMap["seven8"] = entry8.seven8;
        entryMap["eight8"] = entry8.eight8;
        entryMap["nine8"] = entry8.nine8;
        entryMap["a8"] = entry8.a8;
        entryMap["b8"] = entry8.b8;
        entryMap["c8"] = entry8.c8;
        entryMap["d8"] = entry8.d8;
        entryMap["e8"] = entry8.e8;
        entryMap["f8"] = entry8.f8;
        // ASCII
        entryMap["ascii"] = entry32.ascii;

        m_memoryData.append(entryMap);
        index += 16;
    }
    if (m_memoryData.isEmpty()) {
        m_memoryData.append(QVariantMap{{"address", "No data to display"}, {"zero32", ""}, {"four32", ""}, {"eight32", ""}, {"c32", ""}, {"ascii", ""}});
    }
    emit memoryDataChanged();
}

CubeProgrammerInterface::MemoryEntry CubeProgrammerInterface::format32BitMemoryData(unsigned char *data, int index, int remaining, int startAddress)
{
    MemoryEntry entry;
    unsigned int dataInt = 0;
    QString columns[4] = { "", "", "", "" };
    const QString ZEROES8 = "00000000";
    QString ascii = "";

    if (remaining >= 16)
    {
        for (int i = 0; i < 16; i += 4)
        {
            dataInt = (data[index + i + 3] << 24);
            dataInt |= ((data[index + i + 2] << 16) & 0x00FF0000);
            dataInt |= ((data[index + i + 1] << 8) & 0x0000FF00);
            dataInt |= (data[index + i] & 0x000000FF);

            columns[i / 4] = QString::number(dataInt, 16).toUpper();
            columns[i / 4] = columns[i / 4].length() < 8 ? ZEROES8.mid(columns[i / 4].length()) + columns[i / 4] : columns[i / 4];

            for (int j = 0; j < 4; j++)
            {
                char ch = static_cast<char>(data[index + i + j] & 0xFF);
                ascii += (ch >= 32 && ch <= 126) ? ch : '.';
            }
        }
    }
    else
    {
        int rest = remaining % 4;
        int i = 0;
        int j = 0;

        while (i < (remaining - rest))
        {
            dataInt = (data[index + i + 3] << 24);
            dataInt |= ((data[index + i + 2] << 16) & 0x00FF0000);
            dataInt |= ((data[index + i + 1] << 8) & 0x0000FF00);
            dataInt |= (data[index + i] & 0x000000FF);

            columns[i / 4] = QString::number(dataInt, 16).toUpper();
            columns[i / 4] = columns[i / 4].length() < 8 ? ZEROES8.mid(columns[i / 4].length()) + columns[i / 4] : columns[i / 4];

            for (int k = 0; k < 4; k++)
            {
                char ch = static_cast<char>(data[index + i + k] & 0xFF);
                ascii += (ch >= 32 && ch <= 126) ? ch : '.';
            }

            j++;
            i += 4;
        }

        switch (rest)
        {
        case 3:
            dataInt = ((data[index + i + 2] << 16) & 0x00FF0000);
            dataInt |= ((data[index + i + 1] << 8) & 0x0000FF00);
            dataInt |= (data[index + i] & 0x000000FF);

            columns[j] = QString::number(dataInt, 16).toUpper();
            columns[j] = columns[j].length() < 6 ? ZEROES8.mid(columns[j].length()) + columns[j] : columns[j];

            for (int k = 0; k < 3; k++)
            {
                char ch = static_cast<char>(data[index + i + k] & 0xFF);
                ascii += (ch >= 32 && ch <= 126) ? ch : '.';
            }
            break;
        case 2:
            dataInt = ((data[index + i + 1] << 8) & 0x0000FF00);
            dataInt |= (data[index + i] & 0x000000FF);

            columns[j] = QString::number(dataInt, 16).toUpper();
            columns[j] = columns[j].length() < 4 ? ZEROES8.mid(columns[j].length()) + columns[j] : columns[j];

            for (int k = 0; k < 2; k++)
            {
                char ch = static_cast<char>(data[index + i + k] & 0xFF);
                ascii += (ch >= 32 && ch <= 126) ? ch : '.';
            }
            break;
        case 1:
            dataInt = (data[index + i] & 0x000000FF);

            columns[j] = QString::number(dataInt, 16).toUpper();
            columns[j] = columns[j].length() < 2 ? ZEROES8.mid(columns[j].length()) + columns[j] : columns[j];

            char ch = static_cast<char>(data[index + i] & 0xFF);
            ascii += (ch >= 32 && ch <= 126) ? ch : '.';
            break;
        }
    }

    entry.address = QString("0x%1").arg(QString::number(startAddress + index, 16).toUpper().rightJustified(8, '0'));
    entry.zero32 = columns[0];
    entry.four32 = columns[1];
    entry.eight32 = columns[2];
    entry.c32 = columns[3];
    entry.ascii = ascii;

    return entry;
}

CubeProgrammerInterface::MemoryEntry CubeProgrammerInterface::format16BitMemoryData(unsigned char *data, int index, int remaining, int startAddress)
{
    MemoryEntry entry;
    int dataShort = 0;
    QString columns[8] = { "", "", "", "", "", "", "", "" };
    const QString ZEROES4 = "0000";
    QString ascii = "";

    if (remaining >= 16)
    {
        for (int i = 0; i < 16; i += 2)
        {
            dataShort = (data[index + i + 1] << 8) & 0xFF00;
            dataShort |= (data[index + i] & 0x00FF);

            columns[i / 2] = QString::number(dataShort & 0xFFFF, 16).toUpper();
            columns[i / 2] = columns[i / 2].length() < 4 ? ZEROES4.mid(columns[i / 2].length()) + columns[i / 2] : columns[i / 2];

            for (int j = 0; j < 2; j++)
            {
                char ch = static_cast<char>(data[index + i + j] & 0xFF);
                ascii += (ch >= 32 && ch <= 126) ? ch : '.';
            }
        }
    }
    else
    {
        int rest = remaining % 2;
        int i = 0;
        int j = 0;

        while (i < (remaining - rest))
        {
            dataShort = (data[index + i + 1] << 8) & 0xFF00;
            dataShort |= (data[index + i] & 0x00FF);

            columns[i / 2] = QString::number(dataShort & 0xFFFF, 16).toUpper();
            columns[i / 2] = columns[i / 2].length() < 4 ? ZEROES4.mid(columns[i / 2].length()) + columns[i / 2] : columns[i / 2];

            for (int k = 0; k < 2; k++)
            {
                char ch = static_cast<char>(data[index + i + k] & 0xFF);
                ascii += (ch >= 32 && ch <= 126) ? ch : '.';
            }

            j++;
            i += 2;
        }

        if (rest == 1)
        {
            dataShort = (data[index + i] & 0x00FF);

            columns[j] = QString::number(dataShort & 0xFFFF, 16).toUpper();
            columns[j] = columns[j].length() < 2 ? ZEROES4.mid(columns[j].length()) + columns[j] : columns[j];

            char ch = static_cast<char>(data[index + i] & 0xFF);
            ascii += (ch >= 32 && ch <= 126) ? ch : '.';
        }
    }

    entry.address = QString("0x%1").arg(QString::number(startAddress + index, 16).toUpper().rightJustified(8, '0'));
    entry.zero16 = columns[0];
    entry.two16 = columns[1];
    entry.four16 = columns[2];
    entry.six16 = columns[3];
    entry.eight16 = columns[4];
    entry.a16 = columns[5];
    entry.c16 = columns[6];
    entry.e16 = columns[7];
    entry.ascii = ascii;

    return entry;
}

CubeProgrammerInterface::MemoryEntry CubeProgrammerInterface::format8BitMemoryData(unsigned char *data, int index, int remaining, int startAddress)
{
    MemoryEntry entry;
    QString columns[16] = { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" };
    const QString ZEROES2 = "00";
    QString ascii = "";

    for (int i = 0; i < ((remaining >= 16) ? 16 : remaining); i++)
    {
        columns[i] = QString::number(data[index + i] & 0xFF, 16).toUpper();
        columns[i] = columns[i].length() < 2 ? ZEROES2.mid(columns[i].length()) + columns[i] : columns[i];

        char ch = static_cast<char>(data[index + i] & 0xFF);
        ascii += (ch >= 32 && ch <= 126) ? ch : '.';
    }

    entry.address = QString("0x%1").arg(QString::number(startAddress + index, 16).toUpper().rightJustified(8, '0'));
    entry.zero8 = columns[0];
    entry.one8 = columns[1];
    entry.two8 = columns[2];
    entry.three8 = columns[3];
    entry.four8 = columns[4];
    entry.five8 = columns[5];
    entry.six8 = columns[6];
    entry.seven8 = columns[7];
    entry.eight8 = columns[8];
    entry.nine8 = columns[9];
    entry.a8 = columns[10];
    entry.b8 = columns[11];
    entry.c8 = columns[12];
    entry.d8 = columns[13];
    entry.e8 = columns[14];
    entry.f8 = columns[15];
    entry.ascii = ascii;

    return entry;
}
// Erasing & Programming
void CubeProgrammerInterface::programDevice(const QString &filePath, QString startAddress, bool skipErase, bool verify, bool fullChecksum, bool runAfter) {
    QFileInfo fileInfo(filePath);
    if (!fileInfo.exists()) {
        emit logMessage(formatLogMessage("Error: File does not exist: " + filePath));
        return;
    }
    if (!fileInfo.isReadable()) {
        emit logMessage(formatLogMessage("Error: File is not readable: " + filePath));
        return;
    }

    std::wstring filePathW = filePath.toStdWString();
    const wchar_t* filePathWC = filePathW.c_str();

    if (startAddress.isEmpty()) {
        startAddress = "0x08000000";
    }

    bool ok;
    unsigned int address = startAddress.toUInt(&ok, 16);
    if (!ok) {
        emit logMessage(formatLogMessage("Invalid start address: " + startAddress));
        return;
    }

    unsigned int isSkipErase = skipErase ? 1 : 0;
    unsigned int isVerify = verify ? 1 : 0;

    qDebug() << "Starting download process...";
    qDebug() << "File path:" << QString::fromWCharArray(filePathWC);
    qDebug() << "Start address:" << QString::number(address, 16);
    qDebug() << "Skip Erase:" << isSkipErase;
    qDebug() << "Verify:" << isVerify;

    int downloadFileFlag = downloadFile(filePathWC, address, isSkipErase, isVerify, L"");
    if (downloadFileFlag != 0) {
        emit logMessage(formatLogMessage(QString("Download failed with error code: %1").arg(downloadFileFlag)));
    } else {
        emit logMessage(formatLogMessage("Programming completed successfully."));
    }

    if (fullChecksum) {
    }

    if (runAfter) {
        int executeFlag = execute(address);
        if (executeFlag != 0) {
            emit logMessage(formatLogMessage("Running the application failed."));
        } else {
            emit logMessage(formatLogMessage("Application is running."));
        }
    }
}
//option bytes
void CubeProgrammerInterface::fetchOptionBytes() {
    peripheral_C* ob = initOptionBytesInterface();
    if (ob == nullptr) {
        emit logMessage("Failed to initialize option bytes interface.");
        return;
    }

    QList<OptionByteItem> optionByteItems;

    QStringList categoriesList;
    QStringList DupCategoriesList;
    for (unsigned int i = 0; i < ob->banksNbr; ++i) {
        for (unsigned int j = 0; j < ob->banks[i]->categoriesNbr; ++j) {
            QString categoryName = ob->banks[i]->categories[j]->name;

            for (unsigned int k = 0; k < ob->banks[i]->categories[j]->bitsNbr; ++k) {
                OptionByteItem item;

                item.label = categoryName;
                item.name = ob->banks[i]->categories[j]->bits[k]->name;
                item.value = QString::number(ob->banks[i]->categories[j]->bits[k]->bitValue, 16).toUpper();
                item.description = ob->banks[i]->categories[j]->bits[k]->description;

                int bitWidth = ob->banks[i]->categories[j]->bits[k]->bitWidth;

                QStringList valueDescriptions;
                for (unsigned int l = 0; l < ob->banks[i]->categories[j]->bits[k]->valuesNbr; ++l) {
                    bitValue_C* currentValue = ob->banks[i]->categories[j]->bits[k]->values[l];
                    QString val = QString::number(currentValue->value, 16).toUpper();
                    item.values.append(val);

                    if (bitWidth == 1) {
                        QString displayValue = (currentValue->value == 0) ? "Unchecked" : "Checked";
                        valueDescriptions.append(displayValue + ": " + QString::fromUtf8(currentValue->description));
                    } else {
                        valueDescriptions.append(val + ": " + QString::fromUtf8(currentValue->description));
                    }
                }

                if (bitWidth == 1) {
                    item.display = "CHECKBOX";
                } else if (!item.values.isEmpty()) {
                    item.display = "COMBOBOX";
                } else if (ob->banks[i]->categories[j]->bits[k]->equation.multiplier >= 1 &&
                           ob->banks[i]->categories[j]->bits[k]->equation.offset >= 0) {
                    item.display = "TEXTFIELDS";
                    item.equationMultiplier = ob->banks[i]->categories[j]->bits[k]->equation.multiplier;
                    item.equationOffset = ob->banks[i]->categories[j]->bits[k]->equation.offset;
                } else {
                    item.display = "TEXTFIELD";
                }

                if (!valueDescriptions.isEmpty()) {
                    item.description += "\n" + valueDescriptions.join("\n");
                }

                if (!categoriesList.contains(item.label)) {
                    categoriesList.append(item.label);
                    optionByteItems.append(item);
                } else {
                    DupCategoriesList.append(item.label);
                    OptionByteItem DupItems;

                    DupItems.label = item.label;
                    DupItems.name = item.name;
                    DupItems.value = item.value;
                    DupItems.description = item.description;
                    DupItems.display = item.display;
                    DupItems.values = item.values;

                    optionByteItems.append(DupItems);
                }
            }
        }
    }

    processAndSendOptionBytes(optionByteItems);
}

void CubeProgrammerInterface::processAndSendOptionBytes(const QList<OptionByteItem>& optionByteItems) {
    QMap<QString, QList<OptionByteItem>> groupedItems;

    for (const OptionByteItem& item : optionByteItems) {
        groupedItems[item.label].append(item);
    }

    m_optionBytesModel->setGroupedOptionBytes(groupedItems);
    emit optionBytesModelChanged();
}


